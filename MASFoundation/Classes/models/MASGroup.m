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

//SCIM Group Object Keys
#define kSCIM_Group_ObjectIdKey         @"id"
#define kSCIM_Group_Name                @"displayName"
#define kSCIM_Group_Owner               @"owner"
#define kSCIM_Group_Owner_value         @"value"
#define kSCIM_Group_Members             @"members"

@implementation MASGroup

- (instancetype)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    [self setValue:[info valueForKey:kSCIM_Group_ObjectIdKey] forKey:@"objectId"];
    [self setValue:[info valueForKey:kSCIM_Group_Name] forKey:@"groupName"];
    [self setValue:[[info valueForKey:kSCIM_Group_Owner] valueForKey:kSCIM_Group_Owner_value] forKey:@"owner"];
    [self setValue:[info valueForKey:kSCIM_Group_Members] forKey:@"members"];
    [self setValue:[[NSMutableDictionary alloc] initWithDictionary:info] forKey:@"_attributes"];
    
    return self;

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
    [group setValue:self.groupName forKey:@"groupName"];
    [group setValue:self.owner forKey:@"owner"];
    [group setValue:self.members forKey:@"members"];
    
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
