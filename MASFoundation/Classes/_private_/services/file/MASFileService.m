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

#import "MASIFileManager.h"
#import "MASSecurityService.h"


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


- (void)serviceDidReset
{
    //DLog(@"called");
    
    //
    // Retrieve application directory
    //
    NSString *path = [MASIFileManager pathForApplicationSupportDirectoryWithPath:nil];
    if(path)
    {
        NSError *error;
        [MASIFileManager removeItemsInDirectoryAtPath:path error:&error];

        if(error)
        {
            //DLog(@"\n\nError on removing file items: %@\n\n", [error localizedDescription]);
        }
    }
    
    [super serviceDidReset];
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

- (MASFile *)fileWithName:(NSString *)name contents:(NSData *)contents
{
    return [[MASFile alloc] initWithName:name contents:contents];
}


# pragma mark - Finding a File

- (MASFile *)findFileWithName:(NSString *)name
{
    //DLog(@"\ncalled with file name: %@\n", name);
    
    //
    // Generate the full file path
    //
    NSString *filePath = [MASIFileManager pathForApplicationSupportDirectoryWithPath:name];
    
    //
    // Check if a file exists at the given path, return nil if not.
    //
    if(![MASIFileManager existsItemAtPath:filePath])
    {
        return nil;
    }
    
    //
    // Read the data at the file path
    //
    NSError *error;
    NSData *data = [MASIFileManager readFileAtPathAsData:filePath error:&error];
    
    if(error)
    {
        //DLog(@"Error reading unsecured item at file path: %@ with message: %@",
          //  filePath, [error localizedDescription]);
        return nil;
    }

    //
    // Reserialize from data, could throw an exception if this is a secured MASFile
    //
    MASFile *file = [[MASFile alloc] initWithName:name contents:data];
    
    return file;
}


- (MASFile *)findFileWithName:(NSString *)name password:(NSString *)password
{
    //DLog(@"\ncalled with file name: %@ and password: %@\n", name, password);
    
    //
    // Generate the full file path
    //
    NSString *filePath = [MASIFileManager pathForApplicationSupportDirectoryWithPath:name];
    
    //
    // Check if a file exists at the given path, return nil if not.
    //
    if(![MASIFileManager existsItemAtPath:filePath])
    {
        return nil;
    }
    
    //
    // Read the data at the file path
    //
    NSError *error;
    NSData *data = [MASIFileManager readFileAtPathAsData:filePath error:&error];
    
    if(error)
    {
//        DLog(@"Error decrypting secured item at file path: %@ with message: %@",
//            filePath, [error localizedDescription]);
        return nil;
    }
    
    //
    // Reserialize from data, could throw an exception if
    //
    MASFile *file = [[MASFile alloc] initWithName:name contents:data];
    
    return file;
}

@end
