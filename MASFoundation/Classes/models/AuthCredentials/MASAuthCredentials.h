//
//  MASAuthCredentials.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASObject.h"

@interface MASAuthCredentials : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Authentication credential type.
 */
@property (nonatomic, assign, readonly) NSString *credentialsType;



/**
 *  boolean indicator whether this particular auth credentials can be used for device registration.
 */
@property (nonatomic, assign, readonly) BOOL canRegisterDevice;



/**
 *  boolean indicator whether this particular auth credentials can be re-used.
 */
@property (nonatomic, assign, readonly) BOOL isReuseable;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 *  A method to clear stored credentials in memory.
 */
- (void)clearCredentials;

@end
