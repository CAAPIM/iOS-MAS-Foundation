//
//  MASAuthenticationProvider+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthenticationProvider.h"


@interface MASAuthenticationProvider (MASPrivate)
    <NSCoding>


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Initializer to perform a default initialization.
 *
 * @return Returns the newly initialized MASAuthenticationProvider.
 */
- (id)initWithInfo:(NSDictionary *)info;


/**
 * Retrieves the instance of MASAuthenticationProvider from local storage, if it exists.
 *
 * @return Returns the newly initialized MASAuthenticationProvider or nil if none was stored.
 */
+ (MASAuthenticationProvider *)instanceFromStorage;


/**
 * Remove all traces of the current application.
 */
- (void)reset;

@end
