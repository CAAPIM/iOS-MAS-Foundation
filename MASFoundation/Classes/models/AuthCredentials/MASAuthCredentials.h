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
@property (nonatomic, assign, readonly, nonnull) NSString *credentialsType;



/**
 Internal username value for device registration's generating CSR.
 csrUsername value should be assigned to username registering the device against MAG during custom MASAuthCredentials object initialization.
 */
@property (nonatomic, assign, readonly, nonnull) NSString *csrUsername;



/**
 MAG system endpoint for device registration of current auth credentials type
 */
@property (nonatomic, assign, readonly, nonnull) NSString *registerEndpoint;



/**
 OTK system endpoint for user/client authentication of current auth credentials type
 */
@property (nonatomic, assign, readonly, nonnull) NSString *tokenEndpoint;



/**
 *  boolean indicator whether this particular auth credentials can be used for device registration.
 */
@property (nonatomic, assign, readonly) BOOL canRegisterDevice;



/**
 *  boolean indicator whether this particular auth credentials can be re-used.
 */
@property (nonatomic, assign, readonly) BOOL isReusable;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle


/**
 Initializes MASAuthCredentials object.
 
 This initialization method is intended to be used in any extended classes of MASAuthCredentials, and not to be used directly in application's code.
 Arguments on this initialization method are read-only properties along with registerEndpoint and tokenEndpoint.
 
 Make sure to initialize custom MASAuthCredentials object within custom MASAuthCredentials' init method.

 @param credentialsType NSString value of unique identifier for auth credentials type such as OAuth2 grant type
 @param canRegisterDevice BOOL value indicating whether auth credentials type can be used for device registration against MAG
 @param isReusable BOOL value indicating whether auth credentials type can be re-used multiple times
 @return MASAuthCredentials object
 */
- (instancetype _Nullable)initWithCredentialsType:(NSString * _Nonnull)credentialsType csrUsername:(NSString *)csrUsername canRegisterDevice:(BOOL)canRegisterDevice isReusable:(BOOL)isReusable;


/**
 Initializes MASAuthCredentials object.
 
 This initialization method is intended to be used in any extended classes of MASAuthCredentials, and not to be used directly in application's code.
 Arguments on this initialization method are read-only properties.
 
 Make sure to initialize custom MASAuthCredentials object within custom MASAuthCredentials' init method.

 @param credentialsType NSString value of unique identifier for auth credentials type such as OAuth2 grant type
 @param canRegisterDevice BOOL value indicating whether auth credentials type can be used for device registration against MAG
 @param isReusable BOOL value indicating whether auth credentials type can be re-used multiple times
 @param registerEndpoint NSString value of MAG device registration endpoint
 @param tokenEndpoint NSString value of OTK token endpoint
 @return MASAuthCredentials object
 */
- (instancetype _Nullable)initWithCredentialsType:(NSString * _Nonnull)credentialsType csrUsername:(NSString *)csrUsername canRegisterDevice:(BOOL)canRegisterDevice isReusable:(BOOL)isReusable registerEndpoint:(NSString * _Nonnull)registerEndpoint tokenEndpoint:(NSString * _Nonnull)tokenEndpoint;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 *  A method to clear stored credentials in memory.
 */
- (void)clearCredentials;


/**
 Prepare all required header values for the registration/authentication request
 
 @return NSDictionary of all required headers
 */
- (NSDictionary * _Nullable)getHeaders;


/**
 Prepare all required parameter values for the registration/authentication request
 
 @return NSDictionary of all required parameters
 */
- (NSDictionary * _Nullable)getParameters;

@end
