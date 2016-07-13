//
//  L7SErrors.h
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;


typedef enum
{
    //Error code for authentication domain
    L7SAuthenticationLoginError = -101,
    L7SAuthenticationJWTError = -102,
    L7SAuthenticationRefreshError = -103,
    L7SAuthenticationLogoutError = -104,
    L7SAuthenticationLogoffError = -105,
    L7SSocialLoginError = -106,
    L7SQRCodeAuthenticationError = -107,
    L7SQRCodeAuthorizationError = -108,

    
    //Error code for registration domain
    L7SRegistrationError = -201,
    L7SDeRegistrationError = -202,
    
    //Error code for location domain
    L7SLocationError = -301,
    L7SLocationUnauthorizedError = -302,
    
    //Error code for network
    L7SNetworkError = -401,
    
    //HTTPCall error
    L7SHTTPCallError = -501,
    
    //JWT validation errors
    L7SJWTSignatureNotMatch = -701,
    L7SJWTAUDNotMatch = -702,
    L7SJWTAZPNotMatch = -703,
    L7SJWTExpired = -704,
    L7SJWTInvalidFormat = -705,
    
    //Enterprise browser error
    L7SEnterpriseBrowserInvalidJSON = -801,
    L7SEnterrpiseBrowserNativeAppNotExist = -802,
    L7SEnterrpiseBrowserInvalidURLError = -803,
    L7SEnterrpiseBrowserAppNotExist = -804,
    
    //Dynamic client credential error
    L7SDynamicClientCredentialError = -901

} L7SError DEPRECATED_ATTRIBUTE;


typedef enum
{
    //error codes for both Central and Peripheral devices
    
    //reason: Unkown error
    //detailed message:  Unknown error.
    L7SBLESessionSharingErrorUnknown = 10,
    
    //reason: Bluetooth connection lost
    //detailed message: The connection with the system service was momentarily lost, update imminent.
    L7SBLESessionSharingErrorConnectionLost = 11,
    
    //reason: Bluetooth powered off
    //detailed message: Bluetooth is currently powered off.
    L7SBLESessionSharingErrorPoweroff = 12,
    
    //reason: Invalid UUID
    //detailed message: Invalid UUID, either it is not the correct format or empty.
    L7SBLESessionSharingErrorInvalidUUID = 13,
    
    //error codes for Central device
    
    //reason: Central role not supported
    //detailed message: The platform doesn't support the Bluetooth Low Energy Central/Client role.
    L7SBLESessionSharingErrorCentralUnsupported = 20,
    
    //reason: Central role unauthorized
    //detailed message: The application is not authorized to use the Bluetooth Low Energy Central/Client role.
    L7SBLESessionSharingErrorCentralUnauthorized = 21,
    
    //reason: Invalid sessionID or URL format
    //detailed message: Session ID or poll URL cannot be empty.
    L7SBLESessionSharingErrorInvalidSessionIDOrPollURL = 22,
    
    
    //reason: Failed to poll auth_code
    //detailed message: BLE authentication failed due to failure to poll auth_code
    L7SBLESessionSharingErrorAuthenticationFailurePollingAuthCode = 23,
    
    
    //error codes for Peripheral device
    
    //reason: Peripheral role not supported
    //detailed message: The platform doesn't support the Bluetooth Low Energy Periperhal/Server role.
    L7SBLESessionSharingErrorPeripheralUnsupported = 30,
    

    //reason: Peripheral role unauthorized
    //detailed message: The application is not authorized to use the Bluetooth Low Energy Peripheral/Server role.
    L7SBLESessionSharingErrorPeripheralUnauthorized = 31,
    

    //reason: Invalid or expired session
    //detailed message: BLE authorization failed due to invalid or expired sesssion ID.
    L7SBLESessionSharingErrorAuthorizationFailed = 32,
    
    //reason: Central not subscribed
    //detailed message: LE authorization failed due to no central device subscribed.
    L7SBLESessionSharingErrorAuthorizationCentralUnsubscribed = 33
    
} L7SBLESessionSharingError DEPRECATED_ATTRIBUTE;


extern NSString* const L7SAuthenticationDomain;
extern NSString* const L7SRegistrationDomain;
extern NSString* const L7SLocationDomain;
extern NSString* const L7SNetworkDomain;
extern NSString* const L7SJWTValidationDomain;
extern NSString* const L7SEnterpriseBrowserDomain;
extern NSString* const L7SClientCredentialDomain;
extern NSString* const L7SBLESessionSharingDomain;

//Authentication Error
extern NSString* const AuthenticationError;
extern NSString* const InvalidUsernamePasswordErrorMessage;
extern NSString* const InvaidJWTErrorMessage;
extern NSString* const InvaidRefreshTokenErrorMessage;
extern NSString* const SocialLoginErrorMessage;
extern NSString* const EnterpriseLoginDisabledErrorMessage;
extern NSString* const QRCodeAuthenticationErrorMessage;
extern NSString* const QRCodeAuthrorizeErrorMessage;

//Logoff Error
extern NSString* const LogoffError;
extern NSString* const LogoffErrorMessage;
extern NSString* const LogoffErrorResponseMessage;

//Logout Error
extern NSString* const LogoutError;
extern NSString* const LogoutErrorMessage;
extern NSString* const LogoutErrorResponseMessage;

//Location Error
extern NSString* const LocationError;
extern NSString* const LocationUnauthorizedError;
extern NSString* const LocationErrorMessage;
extern NSString* const LocationErrorUnauthorizedMessage;


//Registration Error
extern NSString* const RegistrationError;
extern NSString* const RegistrationErrorResponseMessage;


//De-Registration Error
extern NSString* const DeRegistrationError;
extern NSString* const DeRegistrationErrorMessage;
extern NSString* const DeRegistrationErrorResponseMessage;


//Network Error
extern NSString* const NetworkError;
extern NSString* const NetworkUnavailableMessage;

//JWT validation errors
extern NSString* const JWTValidationError;
extern NSString* const JWTSignatureNotMatchErrorMessage; //-701
extern NSString* const JWTAUDNotMatchErrorMessage; //-702
extern NSString* const JWTAZPNotMatchErrorMessage; //-703
extern NSString* const JWTExpiredErrorMessage; //-704
extern NSString* const JWTInvalidFormatErrorMessage; //-705

//Eneterprise Browser Error
extern NSString* const EnterpriseBrowserError;
extern NSString* const EnterpriseBrowserInvalidJSONMessage;
extern NSString* const EnterrpiseBrowserNativeAppNotExistMessage;
extern NSString* const EnterrpiseBrowserAppNotExistMessage;
extern NSString* const EnterrpiseBrowserInvalidURLErrorMessage;

//Client credential error
extern NSString* const ClientCredentialError;
extern NSString* const DynamicClientCredentialErrorMessage;

DEPRECATED_ATTRIBUTE
@interface L7SErrors : NSObject 

+ (void)errorWithDomain:(NSString *)domain
    code:(L7SError)errorCode
    reason:(NSString *)reason
    description:(NSString *)description DEPRECATED_ATTRIBUTE;

+ (void)errorWithError:(NSError *)error DEPRECATED_ATTRIBUTE;

+ (void)errorWithError:(NSError *)error
    domain:(NSString *)
    domain code:(L7SError)errorCode
    reason:(NSString *)reason
    description:(NSString *)description DEPRECATED_ATTRIBUTE;

+ (void)errorWithUserInfo:(NSMutableDictionary *)userInfo
    domain:(NSString *)domain
    code:(L7SError)errorCode
    reason:(NSString *)reason
    description:(NSString *)description DEPRECATED_ATTRIBUTE;

@end
