//
//  MASUser+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


@interface MASUser (MASPrivate)
    <NSCoding>


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Initializer to perform a default initialization.
 *
 * @return Returns the newly initialized MASUser.
 */
- (id)initWithInfo:(NSDictionary *)info;


/**
 * Retrieves the instance of MASUser from local storage, it it exists.
 *
 * @return Returns the newly initialized MASUser or nil if none was stored.
 */
+ (MASUser *)instanceFromStorage;


/**
 * Save the current MASUser instance with newly provided information.
 *
 * @param info An NSDictionary containing newly provided information.
 */
- (void)saveWithUpdatedInfo:(NSDictionary *)info;


/**
 * Remove all traces of the current user.
 */
- (void)reset;


/**
 * Set the logoff state of the user and store the change.
 *
 * @param wasLoggedOff The BOOL value to set the wasLoggedOff state too.
 */
- (void)setWasLoggedOffAndSave:(BOOL)wasLoggedOff;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Retrieves the authorization header formatted with the given userName and password.
 *
 * This is formatted as: 'Basic <userName:password>' with the <...> base64 encoded.
 *
 * @return Returns the value as partially Base64 encoded NSString.
 */
+ (NSString *)authorizationBasicHeaderValueWithUsername:(NSString *)userName
                                               password:(NSString *)password;

/**
 * Retrieves the authorization Bearer header formatted with the current access token, if any.
 *
 * This is formatted as: 'Bearer <accessToken>' with the <...> base64 encoded.
 *
 * @return Returns the value as partially Base64 encoded NSString.
 */
+ (NSString *)authorizationBearerWithAccessToken;

@end
