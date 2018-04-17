//
// MASConstants.h
// MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

@class CLLocation;
@class MASAuthCredentials;
@class MASUser;


/**
 * The NSString constant indicating the MAS 'start' method has not been called yet.
 */
extern NSString *const _Nonnull MASNotStartedYet;


/**
 * The NSString constant key for the user info returned in various file related operations or errors.
 */
extern NSString *const _Nonnull MASFileNameKey;


/**
 * The NSString constant key for the otp retry suspension time returned in various otp related operations or errors.
 */
extern NSString *const _Nonnull MASOTPSuspensionTimeKey;


/**
 * The NSString constant key for the header info in the response dictionary.
 */
extern NSString *const _Nonnull MASResponseInfoHeaderInfoKey;


/**
 * The NSString constant key for the NSHTTPURLResponse object in the response dictionary.
 */
extern NSString *const _Nonnull MASNSHTTPURLResponseObjectKey;


/**
 * The NSString constant key for the error value in the response header info dictionary.
 */
extern NSString *const _Nonnull MASHeaderInfoErrorKey;


/**
 * The NSString constant key for the body info in the response dictionary.
 */
extern NSString *const _Nonnull MASResponseInfoBodyInfoKey;


/**
 * The NSString constant key for the gateway monitor notification's NSDictionary userInfo that will
 * retrieve new status value.
 */
extern NSString *const _Nonnull MASGatewayMonitorStatusKey;



///--------------------------------------
/// @name MAS Blocks
///--------------------------------------

# pragma mark - MAS Blocks

/**
 * A standard (BOOL completed, NSError *error) block.
 */
typedef void (^MASCompletionErrorBlock)(BOOL completed, NSError *_Nullable error);


/**
 * A standard (id objects, NSError *error) block.  The response object could potentially
 * be any type of MASObject.
 */
typedef void (^MASObjectResponseErrorBlock)(id _Nullable object, NSError *_Nullable error);


/**
 * A standard (NSArray *objects, NSError *error) block.  The response objects could potentially
 * be any type of MASObject.
 */
typedef void (^MASObjectsResponseErrorBlock)(NSArray<id> *_Nullable objects, NSError *_Nullable error);


/**
 * A standard (NSDictionary *responseInfo, NSError *error) block.  The response object could potentially
 * be any type of object.  It is most often used to return NSString JSON responses from 
 * HTTP calls for example.
 */
typedef void (^MASResponseInfoErrorBlock)(NSDictionary<NSString *, id> *_Nullable responseInfo, NSError *_Nullable error);


/**
 * A standard (NSHTTPURLResponse *response, id responseObject, NSError *error) block.
 * The block will be executed when a request finishes the task unsuccessfully, or successfully.
 * All of three arguments in the block can be null depends on the result of the request, 
 * and response object should be casted to appropriate data type when it is received.
 */
typedef void (^MASResponseObjectErrorBlock)(NSHTTPURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error);


/**
 * The MASUser specific (MASUser *user, NSError *error) block.
 */
typedef void (^MASUserResponseErrorBlock)(MASUser *_Nullable user, NSError *_Nullable error);


/**
 *  The MASAuthCredentialsBlcok to provide auth credentials for device registration and/or user authentication.
 */
typedef void (^MASAuthCredentialsBlock)(MASAuthCredentials *_Nullable authCredentials, BOOL cancel, MASCompletionErrorBlock _Nullable);


/**
 *  The user auth credentials blcok that will be invoked by SDK to notify developers to provide auth credentials.
 */
typedef void (^MASUserAuthCredentialsBlock)(MASAuthCredentialsBlock _Nonnull authCredentialBlock);


/**
 * The OTP channels (NSArray *otpChannels, BOOL cancel, MASCompletionErrorBlock) block.
 */
typedef void (^MASOTPGenerationBlock)(NSArray *_Nonnull otpChannels, BOOL cancel, MASCompletionErrorBlock _Nullable);


/**
 * The OTP credentials (NSString *oneTimePassword, BOOL cancel, MASCompletionErrorBlock) block.
 */
typedef void (^MASOTPFetchCredentialsBlock)(NSString *_Nonnull oneTimePassword, BOOL cancel, MASCompletionErrorBlock _Nullable);


/**
 * The Two-factor authentication with supported OTP Channels (NSArray *supportedOTPChannels, MASOTPGenerationBlock) block.
 */
typedef void (^MASOTPChannelSelectionBlock)(NSArray *_Nonnull supportedOTPChannels, MASOTPGenerationBlock _Nonnull otpGenerationBlock);


/**
 * The Two-factor authentication with OTP Credentials (MASOTPFetchCredentialsBlock) block.
 */
typedef void (^MASOTPCredentialsBlock)(MASOTPFetchCredentialsBlock _Nonnull otpBlock, NSError *_Nullable otpError);


/**
 * The Selected Biometric modalities (NSArray *_Nullable biometricModalities, BOOL cancel, MASCompletionErrorBlock _Nullable)
 *  block.
 */
typedef void (^MASBiometricModalitiesBlock)(NSArray *_Nullable biometricModalities, BOOL cancel, MASCompletionErrorBlock _Nullable);


/**
 * The Biometric registration with available modalities (NSArray *_Nonnull availableModalities,  MASBiometricModalitiesBlock
 * _Nonnull biometricModalitiesBlock) block.
 */
typedef void (^MASBiometricRegistrationModalitiesSelectionBlock)(NSArray *_Nonnull availableModalities,  MASBiometricModalitiesBlock _Nonnull biometricModalitiesBlock);


/**
 * The Biometric deregistration with available modalities (NSArray *_Nonnull availableModalities,  MASBiometricModalitiesBlock
 * _Nonnull biometricModalitiesBlock) block.
 */
typedef void (^MASBiometricDeregistrationModalitiesSelectionBlock)(NSArray *_Nonnull availableModalities,  MASBiometricModalitiesBlock _Nonnull biometricModalitiesBlock);


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
     *  State that SDK has not been initialized and does not have configuration file 
     *  either in local file system based on the default configuration file name, nor in the keychain storage.
     */
    MASStateNotConfigured = -1,
    /**
     *  State that SDK has the active configuration either in the local file system, or keychain storage, but has not been inistialized yet.
     */
    MASStateNotInitialized,
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
 *  Enumerated MASFileDirectoryType that indicates which directory to store MASFile into.
 */
typedef NS_ENUM(NSInteger, MASFileDirectoryType) {

    /**
     *  Temporary directory in the application package.
     */
    MASFileDirectoryTypeTemporary = -1,
    /**
     *  Application Support directory in the application package.
     */
    MASFileDirectoryTypeApplicationSupport,
    /**
     *  Cache directory in the application package.
     */
    MASFileDirectoryTypeCachesDirectory,
    /**
     *  Documents directory in the application package.
     */
    MASFileDirectoryTypeDocuments,
    /**
     *  Library directory in the application package.
     */
    MASFileDirectoryTypeLibrary
};


///--------------------------------------
/// @name Gateway Monitoring Constants
///--------------------------------------

# pragma mark - Gateway Monitoring Constants


/**
 Enumerated values for MASNetworkReachabilityStatus

 - MASNetworkReachabilityStatusUnknown: network reachability status unknown
 - MASNetworkReachabilityStatusNotReachable: network is not reachable
 - MASNetworkReachabilityStatusReachableViaWWAN: network is reachable via cellular network
 - MASNetworkReachabilityStatusReachableViaWiFi: network is reachable via WiFi
 - MASNetworkReachabilityStatusInitializing: network manager is being initialized and monitoring process is starting up
 */
typedef NS_ENUM(NSInteger, MASNetworkReachabilityStatus)
{
    MASNetworkReachabilityStatusUnknown = -1,
    
    MASNetworkReachabilityStatusNotReachable = 1,
    
    MASNetworkReachabilityStatusReachableViaWWAN = 2,
    
    MASNetworkReachabilityStatusReachableViaWiFi = 3,
    
    MASNetworkReachabilityStatusInitializing = 4
};


/**
 Network reachability status monitoring block definition which will receive MASNetworkRechabilityStatus enum value as in argument.

 @param status MASNetworkReachabilityStatus enum value indicating current status of the network reachability.
 */
typedef void (^MASNetworkReachabilityStatusBlock)(MASNetworkReachabilityStatus status);


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
