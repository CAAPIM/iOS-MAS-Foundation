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
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"
#import "MASFileService.h"

# pragma mark - Property Constants

static NSString *const MASFileNamePropertyKey = @"name"; // string
static NSString *const MASFileContentsPropertyKey = @"contents"; // data
static NSString *const MASFileFilePathPropertyKey = @"filePath"; // string
static NSString *const MASFileDirectoryTypePropertyKey = @"directoryType"; // integer


@implementation MASFile (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithName:(NSString *)name contents:(NSData *)contents directoryType:(MASFileDirectoryType)directoryType
{
    self = [super init];
    if(self)
    {
        [self setValue:name forKey:@"name"];
        [self setValue:[[MASFileService sharedService] getFilePathForFileName:self.name fileDirectoryType:directoryType] forKey:@"filePath"];
        [self setValue:contents forKey:@"contents"];
        [self setValue:[NSNumber numberWithInteger:directoryType] forKey:@"directoryType"];
    }
    
    return self;
}


# pragma mark - Saving and Removing Files



# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if(self.name) [aCoder encodeObject:self.name forKey:MASFileNamePropertyKey];
    if(self.contents) [aCoder encodeObject:self.contents forKey:MASFileContentsPropertyKey];
    if(self.filePath) [aCoder encodeObject:self.filePath forKey:MASFileFilePathPropertyKey];
    if(self.directoryType) [aCoder encodeObject:[NSNumber numberWithInteger:self.directoryType] forKey:MASFileDirectoryTypePropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        [self setValue:[aDecoder decodeObjectForKey:MASFileNamePropertyKey] forKey:@"name"];
        [self setValue:[aDecoder decodeObjectForKey:MASFileContentsPropertyKey] forKey:@"contents"];
        [self setValue:[aDecoder decodeObjectForKey:MASFileFilePathPropertyKey] forKey:@"filePath"];
        [self setValue:[aDecoder decodeObjectForKey:MASFileDirectoryTypePropertyKey] forKey:@"directoryType"];
        
    }
    
    return self;
}

@end
