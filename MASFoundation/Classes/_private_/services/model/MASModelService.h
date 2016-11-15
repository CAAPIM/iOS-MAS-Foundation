//
//  MASModelService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"

#import "MASConstantsPrivate.h"



@interface MASModelService : MASService



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The current application singleton.
 */
@property (nonatomic, strong, readonly) MASApplication *currentApplication;


/**
 * The current authentication providers.
 */
@property (nonatomic, strong, readonly) MASAuthenticationProviders *currentProviders;


/**
 * The current device singleton.
 */
@property (nonatomic, strong, readonly) MASDevice *currentDevice;


/**
 * The current user singleton.
 */
@property (nonatomic, strong, readonly) MASUser *currentUser;


/**
 *  The current device grant flow
 *
 *  @return MASGrantFlow is returned.
 */
+ (MASGrantFlow)grantFlow;


/**
 *  Sets the MASGrantFlow property.  The default is MASGrantFlowClientCredentials.
 *
 *  @param grantFlow The MASGrantFlow.
 */
+ (void)setGrantFlow:(MASGrantFlow)grantFlow;


/**
 *  Set a user login block to handle the case where the type set in 'setDeviceRegistrationType:(MASDeviceRegistrationType)'
 *  is 'MASDeviceRegistrationTypeUserCredentials'.  If it set to 'MASDeviceRegistrationTypeClientCredentials' this
 *  is not called.
 *
 *  @param registration The MASUserLoginWithUserCredentialsBlock to receive the request for user credentials.
 */
+ (void)setUserLoginBlock:(MASUserLoginWithUserCredentialsBlock)login;



///--------------------------------------
/// @name Application
///--------------------------------------

# pragma mark - Application

/** 
 *  Perform the registraton of the application to retrieve new, or updated client credentials.
 *
 *  @param completion The MASCompletionErrorBlock (BOOL completion, NSError *error) completion block.
 */
- (void)registerApplication:(MASCompletionErrorBlock)completion;


/**
 *  Retrieve the applications supported social login authentication providers.
 *
 *  @param completion The MASObjectResponseErrorBlock (id object, NSError *error) completion block.
 */
- (void)retrieveAuthenticationProviders:(MASObjectResponseErrorBlock)completion;


/**
 *  Retrieve the currently registered enterprise apps.
 *
 *  @param completion The MASObjectsResponseErrorBlock (NSArray *objects, NSError *error) completion block.
 */
- (void)retrieveEnterpriseApplications:(MASObjectsResponseErrorBlock)completion;



///--------------------------------------
/// @name Device
///--------------------------------------

# pragma mark - Device

/**
 *  Deregister the current device's record from the application record on the Gateway.  This
 *  means that record will be deleted upon a successful conclusion.
 *  
 *  Note this can only work if the client, device and access credentials locally
 *  stored on the device still exist and are valid.  It will fail if they have been previously
 *  erased, those credentials do not match what is in the device record on the Gateway or 
 *  the device record no longer exists on the Gateway.
 *
 *  @param completion The MASCompletionErrorBlock (BOOL completed, NSError *error) block that 
 *  receives the results.
 */
- (void)deregisterCurrentDeviceWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Register the device with requested MASDeviceRegistrationType.
 *
 *  There are two forms of device registration:
 *
 *      MASGrantFlowClientCredentials
 *      MASGrantFlowPassword
 *
 *  @param completion The MASCompletionErrorBlock (BOOL completed, NSError *error) block that 
 *  receives the results.
 */
- (void)registerDeviceWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Register the device with grantFlowClientCredentials
 *
 *  @param completion MASCompletionErrorBlock that receives the results.
 */
- (void)registerDeviceForClientCredentialsCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Register the device with grantFlowPassword with given username and password
 *
 *  @param userName   NSString of username.
 *  @param password   NSString of password.
 *  @param completion MASCompletionErrorBlock that receives the results.
 */
- (void)registerDeviceForUser:(NSString *)userName password:(NSString *)password completion:(MASCompletionErrorBlock)completion;


/**
 *  Renew signed client certificate.
 *
 *  @param completion MASCompletionErrorBlock that receives the results.
 */
- (void)renewClientCertificateWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Retrieve the currently registered devices.
 *
 *  @param completion The MASObjectsResponseErrorBlock (NSArray *objects, NSError *error) completion block.
 */
- (void)retrieveRegisteredDevices:(MASObjectsResponseErrorBlock)completion;


/**
 *  Logout the device from the server (revoking id_token).
 *  If clearLocal is defined as true, as part of log out process (revoking id_token), 
 *  this method will also clear access_token, and refresh_token that are stored in local.
 *
 *  @param clearLocal BOOL
 *  @param completion The MASCompletionErrorBlock (BOOL completed, NSError *error) block that
 *  receives the results.
 */
- (void)logOutDeviceAndClearLocalAccessToken:(BOOL)clearLocal completion:(MASCompletionErrorBlock)completion;


///--------------------------------------
/// @name Login & Logout
///--------------------------------------

# pragma mark - Login & Logout

/**
 *  Login user with defined MASDeviceRegistrationType.
 *
 *  There are two type of device registration supported
 *
 *      MASDeviceRegistrationTypeClientCredentials
 *      MASDeviceRegistrationTypeUserCredentials
 *
 *  @param completion The MASCompletionErrorBlock (BOOL completed, NSError *error) block that
 *  receives the results.
 */
- (void)loginWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Login anonymously with client credentials.
 *
 *  This means that upon a successful authentication completion the access credentials will have
 *  very limited access scope as defined by the Gateway administrator and custom endpoints.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)loginAnonymouslyWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Login a specific user with basic credentials.
 *
 *  This means that upon a successful authentication completion the access credentials will have
 *  scope access as defined for that user by the Gateway administrator and access to custom 
 *  endpoints which allow that scope.
 *
 *  @param userName The userName of the user.
 *  @param password The password of the user.
 *  @param completion The completion block that receives the results.
 */
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(MASCompletionErrorBlock)completion;


/**
 *  Re-login a specifc user with the refresh token.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)loginAsRefreshTokenWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Re-login a specific user with the id_token
 *
 *  @param ignoreFallback BOOL property that specifies whether to ignore fallback to user authenticated session validation or not
 *  @param completion     The completion block that receives the results.
 */
- (void)loginAsIdTokenIgnoreFallback:(BOOL)ignoreFallback completion:(MASCompletionErrorBlock)completion;


/**
 *  Logout the current access credentials via asynchronous request.
 *
 *  This will remove the user available from 'currentUser' upon a successful result if one exists.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)logoutWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Request the current user's information via asynchronous request.
 *
 *  This will update the user available from 'currentUser' upon a successful result.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)requestUserInfoWithCompletion:(MASUserResponseErrorBlock)completion;


/**
 *  If the current user exists, clear the user credentials from keychain storage, and log out.
 */
- (void)clearCurrentUserForLogout;


# pragma mark - Authentication Validation

/**
 *  Validate the current user's authentication session information.
 *  This method will go through the validation process of application registration, device registration and user authentication.
 *  For device registration, the method will register the device with specified MASGrantFlow.
 *
 *  @param username           NSString of username.
 *  @param password           NSString of password.
 *  @param originalCompletion completion The completion block that receives the results.
 */
- (void)validateCurrentUserAuthenticationWithUsername:(NSString *)username password:(NSString *)password completion:(MASCompletionErrorBlock)originalCompletion;


/**
 *  Validate the current user's session information
 *
 *  This method will go through access_token validation, refresh_token validation (for user credential session), and id_token validation
 *
 *  @param completion
 */
- (void)validateCurrentUserSession:(MASCompletionErrorBlock)completion;


/**
 Validate the current user's session information with authorization code.
 
 Note: if the authorization code was consumed for device registration, the validation process will fall back to currently set flow.  In this case, the authorization code will not be guranteed to proceed authentication as well which may result in presenting login view controller once again for authentication.

 @param authorizationCode NSString of authorization code
 @param completion        MASCompletionErrorBlock to notify original caller for the result of the validation process.
 */
- (void)validateCurrentUserAuthenticationWithAuthorizationCode:(NSString *)authorizationCode completion:(MASCompletionErrorBlock)completion;


@end
