//
//  MASGroup.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASGroup.h"
#import "MASGroup+MASPrivate.h"

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
    
    group.groupName     = self.groupName;
    group.owner         = self.owner;
    group.members       = self.members;
    
    return group;
    
}

#pragma mark - Debug methods

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@)\n\n"
            "        objectId: %@\n        group name: %@\n        owner: %@\n        members: %@\n",
            [self class], [self objectId], [self groupName], [self owner], [self members]];
}


@end
