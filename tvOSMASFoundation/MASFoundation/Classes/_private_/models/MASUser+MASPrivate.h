//
//  MASUser+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#if TARGET_OS_TV
#import <tvOS_MASFoundation/tvOS_MASFoundation.h>
#else
#import <MASFoundation/MASFoundation.h>
#endif


@interface MASUser (MASPrivate)
    <NSCoding>


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, assign, readonly) BOOL isCurrentUser;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, assign, readonly) BOOL isSessionLocked;

@property (nonatomic, copy, readwrite) NSString *userName;
@property (nonatomic, copy, readwrite) NSString *familyName;
@property (nonatomic, copy, readwrite) NSString *givenName;
@property (nonatomic, copy, readwrite) NSString *formattedName;
@property (nonatomic, copy, readwrite) NSDictionary *emailAddresses;
@property (nonatomic, copy, readwrite) NSDictionary *phoneNumbers;
@property (nonatomic, copy, readwrite) NSDictionary *addresses;
@property (nonatomic, copy, readwrite) NSDictionary *photos;
@property (nonatomic, copy, readwrite) NSArray *groups;
@property (nonatomic, assign, readwrite) BOOL active;
@property (nonatomic, copy, readonly) NSString *accessToken;
@property (nonatomic, copy, readwrite) NSMutableDictionary *_attributes;


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
