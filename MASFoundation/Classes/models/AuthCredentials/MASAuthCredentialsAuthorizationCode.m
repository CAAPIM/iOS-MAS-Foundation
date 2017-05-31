//
//  MASAuthCredentialsAuthorizationCode.m
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentialsAuthorizationCode.h"

#import "MASAccessService.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"

@implementation MASAuthCredentialsAuthorizationCode

@synthesize credentialsType = _credentialsType;
@synthesize canRegisterDevice = _canRegisterDevice;
@synthesize isReuseable = _isReuseable;


# pragma mark - LifeCycle

+ (MASAuthCredentialsAuthorizationCode *)initWithAuthorizationCode:(NSString *)authorizationCode
{
    MASAuthCredentialsAuthorizationCode *authCredentials = [[self alloc] initPrivateWithAuthorizationCode:authorizationCode];
    
    return authCredentials;
}


- (instancetype)initPrivateWithAuthorizationCode:(NSString *)authorizationCode
{
    self = [super init];
    
    if(self) {
        _authorizationCode = authorizationCode;
        _credentialsType = MASAuthCredentialsTypeAuthCode;
        _canRegisterDevice = YES;
        _isReuseable = NO;
    }
    
    return self;
}


# pragma mark - Public

- (void)clearCredentials
{
    _authorizationCode = nil;
}


# pragma mark - Private

- (void)registerDeviceWithCredential:(MASCompletionErrorBlock)completion
{
    //
    // Detect if device is already registered, if so stop here
    //
    if ([[MASDevice currentDevice] isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        
        return;
    }
    
    //
    // Post the will register notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceWillRegisterNotification object:self];
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceRegisterEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    // Authorization with 'Authorization' header key
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", _authorizationCode];
    if(authorization) headerInfo[MASAuthorizationRequestResponseKey] = authorization;
    
    // Redirect-Uri
    headerInfo[MASRedirectUriHeaderRequestResponseKey] = [MASApplication currentApplication].redirectUri.absoluteString;
    
    // Client Authorization
    NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
    if(clientAuthorization) headerInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
    
    // DeviceId
    NSString *deviceId = [MASDevice deviceIdBase64Encoded];
    if(deviceId) headerInfo[MASDeviceIdRequestResponseKey] = deviceId;
    
    // DeviceName
    NSString *deviceName = [MASDevice deviceNameBase64Encoded];
    if(deviceName) headerInfo[MASDeviceNameRequestResponseKey] = deviceName;
    
    // Create Session
    headerInfo[MASCreateSessionRequestResponseKey] = [MASConfiguration currentConfiguration].ssoEnabled ? @"true" : @"false";
    
    // Certificate Format
    headerInfo[MASCertFormatRequestResponseKey] = @"pem";
    
    //
    // If code verifier exists in the memory
    //
    if ([[MASAccessService sharedService].currentAccessObj retrieveCodeVerifier])
    {
        //
        // inject it into parameter of the request
        //
        headerInfo[MASPKCECodeVerifierHeaderRequestResponseKey] = [[MASAccessService sharedService].currentAccessObj retrieveCodeVerifier];
    }
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // Certificate Signing Request
    MASSecurityService *securityService = [MASSecurityService sharedService];
    [securityService deleteAsymmetricKeys];
    [securityService generateKeypair];
    NSString *certificateSigningRequest = [securityService generateCSRWithUsername:@"socialLogin"];
    
    if(certificateSigningRequest) parameterInfo[MASCertificateSigningRequestResponseKey] = certificateSigningRequest;
    
    //
    // Trigger the request
    //
    __block MASAuthCredentialsAuthorizationCode *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    [[MASNetworkingService sharedService] postTo:endPoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
                                     requestType:MASRequestResponseTypeTextPlain
                                    responseType:MASRequestResponseTypeTextPlain
                                      completion:^(NSDictionary *responseInfo, NSError *error)
     {
         //
         // Detect if error, if so stop here
         //
         if(error)
         {
             //DLog(@"Error detected attempting to request registration of the device: %@",
             //    [error localizedDescription]);
             
             //
             // Notify
             //
             if (blockCompletion)
             {
                 blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
             }
             
             //
             // Post the notification
             //
             [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidFailToRegisterNotification object:blockSelf];
             
             return;
         }
         
         //
         // Remove PKCE Code Verifier and state
         //
         [[MASAccessService sharedService].currentAccessObj deleteCodeVerifier];
         [[MASAccessService sharedService].currentAccessObj deletePKCEState];
         
         //
         // Validate id_token when received from server.
         //
         NSDictionary *headerInfo = responseInfo[MASResponseInfoHeaderInfoKey];
         
         if ([headerInfo objectForKey:MASIdTokenHeaderRequestResponseKey] &&
             [headerInfo objectForKey:MASIdTokenTypeHeaderRequestResponseKey] &&
             [[headerInfo objectForKey:MASIdTokenTypeHeaderRequestResponseKey] isEqualToString:MASIdTokenTypeToValidateConstant])
         {
             NSError *idTokenValidationError = nil;
             BOOL isIdTokenValid = [MASAccessService validateIdToken:[headerInfo objectForKey:MASIdTokenHeaderRequestResponseKey]
                                                       magIdentifier:[headerInfo objectForKey:MASMagIdentifierRequestResponseKey]
                                                               error:&idTokenValidationError];
             
             if (!isIdTokenValid && idTokenValidationError)
             {
                 if (blockCompletion)
                 {
                     blockCompletion(NO, idTokenValidationError);
                     
                     return;
                 }
             }
         }
         
         //
         // Updated with latest info
         //
         [[MASDevice currentDevice] saveWithUpdatedInfo:responseInfo];
         
         //
         // re-establish URLSession to trigger URL authentication
         //
         [[MASNetworkingService sharedService] establishURLSession];
         
         //
         // Post the notification
         //
         [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidRegisterNotification object:blockSelf];
         
         //
         // Notify
         //
         if (blockCompletion)
         {
             blockCompletion(YES, nil);
         };
     }];
}


- (void)loginWithCredential:(MASCompletionErrorBlock)completion
{
    //
    // The application must be registered else stop here
    //
    if (![MASApplication currentApplication].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorApplicationNotRegistered]);
        }
        
        return;
    }
    
    //
    // The device must be registered else stop here
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceNotRegistered]);
        }
        
        return;
    }
    
    //
    // The current user must NOT be authenticated else stop here
    //
    if ([MASApplication currentApplication] && [MASApplication currentApplication].authenticationStatus == MASAuthenticationStatusLoginWithUser)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        
        return;
    }
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].tokenEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    //
    // Empty authorization header for token endpoint with auth code
    //
    headerInfo[MASAuthorizationRequestResponseKey] = @"";
    
    // AccessService
    MASAccessService *accessService = [MASAccessService sharedService];
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // ClientId
    NSString *clientId = [accessService getAccessValueStringWithType:MASAccessValueTypeClientId];
    if (clientId)
    {
        parameterInfo[MASClientIdentifierRequestResponseKey] = clientId;
    }
    
    NSString *clientSecret = [accessService getAccessValueStringWithType:MASAccessValueTypeClientSecret];
    if (clientSecret)
    {
        parameterInfo[MASClientSecretRequestResponseKey] = clientSecret;
    }
    
    // Scope
    NSString *scope = [[MASApplication currentApplication] scopeAsString];
    
    //
    //  Check if MASAccess has additional requesting scope to be added as part of the authentication call
    //
    if ([MASAccess currentAccess].requestingScopeAsString)
    {
        if (scope)
        {
            //  Making sure that the new scope has an leading space
            scope = [scope stringByAppendingString:[NSString stringWithFormat:@" %@",[MASAccess currentAccess].requestingScopeAsString]];
        }
        else {
            scope = [MASAccess currentAccess].requestingScopeAsString;
        }
        
        //
        //  Nullify the requestingScope
        //
        [MASAccess currentAccess].requestingScopeAsString = nil;
    }
    
    //
    //  If sso is disabled, manually remove msso scope, as it will create id_token with msso scope
    //
    if (scope && ![MASConfiguration currentConfiguration].ssoEnabled)
    {
        scope = [scope replaceStringWithRegexPattern:@"\\bmsso\\b" withString:@""];
    }
    
    if (scope)
    {
        parameterInfo[MASScopeRequestResponseKey] = scope;
    }
    
    // Code
    if (_authorizationCode)
    {
        parameterInfo[MASCodeRequestResponseKey] = _authorizationCode;
    }
    
    // Redirect-Uri
    parameterInfo[MASRedirectUriRequestResponseKey] = [MASApplication currentApplication].redirectUri.absoluteString;
    
    // Grant Type
    parameterInfo[MASGrantTypeRequestResponseKey] = MASGrantTypeAuthorizationCode;
    
    //
    // If code verifier exists in the memory
    //
    if ([[MASAccessService sharedService].currentAccessObj retrieveCodeVerifier])
    {
        //
        // inject it into parameter of the request
        //
        parameterInfo[MASPKCECodeVerifierRequestResponseKey] = [[MASAccessService sharedService].currentAccessObj retrieveCodeVerifier];
    }
    
    //
    // Trigger the request
    //
    // Note that security credentials are added automatically by this method
    //
    __block MASAuthCredentialsAuthorizationCode *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    [[MASNetworkingService sharedService] postTo:endPoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
                                     requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                    responseType:MASRequestResponseTypeJson
                                      completion:^(NSDictionary *responseInfo, NSError *error)
     {
         //
         // Detect if error, if so stop here
         //
         if(error)
         {
             //
             // Post the notification
             //
             [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToAuthenticateNotification object:blockSelf];
             
             //
             // Notify
             //
             if (blockCompletion)
             {
                 blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
             }
             
             return;
         }
         
         //
         // Validate id_token when received from server.
         //
         NSDictionary *bodayInfo = responseInfo[MASResponseInfoBodyInfoKey];
         
         //
         // Remove PKCE Code Verifier and state once it's validated
         //
         [[MASAccessService sharedService].currentAccessObj deleteCodeVerifier];
         [[MASAccessService sharedService].currentAccessObj deletePKCEState];
         
         if ([bodayInfo objectForKey:MASIdTokenBodyRequestResponseKey] &&
             [bodayInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] &&
             [[bodayInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] isEqualToString:MASIdTokenTypeToValidateConstant])
         {
             NSError *idTokenValidationError = nil;
             BOOL isIdTokenValid = [MASAccessService validateIdToken:[bodayInfo objectForKey:MASIdTokenBodyRequestResponseKey]
                                                       magIdentifier:[[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier]
                                                               error:&idTokenValidationError];
             
             if (!isIdTokenValid && idTokenValidationError)
             {
                 //
                 // Post the notification
                 //
                 [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToAuthenticateNotification object:blockSelf];
                 
                 if (blockCompletion)
                 {
                     blockCompletion(NO, idTokenValidationError);
                     
                     return;
                 }
             }
         }
         
         //
         // Create a new instance
         //
         if (![MASUser currentUser])
         {
             [[MASModelService sharedService] setUserObject:[[MASUser alloc] initWithInfo:responseInfo]];
         }
         
         //
         // Update the existing user with new information
         //
         else
         {
             [[MASUser currentUser] saveWithUpdatedInfo:responseInfo];
         }
         
         //
         // Post the notification
         //
         [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidAuthenticateNotification object:blockSelf];
         
         [[MASModelService sharedService] requestUserInfoWithCompletion:^(MASUser *user, NSError *error) {
             
             //
             // Requesting additional userInfo upon successful authentication
             // and do not depend on the result of userInfo call.
             // This a workaround to fix other frameworks' dependency issue on userInfo.
             // James Go @ April 4, 2016
             //
             
             //
             // Notify
             //
             if (blockCompletion)
             {
                 blockCompletion(YES, nil);
             }
         }];
     }];
}

@end
