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

/**
 MASAuthCredentials class is designed to allow customization on device registration and/or user authentication on MASFoundation.
 Any customization, such as sending additional parameters, or processing customized logic on device registration and/or user authentication, can be handled by inheriting MASAuthCredentials class in application layer.
 
 MASAuthCredentials class and any extended classes will be consumed by Mobile SDK in two scenarios:
    1. Device registration request
        * Default API path: /connect/device/register
        * Request type: MASRequestResponseTypeTextPlain
    2. Session authentication request
        * Default API path: /auth/oauth/v2/token
        * Request type: MASRequestResponseTypeWwwFormUrlEncoded
 
 **Important Note**
    * For device registration, the payload (parameter) of the request contains CSR (certificate signing request) based on csrUsername that was passed in. This payload should not be modified or altered, as it is generated in a specific way by Mobile SDK.
    * Value of csrUsername should be username, in case of password grant flow, otherwise, it is recommended to be socialLogin.

 An application that extends this MASAuthCredentials class should follow below steps:
 
    1. Create a customization class by inheriting MASAuthCredentials class
    2. Define any custom property in the class, and determines where it will be sent (either header, or parameter of device registration and/or token endpoint)
    3. Override getHeaders, and getParameters methods and get default headers and parameters from super class
    4. Add or modify any necessary values in these methods

 Any specification or requirement on above APIs, please refer to Swagger documentation on Server side, or consult with server admin.
 Any customization based on existing flow can be referenced in MASAuthCredentialsPassword class in MASFoundation.
 */
@interface MASAuthCredentials : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Authentication credential type.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *credentialsType;



/**
 Internal username value for device registration's generating CSR.
 csrUsername value should be assigned to username registering the device against MAG during custom MASAuthCredentials object initialization.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *csrUsername;



/**
 MAG system endpoint for device registration of current auth credentials type
 */
@property (nonatomic, strong, readonly, nonnull) NSString *registerEndpoint;



/**
 OTK system endpoint for user/client authentication of current auth credentials type
 */
@property (nonatomic, strong, readonly, nonnull) NSString *tokenEndpoint;



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
- (instancetype _Nullable)initWithCredentialsType:(NSString * _Nonnull)credentialsType csrUsername:(NSString * _Nonnull)csrUsername canRegisterDevice:(BOOL)canRegisterDevice isReusable:(BOOL)isReusable;


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
- (instancetype _Nullable)initWithCredentialsType:(NSString * _Nonnull)credentialsType csrUsername:(NSString * _Nonnull)csrUsername canRegisterDevice:(BOOL)canRegisterDevice isReusable:(BOOL)isReusable registerEndpoint:(NSString * _Nonnull)registerEndpoint tokenEndpoint:(NSString * _Nonnull)tokenEndpoint;



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
 
 Inherited MASAuthCredentials class should override and call parent's getHeaders method in order to customize, or modify header values for following requests
    * device registration (default: "/connect/device/register")
    * session authentication (default: "/auth/oauth/v2/token")
 
 By default, the minimum required header values for each request are:
 
 Device Registration:
    * client-authorization
    * device-id
    * device-name
    * create-session
    * cert-format
 
 Session Authentication:
    * authorization
 
 The above header values are automatically populated by the Mobile SDK based on the settings of the application. You can override these values in the inherited class but you can cause unexpected behaviour in registration and/or authentication if you fail to coordinate with the server side.  You can also add customize header values in registration and/or authentication as needed.
 
 @return NSDictionary of all required headers
 */
- (NSDictionary * _Nullable)getHeaders;


/**
 Prepare all required parameter values for the registration/authentication request
 
 Inherited MASAuthCredentials class should override and call parent's getParameters method in order to customize, or modify parameter values for following requests
 * device registration (default: "/connect/device/register")
 * session authentication (default: "/auth/oauth/v2/token")
 
 By default, the minimum required header values for each request are:
 
 Device Registration:
    * certificateSigningRequest
 
 Session Authentication:
    * scope
    * grant_type
 
 The above header values are automatically populated by the Mobile SDK based on the settings of the application. You can override these values in the inherited class but you can cause unexpected behaviour in registration and/or authentication if you fail to coordinate with the server side.  You can also add customize header values in registration and/or authentication as needed.
 
 @return NSDictionary of all required parameters
 */
- (NSDictionary * _Nullable)getParameters;

@end
