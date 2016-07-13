//
//  NSNotificationCenter+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "NSNotificationCenter+MASPrivate.h"


@implementation NSNotificationCenter (MASPrivate)


# pragma mark - Create specific notifications

+ (void)postNotificationWithName:(NSString *)name
{
    [self postNotificationWithName:name object:nil userInfo:nil];
}


+ (void)postNotificationWithName:(NSString *)name object:(id)sender
{
    [self postNotificationWithName:name object:sender userInfo:nil];
}


+ (void)postNotificationWithName:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo
{
    [[self defaultCenter] postNotificationName:name object:sender userInfo:userInfo];
}

@end
