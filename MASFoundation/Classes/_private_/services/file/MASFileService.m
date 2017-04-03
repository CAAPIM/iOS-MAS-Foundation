//
//  MASFileService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASFileService.h"

#import "MASSecurityService.h"

@interface MASFileService ()

@property (nonatomic, strong) NSDictionary *filePathDirectories;

@end


@implementation MASFileService


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[MASFileService alloc] initProtected];
    });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (NSString *)serviceUUID
{
    return MASFileServiceUUID;
}


# pragma mark - Public

- (NSString *)debugDescription
{
    NSString *header = [NSString stringWithFormat:@"(%@)", [self class]];
    NSMutableString *mutableCopy = [[NSMutableString alloc] initWithString:header];
    
    BOOL filesFound = NO;
    
    //
    // ServerCertificate
    //
    MASFile *file = [[MASSecurityService sharedService] getClientCertificate]; //[self findFileWithName:MASCertificate];
    if(file)
    {
        filesFound = YES;
        [mutableCopy appendString:@"\n\n    "];
        [mutableCopy appendString:[file debugDescription]];
    }
    
    //
    // SignedCertificate
    //
    file = [[MASSecurityService sharedService] getSignedCertificate]; //[self findFileWithName:MASSignedCertificate];
    if(file)
    {
        filesFound = YES;
        [mutableCopy appendString:@"\n\n    "];
        [mutableCopy appendString:[file debugDescription]];
    }
    
    //
    // Private Key
    //
    file = [[MASSecurityService sharedService] getPrivateKey]; //[self findFileWithName:MASKey];
    if(file)
    {
        filesFound = YES;
        [mutableCopy appendString:@"\n\n    "];
        [mutableCopy appendString:[file debugDescription]];
    }
    
    //
    // If no files were found
    //
    if(!filesFound)
    {
        [mutableCopy appendString:@"\n\n    No files found"];
    }
    
    return mutableCopy;
}


# pragma mark - Creating a New File

- (MASFile *)fileWithName:(NSString *)name contents:(NSData *)contents directoryType:(MASFileDirectoryType)directoryType
{
    return [[MASFile alloc] initWithName:name contents:contents directoryType:directoryType];
}


# pragma mark - Finding a File

- (MASFile *)findFileWithName:(NSString *)name directoryType:(MASFileDirectoryType)directoryType
{

    //
    //  Generate the full file path
    //
    NSString *filePath = [[MASFileService sharedService] getFilePathForFileName:name fileDirectoryType:directoryType];
    
    //
    //  Check if a file exists at the given file name and directory type, return nil if not.
    //
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return nil;
    }
    
    //
    //  Read file data from the path, and check if the data is readable
    //
    NSError *error;
    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMapped error:&error];
    
    if (error)
    {
        return nil;
    }
    
    //
    //  Reserialize from data
    //
    MASFile *file = [[MASFile alloc] initWithName:name contents:fileData directoryType:directoryType];
    
    return file;
}


- (NSString *)getFilePathForFileName:(NSString *)fileName fileDirectoryType:(MASFileDirectoryType)fileDirectoryType
{
    if (!fileName || [fileName length] == 0)
    {
        return nil;
    }
    
    NSString *baseDirectoryPath = nil;
    
    NSDictionary *directories = [MASFileService getFilePathDirectories];
    
    if ([[directories allKeys] containsObject:[MASFileService directoryTypeToString:fileDirectoryType]])
    {
        baseDirectoryPath = [directories objectForKey:[MASFileService directoryTypeToString:fileDirectoryType]];
    }
    
    return [baseDirectoryPath stringByAppendingPathComponent:fileName];
}


# pragma mark - Wrtie/remove a file

- (BOOL)removeFileAtDirectoryType:(MASFileDirectoryType)directoryType fileName:(NSString *)fileName
{
    //
    //  Construct full path including file name
    //
    NSString *fullPath = [self getFilePathForFileName:fileName fileDirectoryType:directoryType];
    
    return [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
}


- (BOOL)writeFileAtDirectoryType:(MASFileDirectoryType)directoryType fileName:(NSString *)fileName content:(NSObject *)content dataWritingOption:(NSDataWritingOptions)dataWritingOption error:(NSError **)error
{
    
    BOOL wasSuccessful = NO;
    
    //
    //  Construct full path including file name
    //
    NSString *fullPath = [self getFilePathForFileName:fileName fileDirectoryType:directoryType];
    NSString *directoryPath = [fullPath stringByReplacingOccurrencesOfString:[fullPath lastPathComponent] withString:@""];
    
    //
    //  If directory path does not exist, create one
    //
    BOOL isDir;
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir];
    
    if (!doesExist && !isDir)
    {
        BOOL didCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:error];
        
        if (!didCreateDir)
        {
            return NO;
        }
    }
    
    
    if([content isKindOfClass:[NSMutableArray class]])
    {
        [((NSMutableArray *)content) writeToFile:fullPath atomically:YES];
    }
    else if([content isKindOfClass:[NSArray class]])
    {
        [((NSArray *)content) writeToFile:fullPath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableData class]])
    {
        [((NSMutableData *)content) writeToFile:fullPath options:dataWritingOption error:error];
    }
    else if([content isKindOfClass:[NSData class]])
    {
        [((NSData *)content) writeToFile:fullPath options:dataWritingOption error:error];
    }
    else if([content isKindOfClass:[NSMutableDictionary class]])
    {
        [((NSMutableDictionary *)content) writeToFile:fullPath atomically:YES];
    }
    else if([content isKindOfClass:[NSDictionary class]])
    {
        [((NSDictionary *)content) writeToFile:fullPath atomically:YES];
    }
    else if([content isKindOfClass:[NSJSONSerialization class]])
    {
        [((NSDictionary *)content) writeToFile:fullPath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fullPath options:dataWritingOption error:error];
    }
    else if([content isKindOfClass:[NSString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fullPath options:dataWritingOption error:error];
    }
    else if([content isKindOfClass:[UIImage class]])
    {
        [UIImagePNGRepresentation((UIImage *)content) writeToFile:fullPath options:dataWritingOption error:error];
    }
    else if([content conformsToProtocol:@protocol(NSCoding)])
    {
        [NSKeyedArchiver archiveRootObject:content toFile:fullPath];
    }
    else {
        
        return NO;
    }
    
    return wasSuccessful;
}


# pragma mark - Private

+ (NSString *)directoryTypeToString:(MASFileDirectoryType)directoryType
{
    NSString *directoryTypeAsString;
    
    switch (directoryType) {
        case MASFileDirectoryTypeApplicationSupport:
            directoryTypeAsString = @"applicationSupport";
            break;
            
        case MASFileDirectoryTypeCachesDirectory:
            directoryTypeAsString = @"caches";
            break;
            
        case MASFileDirectoryTypeDocuments:
            directoryTypeAsString = @"documents";
            break;
            
        case MASFileDirectoryTypeLibrary:
            directoryTypeAsString = @"library";
            break;
            
        case MASFileDirectoryTypeTemporary:
            directoryTypeAsString = @"temporary";
            break;
            
        default:
            directoryTypeAsString = @"applicationSupport";
            break;
    }
    
    return directoryTypeAsString;
}


+ (NSMutableDictionary *)getFilePathDirectories
{
    static NSMutableDictionary *directories;
    static dispatch_once_t once;
    
    //
    //  Extract file path for NSSearchPathDirectory only once
    //
    dispatch_once(&once, ^{
        
        if (!directories)
        {
            directories = [NSMutableDictionary dictionary];
        }
        
        NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        if ([libPaths lastObject])
        {
            [directories setObject:[libPaths lastObject] forKey:[self directoryTypeToString:MASFileDirectoryTypeLibrary]];
        }
        
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([docPaths lastObject])
        {
            [directories setObject:[docPaths lastObject] forKey:[self directoryTypeToString:MASFileDirectoryTypeDocuments]];
        }
        
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([cachePaths lastObject])
        {
            [directories setObject:[cachePaths lastObject] forKey:[self directoryTypeToString:MASFileDirectoryTypeCachesDirectory]];
        }
        
        NSArray *appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        if ([appSupportPaths lastObject])
        {
            [directories setObject:[appSupportPaths lastObject] forKey:[self directoryTypeToString:MASFileDirectoryTypeApplicationSupport]];
        }
        
        [directories setObject:NSTemporaryDirectory() forKey:[self directoryTypeToString:MASFileDirectoryTypeTemporary]];
        
    });
    
    return directories;
}


@end
