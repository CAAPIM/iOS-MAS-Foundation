//
//  MASFile.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASFile.h"

#import "MASFileService.h"


@interface MASFile ()

- (id)init NS_UNAVAILABLE;

@end


@implementation MASFile


# pragma mark - Creating a new file

+ (MASFile *)fileWithName:(NSString *)name contents:(NSData *)contents
{
    return [[MASFileService sharedService] fileWithName:name contents:contents directoryType:MASFileDirectoryTypeApplicationSupport];
}


+ (MASFile *_Nullable)fileWithName:(NSString *_Nonnull)name contents:(NSData *_Nonnull)contents directoryType:(MASFileDirectoryType)directoryType
{
    return [[MASFileService sharedService] fileWithName:name contents:contents directoryType:directoryType];
}


- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) file name: %@\n\n        content data length: %ld\n        path: %@",
        [self class], [self name], (unsigned long)[self contents].length, [self filePath]];
}


# pragma mark - Finding a file

+ (MASFile *)findFileWithName:(NSString *)name
{
    return [[MASFileService sharedService] findFileWithName:name directoryType:MASFileDirectoryTypeApplicationSupport];
}


+ (MASFile *)findFileWithName:(NSString *)name directoryType:(MASFileDirectoryType)directoryType
{
    return [[MASFileService sharedService] findFileWithName:name directoryType:directoryType];
}


# pragma mark - Save/Delete file

- (BOOL)save
{
    NSError *error;
    
    // Write to file
    //
    // If it doesn't exist already it creates it, if it does exist it will overwrite it
    //
    [[MASFileService sharedService] writeFileAtDirectoryType:self.directoryType fileName:self.name content:self.contents dataWritingOption:NSDataWritingFileProtectionComplete error:&error];
    
    if(error)
    {
        DLog(@"Error creating item at file path: %@ with message: %@", self.filePath, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


- (BOOL)saveWithDataWritingOption:(NSDataWritingOptions)option
{
    NSError *error;
    
    // Write to file
    //
    // If it doesn't exist already it creates it, if it does exist it will overwrite it
    //
    [[MASFileService sharedService] writeFileAtDirectoryType:self.directoryType fileName:self.name content:self.contents dataWritingOption:option error:&error];
    
    if(error)
    {
        DLog(@"Error creating item at file path: %@ with message: %@", self.filePath, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


- (BOOL)remove
{
    //
    // Remove data at file path
    //
    return [[MASFileService sharedService] removeFileAtDirectoryType:self.directoryType fileName:self.name];
}


+ (BOOL)removeItemAtFilePath:(NSString *)filePath
{
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


# pragma mark - Temporary file

+ (NSString *)storeTemporaryItem:(NSData *)data
{
    NSString *randomName = [NSString randomStringWithLength:20];
    
    //
    // Generate the full file path in the Temporary Directory
    //
    NSString *filePath = [[MASFileService sharedService] getFilePathForFileName:randomName fileDirectoryType:MASFileDirectoryTypeTemporary];
        
    BOOL wasSuccessful = [[MASFileService sharedService] writeFileAtDirectoryType:MASFileDirectoryTypeTemporary fileName:randomName content:data dataWritingOption:NSDataWritingFileProtectionNone error:nil];
    
    return wasSuccessful ? filePath : nil;
}

@end
