//
//  MASGroup.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASGroup.h"
#import "MASGroup+MASPrivate.h"

# pragma mark - Property Constants

static NSString *const kMASGroupObjectIdPropertyKey = @"id"; // string
static NSString *const kMASGroupGroupNamePropertyKey = @"displayName"; // string
static NSString *const kMASGroupOwnerPropertyKey = @"owner"; // string
static NSString *const kMASGroupMembersPropertyKey = @"members"; // string
static NSString *const kMASGroupAttributesPropertyKey = @"attributes"; // json

@implementation MASGroup

- (instancetype)initWithInfo:(NSDictionary *)info
{
    return [self initWithAttributes:info];
}


# pragma mark - Creating a new group

+ (MASGroup *)group
{
    MASGroup *group = [[self alloc] initPrivate];
    
    return group;
}


- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    
    if(self) {
        
    }
    
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASGroup *group = [super copyWithZone:zone];
    
    [group setValue:self.objectId forKey:@"objectId"];
    group.groupName     = self.groupName;
    group.owner         = self.owner;
    group.members       = self.members;
    
    return group;
    
}

# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder]; //ObjectID is encoded in the super class MASObject
    
    if(self.groupName) [aCoder encodeObject:self.groupName forKey:kMASGroupGroupNamePropertyKey];
    if(self.owner) [aCoder encodeObject:self.owner forKey:kMASGroupOwnerPropertyKey];
    if(self.members) [aCoder encodeObject:self.members forKey:kMASGroupMembersPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) //ObjectID is decoded in the super class MASObject
    {
        [self setValue:[aDecoder decodeObjectForKey:kMASGroupGroupNamePropertyKey] forKey:@"groupName"];
        [self setValue:[aDecoder decodeObjectForKey:kMASGroupOwnerPropertyKey] forKey:@"owner"];
        [self setValue:[aDecoder decodeObjectForKey:kMASGroupMembersPropertyKey] forKey:@"members"];
    }
    
    return self;
}


#pragma mark - Debug methods

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@)\n\n"
            "        objectId: %@\n        group name: %@\n        owner: %@\n        members: %@\n",
            [self class], [self objectId], [self groupName], [self owner], [self members]];
}


@end
