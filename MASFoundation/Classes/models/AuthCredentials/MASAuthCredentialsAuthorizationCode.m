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

# pragma mark - LifeCycle

+ (MASAuthCredentialsAuthorizationCode *)initWithAuthorizationCode:(NSString *)authorizationCode
{
    MASAuthCredentialsAuthorizationCode *authCredentials = [[self alloc] initPrivateWithAuthorizationCode:authorizationCode];
    
    return authCredentials;
}


- (instancetype)initPrivateWithAuthorizationCode:(NSString *)authorizationCode
{
    self = [super initWithCredentialsType:MASGrantTypeAuthorizationCode csrUsername:@"socialLogin" canRegisterDevice:YES isReusable:NO];
    
    if (self)
    {
        _authorizationCode = authorizationCode;
    }
    
    return self;
}


# pragma mark - Public

- (void)clearCredentials
{
    _authorizationCode = nil;
}


# pragma mark - Private


- (NSDictionary *)getHeaders
{
    NSMutableDictionary *headerInfo = [[super getHeaders] mutableCopy];
    
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
    NSMutableDictionary *parameterInfo = [[super getParameters] mutableCopy];
    
    //
    //  For device registration parameters
    //
    if (![MASDevice currentDevice].isRegistered)
    {

    }
    //
    //  For user authentication parameters
    //
    else {
        
        // AccessService
        MASAccessService *accessService = [MASAccessService sharedService];
        
        // ClientId
        NSString *clientId = [accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientId];
        if (clientId)
        {
            parameterInfo[MASClientIdentifierRequestResponseKey] = clientId;
        }
        
        NSString *clientSecret = [accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientSecret];
        if (clientSecret)
        {
            parameterInfo[MASClientSecretRequestResponseKey] = clientSecret;
        }
        
        // Code
        if (_authorizationCode)
        {
            parameterInfo[MASCodeRequestResponseKey] = _authorizationCode;
        }
        
        // Redirect-Uri
        parameterInfo[MASRedirectUriRequestResponseKey] = [MASApplication currentApplication].redirectUri.absoluteString;
        
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
