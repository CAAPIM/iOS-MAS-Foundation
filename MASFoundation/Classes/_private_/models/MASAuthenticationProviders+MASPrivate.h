//
//  MASAuthenticationProviders+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthenticationProviders.h"


@interface MASAuthenticationProviders (MASPrivate)
    <NSCoding>



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

//@property (nonatomic, copy, readwrite) NSArray *providers;
//
//
//@property (nonatomic, copy, readwrite) NSString *idp;


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
 * Retrieves the instance of MASAuthenticationProviders from local storage, if they exist.
 *
 * @return Returns the newly initialized MASAuthenticationProviders list or nil if none were stored.
 */
+ (MASAuthenticationProviders *)instanceFromStorage;


/**
 * Remove all traces of the current application.
 */
- (void)reset;

@end
