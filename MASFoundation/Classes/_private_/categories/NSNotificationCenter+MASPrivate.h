//
//  NSNotificationCenter+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

#import "MASConstantsPrivate.h"


@interface NSNotificationCenter (MASPrivate)



///--------------------------------------
/// @name Create general notifications
///--------------------------------------

# pragma mark - Create specific notifications

/**
 *
 */
+ (void)postNotificationWithName:(NSString *)name;


/**
 *
 */
+ (void)postNotificationWithName:(NSString *)name object:(id)sender;


/**
 *
 */
+ (void)postNotificationWithName:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo;

@end
