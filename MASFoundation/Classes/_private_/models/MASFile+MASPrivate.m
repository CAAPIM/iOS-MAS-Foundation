//
//  MASFile+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASFile+MASPrivate.h"

#import <objc/runtime.h>
#import "MASIFileManager.h"
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"


# pragma mark - Property Constants

static NSString *const MASFileNamePropertyKey = @"name"; // string
static NSString *const MASFileContentsPropertyKey = @"contents"; // data
static NSString *const MASFileFilePathPropertyKey = @"filePath"; // string


@implementation MASFile (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithName:(NSString *)name contents:(NSData *)contents
{
    self = [super init];
    if(self)
    {
        [self setValue:name forKey:@"name"];
        [self setValue:[MASIFileManager pathForApplicationSupportDirectoryWithPath:self.name] forKey:@"filePath"];
        [self setValue:contents forKey:@"contents"];
    }
    
    return self;
}


# pragma mark - Saving and Removing Files

- (BOOL)remove
{
    //
    // Remove data at file path
    //
    NSError *error;
    [MASIFileManager removeItemAtPath:self.filePath
                              error:&error];
    
    if(error)
    {
        DLog(@"Error removing item at file path: %@ with message: %@", self.filePath, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


- (BOOL)save
{
    NSError *error;
    
    //
    // Write to file
    //
    // If it doesn't exist already it creates it, if it does exist it will overwrite it
    //
    [MASIFileManager writeFileAtPath:self.filePath
                           content:self.contents
                             error:&error];
    
    if(error)
    {
        DLog(@"Error creating item at file path: %@ with message: %@", self.filePath, [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if(self.name) [aCoder encodeObject:self.name forKey:MASFileNamePropertyKey];
    if(self.contents) [aCoder encodeObject:self.contents forKey:MASFileContentsPropertyKey];
    if(self.filePath) [aCoder encodeObject:self.filePath forKey:MASFileFilePathPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        [self setValue:[aDecoder decodeObjectForKey:MASFileNamePropertyKey] forKey:@"name"];
        [self setValue:[aDecoder decodeObjectForKey:MASFileContentsPropertyKey] forKey:@"contents"];
        [self setValue:[aDecoder decodeObjectForKey:MASFileFilePathPropertyKey] forKey:@"filePath"];
    }
    
    return self;
}

@end
