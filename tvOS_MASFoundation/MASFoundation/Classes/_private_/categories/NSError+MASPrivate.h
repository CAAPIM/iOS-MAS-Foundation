//
//  NSError+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

#import "MASConstantsPrivate.h"


@interface NSError (MASPrivate)


///--------------------------------------
/// @name Create general errors
///--------------------------------------

# pragma mark - Create general errors


/**
 * Creates a MAS friendly NSError for the given API error code contained within an HTTP
 * response info NSDictionary, if any.  If not it will check the original NSError for
 * other types of errors, i.e. network issues.
 *
 * All errors will include the following standard keys with applicable values:
 *
 *    NSLocalizedDescriptionKey
 *
 * @param responseInfo The HTTP response info NSDictionary.
 * @param error The original NSError.
 * @returns Returns the MAS friendly NSError instance.
 */
+ (NSError *)errorFromApiResponseInfo:(NSDictionary *)responseInfo andError:(NSError *)error;


/**
 *  Creates a MAS friendly NSError for the given NSError with response info NSDictionary from the server.
 *  A NSError will be created based on response info's contents from MAS' standard format of MASResponseInfoHeaderInfoKey and MASResponseInfoBodyInfoKey.
 *  If the response does not contain sufficient information to create an error, the error will be created based on given NSError with given errorDomain.
 *
 *  @param responseInfo The HTTP response info NSDictionary.
 *  @param error        The original NSError.
 *  @param errorDomain  The error domain for this particular error.
 *
 *  @return Returns the MAS friendly NSError instance.
 */
+ (NSError *)errorForFoundationWithResponseInfo:(NSDictionary *)responseInfo error:(NSError *)error errorDomain:(NSString *)errorDomain;


/**
 * Creates an NSError for the given MASFoundationErrorCode.  These errors will fall
 * under the specified domain in parameter.
 *
 * This version is a convenience version without the info:(NSDictionary *)info
 * parameter for those that don't need to add any custom info.
 *
 * All errors will include the following standard keys with applicable values:
 *
 *    NSLocalizedDescriptionKey
 *
 * @param errorCode The MASFoundationErrorCode which identifies the error.
 * @param errorDomain The NSString of error domain.
 * @returns Returns the NSError instance.
 */
+ (NSError *)errorForFoundationCode:(MASFoundationErrorCode)errorCode errorDomain:(NSString *)errorDomain;


/**
 * Creates an NSError for the given MASFoundationErrorCode.  These errors will fall
 * under the sepcified domain in parameter.
 *
 * All errors will include the following standard keys with applicable values:
 *
 *    NSLocalizedDescriptionKey
 *
 * @param errorCode The MASFoundationErrorCode which identifies the error.
 * @param info An additional NSDictionary of custom values that can be included
 * in addition to the defaults included by this method.  Optional, nil is allowed.
 * @param errorDomain The NSString which identifies the domain of the error.
 * @returns Returns the NSError instance.
 */
+ (NSError *)errorForFoundationCode:(MASFoundationErrorCode)errorCode info:(NSDictionary *)info errorDomain:(NSString *)errorDomain;



///--------------------------------------
/// @name Create specific errors
///--------------------------------------

# pragma mark - Create specific error types


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeInvalidUserLoginBlock.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and 
 *  error code MASFoundationErrorCodeInvalidUserLoginBlock.
 */
+ (NSError *)errorInvalidUserLoginBlock;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeInvalidOTPChannelSelectionBlock.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeInvalidOTPChannelSelectionBlock.
 */
+ (NSError *)errorInvalidOTPChannelSelectionBlock;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeInvalidOTPCredentialsBlock.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeInvalidOTPCredentialsBlock.
 */
+ (NSError *)errorInvalidOTPCredentialsBlock;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeOTPNotProvided.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeOTPNotProvided.
 */
+ (NSError *)errorOTPCredentialsNotProvided;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeInvalidOTPProvided.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeInvalidOTPProvided.
 */
+ (NSError *)errorInvalidOTPCredentials;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeOTPExpired.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeOTPExpired.
 */
+ (NSError *)errorOTPCredentialsExpired;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeOTPRetryLimitExceeded.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeOTPRetryLimitExceeded.
 */
+ (NSError *)errorOTPRetryLimitExceeded:(NSString *)suspensionTime;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeOTPRetryBarred.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeOTPRetryBarred.
 */
+ (NSError *)errorOTPRetryBarred:(NSString *)suspensionTime;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeInvalidNSURL.
 *
 *  @return Retruns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeInvalidNSURL.
 */
+ (NSError *)errorInvalidNSURL;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeInvalidNSDictionary.
 *
 *  @return Retruns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeInvalidNSDictionary.
 */
+ (NSError *)errorInvalidNSDictionary;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeApplicationAlreadyRegistered.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomain and
 * error code MASFoundationErrorCodeApplicationAlreadyRegistered.
 */
+ (NSError *)errorApplicationAlreadyRegistered;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeApplicationNotRegistered.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomain and
 * error code MASFoundationErrorCodeApplicationNotRegistered.
 */
+ (NSError *)errorApplicationNotRegistered;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeApplicationRedirectUriInvalid.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomain and
 * error code MASFoundationErrorCodeApplicationRedirectUriInvalid.
 */
+ (NSError *)errorApplicationRedirectUriInvalid;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeConfigurationLoadingFailedFileNotFound.
 *
 * @param fileName The file name of the configuration file which could not be loaded.
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomain and
 * error code MASFoundationErrorCodeConfigurationLoadingFailedFileNotFound.
 */
+ (NSError *)errorConfigurationLoadingFailedFileNotFound:(NSString *)fileName;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeConfigurationLoadingFailedJsonSerialization.
 *
 * @param fileName The file name of the configuration file which could not be loaded.
 * @param description The json serialization error description.
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomain and
 * error code MASFoundationErrorCodeConfigurationLoadingFailedJsonSerialization.
 */
+ (NSError *)errorConfigurationLoadingFailedJsonSerialization:(NSString *)fileName description:(NSString *)description;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeConfigurationLoadingFailedJsonValidation.
 *
 *  @param description The json validation error description
 *
 *  @return Returns an NSerror instance with the domain MASFoundationErrorDomainLocal and error code MASFoundationErrorCodeConfigurationLoadingFailedJsonValidation.
 */
+ (NSError *)errorConfigurationLoadingFailedJsonValidationWithDescription:(NSString *)description;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceAlreadyRegistered.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeDeviceAlreadyRegistered.
 */
+ (NSError *)errorDeviceAlreadyRegistered;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceAlreadyRegisteredWithDifferentFlow.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeDeviceRegisteredWithDifferentFlow.
 */
+ (NSError *)errorDeviceAlreadyRegisteredWithDifferentFlow;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceCouldNotBeDeregistered.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeDeviceCouldNotBeDeregistered.
 */
+ (NSError *)errorDeviceCouldNotBeDeregistered;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceNotRegistered.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeDeviceNotRegistered.
 */
+ (NSError *)errorDeviceNotRegistered;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceNotLoggedIn
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and error code MASFoundationErrorCodeDeviceNotLoggedIn.
 */
+ (NSError *)errorDeviceNotLoggedIn;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceRegistrationAttempedWithUnregisteredScope.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeDeviceRegistrationAttemptedWithUnregisteredScope.
 */
+ (NSError *)errorDeviceRegistrationAttemptedWithUnregisteredScope;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceRegistrationWithoutRequiredParameters.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeDeviceWithoutRequiredParameters.
 */
+ (NSError *)errorDeviceRegistrationWithoutRequiredParameters;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeDeviceDoesNotSupportLocalAuthentication.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeDeviceDoesNotSupportLocalAuthentication.
 */
+ (NSError *)errorDeviceDoesNotSupportLocalAuthentication;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeFlowIsNotActive.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeFlowIsNotActive.
 */
+ (NSError *)errorFlowIsNotActive;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeFlowIsNotImplemented.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeFlowIsNotImplemented.
 */
+ (NSError *)errorFlowIsNotImplemented;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeFlowTypeUnsupported.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeFlowTypeUnsupported.
 */
+ (NSError *)errorFlowTypeUnsupported;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeNetworkNotReachable.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeNetworkNotReachable.
 */
+ (NSError *)errorNetworkNotReachable;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeGeolocationIsInvalid.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeGeolocationIsInvalid.
 */
+ (NSError *)errorGeolocationIsInvalid;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeGeolocationIsMissing.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeGeolocationIsMissing.
 */
+ (NSError *)errorGeolocationIsMissing;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeGeolocationServicesAreUnauthorized.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeGeolocationServicesAreUnauthorized.
 */
+ (NSError *)errorGeolocationServicesAreUnauthorized;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeGeolocationIsNotConfigured.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeGeolocationIsNotConfigured.
 */
+ (NSError *)errorGeolocationServiceIsNotConfigured;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeMasIsNotStarted.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error code MASFoundationErrorCodeMASIsNotStarted.
 */
+ (NSError *)errorMASIsNotStarted;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeNetworkNotStarted.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeNetworkNotStarted.
 */
+ (NSError *)errorNetworkNotStarted;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeInvalidAuthorization.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeInvalidAuthorization.
 */
+ (NSError *)errorInvalidAuthorization;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeUserAlreadyAuthenticated.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeUserAlreadyAuthenticated.
 */
+ (NSError *)errorUserAlreadyAuthenticated;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeUserBasicCredentialsNotValid.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeUserBasicCredentialsNotValid.
 */
+ (NSError *)errorUserBasicCredentialsNotValid;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeUserDoesNotExist.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeUserDoesNotExist.
 */
+ (NSError *)errorUserDoesNotExist;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeUserNotAuthenticated.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeUserNotAuthenticated.
 */
+ (NSError *)errorUserNotAuthenticated;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeLoginProcessCancel.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeLoginProcessCancel.
 */
+ (NSError *)errorLoginProcessCancelled;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeOTPChannelSelectionCancelled.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeOTPChannelSelectionCancelled.
 */
+ (NSError *)errorOTPChannelSelectionCancelled;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeOTPAuthenticationCancelled.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeOTPAuthenticationCancelled.
 */
+ (NSError *)errorOTPAuthenticationCancelled;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeUserSessionIsAlreadyLocked.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeUserSessionIsAlreadyLocked.
 */
+ (NSError *)errorUserSessionIsAlreadyLocked;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeUserSessionIsAlreadyUnlocked.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeUserSessionIsAlreadyUnlocked.
 */
+ (NSError *)errorUserSessionIsAlreadyUnlocked;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeUserSessionIsCurrentlyLocked.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error code MASFoundationErrorCodeUserSessionIsCurrentlyLocked.
 */
+ (NSError *)errorUserSessionIsCurrentlyLocked;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeTokenInvalidIdToken.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeTokenInvalidIdToken.
 */
+ (NSError *)errorInvalidIdToken;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeTokenIdTokenExpired.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeTokenIdTokenExpired.
 */
+ (NSError *)errorIdTokenExpired;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeTokenIdTokenInvalidSignature.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeTokenIdTokenInvalidSignature.
 */
+ (NSError *)errorIdTokenInvalidSignature;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeTokenIdTokenInvalidAzp.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeTokenIdTokenInvalidAzp.
 */
+ (NSError *)errorIdTokenInvalidAzp;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeTokenIdTokenInvalidAud.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeTokenIdTokenInvalidAud.
 */
+ (NSError *)errorIdTokenInvalidAud;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeTokenIdTokenNotExistForLockingUserSession.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeTokenIdTokenNotExistForLockingUserSession.
 */
+ (NSError *)errorIdTokenNotExistForLockingUserSession;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeEnterpriseBrowserWebAppInvalidURL.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeEnterpriseBrowserWebAppInvalidURL.
 */
+ (NSError *)errorEnterpriseBrowserWebAppInvalidURL;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeEnterpriseBrowserNativeAppDoesNotExist.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeEnterpriseBrowserNativeAppDoesNotExist.
 */
+ (NSError *)errorEnterpriseBrowserNativeAppDoesNotExist;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeEnterpriseBrowserNativeAppCannotOpen.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeEnterpriseBrowserNativeAppCannotOpen.
 */
+ (NSError *)errorEnterpriseBrowserNativeAppCannotOpen;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeEnterpriseBrowserAppDoesNotExist.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeEnterpriseBrowserAppDoesNotExist.
 */
+ (NSError *)errorEnterpriseBrowserAppDoesNotExist;


/**
 * Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeConfigurationInvalidEndpoint.
 *
 * @returns Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 * error MASFoundationErrorCodeConfigurationInvalidEndpoint.
 */
+ (NSError *)errorInvalidEndpoint;



/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeProximityLoginAuthorizationInProgress.
 *
 *  @return Returns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error MASFoundationErrorCodeProximityLoginAuthorizationInProgress.
 */
+ (NSError *)errorProximityLoginAuthorizationInProgress;


/**
 *  Create MASFoundationErrorDomainLocal NSError for MASFoundationErrorCodeProximityLoginInvalidAuthorizeURL.
 *
 *  @return REturns an NSError instance with the domain MASFoundationErrorDomainLocal and
 *  error MASFoundationErrorCodeProximityLoginInvalidAuthorizeURL
 */
+ (NSError *)errorProximityLoginInvalidAuthroizeURL;

@end
