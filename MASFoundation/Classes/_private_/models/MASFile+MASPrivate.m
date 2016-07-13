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
        self.name = name;
        self.filePath = [MASIFileManager pathForApplicationSupportDirectoryWithPath:self.name];
        self.contents = contents;
    }
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)name
{
    return objc_getAssociatedObject(self, &MASFileNamePropertyKey);
}


- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, &MASFileNamePropertyKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSData *)contents
{
    return objc_getAssociatedObject(self, &MASFileContentsPropertyKey);
}


- (void)setContents:(NSData *)contents
{
    objc_setAssociatedObject(self, &MASFileContentsPropertyKey, contents, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)filePath
{
    return objc_getAssociatedObject(self, &MASFileFilePathPropertyKey);
}


- (void)setFilePath:(NSString *)filePath
{
    objc_setAssociatedObject(self, &MASFileFilePathPropertyKey, filePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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


- (BOOL)saveWithPassword:(NSString *)password
{
    NSError *error;
    
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
    //DLog(@"called with aDecoder: %@", aDecoder);
    
    if(self.name) [aCoder encodeObject:self.name forKey:MASFileNamePropertyKey];
    if(self.contents) [aCoder encodeObject:self.contents forKey:MASFileContentsPropertyKey];
    if(self.filePath) [aCoder encodeObject:self.filePath forKey:MASFileFilePathPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //DLog(@"called with aDecoder: %@", aDecoder);
    
    if(self = [super init])
    {
        self.name = [aDecoder decodeObjectForKey:MASFileNamePropertyKey];
        self.contents = [aDecoder decodeObjectForKey:MASFileContentsPropertyKey];
        self.filePath = [aDecoder decodeObjectForKey:MASFileFilePathPropertyKey];
    }
    
    //DLog(@"called with self: %@", [self debugDescription]);
    
    return self;
}

@end
