//
//  MASGroup+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASGroup+MASPrivate.h"
#import <objc/runtime.h>

//SCIM Group Object Keys
#define kSCIM_Group_ObjectIdKey         @"id"
#define kSCIM_Group_Name                @"displayName"
#define kSCIM_Group_Owner               @"owner"
#define kSCIM_Group_Owner_value         @"value"
#define kSCIM_Group_Members             @"members"

# pragma mark - Property Constants

static NSString *const kMASGroupObjectIdPropertyKey = @"id"; // string
static NSString *const kMASGroupGroupNamePropertyKey = @"displayName"; // string
static NSString *const kMASGroupOwnerPropertyKey = @"owner"; // string
static NSString *const kMASGroupMembersPropertyKey = @"members"; // string
static NSString *const kMASGroupAttributesPropertyKey = @"attributes"; // json

@implementation MASGroup (MASPrivate)

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    self.objectId       = [attributes valueForKey:kSCIM_Group_ObjectIdKey];
    self.groupName      = [attributes valueForKey:kSCIM_Group_Name];
    self.owner          = [[attributes valueForKey:kSCIM_Group_Owner] valueForKey:kSCIM_Group_Owner_value];
    self.members        = [attributes valueForKey:kSCIM_Group_Members];
    
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)objectId
{
    return objc_getAssociatedObject(self, &kMASGroupObjectIdPropertyKey);
}

- (void)setObjectId:(NSString *)objectId
{
    objc_setAssociatedObject(self, &kMASGroupObjectIdPropertyKey, objectId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)groupName
{
    return objc_getAssociatedObject(self, &kMASGroupGroupNamePropertyKey);
}

- (void)setGroupName:(NSString *)groupName
{
    objc_setAssociatedObject(self, &kMASGroupGroupNamePropertyKey, groupName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)owner
{
    return objc_getAssociatedObject(self, &kMASGroupOwnerPropertyKey);
}

- (void)setOwner:(NSString *)owner
{
    objc_setAssociatedObject(self, &kMASGroupOwnerPropertyKey, owner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)members
{
    return objc_getAssociatedObject(self, &kMASGroupMembersPropertyKey);
}

- (void)setMembers:(NSArray *)members
{
    objc_setAssociatedObject(self, &kMASGroupMembersPropertyKey, members, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)_attributes
{
    return objc_getAssociatedObject(self, &kMASGroupAttributesPropertyKey);
}

- (void)set_attributes:(NSDictionary *)attributes
{
    objc_setAssociatedObject(self, &kMASGroupAttributesPropertyKey, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASGroup *group = [super copyWithZone:zone];
    
    group.objectId      = self.objectId;
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
        self.groupName = [aDecoder decodeObjectForKey:kMASGroupGroupNamePropertyKey];
        self.owner = [aDecoder decodeObjectForKey:kMASGroupOwnerPropertyKey];
        self.members = [aDecoder decodeObjectForKey:kMASGroupMembersPropertyKey];
    }
    
    return self;
}

@end
