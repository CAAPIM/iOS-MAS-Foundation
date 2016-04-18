//
//  L7SErrors.m
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "L7SErrors.h"
#import "L7SClientManager.h"


NSString * const L7SAuthenticationDomain = @"AuthenticationDomain";
NSString * const L7SRegistrationDomain = @"RegistrationDomain";
NSString * const L7SLocationDomain = @"LocationDomain";
NSString * const L7SNetworkDomain = @"NetworkDomain";
NSString * const L7SJWTValidationDomain = @"JWTValidationDomain";
NSString * const L7SEnterpriseBrowserDomain = @"EnterpriseBrowserDomain";
NSString * const L7SClientCredentialDomain = @"ClientCredentialDomain";
NSString * const L7SBLESessionSharingDomain = @"L7SBLESessionSharingDomain";

NSString* const AuthenticationError = @"Authentication Error";
NSString* const InvalidUsernamePasswordErrorMessage = @"Unable to pass the authentication with given username and password.";
NSString* const InvaidJWTErrorMessage = @"Unable to pass the authentication with JWT.  The JWT may be invalid.";
NSString* const InvaidRefreshTokenErrorMessage = @"The server responds an error to the credential refresh request.";
NSString* const SocialLoginErrorMessage = @"An error occurs during retrieving social login providers.";
NSString* const EnterpriseLoginDisabledErrorMessage = @"EnterpriseLogin is disabled.";
NSString* const QRCodeAuthenticationErrorMessage = @"Failed to authenticate with QR cdoe";
NSString* const QRCodeAuthrorizeErrorMessage = @"QR Authorization URL is invalid";

NSString* const LogoffError = @"Logoff Error";
NSString* const LogoffErrorMessage = @"The app has been already logged off.";
NSString* const LogoffErrorResponseMessage = @"The device has been logged off, however, an error was returned.";


NSString* const LogoutError = @"Device Logout Error";
NSString* const LogoutErrorMessage = @"The device has already been logged out";
NSString* const LogoutErrorResponseMessage = @"The device has been logged out, however, an error was returned.";

NSString* const LocationError = @"Requires location";
NSString* const LocationErrorMessage = @"This application requires your location information. Please enable location services to continue.";

NSString* const LocationUnauthorizedError = @"Location unauthorized";
NSString* const LocationErrorUnauthorizedMessage = @"This location is unauthorized.";

NSString* const RegistrationError = @"Registration Error";
NSString* const RegistrationErrorResponseMessage = @"The device is not registered properly due to an error response from the server.  Please contact administrator to resolve the issue.";


NSString* const DeRegistrationError = @"Device De-registration Error";
NSString* const DeRegistrationErrorMessage = @"The device has already been de-registered";
NSString* const DeRegistrationErrorResponseMessage = @"The device has been de-registered, however, an error was returned.";


NSString* const NetworkError = @"Network Error";
NSString* const NetworkUnavailableMessage = @"Network is not available";


NSString* const JWTValidationError = @"Invalid JWT";
NSString* const JWTSignatureNotMatchErrorMessage = @"The signature does not match"; //-701
NSString* const JWTAUDNotMatchErrorMessage = @"The aud doesn't match"; //-702
NSString* const JWTAZPNotMatchErrorMessage = @"The azp doesn't match"; //-703
NSString* const JWTExpiredErrorMessage = @"The JWT is expired"; //-704
NSString* const JWTInvalidFormatErrorMessage = @"JWT format is invalid"; //-705



NSString* const EnterpriseBrowserError = @"Enterprise Error";
NSString* const EnterpriseBrowserInvalidJSONMessage = @"Invalid JSON object";
NSString* const EnterrpiseBrowserAppNotExistMessage = @"App does not exist";
NSString* const EnterrpiseBrowserInvalidURLErrorMessage = @"Invalid webapp auth url";
NSString* const EnterrpiseBrowserNativeAppNotExistMessage = @"Native app does not exist";

NSString* const ClientCredentialError = @"Client Credential Error";
NSString* const DynamicClientCredentialErrorMessage = @"Error during updating client credential";


@implementation L7SErrors


+ (void)errorWithDomain:(NSString *)domain
    code:(L7SError)errorCode
    reason:(NSString *)reason
    description:(NSString *)description
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    [userInfo setValue:reason forKey:NSLocalizedFailureReasonErrorKey];
    [userInfo setValue:description forKey:NSLocalizedDescriptionKey];
    
    //
    // Create the error
    //
    NSError *error = [NSError errorWithDomain:domain code:errorCode userInfo:userInfo];
    
    //
    // Notify
    //
    if([[L7SClientManager delegate] respondsToSelector:@selector(DidReceiveError:)])
    {
        [[L7SClientManager delegate] DidReceiveError:error];
    }
}


+ (void)errorWithError:(NSError *)error
{
    //
    // Notify
    //
    if([[L7SClientManager delegate] respondsToSelector:@selector(DidReceiveError:)])
    {
        [[L7SClientManager delegate] DidReceiveError:error];
    }
}


+ (void)errorWithError:(NSError *)error
    domain:(NSString *)domain
    code:(L7SError)errorCode
    reason:(NSString *)reason
    description:(NSString *)description
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    // Error Reason
    [userInfo setValue:reason forKey:NSLocalizedFailureReasonErrorKey];
    
    // Error detail if no error passed
    if(error == nil)
    {
        [userInfo setValue:description forKey:NSLocalizedDescriptionKey];
    }
    
    //
    // Http level error
    //
    else
    {
        [userInfo setValue:[error localizedDescription] forKey:NSLocalizedDescriptionKey];
    }
    
    //
    // Create the error
    //
    [NSError errorWithDomain:domain code:errorCode userInfo:userInfo];

    //
    // Notify
    //
    if([[L7SClientManager delegate] respondsToSelector:@selector(DidReceiveError:)])
    {
        [[L7SClientManager delegate] DidReceiveError:error];
    }
}


+ (void)errorWithUserInfo:(NSMutableDictionary *)userInfo
    domain:(NSString *)domain
    code:(L7SError)errorCode
    reason:(NSString *)reason
    description:(NSString *)description
{
    //
    // UserInfo
    //
    [userInfo setValue:reason forKey:NSLocalizedFailureReasonErrorKey];
    [userInfo setValue:description forKey:NSLocalizedDescriptionKey];

    //
    // Create the error
    //
    NSError *error = [NSError errorWithDomain:domain code:errorCode userInfo:userInfo];
    
    //
    // Notify
    //
    if([[L7SClientManager delegate] respondsToSelector:@selector(DidReceiveError:)])
    {
        [[L7SClientManager delegate] DidReceiveError:error];
    }
}

@end
