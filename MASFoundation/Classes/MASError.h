//
//  MASError.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>


///--------------------------------------
/// @name MAS Error Domains
///--------------------------------------

# pragma mark - MAS Error Domains

/**
 * The NSString error domain used by all MAS server related Foundation level NSErrors.
 */
extern NSString *const _Nonnull MASFoundationErrorDomain;


/**
 *  The NSString error domain used by all MAS local level NSErrors.
 */
extern NSString *const _Nonnull MASFoundationErrorDomainLocal;


/**
 *  The NSString error domain used by all target API level NSErrors.
 */
extern NSString *const _Nonnull MASFoundationErrorDomainTargetAPI;



///--------------------------------------
/// @name MAS Error codes
///--------------------------------------

# pragma mark - MAS Error codes

/**
 * The enumerated error codes for Foundation level NSErrors.
 */
typedef NS_ENUM(NSInteger, MASFoundationErrorCode)
{
    MASFoundationErrorCodeUnknown = -1,
    
    //
    // SDK start
    //
    MASFoundationErrorCodeInvalidNSURL = 100001,
    MASFoundationErrorCodeInvalidNSDictionary = 100002,
    MASFoundationErrorCodeInvalidUserLoginBlock = 100003,
    MASFoundationErrorCodeMASIsNotStarted = 100004,
    MASFoundationErrorCodeInvalidEnrollmentURL = 100005,
    
    //
    // Flow
    //
    MASFoundationErrorCodeFlowIsNotActive = 100101,
    MASFoundationErrorCodeFlowIsNotImplemented = 100102,
    MASFoundationErrorCodeFlowTypeUnsupported = 100103,
    
    //
    // Configuration
    //
    MASFoundationErrorCodeConfigurationLoadingFailedFileNotFound = 100201,
    MASFoundationErrorCodeConfigurationLoadingFailedJsonSerialization = 100202,
    MASFoundationErrorCodeConfigurationLoadingFailedJsonValidation = 100203,
    MASFoundationErrorCodeConfigurationInvalidEndpoint = 100204,
    
    //
    //  Security Configuration
    //
    MASFoundationErrorCodeConfigurationInvalidHostForSecurityConfiguration = 100211,
    MASFoundationErrorCodeConfigurationInvalidPinningInfoForSecurityConfiguration = 100212,
    
    //
    // Geolocation
    //
    MASFoundationErrorCodeGeolocationIsInvalid = 100301,
    MASFoundationErrorCodeGeolocationIsMissing = 100302,
    MASFoundationErrorCodeGeolocationServicesAreUnauthorized = 100303,
    MASFoundationErrorCodeGeolocationIsNotConfigured = 100304,
    
    //
    // Network
    //
    MASFoundationErrorCodeNetworkUnacceptableContentType = 100401,
    MASFoundationErrorCodeNetworkIsOffline = 100402,
    MASFoundationErrorCodeNetworkNotReachable = 100403,
    MASFoundationErrorCodeNetworkNotStarted = 100404,
    MASFoundationErrorCodeNetworkRequestTimedOut = 100405,
    MASFoundationErrorCodeNetworkSSLConnectionCannotBeMade = 100406,
    MASFoundationErrorCodeResponseSerializationFailedToParseResponse = 100407,
    MASFoundationErrorCodeNetworkSSLAuthenticationChallengeFailure = 100408,
    
    //
    // Application
    //
    MASFoundationErrorCodeApplicationAlreadyRegistered = 110001,
    MASFoundationErrorCodeApplicationInvalid = 110002,
    MASFoundationErrorCodeApplicationNotRegistered = 110003,
    MASFoundationErrorCodeApplicationInvalidMagIdentifer = 110004,
    MASFoundationErrorCodeApplicationRedirectUriInvalid = 110005,
    
    //
    // Device
    //
    MASFoundationErrorCodeDeviceAlreadyRegistered = 120001,
    MASFoundationErrorCodeDeviceAlreadyRegisteredWithDifferentFlow = 120002,
    MASFoundationErrorCodeDeviceCouldNotBeDeregistered = 120003,
    MASFoundationErrorCodeDeviceNotRegistered = 120004,
    MASFoundationErrorCodeDeviceNotLoggedIn = 120005,
    MASFoundationErrorCodeDeviceRecordIsNotValid = 120006,
    MASFoundationErrorCodeDeviceRegistrationAttemptedWithUnregisteredScope = 120007,
    MASFoundationErrorCodeDeviceRegistrationWithoutRequiredParameters = 120008,
    MASFoundationErrorCodeDeviceDoesNotSupportLocalAuthentication = 120009,
    MASFoundationErrorCodeDeviceInvalidAuthCredentialsForDeviceRegistration = 120010,
    
    //
    // Authorization
    //
    MASFoundationErrorCodeInvalidAuthorization = 131001,
    
    //
    // User
    //
    MASFoundationErrorCodeUserAlreadyAuthenticated = 130001,
    MASFoundationErrorCodeUserBasicCredentialsNotValid = 130002,
    MASFoundationErrorCodeUserDoesNotExist = 130003,
    MASFoundationErrorCodeUserNotAuthenticated = 130004,
    MASFoundationErrorCodeLoginProcessCancel = 130005,
    MASFoundationErrorCodeUserSessionIsAlreadyLocked = 130006,
    MASFoundationErrorCodeUserSessionIsAlreadyUnlocked = 130007,
    MASFoundationErrorCodeUserSessionIsCurrentlyLocked = 130008,
    
    //
    // Token
    //
    MASFoundationErrorCodeTokenInvalidIdToken = 130101,
    MASFoundationErrorCodeTokenIdTokenExpired = 130102,
    MASFoundationErrorCodeTokenIdTokenInvalidAud = 130103,
    MASFoundationErrorCodeTokenIdTokenInvalidAzp = 130104,
    MASFoundationErrorCodeTokenIdTokenInvalidSignature = 130105,
    MASFoundationErrorCodeTokenIdTokenNotExistForLockingUserSession = 130106,
    MASFoundationErrorCodeTokenIdTokenNotSupportedSigningAlgorithm = 130107,
    
    MASFoundationErrorCodeAccessTokenInvalid = 130201,
    MASFoundationErrorCodeAccessTokenDisabled = 130202,
    MASFoundationErrorCodeAccessTokenNotGrantedScope = 130203,
    
    //
    // Enterprise Browser
    //
    MASFoundationErrorCodeEnterpriseBrowserWebAppInvalidURL = 140001,
    MASFoundationErrorCodeEnterpriseBrowserNativeAppDoesNotExist = 140002,
    MASFoundationErrorCodeEnterpriseBrowserNativeAppCannotOpen = 140003,
    MASFoundationErrorCodeEnterpriseBrowserAppDoesNotExist = 140004,
    
    //
    // BLE
    //
    MASFoundationErrorCodeBLEUnknownState = 150001,
    MASFoundationErrorCodeBLEAuthorizationFailed = 150002,
    MASFoundationErrorCodeBLEAuthorizationPollingFailed = 150003,
    MASFoundationErrorCodeBLECentralDeviceNotFound = 150004,
    MASFoundationErrorCodeBLEDelegateNotDefined = 150005,
    MASFoundationErrorCodeBLEInvalidAuthenticationProvider = 150006,
    MASFoundationErrorCodeBLEPoweredOff = 150007,
    MASFoundationErrorCodeBLEResetting = 150008,
    MASFoundationErrorCodeBLERSSINotInRange = 150009,
    MASFoundationErrorCodeBLEUnSupported = 150010,
    MASFoundationErrorCodeBLEUnauthorized = 150011,
    MASFoundationErrorCodeBLEUserDeclined = 150012,
    MASFoundationErrorCodeBLECentral = 150013,
    MASFoundationErrorCodeBLEPeripheral = 150014,
    MASFoundationErrorCodeBLEPeripheralServices = 150015,
    MASFoundationErrorCodeBLEPeripheralCharacteristics = 150016,
    
    //
    // Proximity Login
    //
    MASFoundationErrorCodeProximityLoginAuthorizationInProgress = 150101,
    MASFoundationErrorCodeProximityLoginInvalidAuthenticationURL = 150102,
    MASFoundationErrorCodeQRCodeProximityLoginAuthorizationPollingFailed = 150103,
    MASFoundationErrorCodeProximityLoginInvalidAuthorizeURL = 150104,
    
    //
    // OTP
    //
    MASFoundationErrorCodeInvalidOTPChannelSelectionBlock = 160101,
    MASFoundationErrorCodeInvalidOTPCredentialsBlock = 160102,
    MASFoundationErrorCodeInvalidOTPProvided = 160103,
    MASFoundationErrorCodeOTPNotProvided = 160104,
    MASFoundationErrorCodeOTPExpired = 160105,
    MASFoundationErrorCodeOTPRetryLimitExceeded = 160106,
    MASFoundationErrorCodeOTPRetryBarred = 160107,
    MASFoundationErrorCodeOTPChannelSelectionCancelled = 160201,
    MASFoundationErrorCodeOTPAuthenticationCancelled = 160202,
    
    //
    //  JWT
    //
    MASFoundationErrorCodeJWTInvalidClaims = 170001,
    MASFoundationErrorCodeJWTUnexpectedClassType = 170002,
    MASFoundationErrorCodeJWTSerializationError = 170003,
    
    //
    // Browser Based Login
    //
    MASFoundationErrorCodeBBANotEnabled = 180000,
    
    //
    //  SharedStorage
    //
    MASFoundationErrorCodeSharedStorageNotNilKey = 180001,
    
    //
    //  Multi Factor Authentication
    //
    MASFoundationErrorCodeMultiFactorAuthenticationCancelled = 180002,
    MASFoundationErrorCodeMultiFactorAuthenticationInvalidRequest = 180003,
    
    MASFoundationErrorCodeCount = -999999
};


