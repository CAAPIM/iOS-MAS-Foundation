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
 *  Set a user auth credentials block to handle the case where SDK's grant flow is set to MASGrantFlowPassword, or SDK recognizes that
 *  any type of MASAuthCredentials is required.
 *
 *  @param authCredentialsBlock MASUserAuthCredentialsBlock that contains callback for developers to invoke with MASAuthCredentials.
 */
+ (void)setAuthCredentialsBlock:(MASUserAuthCredentialsBlock)authCredentialsBlock;



/**
 *  Set MASUser object to [MASUser currentUser] after re-authentication, or log-out of current user
 *
 *  @param user current MASUser object
 */
- (void)setUserObject:(MASUser *)user;


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
 *  Re-login a specifc user with the refresh token.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)loginAsRefreshTokenWithCompletion:(MASCompletionErrorBlock)completion;


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
 *  Validate the current user's session information
 *
 *  This method will go through access_token validation, refresh_token validation (for user credential session), and id_token validation
 *
 *  @param completion
 */
- (void)validateCurrentUserSession:(MASCompletionErrorBlock)completion;


# pragma mark - Authentication flow with MASAuthCredentials

/**
 *  Validate the current user's session information with given MASAuthCredentials object.
 *
 *  This method will go through access_token, refresh_token, and id_token (optional) validation
 *
 *  @param authCredentials  MASAuthCredentials object that contains auth credentials that can be used for session validation.
 *  @param completion       MASCompletionErrorBlock block that notifies original caller for the result of validation.
 */
- (void)validateCurrentUserSessionWithAuthCredentials:(MASAuthCredentials *)authCredentials completion:(MASCompletionErrorBlock)completion;


# pragma mark - Deprecated as of MAS 1.5

/**
 *  Set a user login block to handle the case where the type set in 'setDeviceRegistrationType:(MASDeviceRegistrationType)'
 *  is 'MASDeviceRegistrationTypeUserCredentials'.  If it set to 'MASDeviceRegistrationTypeClientCredentials' this
 *  is not called.
 *
 *  @param registration The MASUserLoginWithUserCredentialsBlock to receive the request for user credentials.
 */
+ (void)setUserLoginBlock:(MASUserLoginWithUserCredentialsBlock)login DEPRECATED_MSG_ATTRIBUTE("[MASModelService setUserLoginBlock:] is deprecated as of MAS 1.5. Use [MASModelService setAuthCredentials:] instead.");

@end
