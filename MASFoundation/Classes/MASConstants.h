//
//  MASConstants.h
// MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

@class CLLocation;
@class MASUser;



///--------------------------------------
/// @name MAS Blocks
///--------------------------------------

# pragma mark - MAS Blocks

/**
 * A standard (BOOL completed, NSError *error) block.
 */
typedef void (^MASCompletionErrorBlock)(BOOL completed, NSError *error);


/**
 * A standard (id objects, NSError *error) block.  The response object could potentially
 * be any type of MASObject.
 */
typedef void (^MASObjectResponseErrorBlock)(id object, NSError *error);


/**
 * A standard (NSArray *objects, NSError *error) block.  The response objects could potentially
 * be any type of MASObject.
 */
typedef void (^MASObjectsResponseErrorBlock)(NSArray *objects, NSError *error);


/**
 * A standard (NSDictionary *responseInfo, NSError *error) block.  The response object could potentially
 * be any type of object.  It is most often used to return NSString JSON responses from 
 * HTTP calls for example.
 */
typedef void (^MASResponseInfoErrorBlock)(NSDictionary *responseInfo, NSError *error);


/**
 * The MASUser specific (MASUser *user, NSError *error) block.
 */
typedef void (^MASUserResponseErrorBlock)(MASUser *user, NSError *error);


/**
 * The Basic Credentials (NSString *userName, NSString *password, BOOL cancel) block.
 */
typedef void (^MASBasicCredentialsBlock)(NSString *userName, NSString *password, BOOL cancel, MASCompletionErrorBlock);


/**
 * The Authorization Code Credentials (NSString *authorizationCode, BOOL cancel, MAScompletionErrorBlock) block.
 */
typedef void (^MASAuthorizationCodeCredentialsBlock)(NSString *authorizationCode, BOOL cancel, MASCompletionErrorBlock);


/**
 * The Device Registration with User Credentials (MASBasicCredentialsBlock,. MASAuthorizationCodeCredentialsBlock) block.
 */
typedef void (^MASDeviceRegistrationWithUserCredentialsBlock)(MASBasicCredentialsBlock basicBlock, MASAuthorizationCodeCredentialsBlock authorizationCodeBlock);


/**
 * The User Login with User Credentials (MASBasicCredentialsBlock,. MASAuthorizationCodeCredentialsBlock) block.
 */
typedef void (^MASUserLoginWithUserCredentialsBlock)(MASBasicCredentialsBlock basicBlock, MASAuthorizationCodeCredentialsBlock authorizationCodeBlock);


/**
 * The OTP channels (NSArray *otpChannels, BOOL cancel, MASCompletionErrorBlock) block.
 */
typedef void (^MASOTPGenerationBlock)(NSArray *otpChannels, BOOL cancel, MASCompletionErrorBlock);


/**
 * The OTP credentials (NSString *oneTimePassword, BOOL cancel, MASCompletionErrorBlock) block.
 */
typedef void (^MASOTPFetchCredentialsBlock)(NSString *oneTimePassword, BOOL cancel, MASCompletionErrorBlock);


/**
 * The Two-factor authentication with supported OTP Channels (NSArray *supportedOTPChannels, MASOTPGenerationBlock) block.
 */
typedef void (^MASOTPChannelSelectionBlock)(NSArray *supportedOTPChannels, MASOTPGenerationBlock otpGenerationBlock);


/**
 * The Two-factor authentication with OTP Credentials (MASOTPFetchCredentialsBlock) block.
 */
typedef void (^MASOTPCredentialsBlock)(MASOTPFetchCredentialsBlock otpBlock, NSError *otpError);


///--------------------------------------
/// @name MAS Constants
///--------------------------------------

# pragma mark - MAS Constants

/**
 * The enumerated MASGrantFlow.
 */
typedef NS_ENUM(NSInteger, MASGrantFlow)
{
    /**
     * Unknown encoding type.
     */
    MASGrantFlowUnknown = -1,
    
    /**
     * The client credentials grant flow.
     */
    MASGrantFlowClientCredentials,
    
    /**
     * The user credentials grant flow.
     */
    MASGrantFlowPassword,
    
    /**
     * The total number of supported types.
     */
    MASGrantFlowCount
};


/**
 * The enumerated MASRequestResponseTypes that can indicate what data format is expected
 * in a request or a response.
 */
typedef NS_ENUM(NSInteger, MASRequestResponseType)
{
    /**
     * Unknown encoding type.
     */
    MASRequestResponseTypeUnknown = -1,
    
    /**
     * Standard JSON encoding.
     */
    MASRequestResponseTypeJson,
    
    /**
     * SCIM-specific JSON variant encoding.
     */
    MASRequestResponseTypeScimJson,
    
    /**
     * Plain Text.
     */
    MASRequestResponseTypeTextPlain,
    
    /**
     * Standard WWW Form URL encoding.
     */
    MASRequestResponseTypeWwwFormUrlEncoded,
    
    /**
     * Standard XML encoding.
     */
    MASRequestResponseTypeXml,
    
    /**
     * The total number of supported types.
     */
    MASRequestResponseTypeCount
};


/**
 *  The enumerated MASState that can indicate what state of SDK currently is at.
 */
typedef NS_ENUM(NSInteger, MASState) {
    /**
     *  State that SDK has not been inistialized.
     */
    MASStateNotInitialized = -1,
    /**
     *  State that SDK did load; at this state, all services have been loaded.  This state will only be invoked once for the app's lifecycle.
     */
    MASStateDidLoad,
    /**
     *  State that SDK will start; at this state, SDK is initializing and prepareing all elements required to operate.
     */
    MASStateWillStart,
    /**
     *  State that SDK did start; at this state, SDK should be fully functional.
     */
    MASStateDidStart,
    /**
     *  State that SDK will stop; at this state, SDK is preparing to stop the lifecycle and shutting down all elements and services for the SDK.
     */
    MASStateWillStop,
    /**
     *  State that SDK did stop; at this state, SDK is properly stopped and should be able to re-start.
     */
    MASStateDidStop,
    /**
     *  State that SDK is being forced to stop.
     */
    MASStateIsBeingStopped
};


/**
 * The NSString constant indicating the MAS 'start' method has not been called yet.
 */
static NSString *const MASNotStartedYet = @"MAS not started yet";


/**
 * The NSString constant key for the user info returned in various file related operations or errors.
 */
static NSString *const MASFileNameKey = @"MASFileNameKey";


/**
 * The NSString constant key for the otp retry suspension time returned in various otp related operations or errors.
 */
static NSString *const MASOTPSuspensionTimeKey = @"MASOTPSuspensionTimeKey";


/**
 * The NSString constant key for the header info in the response dictionary.
 */
static NSString *const MASResponseInfoHeaderInfoKey = @"MASResponseInfoHeaderInfoKey";

/**
 * The NSString constant key for the error value in the response header info dictionary.
 */
static NSString *const MASHeaderInfoErrorKey = @"x-ca-err";


/**
 * The NSString constant key for the body info in the response dictionary.
 */
static NSString *const MASResponseInfoBodyInfoKey = @"MASResponseInfoBodyInfoKey";



///--------------------------------------
/// @name MAS Errors
///--------------------------------------

# pragma mark - MAS Errors

/**
 * The NSString error domain used by all MAS server related Foundation level NSErrors.
 */
static NSString *const MASFoundationErrorDomain = @"com.ca.MASFoundation:ErrorDomain";


/**
 *  The NSString error domain used by all MAS local level NSErrors.
 */
static NSString *const MASFoundationErrorDomainLocal = @"com.ca.MASFoundation.localError:ErrorDomain";



/**
 *  The NSString error domain used by all target API level NSErrors.
 */
static NSString *const MASFoundationErrorDomainTargetAPI = @"com.ca.MASFoundation.targetAPI:ErrorDomain";


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
    
    //
    // Application
    //
    MASFoundationErrorCodeApplicationAlreadyRegistered = 110001,
    MASFoundationErrorCodeApplicationInvalid = 110002,
    MASFoundationErrorCodeApplicationNotRegistered = 110003,
    MASFoundationErrorCodeApplicationInvalidMagIdentifer = 110004,
    
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
    MASFoundationErrorCodeBLERestting = 150008,
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
    
    MASFoundationErrorCodeCount = -999999
};



///--------------------------------------
/// @name MAS Notifications
///--------------------------------------


# pragma mark - MAS Notifications

/**
 * The NSString constant for the MAS notification indicating that MAS has begun
 * starting all it's processes.
 */
static NSString *const MASWillStartNotification = @"MASWillStartNotification";


/**
 * The NSString constant for the MAS notification indicating that MAS has failed 
 * to successfully start it's processes.
 */
static NSString *const MASDidFailToStartNotification = @"MASDidFailToStartNotification";


/**
 * The NSString constant for the MAS notification indicating that MAS has
 * successfully started it's processes.
 */
static NSString *const MASDidStartNotification = @"MASDidStartNotification";


/**
 * The NSString constant for the MAS notification indicating that MAS has begun
 * stopping all it's processes.
 */
static NSString *const MASWillStopNotification = @"MASWillStopNotification";


/**
 * The NSString constant for the MAS notification indicating that MAS has failed 
 * to successfully stop it's processes.
 */
static NSString *const MASDidFailToStopNotification = @"MASDidFailToStopNotification";


/**
 * The NSString constant for the MAS notification indicating that MAS has
 * successfully stopped it's processes.
 */
static NSString *const MASDidStopNotification = @"MASDidStopNotification";


/**
 *  The NSString constant for the MAS notification indicating that MAS will
 *  switch the server.
 */
static NSString *const MASWillSwitchGatewayServerNotification = @"MASWillSwitchGatewayServerNotification";


/**
 *  The NSString constant for the MAS notification indicating that MAS did finish to
 *  switch the server.
 */
static NSString *const MASDidSwitchGatewayServerNotification = @"MASDidSwitchGatewayServerNotification";




///--------------------------------------
/// @name Device Notifications
///--------------------------------------

# pragma mark - Device Notifications

/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has begun the process of deregistering the device.
 */
static NSString *const MASDeviceWillDeregisterNotification = @"MASDeviceWillDeregisterNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has failed to successfully deregister.
 */
static NSString *const MASDeviceDidFailToDeregisterNotification = @"MASDeviceDidFailToDeregisterNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has successfully deregistered.
 */
static NSString *const MASDeviceDidDeregisterNotification = @"MASDeviceDidDeregisterNotification";



///--------------------------------------
/// @name User Notifications
///--------------------------------------

# pragma mark - User Notifications

/**
 * The NSString constant for the user notification indicating that a MASUser
 * will attempt to authenticate.
 */
static NSString *const MASUserWillAuthenticateNotification = @"MASUserWillAuthenticateNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has failed to authenticate.
 */
static NSString *const MASUserDidFailToAuthenticateNotification = @"MASUserDidFailToAuthenticateNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has successfully authenticated.
 */
static NSString *const MASUserDidAuthenticateNotification = @"MASUserDidAuthenticateNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * will attempt to log out.
 */
static NSString *const MASUserWillLogoutNotification = @"MASUserWillLogoutNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has failed to log out.
 */
static NSString *const MASUserDidFailToLogoutNotification = @"MASUserDidFailToLogoutNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has successfully logged out.
 */
static NSString *const MASUserDidLogoutNotification = @"MASUserDidLogoutNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * will attempt to update it's information.
 */
static NSString *const MASUserWillUpdateInformationNotification = @"MASUserWillUpdateInformationNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has failed to update it's user information.
 */
static NSString *const MASUserDidFailToUpdateInformationNotification = @"MASUserDidFailToUpdateInformationNotification";


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has successfully updated it's information.
 */
static NSString *const MASUserDidUpdateInformationNotification = @"MASUserDidUpdateInformationNotification";


///--------------------------------------
/// @name Proximity Login Notification
///--------------------------------------

# pragma mark - Proximity Login Notification

/**
 *  The NSString constant for the device notification indicating that the MASDevice
 *  has received authorization code from proximity login (BLE/QR Code)
 */
static NSString *const MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification = @"MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification";


/**
 *  The NSString constant for the device notification indicating that the MASDevice
 *  has received an error from proximity login (BLE/QR Code)
 */
static NSString *const MASDeviceDidReceiveErrorFromProximityLoginNotification = @"MASDeviceDidReceiveErrorFromProximityLoginNotification";


/**
 *  The NSString constant for the proximity login notification indicating that QR Code image did start displaying.
 */
static NSString *const MASProximityLoginQRCodeDidStartDisplayingQRCodeImage = @"MASProximityLoginQRCodeDidStartDisplayingQRCodeImage";


/**
 *  The NSString constant for the proximity login notification indicating that QR Code image did stop displaying.
 */
static NSString *const MASProximityLoginQRCodeDidStopDisplayingQRCodeImage = @"MASProximityLoginQRCodeDidStopDisplayingQRCodeImage";


///--------------------------------------
/// @name Gateway Monitoring Constants
///--------------------------------------

# pragma mark - Gateway Monitoring Constants

/**
 * The enumerated MASGatewayMonitoringStatus types.
 */
typedef NS_ENUM(NSInteger, MASGatewayMonitoringStatus)
{
    /**
     *  Unknown Status
     */
    MASGatewayMonitoringStatusUnknown = -1,
    
    /**
     *  The network cannot reach the assigned base network url
     */
    MASGatewayMonitoringStatusNotReachable,
    
    /**
     *  The network can reach the assigned base network url via WWAN
     */
    MASGatewayMonitoringStatusReachableViaWWAN,
    
    /**
     *  The network can reach the assigned base network url via WiFi,
     */
    MASGatewayMonitoringStatusReachableViaWiFi,
    
    /**
     *  Convenience to tell how many status type exist
     */
    MASGatweayMonitoringStatusCount
};


/**
 * The Gateway monitor status block that will receive a MASGatewayMonitoringStatus update
 * when a new status value change is triggered.
 *
 * The monitoring status enumerated values are:
 *
 *     MASGatewayMonitoringStatusNotReachable
 *     MASGatewayMonitoringStatusReachableViaWWAN
 *     MASGatewayMonitoringStatusReachableViaWiFi
 */
typedef void (^MASGatewayMonitorStatusBlock)(MASGatewayMonitoringStatus status);



///--------------------------------------
/// @name Gateway Monitor Notifications
///--------------------------------------

# pragma mark - Gateway Monitor Notifications

/**
 * The NSString constant for the gateway monitor notification indicating that the monitor status
 * has updated to a new value.
 */
static NSString *const MASGatewayMonitorStatusUpdateNotification = @"MASGatewayMonitorStatusUpdateNotification";


/**
 * The NSString constant key for the gateway monitor notification's NSDictionary userInfo that will 
 * retrieve new status value.
 */
static NSString *const MASGatewayMonitorStatusKey = @"MASGatewayMonitorStatusKey";
