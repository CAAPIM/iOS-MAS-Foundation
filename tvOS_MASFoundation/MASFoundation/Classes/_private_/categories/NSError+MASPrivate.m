//
//  NSError+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "NSError+MASPrivate.h"


/**
 * The enumerated error codes for API level NSErrors.
 */
typedef NS_ENUM(NSInteger, MASApiErrorCode)
{
    MASApiErrorCodeUnknown = -1,
    
    // Register Device
    MASApiErrorCodeRegisterDeviceRequestInvalid = 1000000,
    MASApiErrorCodeRegisterDeviceCertificateInvalid = 1000101,
    MASApiErrorCodeRegisterDeviceCertificateFormatUnsupported = 1000102,
    MASApiErrorCodeRegisterDeviceHeadersOrParametersInvalid = 1000103,
    MASApiErrorCodeRegisterDeviceCRSInvalid = 1000104,
    MASApiErrorCodeRegisterDeviceAlreadyRegistered = 1000105,
    MASApiErrorCodeRegisterDeviceAlreadyRegistered2 = 1007105,
    MASApiErrorCodeRegisterDeviceGrantInvalid = 1000113,
    MASApiErrorCodeRegisterDeviceClientCredentialsInvalid = 1000201,
    MASApiErrorCodeRegisterDeviceUserCredentialsInvalid = 1000202,
    
    // Remove Device
    MASApiErrorCodeRemoveDeviceRequestInvalid = 1001000,
    MASApiErrorCodeRemoveDeviceMagIdentifierMissingOrUnknown = 1001101,
    MASApiErrorCodeRemoveDeviceMagIdentifierInvalid = 1001103,
    MASApiErrorCodeRemoveDeviceMagIdentifierInvalid2 = 1001107,
    MASApiErrorCodeRemoveDeviceTokenInvalid = 1001106,
    MASApiErrorCodeRemoveDeviceClientCredentialsInvalid = 1001201,
    
    // Request Client Credentials
    MASApiErrorCodeRequestClientCredentialsServerError = 1002000,
    MASApiErrorCodeRequestClientCredentialsHeadersOrParametersInvalid = 1002103,
    MASApiErrorCodeRequestClientCredentialsMagIdentifierInvalid = 1002107,
    MASApiErrorCodeRequestClientCredentialsDeviceIsNotActive = 1002108,
    MASApiErrorCodeRequestClientCredentialsClientIdIsNotMasterKey = 1002109,
    MASApiErrorCodeRequestClientCredentialsClientCrenditalsInvalid = 1002201,
    MASApiErrorCodeRequestClientCredentialsUrlPrefixInvalid = 1002203,
   
    // Request Authorization Init
    MASApiErrorCodeRequestAuthorizationInitServerError = 3000000,
    MASApiErrorCodeRequestAuthorizationInitParametersInvalid = 3000103,
    MASApiErrorCodeRequestAuthorizationInitMagIdentifierInvalid = 3000107,
    MASApiErrorCodeRequestAuthorizationInitDeviceIsNotActive = 3000108,
    MASApiErrorCodeRequestAuthorizationInitRedirectUriInvalid = 3000114,
    MASApiErrorCodeRequestAuthorizationInitScopeInvalid = 3000115,
    MASApiErrorCodeRequestAuthorizationInitResponseTypeInvalid = 3000116,
    MASApiErrorCodeRequestAuthorizationInitClientTypeInvalid = 3000117,
    MASApiErrorCodeRequestAuthorizationInitNoRedirectUri = 3000130,
    MASApiErrorCodeRequestAuthorizationInitClientCredentialsInvalid = 3000201,
    MASApiErrorCodeRequestAuthorizationInitUrlPrefixInvalid = 3000203,
    
    // Request Authorization Login
    MASApiErrorCodeRequestAuthorizationLoginServerError = 3001000,
    MASApiErrorCodeRequestAuthorizationLoginParametersInvalid = 3001103,
    MASApiErrorCodeRequestAuthorizationLoginSessionInvalid = 3001110,
    MASApiErrorCodeRequestAuthorizationLoginRedirectUrlInvalid = 3001114,
    MASApiErrorCodeRequestAuthorizationLoginAuthenticationDenied = 3001123,
    MASApiErrorCodeRequestAuthorizationLoginUserCredentialsInvalid = 3001202,
    MASApiErrorCodeRequestAuthorizationLoginUrlPrefixInvalid = 3001203,
    
    // Request Authorization Login
    MASApiErrorCodeRequestAuthorizationConsentServerError = 3002000,
    MASApiErrorCodeRequestAuthorizationConsentParametersInvalid = 3002103,
    MASApiErrorCodeRequestAuthorizationConsentSessionInvalid = 3002110,
    MASApiErrorCodeRequestAuthorizationConsentAuthorizationDenied = 3002124,
    MASApiErrorCodeRequestAuthorizationConsentUrlPrefixInvalid = 3002203,
    
    // Request Token
    MASApiErrorCodeRequestTokenServerError = 3003000,
    MASApiErrorCodeRequestTokenMagIdentifierInvalid = 3003101,
    MASApiErrorCodeRequestTokenMissingOrDuplicateParameters = 3003103,
    MASApiErrorCodeRequestTokenMagIdentifierInvalid2 = 3003107,
    MASApiErrorCodeRequestTokenGrantInvalid = 3003113,
    MASApiErrorCodeRequestTokenClientHasNoRegisteredScopeRequested = 3003115,
    MASApiErrorCodeRequestTokenClientIsNotAuthorizedForRequest = 3003117,
    MASApiErrorCodeRequestTokenGrantTypeIsNotSupported = 3003119,
    MASApiErrorCodeRequestTokenClientCredentialsInvalid = 3003201,
    MASApiErrorCodeRequestTokenResourceOwnerCredentialsInvalid = 3003302,
    MASApiErrorCodeRequestTokenResourceOwnerCredentialsInvalid2 = 3003202,
    MASApiErrorCodeRequestTokenPrefixIsInvalid = 3003203,
    MASApiErrorCodeRequestTokenTokenDisabled = 3003993,
    
    // Revoke Token
    MASApiErrorCodeRevokeTokenServerError = 3004000,
    MASApiErrorCodeRevokeTokenClientIsNotAuthorizedForRequest = 3004117,
    MASApiErrorCodeRevokeTokenUnsupportedType = 3004118,
    MASApiErrorCodeRevokeTokenClientCredentialsInvalid = 3004201,
    MASApiErrorCodeRevokeAuthorizationConsentUrlPrefixInvalid = 3004203,
    
    MASApiErrorCodeTokenNotGrantedForScopeSuffix = 991,
    MASApiErrorCodeTokenInvalidAccessTokenSuffix = 992,
    MASApiErrorCodeTokenDisabledSuffix = 993,
    
    // OTP
    MASApiErrorCodeOTPExpired = 8000143,
    MASApiErrorCodeOTPRetryLimitExceeded = 8000144,
    MASApiErrorCodeOTPRetryBarred = 8000145,
    
    MASApiErrorCodeCount
};


/**
 * The enumerated error codes for Url level NSErrors.
 */
typedef NS_ENUM(NSInteger, MASUrlErrorCode)
{
    MASUrliErrorCodeUnknown = -1,
    
    // Geo-location
    MASUrlErrorCodeGeolocationIsInvalid = 448,
    MASUrlErrorCodeGeolocationIsMissing = 449,
    
    // Network
    MASUrlErrorCodeNetworkRequestTimedOut = -1001,
    MASUrlErrorCodeNetworkHostnameNotFound = -1003,
    MASUrlErrorCodeNetworkFailedToConnect = -1004,
    MASUrlErrorCodeNetworkIsOffline = -1009,
    MASUrlErrorCodeNetworkUnacceptableContentType = -1016,
    MASUrlErrorCodeNetworkUnacceptableContentType2 = -1011,
    MASUrlErrorCodeSSLConnectionCannotBeMade = -1200,
    
    MASUrlErrorCodeResponseSerializeFailedToParseResponse = 3840,

    MASUrlErrorCodeCount
};



@implementation NSError (MASPrivate)


# pragma mark - Create general errors

+ (NSError *)errorFromApiResponseInfo:(NSDictionary *)responseInfo andError:(NSError *)error
{
    //
    //  ErrorDomain will most likely be MASFoundation as it's coming from the server.
    //
    NSString *errorDomain = MASFoundationErrorDomain;
    
    //
    // If this is already a MASFoundation defined error just return it and stop here
    //
    if([error.domain isEqualToString:MASFoundationErrorDomain] ||
       [error.domain isEqualToString:MASFoundationErrorDomainLocal] ||
       [error.domain isEqualToString:MASFoundationErrorDomainTargetAPI])
    {
        return error;
    }
    
    //
    // Retrieve the response header
    //
    NSDictionary *headerInfo = responseInfo[MASResponseInfoHeaderInfoKey];
    
    //
    //  If the error code is know local error code and header info does not contain x-ca-err code, change the error domain
    //
    if ([self foundationErrorCodeForError:error] != MASFoundationErrorCodeUnknown && !headerInfo[MASHeaderInfoErrorKey])
    {
        errorDomain = MASFoundationErrorDomainLocal;
    }

    return [self errorForFoundationWithResponseInfo:responseInfo error:error errorDomain:errorDomain];
}


+ (NSError *)errorForFoundationWithResponseInfo:(NSDictionary *)responseInfo error:(NSError *)error errorDomain:(NSString *)errorDomain
{
    //
    // Retrieve the response header
    //
    NSDictionary *headerInfo = responseInfo[MASResponseInfoHeaderInfoKey];
    
    //
    // Retrieve the response body
    //
    NSDictionary *bodyInfo = responseInfo[MASResponseInfoBodyInfoKey];
    
    NSNumber *apiErrorCodeNumber = headerInfo[MASHeaderInfoErrorKey];
    
    
    //
    //  Special handling for error code suffix
    //  API error code containing special suffix for handling access_token
    //
    NSString *apiErrorCodeString = [[NSString stringWithFormat:@"%@", apiErrorCodeNumber] substringWithRange:NSMakeRange([[NSString stringWithFormat:@"%@", apiErrorCodeNumber] length] - 3, 3)];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *apiThreeDigitNumber = [formatter numberFromString:apiErrorCodeString];
    
    //
    //  If error code has recognized suffix, just use the suffix for the error code
    //
    if ([apiThreeDigitNumber integerValue] == MASApiErrorCodeTokenNotGrantedForScopeSuffix ||
        [apiThreeDigitNumber integerValue] == MASApiErrorCodeTokenDisabledSuffix ||
        [apiThreeDigitNumber integerValue] == MASApiErrorCodeTokenInvalidAccessTokenSuffix)
    {
        apiErrorCodeNumber = apiThreeDigitNumber;
    }
    
    
    //
    // Attempt to find a matching API code value
    //
    MASFoundationErrorCode foundationErrorCode = [self foundationErrorCodeForApiCode:[apiErrorCodeNumber intValue]];
    
    //
    // If none found then attempt to find it in the error itself and x-ca-err code is not defined.  This would not be an API specific error but
    // possibly a lower level network error
    //
    if(foundationErrorCode == MASFoundationErrorCodeUnknown && !apiErrorCodeNumber)
    {
        foundationErrorCode = [self foundationErrorCodeForError:error];
    }
    
    //
    // Standard error key/values
    //
    NSMutableDictionary *errorInfo = [NSMutableDictionary new];
    
    //
    //  http status code
    //
    if ([[error.userInfo allKeys] containsObject:MASErrorStatusCodeRequestResponseKey])
    {
        [errorInfo setObject:[error.userInfo objectForKey:MASErrorStatusCodeRequestResponseKey] forKey:MASErrorStatusCodeRequestResponseKey];
    }
    
    //
    //  Add http response body
    //
    if (bodyInfo)
    {
        [errorInfo setObject:bodyInfo forKey:MASResponseInfoBodyInfoKey];
    }
    
    //
    //  Add http response header
    //
    if (headerInfo)
    {
        [errorInfo setObject:headerInfo forKey:MASResponseInfoHeaderInfoKey];
    }
    
    //
    //  If the errorCode was not found in client side translation and the server returned the error info, use the one from the server
    //
    if (foundationErrorCode == MASFoundationErrorCodeUnknown && ([bodyInfo isKindOfClass:[NSDictionary class]] && [[bodyInfo allKeys] containsObject:MASErrorRequestResponseKey] && [[bodyInfo allKeys] containsObject:MASErrorDescriptionRequestResponseKey]))
    {
        NSString *errorTitle = [bodyInfo objectForKey:MASErrorRequestResponseKey];
        NSString *errorDescription = [bodyInfo objectForKey:MASErrorDescriptionRequestResponseKey];
        
        NSString *localizedErrorDescription = nil;
        
        if (errorTitle)
        {
            localizedErrorDescription = errorTitle;
        }
        
        if (errorDescription)
        {
            localizedErrorDescription = localizedErrorDescription ? [NSString stringWithFormat:@"%@: %@",localizedErrorDescription, errorDescription] : errorDescription;
        }
        
        if (!localizedErrorDescription)
        {
            localizedErrorDescription = [error localizedDescription];
        }
        
        errorInfo[NSLocalizedDescriptionKey] = localizedErrorDescription;
    }
    //
    //  If the errorCode was found in client side translation and the client side translation is available, use the client side translation
    //
    else if (foundationErrorCode != MASFoundationErrorCodeUnknown){
        errorInfo[NSLocalizedDescriptionKey] = [self descriptionForFoundationErrorCode:foundationErrorCode];
    }
    //
    //  If nothing was found, just use the default localized error description
    //
    else {
        errorInfo[NSLocalizedDescriptionKey] = [error localizedDescription];
    }
    
    //
    //  If the API error code is defined, use the API defined error code; otherwise, use the original error code
    //
    NSInteger errorCode = [apiErrorCodeNumber integerValue] ? [apiErrorCodeNumber integerValue] : [error code];
    
    //
    //  Create an error with the error code from the server
    //
    return [NSError errorWithDomain:errorDomain code:errorCode userInfo:errorInfo];
}


+ (NSError *)errorForFoundationCode:(MASFoundationErrorCode)errorCode errorDomain:(NSString *)errorDomain
{
    return [self errorForFoundationCode:errorCode info:nil errorDomain:errorDomain];
}


+ (NSError *)errorForFoundationCode:(MASFoundationErrorCode)errorCode info:(NSDictionary *)info errorDomain:(NSString *)errorDomain
{
    //
    // Standard error key/values
    //
    NSMutableDictionary *errorInfo = [NSMutableDictionary new];
    if(![info objectForKey:NSLocalizedDescriptionKey])
    {
        errorInfo[NSLocalizedDescriptionKey] = [self descriptionForFoundationErrorCode:errorCode];
    }
    
    [errorInfo addEntriesFromDictionary:info];
    
    return [NSError errorWithDomain:errorDomain
                               code:errorCode
                           userInfo:errorInfo];
}


# pragma mark - Create specific error types

+ (NSError *)errorInvalidUserLoginBlock
{
    return [self errorForFoundationCode:MASFoundationErrorCodeInvalidUserLoginBlock errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidNSURL
{
    return [self errorForFoundationCode:MASFoundationErrorCodeInvalidNSURL errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidOTPChannelSelectionBlock
{
    return [self errorForFoundationCode:MASFoundationErrorCodeInvalidOTPChannelSelectionBlock errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidOTPCredentialsBlock
{
    return [self errorForFoundationCode:MASFoundationErrorCodeInvalidOTPCredentialsBlock errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorOTPCredentialsNotProvided
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *localDescription =
    [self descriptionForFoundationErrorCode:MASFoundationErrorCodeOTPNotProvided];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeOTPNotProvided info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidOTPCredentials
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *localDescription =
    [self descriptionForFoundationErrorCode:MASFoundationErrorCodeInvalidOTPProvided];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeInvalidOTPProvided info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorOTPCredentialsExpired
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *localDescription =
    [self descriptionForFoundationErrorCode:MASFoundationErrorCodeOTPExpired];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeOTPExpired info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorOTPRetryLimitExceeded:(NSString *)suspensionTime
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *localDescription =
    [self descriptionForFoundationErrorCode:MASFoundationErrorCodeOTPRetryLimitExceeded];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    //
    // Suspension time
    //
    if(suspensionTime) userInfo[MASOTPSuspensionTimeKey] = suspensionTime;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeOTPRetryLimitExceeded info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorOTPRetryBarred:(NSString *)suspensionTime
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *localDescription =
    [self descriptionForFoundationErrorCode:MASFoundationErrorCodeOTPRetryBarred];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    //
    // Suspension time
    //
    if(suspensionTime) userInfo[MASOTPSuspensionTimeKey] = suspensionTime;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeOTPRetryBarred info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidNSDictionary
{
    return [self errorForFoundationCode:MASFoundationErrorCodeInvalidNSDictionary errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorApplicationAlreadyRegistered
{
    return [self errorForFoundationCode:MASFoundationErrorCodeApplicationAlreadyRegistered errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorApplicationNotRegistered
{
    return [self errorForFoundationCode:MASFoundationErrorCodeApplicationNotRegistered errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorApplicationRedirectUriInvalid
{
    return [self errorForFoundationCode:MASFoundationErrorCodeApplicationRedirectUriInvalid errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorConfigurationLoadingFailedFileNotFound:(NSString *)fileName
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *format = [self descriptionForFoundationErrorCode:MASFoundationErrorCodeConfigurationLoadingFailedFileNotFound];
    NSString *localDescription = [NSString stringWithFormat:format, fileName];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    //
    // FileName
    //
    if(fileName) userInfo[MASFileNameKey] = fileName;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeConfigurationLoadingFailedFileNotFound info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorConfigurationLoadingFailedJsonSerialization:(NSString *)fileName description:(NSString *)description
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *format = [self descriptionForFoundationErrorCode:MASFoundationErrorCodeConfigurationLoadingFailedJsonSerialization];
    NSString *localDescription = [NSString stringWithFormat:format, fileName, description];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    //
    // FileName
    //
    if(fileName) userInfo[MASFileNameKey] = fileName;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeConfigurationLoadingFailedJsonSerialization info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorConfigurationLoadingFailedJsonValidationWithDescription:(NSString *)description
{
    //
    // UserInfo
    //
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    //
    // Description
    //
    NSString *format = [self descriptionForFoundationErrorCode:MASFoundationErrorCodeConfigurationLoadingFailedJsonValidation];
    NSString *localDescription = [NSString stringWithFormat:format, description];
    
    userInfo[NSLocalizedDescriptionKey] = localDescription;
    
    return [self errorForFoundationCode:MASFoundationErrorCodeConfigurationLoadingFailedJsonValidation info:userInfo errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceAlreadyRegistered
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceAlreadyRegistered errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceAlreadyRegisteredWithDifferentFlow
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceAlreadyRegisteredWithDifferentFlow errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceCouldNotBeDeregistered
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceCouldNotBeDeregistered errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceNotRegistered
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceNotRegistered errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceNotLoggedIn
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceNotLoggedIn errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceRegistrationAttemptedWithUnregisteredScope
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceRegistrationAttemptedWithUnregisteredScope errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceRegistrationWithoutRequiredParameters
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceRegistrationWithoutRequiredParameters errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorDeviceDoesNotSupportLocalAuthentication
{
    return [self errorForFoundationCode:MASFoundationErrorCodeDeviceDoesNotSupportLocalAuthentication errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorFlowIsNotActive
{
    return [self errorForFoundationCode:MASFoundationErrorCodeFlowIsNotActive errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorFlowIsNotImplemented
{
    return [self errorForFoundationCode:MASFoundationErrorCodeFlowIsNotImplemented errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorFlowTypeUnsupported
{
    return [self errorForFoundationCode:MASFoundationErrorCodeFlowTypeUnsupported errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorGeolocationIsInvalid
{
    return [self errorForFoundationCode:MASFoundationErrorCodeGeolocationIsInvalid errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorGeolocationIsMissing
{
    return [self errorForFoundationCode:MASFoundationErrorCodeGeolocationIsMissing errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorGeolocationServicesAreUnauthorized
{
    return [self errorForFoundationCode:MASFoundationErrorCodeGeolocationServicesAreUnauthorized errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorGeolocationServiceIsNotConfigured
{
    return [self errorForFoundationCode:MASFoundationErrorCodeGeolocationIsNotConfigured errorDomain:MASFoundationErrorDomainLocal];
}

+ (NSError *)errorMASIsNotStarted
{
    return [self errorForFoundationCode:MASFoundationErrorCodeMASIsNotStarted errorDomain:MASFoundationErrorDomainLocal];
}

+ (NSError *)errorNetworkNotReachable
{
    return [self errorForFoundationCode:MASFoundationErrorCodeNetworkNotReachable errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorNetworkNotStarted
{
    return [self errorForFoundationCode:MASFoundationErrorCodeNetworkNotStarted errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidAuthorization
{
    return [self errorForFoundationCode:MASFoundationErrorCodeInvalidAuthorization errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorUserAlreadyAuthenticated
{
    return [self errorForFoundationCode:MASFoundationErrorCodeUserAlreadyAuthenticated errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorUserBasicCredentialsNotValid
{
    return [self errorForFoundationCode:MASFoundationErrorCodeUserBasicCredentialsNotValid errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorUserDoesNotExist
{
    return [self errorForFoundationCode:MASFoundationErrorCodeUserDoesNotExist errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorUserNotAuthenticated
{
    return [self errorForFoundationCode:MASFoundationErrorCodeUserNotAuthenticated errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorLoginProcessCancelled
{
    return [self errorForFoundationCode:MASFoundationErrorCodeLoginProcessCancel errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorOTPChannelSelectionCancelled
{
    return [self errorForFoundationCode:MASFoundationErrorCodeOTPChannelSelectionCancelled errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorOTPAuthenticationCancelled
{
    return [self errorForFoundationCode:MASFoundationErrorCodeOTPAuthenticationCancelled errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorUserSessionIsAlreadyLocked
{
    return [self errorForFoundationCode:MASFoundationErrorCodeUserSessionIsAlreadyLocked errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorUserSessionIsAlreadyUnlocked
{
    return [self errorForFoundationCode:MASFoundationErrorCodeUserSessionIsAlreadyUnlocked errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorUserSessionIsCurrentlyLocked
{
    return [self errorForFoundationCode:MASFoundationErrorCodeUserSessionIsCurrentlyLocked errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidIdToken
{
    return [self errorForFoundationCode:MASFoundationErrorCodeTokenInvalidIdToken errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorIdTokenExpired
{
    return [self errorForFoundationCode:MASFoundationErrorCodeTokenIdTokenExpired errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorIdTokenInvalidSignature
{
    return [self errorForFoundationCode:MASFoundationErrorCodeTokenIdTokenInvalidSignature errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorIdTokenInvalidAzp
{
    return [self errorForFoundationCode:MASFoundationErrorCodeTokenIdTokenInvalidAzp errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorIdTokenInvalidAud
{
    return [self errorForFoundationCode:MASFoundationErrorCodeTokenIdTokenInvalidAud errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorIdTokenNotExistForLockingUserSession
{
    return [self errorForFoundationCode:MASFoundationErrorCodeTokenIdTokenNotExistForLockingUserSession errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorEnterpriseBrowserWebAppInvalidURL
{
    return [self errorForFoundationCode:MASFoundationErrorCodeEnterpriseBrowserWebAppInvalidURL errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorEnterpriseBrowserNativeAppDoesNotExist
{
    return [self errorForFoundationCode:MASFoundationErrorCodeEnterpriseBrowserNativeAppDoesNotExist errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorEnterpriseBrowserNativeAppCannotOpen
{
    return [self errorForFoundationCode:MASFoundationErrorCodeEnterpriseBrowserNativeAppCannotOpen errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorEnterpriseBrowserAppDoesNotExist
{
    return [self errorForFoundationCode:MASFoundationErrorCodeEnterpriseBrowserAppDoesNotExist errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorInvalidEndpoint
{
    return [self errorForFoundationCode:MASFoundationErrorCodeConfigurationInvalidEndpoint errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorProximityLoginAuthorizationInProgress
{
    return [self errorForFoundationCode:MASFoundationErrorCodeProximityLoginAuthorizationInProgress errorDomain:MASFoundationErrorDomainLocal];
}


+ (NSError *)errorProximityLoginInvalidAuthroizeURL
{
    return [self errorForFoundationCode:MASFoundationErrorCodeProximityLoginInvalidAuthorizeURL errorDomain:MASFoundationErrorDomainLocal];
}


# pragma mark - Foundation Errors Private

+ (MASFoundationErrorCode)foundationErrorCodeForApiCode:(MASApiErrorCode)apiCode
{
    //
    // Detect code and respond appropriately
    //
    switch(apiCode)
    {
            
        //
        // ClientId / ClientSecret
        //
        case MASApiErrorCodeRequestAuthorizationInitClientCredentialsInvalid: return MASFoundationErrorCodeApplicationInvalid;
            
        //
        // MAG Identifier
        //
        case MASApiErrorCodeRequestClientCredentialsMagIdentifierInvalid: return MASFoundationErrorCodeApplicationInvalidMagIdentifer;
        
        case MASApiErrorCodeRemoveDeviceMagIdentifierMissingOrUnknown:
        case MASApiErrorCodeRemoveDeviceMagIdentifierInvalid:
        case MASApiErrorCodeRemoveDeviceMagIdentifierInvalid2: return MASFoundationErrorCodeDeviceCouldNotBeDeregistered;
        
        //
        // Device is already registered
        //
        case MASApiErrorCodeRegisterDeviceAlreadyRegistered:
        case MASApiErrorCodeRegisterDeviceAlreadyRegistered2: return MASFoundationErrorCodeDeviceAlreadyRegistered;
        
        //
        // Device record is not valid
        //
        case MASApiErrorCodeRequestTokenMagIdentifierInvalid:
        case MASApiErrorCodeRequestTokenMagIdentifierInvalid2: return MASFoundationErrorCodeDeviceRecordIsNotValid;
        
        //
        // Basic user credentials missing or invalid
        //
        case MASApiErrorCodeRegisterDeviceUserCredentialsInvalid:
        case MASApiErrorCodeRequestAuthorizationLoginUserCredentialsInvalid:
        case MASApiErrorCodeRequestTokenResourceOwnerCredentialsInvalid:
        case MASApiErrorCodeRequestTokenResourceOwnerCredentialsInvalid2: return MASFoundationErrorCodeUserBasicCredentialsNotValid;
        
        //
        // Token
        //
        case MASApiErrorCodeTokenInvalidAccessTokenSuffix: return MASFoundationErrorCodeAccessTokenInvalid;
        case MASApiErrorCodeTokenDisabledSuffix: return MASFoundationErrorCodeAccessTokenDisabled;
        case MASApiErrorCodeTokenNotGrantedForScopeSuffix: return MASFoundationErrorCodeAccessTokenNotGrantedScope;
         
        //
        // OTP
        //
        case MASApiErrorCodeOTPExpired: return MASFoundationErrorCodeOTPExpired;
        case MASApiErrorCodeOTPRetryLimitExceeded: return MASFoundationErrorCodeOTPRetryLimitExceeded;
        case MASApiErrorCodeOTPRetryBarred: return MASFoundationErrorCodeOTPRetryBarred;
            
        //
        // Default
        //
        default: return MASFoundationErrorCodeUnknown;
    }
}


+ (MASFoundationErrorCode)foundationErrorCodeForError:(NSError *)error
{
    //
    // Detect code and respond appropriately
    //
    switch(error.code)
    {
        //
        // Geolocation
        //
        
        case MASUrlErrorCodeGeolocationIsMissing: return MASFoundationErrorCodeGeolocationIsMissing;
        case MASUrlErrorCodeGeolocationIsInvalid: return MASFoundationErrorCodeGeolocationIsInvalid;
        
        //
        // Network
        //
        
        case MASUrlErrorCodeNetworkRequestTimedOut: return MASFoundationErrorCodeNetworkRequestTimedOut;
        case MASUrlErrorCodeNetworkHostnameNotFound: return MASFoundationErrorCodeNetworkNotReachable;
        case MASUrlErrorCodeNetworkFailedToConnect: return MASFoundationErrorCodeNetworkNotReachable;
        case MASUrlErrorCodeNetworkIsOffline: return MASFoundationErrorCodeNetworkIsOffline;
        case MASUrlErrorCodeNetworkUnacceptableContentType: return MASFoundationErrorCodeNetworkUnacceptableContentType;
        case MASUrlErrorCodeSSLConnectionCannotBeMade: return MASFoundationErrorCodeNetworkSSLConnectionCannotBeMade;
        
        //
        // Response serialization
        //
        case MASUrlErrorCodeResponseSerializeFailedToParseResponse: return MASFoundationErrorCodeResponseSerializationFailedToParseResponse;
        //
        // Default
        //
        
        default: return MASFoundationErrorCodeUnknown;
    }
}


+ (NSString *)descriptionForFoundationErrorCode:(MASFoundationErrorCode)errorCode
{
    //
    // Detect code and respond appropriately
    //
    switch(errorCode)
    {
        //
        // SDK start
        //
        case MASFoundationErrorCodeInvalidNSDictionary: return @"Invalid NSDictionary object. JSON object cannot be nil.";
        case MASFoundationErrorCodeInvalidNSURL: return @"Invalid NSURL object. File URL cannot be nil";
        case MASFoundationErrorCodeInvalidUserLoginBlock: return @"SDK is attempting to invoke MASDeviceRegistrationWithUserCredentialsBlock, but the block has not defined.  The block is mandatory for user credential flow if you have decided to not use MASUI.";
        case MASFoundationErrorCodeMASIsNotStarted: return @"MAS SDK has not been started.";
            
        //
        // OTP
        //
        case MASFoundationErrorCodeOTPNotProvided: return @"Enter the OTP";
        case MASFoundationErrorCodeInvalidOTPProvided: return @"Authentication failed due to invalid OTP";
        case MASFoundationErrorCodeOTPExpired: return @"The OTP has expired.";
        case MASFoundationErrorCodeOTPRetryLimitExceeded: return @"You have exceeded the maximum number of invalid attempts. Please try after some time.";
        case MASFoundationErrorCodeOTPRetryBarred: return @"Your account is blocked. Try after some time.";
        case MASFoundationErrorCodeOTPChannelSelectionCancelled: return @"OTP channel selection has been cancelled by user.";
        case MASFoundationErrorCodeOTPAuthenticationCancelled: return @"OTP authentication has been cancelled by user.";
            
        //
        // Application
        //
        case MASFoundationErrorCodeApplicationAlreadyRegistered: return @"The application is already registered with valid credentials";
        case MASFoundationErrorCodeApplicationInvalid: return @"The application has invalid credentials";
        case MASFoundationErrorCodeApplicationNotRegistered: return @"The application is not registered";
        case MASFoundationErrorCodeApplicationRedirectUriInvalid: return @"redirect_uri is invalid";
        case MASFoundationErrorCodeApplicationInvalidMagIdentifer: return @"Given mag-identifer is invalid.";
        
        //
        // Configuration
        //
        
        case MASFoundationErrorCodeConfigurationLoadingFailedFileNotFound: return @"The configuration file %@ could not be found";
        case MASFoundationErrorCodeConfigurationLoadingFailedJsonSerialization: return @"The configuration file %@ was found but the contents could not be loaded with description\n\n\'%@\'";
        case MASFoundationErrorCodeConfigurationLoadingFailedJsonValidation: return @"The configuration was successfully loaded, but the configuration is invalid for the following reason\n\n'%@'";
        case MASFoundationErrorCodeConfigurationInvalidEndpoint: return @"Invalid endpoint";
            
        //
        // Device
        //
        
        case MASFoundationErrorCodeDeviceAlreadyRegistered: return @"This device has already been registered and has not been configured to accept updates";
        case MASFoundationErrorCodeDeviceAlreadyRegisteredWithDifferentFlow: return @"This device has already been registered within a different flow";
        case MASFoundationErrorCodeDeviceCouldNotBeDeregistered: return @"This device could not be deregistered on the Gateway";
        case MASFoundationErrorCodeDeviceNotRegistered: return @"This device is not registered";
        case MASFoundationErrorCodeDeviceNotLoggedIn: return @"This device is not logged in";
        case MASFoundationErrorCodeDeviceRecordIsNotValid: return @"The registered device record is invalid";
        case MASFoundationErrorCodeDeviceRegistrationAttemptedWithUnregisteredScope: return @"Attempted to register the device with a Scope that isn't registered in the application record on the Gateway";
        case MASFoundationErrorCodeDeviceRegistrationWithoutRequiredParameters: return @"The device registration does not have the required parameters";
        case MASFoundationErrorCodeDeviceDoesNotSupportLocalAuthentication: return @"The device does not support or have valid local authnetication method";
        
        //
        // Flow
        //
        
        case MASFoundationErrorCodeFlowIsNotActive: return @"There is not a currently active flow";
        case MASFoundationErrorCodeFlowIsNotImplemented: return @"This flow type has not yet been implemented";
        case MASFoundationErrorCodeFlowTypeUnsupported: return @"This flow type is not yet supported";
    
        //
        // Geolocation
        //
        
        case MASFoundationErrorCodeGeolocationIsMissing: return @"No location coordinates found and they are required.";
        case MASFoundationErrorCodeGeolocationIsInvalid: return @"The current location is not valid.";
        case MASFoundationErrorCodeGeolocationServicesAreUnauthorized: return @"The geolocation services are unauthorized.";
        case MASFoundationErrorCodeGeolocationIsNotConfigured: return @"The geolocation service is not configured in JSON configuration file.";
        
        //
        // Network
        //
        
        case MASFoundationErrorCodeNetworkUnacceptableContentType: return @"The network detected an unacceptable content-type";
        case MASFoundationErrorCodeNetworkIsOffline: return @"The network appears to be offline";
        case MASFoundationErrorCodeNetworkSSLConnectionCannotBeMade: return @"An SSL error has occurred, this may be caused by attempting to connect to a server using TLS version below 1.2.\n\n";
        case MASFoundationErrorCodeNetworkNotStarted: return @"The network is not started";
        case MASFoundationErrorCodeNetworkNotReachable: return @"The network host is not currently reachable";
        case MASFoundationErrorCodeNetworkRequestTimedOut: return @"The network request has timed out";
        
        case MASFoundationErrorCodeResponseSerializationFailedToParseResponse: return @"Invalid response format - failed to parse response";
        
        //
        // Authorization
        //
        case MASFoundationErrorCodeInvalidAuthorization: return @"The authorization failed due to invalid state.";
            
        //
        // User
        //
        case MASFoundationErrorCodeUserAlreadyAuthenticated: return @"A user is already authenticated";
        case MASFoundationErrorCodeUserBasicCredentialsNotValid: return @"Username or password invalid";
        case MASFoundationErrorCodeUserDoesNotExist: return @"A user does not exist";
        case MASFoundationErrorCodeUserNotAuthenticated: return @"A user is not authenticated";
        case MASFoundationErrorCodeLoginProcessCancel: return @"Login process has been cancelled";
        case MASFoundationErrorCodeUserSessionIsAlreadyLocked: return @"User session is already locked";
        case MASFoundationErrorCodeUserSessionIsAlreadyUnlocked: return @"User session is not locked";
        case MASFoundationErrorCodeUserSessionIsCurrentlyLocked: return @"User session is currently locked";
    
        //
        // Token
        //
        case MASFoundationErrorCodeTokenInvalidIdToken: return @"JWT Validation: id_token is invalid";
        case MASFoundationErrorCodeTokenIdTokenExpired: return @"JWT Validation: id_token is expired";
        case MASFoundationErrorCodeTokenIdTokenInvalidAud: return @"JWT Validation: aud value does not match";
        case MASFoundationErrorCodeTokenIdTokenInvalidAzp: return @"JWT Validation: azp value does not match";
        case MASFoundationErrorCodeTokenIdTokenInvalidSignature: return @"JWT Validation: signature does not match";
        case MASFoundationErrorCodeTokenIdTokenNotExistForLockingUserSession: return @"id_token does not exist; id_token is required for locking user session";
            
        case MASFoundationErrorCodeAccessTokenNotGrantedScope: return @"Given access token is not granted for required scope.";
        case MASFoundationErrorCodeAccessTokenDisabled: return @"Given access token is disabled";
        case MASFoundationErrorCodeAccessTokenInvalid: return @"Invalid access token";
        
        //
        // EnterpriseBrowser
        //
        case MASFoundationErrorCodeEnterpriseBrowserWebAppInvalidURL: return @"Invalid webapp auth URL";
        case MASFoundationErrorCodeEnterpriseBrowserNativeAppDoesNotExist: return @"Native app does not exist";
        case MASFoundationErrorCodeEnterpriseBrowserNativeAppCannotOpen: return @"Error loading the native app";
        case MASFoundationErrorCodeEnterpriseBrowserAppDoesNotExist: return @"Enterprise Browser App does not exist";
        
        //
        // BLE
        //
        case MASFoundationErrorCodeBLEUnknownState: return @"Unknown error occured while enabling BLE Central";
        case MASFoundationErrorCodeBLEPoweredOff: return @"Bluetooth is currently off";
        case MASFoundationErrorCodeBLERestting: return @"Bluetooth connection is momentarily lost; restting the connection";
        case MASFoundationErrorCodeBLEUnauthorized: return @"Bluetooth feature is not authorized for this application";
        case MASFoundationErrorCodeBLEUnSupported: return @"Bluetooth feature is not supported";
        case MASFoundationErrorCodeBLEDelegateNotDefined: return @"MASDevice's BLE delegate is not defined. Delegate is mandatory to acquire permission from the user.";
        case MASFoundationErrorCodeBLEAuthorizationFailed: return @"BLE authorization failed due to invalid or expired authorization request.";
        case MASFoundationErrorCodeBLECentralDeviceNotFound: return @"BLE authorization failed due to no subscribed central device.";
        case MASFoundationErrorCodeBLERSSINotInRange: return @"BLE RSSI is not in range.  Please refer to msso_config.json for BLE RSSI configuration.";
        case MASFoundationErrorCodeBLEAuthorizationPollingFailed: return @"BLE authorization failed while polling authorization code from gateway.";
        case MASFoundationErrorCodeBLEInvalidAuthenticationProvider: return @"BLE authorization failed due to invalid authentication provider.";
        case MASFoundationErrorCodeBLECentral: return @"BLE Central error encountered in CBCentral with specific reason in userInfo.";
        case MASFoundationErrorCodeBLEPeripheral: return @"BLE Peripheral error encountered while discovering, or connecting central device with specific reason in userInfo.";
        case MASFoundationErrorCodeBLEPeripheralServices: return @"BLE Peripheral error encountered while discovering or connecting peripheral services with specific reason in userInfo.";
        case MASFoundationErrorCodeBLEPeripheralCharacteristics: return @"BLE Peripheral error encountered while discovering, connecting, or writing peripheral service's characteristics with specific reason in userInfo.";
        
        //
        // Session Sharing
        //
        case MASFoundationErrorCodeProximityLoginAuthorizationInProgress: return @"Authorization is currently in progress through proximity login.";
        case MASFoundationErrorCodeQRCodeProximityLoginAuthorizationPollingFailed: return @"QR Code proximity login authentication failed with specific information on userInfo.";
        case MASFoundationErrorCodeProximityLoginInvalidAuthenticationURL: return @"Invalid authentication URL is provided for proximity login.";
        case MASFoundationErrorCodeProximityLoginInvalidAuthorizeURL: return @"Invalid authorization url.";
            
        //
        // Default
        //
        
        default: return [NSString stringWithFormat:@"Unrecognized error code of value: %ld", (long)errorCode];
    }
}

@end
