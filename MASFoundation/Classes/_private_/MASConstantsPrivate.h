//
//  MASConstantsPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

#import "MASConstants.h"

#import "MASNetworkingService.h"
#import "MASIOrderedDictionary.h"

#import "CBCentralManager+MASPrivate.h"
#import "CBPeripheralManager+MASPrivate.h"
#import "CLLocation+MASPrivate.h"
#import "CLLocationManager+MASPrivate.h"
#import "MASApplication+MASPrivate.h"
#import "MASAuthenticationProvider+MASPrivate.h"
#import "MASAuthenticationProviders+MASPrivate.h"
#import "MASDevice+MASPrivate.h"
#import "MASFile+MASPrivate.h"
#import "MASIJSONResponseSerializer+MASPrivate.h"
#import "MASUser+MASPrivate.h"
#import "NSData+MASPrivate.h"
#import "NSError+MASPrivate.h"
#import "NSMutableURLRequest+MASPrivate.h"
#import "NSNotificationCenter+MASPrivate.h"
#import "NSString+MASPrivate.h"

#import "UIImageView+MASINetworking.h"


// Known internal MASFoundation service UUIDs
static NSString *_Nonnull const MASAccessServiceUUID = @"46987e7b-a694-4b44-b02d-694c90ae6952";
static NSString *_Nonnull const MASBluetoothServiceUUID = @"e1c58e79-3df9-4dcc-b32d-f947762450c8";
static NSString *_Nonnull const MASConfigurationServiceUUID = @"277a5b4a-b665-4ace-b23b-237c80bd7083";
static NSString *_Nonnull const MASConnectaServiceUUID = @"ce68de11-609c-42cb-9fb1-96d661e9ff17";
static NSString *_Nonnull const MASLocationServiceUUID = @"83c5830a-019f-4415-a46c-41470bc28219";
static NSString *_Nonnull const MASFileServiceUUID = @"f94672c4-7daf-4a28-a26e-085badf136fa";
static NSString *_Nonnull const MASModelServiceUUID = @"37a4f3f3-e029-430d-a2d2-2c1f46e87bd2";
static NSString *_Nonnull const MASNetworkServiceUUID = @"cd460414-b248-47a4-af8a-4eadfdb937f8";
static NSString *_Nonnull const MASSecurityServiceUUID = @"8a1e8e72-e714-11e5-9730-9a79f06e9478";
static NSString *_Nonnull const MASOTPServiceUUID = @"1dcd2f44-bdc2-449c-9ffc-084592feb046";

// Known external MAS service UUIDs, these are optional and pluggable services
static NSString const *_Nonnull MASDebugServiceUUID = @"018c9134-688e-4f47-ace9-f18b4430ca42";
static NSString const *_Nonnull MASProximityServiceUUID = @"88ed8292-9d60-4d2a-9d50-7e9158c83096";
static NSString const *_Nonnull MASUIServiceUUID = @"c15a0126-fe71-46bb-98f0-f87966b3beb4";


// Defaults
static NSString *_Nonnull const MASDefaultDot = @".";
static NSString *_Nonnull const MASDefaultEmptySpace = @" ";
static NSString *_Nonnull const MASDefaultEmptyString = @"";
static NSString *_Nonnull const MASDefaultNewline = @"\n";

static NSString *_Nonnull const MASDefaultStuff = @"h9872$&!489ykjdhfy9y6i&#!ykfh";
static NSString *_Nonnull const MASCertificate = @"MAS.crt";
static NSString *_Nonnull const MASSignedCertificate = @"MASSigned.crt";
static NSString *_Nonnull const MASKey = @"MAS.key";

static NSString *_Nonnull const MASHeaderErrorKey = @"x-ca-err";

static NSString *_Nonnull const MASIdTokenTypeToValidateConstant = @"urn:ietf:params:oauth:grant-type:jwt-bearer"; // string

static NSString *_Nonnull const MASPKCECodeChallengeMethodSHA256Key = @"S256"; // string
static NSString *_Nonnull const MASPKCECodeChallengeMethodPlainKey = @"plain"; // string

// Client certificate expiration advanced renew timeframe in days
static int const MASClientCertificateAdvancedRenewTimeframe = 30;

# pragma mark - OTP Constants

static NSString *_Nonnull const MASHeaderOTPKey = @"X-OTP";
static NSString *_Nonnull const MASHeaderOTPChannelKey = @"X-OTP-CHANNEL";
static NSString *_Nonnull const MASHeaderOTPRetryIntervalKey = @"X-OTP-RETRY-INTERVAL";

static NSString *_Nonnull const MASOTPRequestEndpointKey = @"end_point"; // string
static NSString *_Nonnull const MASOTPRequestParameterInfoKey = @"parameter_info"; // string
static NSString *_Nonnull const MASOTPRequestHeaderInfoKey = @"header_info"; // string
static NSString *_Nonnull const MASOTPRequestHTTPMethodKey = @"http_method"; // string
static NSString *_Nonnull const MASOTPRequestTypeKey = @"request_type"; // string
static NSString *_Nonnull const MASOTPResponseTypeKey = @"response_type"; // string
static NSString *_Nonnull const MASOTPResponseOTPStatusKey = @"generated"; // string

static NSString *_Nonnull const MASApiErrorCodeOTPPrefix = @"8000"; // string

static NSString *_Nonnull const MASApiErrorCodeOTPNotProvidedSuffix = @"140"; // string
static NSString *_Nonnull const MASApiErrorCodeInvalidOTPProvidedSuffix = @"142"; // string
static NSString *_Nonnull const MASApiErrorCodeOTPExpiredSuffix = @"143"; // string
static NSString *_Nonnull const MASApiErrorCodeOTPRetryLimitExceededSuffix = @"144"; // string
static NSString *_Nonnull const MASApiErrorCodeOTPRetryBarredSuffix = @"145"; // string

# pragma mark - Certificate Constants

static NSString *_Nonnull const MASCertificateBeginPrefix = @"-----BEGIN CERTIFICATE-----";
static NSString *_Nonnull const MASCertificateEndSuffix = @"-----END CERTIFICATE-----";


# pragma mark - GrantType Constants

static NSString *_Nonnull const MASInfoTypeWork = @"work"; // string
static NSString *_Nonnull const MASInfoTypeThumbnail = @"thumbnail"; // string


# pragma mark - Request/Response/Configuration Constants

static NSString *_Nonnull const MASAcceptRequestResponseKey = @"accept"; // string
static NSString *_Nonnull const MASAccessTokenRequestResponseKey = @"access_token"; // string

static NSString *_Nonnull const MASApplicationAuthUrlRequestResponseKey = @"auth_url"; // string
static NSString *_Nonnull const MASApplicationCustomRequestResponseKey = @"custom"; // string
static NSString *_Nonnull const MASApplicationIconUrlRequestResponseKey = @"icon_url"; // string
static NSString *_Nonnull const MASApplicationIdRequestResponseKey = @"id"; // string
static NSString *_Nonnull const MASApplicationNameRequestResponseKey = @"name"; // string
static NSString *_Nonnull const MASApplicationNativeUrlRequestResponseKey = @"native_url"; // string

static NSString *_Nonnull const MASAssertionRequestResponseKey = @"assertion"; // string
static NSString *_Nonnull const MASAuthenticationUrlRequestResponseKey = @"auth_url"; // string
static NSString *_Nonnull const MASAuthorizationRequestResponseKey = @"authorization"; // string
static NSString *_Nonnull const MASCertFormatRequestResponseKey = @"cert-format"; // string
static NSString *_Nonnull const MASCertificateRequestResponseKey = @"certificate"; // string
static NSString *_Nonnull const MASCertificateSigningRequestResponseKey = @"certificateSigningRequest"; // string
static NSString *_Nonnull const MASClientIdentifierRequestResponseKey = @"client_id"; // string
static NSString *_Nonnull const MASClientAuthorizationRequestResponseKey = @"client-authorization"; // string
static NSString *_Nonnull const MASClientKeyRequestResponseKey = @"client_id"; // string
static NSString *_Nonnull const MASClientExpirationRequestResponseKey = @"client_expiration"; // array
static NSString *_Nonnull const MASClientSecretRequestResponseKey = @"client_secret"; // string
static NSString *_Nonnull const MASCodeRequestResponseKey = @"code"; // string
static NSString *_Nonnull const MASContentTypeRequestResponseKey = @"content-type"; // string
static NSString *_Nonnull const MASCreateSessionRequestResponseKey = @"create-session"; // string
static NSString *_Nonnull const MASDeviceIdRequestResponseKey = @"device-id"; // string
static NSString *_Nonnull const MASDeviceLogoutAppRequestResponseKey = @"logout_apps"; // string
static NSString *_Nonnull const MASDeviceNameRequestResponseKey = @"device-name"; // string
static NSString *_Nonnull const MASDeviceStatusRequestResponseKey = @"device-status"; // string
static NSString *_Nonnull const MASDisplayRequestResponseKey = @"display"; // string
static NSString *_Nonnull const MASEnvironmentRequestResponseKey = @"environment"; // string
static NSString *_Nonnull const MASErrorDescriptionRequestResponseKey = @"error_description"; // string
static NSString *_Nonnull const MASErrorRequestResponseKey = @"error"; // string
static NSString *_Nonnull const MASErrorStatusCodeRequestResponseKey = @"status-code"; // string
static NSString *_Nonnull const MASExpiresInRequestResponseKey = @"expires_in"; // number
static NSString *_Nonnull const MASGeoLocationRequestResponseKey = @"geo-location"; // string
static NSString *_Nonnull const MASGrantTypeRequestResponseKey = @"grant_type"; // string
static NSString *_Nonnull const MASIDPRequestResponseKey = @"idp"; // string
static NSString *_Nonnull const MASIdRequestResponseKey = @"id"; // string
static NSString *_Nonnull const MASIdTokenHeaderRequestResponseKey = @"id-token"; // string
static NSString *_Nonnull const MASIdTokenTypeHeaderRequestResponseKey = @"id-token-type"; // string
static NSString *_Nonnull const MASIdTokenBodyRequestResponseKey = @"id_token"; // string
static NSString *_Nonnull const MASIdTokenTypeBodyRequestResponseKey = @"id_token_type"; // string
static NSString *_Nonnull const MASJwtRequestResponseKey = @"jwt"; // string
static NSString *_Nonnull const MASMagIdentifierRequestResponseKey = @"mag-identifier"; // string
static NSString *_Nonnull const MASNonceRequestResponseKey = @"nonce"; // string
static NSString *_Nonnull const MASPasswordRequestResponseKey = @"password"; // string
static NSString *_Nonnull const MASPollUrlRequestResponseKey = @"poll_url"; // string
static NSString *_Nonnull const MASProviderRequestResponseKey = @"provider"; // string
static NSString *_Nonnull const MASProvidersRequestResponseKey = @"providers"; // string
static NSString *_Nonnull const MASRedirectUriRequestResponseKey = @"redirect_uri"; // string
static NSString *_Nonnull const MASRedirectUriHeaderRequestResponseKey = @"redirect-uri"; // string
static NSString *_Nonnull const MASRegisteredByRequestResponseKey = @"registered_by"; // string
static NSString *_Nonnull const MASRefreshTokenRequestResponseKey = @"refresh_token"; // string
static NSString *_Nonnull const MASRequestResponseTypeRequestResponseKey = @"response_type"; // string
static NSString *_Nonnull const MASScopeRequestResponseKey = @"scope"; // number
static NSString *_Nonnull const MASSecretRequestResponseKey = @"secret"; // string
static NSString *_Nonnull const MASStatusRequestResponseKey = @"status"; // string
static NSString *_Nonnull const MASTokenRequestResponseKey = @"token"; // string
static NSString *_Nonnull const MASTokenTypeHintRequestResponseKey = @"token_type_hint"; // string
static NSString *_Nonnull const MASTokenTypeRequestResponseKey = @"token_type"; // string
static NSString *_Nonnull const MASPKCECodeVerifierRequestResponseKey = @"code_verifier"; // string
static NSString *_Nonnull const MASPKCECodeVerifierHeaderRequestResponseKey = @"code-verifier"; // string
static NSString *_Nonnull const MASPKCECodeChallengeRequestResponseKey = @"code_challenge"; // string
static NSString *_Nonnull const MASPKCECodeChallengeMethodRequestResponseKey = @"code_challenge_method"; // string
static NSString *_Nonnull const MASPKCEStateRequestResponseKey = @"state"; // string

static NSString *_Nonnull const MASUserAddressRequestResponseKey = @"address"; // string
static NSString *_Nonnull const MASUserAddressCountryRequestResponseKey = @"country"; // string
static NSString *_Nonnull const MASUserAddressLocalityRequestResponseKey = @"locality"; // string
static NSString *_Nonnull const MASUserAddressPostalCodeRequestResponseKey = @"postal_code"; // string
static NSString *_Nonnull const MASUserAddressRegionRequestResponseKey = @"region"; // string
static NSString *_Nonnull const MASUserAddressStreetRequestResponseKey = @"street_address"; // string

static NSString *_Nonnull const MASUserIdRequestResponseKey = @"uid"; // string
static NSString *_Nonnull const MASUserSubRequestResponseKey = @"sub"; // string
static NSString *_Nonnull const MASUserNameRequestResponseKey = @"username"; // string
static NSString *_Nonnull const MASUserPreferredNameRequestResponseKey = @"preferred_username"; // string
static NSString *_Nonnull const MASUserFamilyNameRequestResponseKey = @"family_name"; // string
static NSString *_Nonnull const MASUserGivenNameRequestResponseKey = @"given_name"; // string
static NSString *_Nonnull const MASUserEmailRequestResponseKey = @"email"; // string
static NSString *_Nonnull const MASUserPhoneRequestResponseKey = @"phone_number"; // string
static NSString *_Nonnull const MASUserPictureRequestResponseKey = @"picture"; // string
static NSString *_Nonnull const MASUserRefreshTokenRequestResponseKey = @"refresh_token"; // string


# pragma mark - GrantType Constants

static NSString *_Nonnull const MASGrantTypeAuthorizationCode = @"authorization_code"; // string
static NSString *_Nonnull const MASGrantTypeClientCredentials = @"client_credentials"; // string
static NSString *_Nonnull const MASGrantTypePassword = @"password"; // string
static NSString *_Nonnull const MASGrantTypeRefreshToken = @"refresh_token"; // string


# pragma mark - Exception error code constant

static int const MASExceptionErrorCodeInvalidCertificate = 9999; // integer


///--------------------------------------
/// @name Location Monitoring Constants
///--------------------------------------

# pragma mark - Location Monitoring Constants

/** 
 * A unique identifier that corresponds to a requested location update.
 */
typedef NSInteger MASLocationUpdateId;


/**
 * The enumerated MASLocationMonitoringStatus types.
 *
 * An abstraction of both the horizontal accuracy and how recent the obtained location data.
 * Room is the highest level of accuracy/recency.  City is the lowest level. 
 */
typedef NS_ENUM(NSInteger, MASLocationMonitoringAccuracy)
{
    MASLocationMonitoringAccuracyUnknown = -1,
    
    //
    // 'None' is not valid as a desired accuracy
    //
    
    // Inaccurate (>5000 meters, and/or received >10 minutes ago)
    MASLocationMonitoringAccuracyNone = 0,
    
    //
    // The below options are valid desired accuracies
    //
    
    // 5000 meters or better, and received within the last 10 minutes. Lowest accuracy
    MASLocationMonitoringAccuracyCity,
    
    // 1000 meters or better, and received within the last 5 minutes
    MASLocationMonitoringAccuracyNeighborhood,
    
    // 100 meters or better, and received within the last 1 minute
    MASLocationMonitoringAccuracyBlock,
    
    // 15 meters or better, and received within the last 15 seconds
    MASLocationMonitoringAccuracyHouse,
    
    // 5 meters or better, and received within the last 5 seconds. Highest accuracy
    MASLocationMonitoringAccuracyRoom,
    
    // Convenience to tell how many accuracy type exist
    MASLocationMonitoringAccuracyCount
};


/**
 * The enumerated MASLocationMonitoringStatus types.
 */
typedef NS_ENUM(NSInteger, MASLocationMonitoringStatus)
{
    MASLocationMonitoringStatusUnknown = -1,
    
    //
    // These statuses will accompany a valid location.
    //
    
    // Valid location and desired accuracy level was achieved successfully
    MASLocationMonitoringStatusSuccess,
    
    // Valid a location but the desired accuracy level was not reached before timeout
    // (Not applicable to subscriptions.)
    MASLocationMonitoringStatusTimedOut,
    
    //
    // These statuses indicate some sort of error, and will accompany a nil location.
    //
    
    // User has not yet responded to the dialog that grants this app permission to access location service
    MASLocationMonitoringStatusServicesNotDetermined,
    
    // User has explicitly denied this app permission to access location services
    MASLocationMonitoringStatusServicesDenied,
    
    // User does not have ability to enable location services
    // (e.g. parental controls, corporate policy, etc).
    MASLocationMonitoringStatusServicesRestricted,
    
    // User has turned off location services device-wide from the system Settings app
    MASLocationMonitoringStatusServicesDisabled,
    
    // An error occurred while using the system location services
    MASLocationMonitoringStatusError,
    
    // Convenience to tell how many status types exist
    MASLocationMonitoringStatusCount
};


/**
 * The Location monitor block that will receive a MASLocationMonitoring update when a new location value change is triggered.
 */
typedef void (^MASLocationMonitorBlock)(CLLocation *_Nonnull location, MASLocationMonitoringAccuracy accuracy, MASLocationMonitoringStatus status);


/**
 * The SessionDataTask completion block that will receive the reponse, the response object and/or error if applicable.
 */
typedef void (^MASSessionDataTaskCompletionBlock)(NSURLResponse *_Nonnull response, id _Nonnull responseObject, NSError *_Nonnull error);


/**
 * Void code block.
 */
typedef void (^MASVoidCodeBlock)(void);


//
// MAS Notification - private
//



///--------------------------------------
/// @name Application Notifications
///--------------------------------------

# pragma mark - Application Notifications

/**
 * The NSString constant for the application notification indicating that the MASApplication
 * has begun the process of registering for credentials.
 */
static NSString *_Nonnull const MASApplicationWillRegisterNotification = @"MASApplicationWillRegisterNotification";


/**
 * The NSString constant for the application notification indicating that the MASApplication
 * has failed to successfully register for credentials.
 */
static NSString *_Nonnull const MASApplicationDidFailToRegisterNotification = @"MASApplicationDidFailToRegisterNotification";


/**
 * The NSString constant for the application notification indicating that the MASApplication
 * has successfully registered for credentials.
 */
static NSString *_Nonnull const MASApplicationDidRegisterNotification = @"MASApplicationDidRegisterNotification";

    

///--------------------------------------
/// @name Device Notifications
///--------------------------------------

# pragma mark - Device Notifications

/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has begun the process of registering for credentials.
 */
static NSString *_Nonnull const MASDeviceWillRegisterNotification = @"MASDeviceWillRegisterNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has failed to successfully register for credentials.
 */
static NSString *_Nonnull const MASDeviceDidFailToRegisterNotification = @"MASDeviceDidFailToRegisterNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has successfully registered for credentials.
 */
static NSString *_Nonnull const MASDeviceDidRegisterNotification = @"MASDeviceDidRegisterNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has failed to successfully deregister on the device.
 */
static NSString *_Nonnull const MASDeviceDidFailToDeregisterOnDeviceNotification = @"MASDeviceDidFailToDeregisterOnDeviceNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has successfully deregistered in the cloud.
 */
static NSString *_Nonnull const MASDeviceDidDeregisterInCloudNotification = @"MASDeviceDidDeregisterInCloudNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has successfully deregistered on the device.
 */
static NSString *_Nonnull const MASDeviceDidDeregisterOnDeviceNotification = @"MASDeviceDidDeregisterOnDeviceNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * will renew its signed client certificate as it will expire.
 */
static NSString *_Nonnull const MASDeviceWillRenewClientCerficiateNotification = @"MASDeviceWillRenewClientCerficiateNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * did successfully renew its signed client certificate.
 */
static NSString *_Nonnull const MASDeviceDidRenewClientCertificateNotification = @"MASDeviceDidRenewClientCertificateNotification";


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * did fail to renew its signed client certificate.
 */
static NSString *_Nonnull const MASDeviceDidFailToRenewClientCertificateNotification = @"MASDeviceDidFailToRenewClientCertificateNotification";
