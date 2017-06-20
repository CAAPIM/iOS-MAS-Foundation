//
//  MASAuthCredentialsAuthorizationCode.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentialsAuthorizationCode.h"

#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
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
    self = [super initPrivate];
    
    if(self) {
        _authorizationCode = authorizationCode;
        _credentialsType = MASGrantTypeAuthorizationCode;
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

- (NSString *)getRegisterEndpoint
{
    return [MASConfiguration currentConfiguration].deviceRegisterEndpointPath;
}


- (NSString *)getTokenEndpoint
{
    return [MASConfiguration currentConfiguration].tokenEndpointPath;
}


- (NSDictionary *)getHeaders
{
    NSMutableDictionary *headerInfo = [NSMutableDictionary dictionary];
    
    //
    //  For device registration headers
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        // Authorization with 'Authorization' header key
        NSString *authorization = [NSString stringWithFormat:@"Bearer %@", _authorizationCode];
        if(authorization) headerInfo[MASAuthorizationRequestResponseKey] = authorization;
        
        // Redirect-Uri
        headerInfo[MASRedirectUriHeaderRequestResponseKey] = [MASApplication currentApplication].redirectUri.absoluteString;
        
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

    }
    //
    //  For user authentication headers
    //
    else {
        
        //
        // Empty authorization header for token endpoint with auth code
        //
        headerInfo[MASAuthorizationRequestResponseKey] = @"";
    }
    
    return headerInfo;
}


- (NSDictionary *)getParameters
{
    NSMutableDictionary *parameterInfo = [NSMutableDictionary dictionary];
    
    //
    //  For device registration parameters
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        // Certificate Signing Request
        MASSecurityService *securityService = [MASSecurityService sharedService];
        [securityService deleteAsymmetricKeys];
        [securityService generateKeypair];
        NSString *certificateSigningRequest = [securityService generateCSRWithUsername:@"socialLogin"];
        
        if (certificateSigningRequest)
        {
            parameterInfo[MASCertificateSigningRequestResponseKey] = certificateSigningRequest;
        }
    }
    //
    //  For user authentication parameters
    //
    else {
        
        // AccessService
        MASAccessService *accessService = [MASAccessService sharedService];
        
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
    }
    
    return parameterInfo;
}

@end
