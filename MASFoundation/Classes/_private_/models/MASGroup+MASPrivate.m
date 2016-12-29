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

static NSString *const kMASGroupAttributesPropertyKey = @"attributes"; // json

@implementation MASGroup (MASPrivate)

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    [self setValue:[attributes valueForKey:kSCIM_Group_ObjectIdKey] forKey:@"objectId"];
    [self setValue:[attributes valueForKey:kSCIM_Group_Name] forKey:@"groupName"];
    [self setValue:[[attributes valueForKey:kSCIM_Group_Owner] valueForKey:kSCIM_Group_Owner_value] forKey:@"owner"];
    [self setValue:[attributes valueForKey:kSCIM_Group_Members] forKey:@"members"];
    
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    return self;
}


# pragma mark - Properties

- (NSDictionary *)_attributes
{
    return objc_getAssociatedObject(self, &kMASGroupAttributesPropertyKey);
}

- (void)set_attributes:(NSDictionary *)attributes
{
    objc_setAssociatedObject(self, &kMASGroupAttributesPropertyKey, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
