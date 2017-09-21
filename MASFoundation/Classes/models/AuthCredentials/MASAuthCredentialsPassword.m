//
//  MASAuthCredentialsPassword.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentialsPassword.h"


#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"

@implementation MASAuthCredentialsPassword

@synthesize credentialsType = _credentialsType;
@synthesize canRegisterDevice = _canRegisterDevice;
@synthesize isReuseable = _isReuseable;


# pragma mark - LifeCycle

+ (MASAuthCredentialsPassword *)initWithUsername:(NSString *)username password:(NSString *)password
{
    MASAuthCredentialsPassword *authCredentials = [[self alloc] initPrivateWithUsername:username password:password];
    
    return authCredentials;
}


- (instancetype)initPrivateWithUsername:(NSString *)username password:(NSString *)password
{
    self = [super initPrivate];
    
    if(self) {
        _username = username;
        _password = password;
        _credentialsType = MASGrantTypePassword;
        _canRegisterDevice = YES;
        _isReuseable = YES;
    }
    
    return self;
}


# pragma mark - Public

- (void)clearCredentials
{
    _username = nil;
    _password = nil;
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
    //  For device registration header
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        
        NSString *authorization = [MASUser authorizationBasicHeaderValueWithUsername:_username password:_password];
        if (authorization)
        {
            headerInfo[MASAuthorizationRequestResponseKey] = authorization;
        }
    }
    //
    //  For user authentication header
    //
    else {
    
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
        NSString *certificateSigningRequest = [securityService generateCSRWithUsername:_username];
        
        if (certificateSigningRequest)
        {
            parameterInfo[MASCertificateSigningRequestResponseKey] = certificateSigningRequest;
        }
    }
    //
    //  For user authentication parameters
    //
    else {
        
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
        
        // UserName
        if (_username)
        {
            parameterInfo[MASUserNameRequestResponseKey] = _username;
        }
        
        // Password
        if (_password)
        {
            parameterInfo[MASPasswordRequestResponseKey] = _password;
        }
        
        // Grant Type
        parameterInfo[MASGrantTypeRequestResponseKey] = MASGrantTypePassword;
    }
    
    return parameterInfo;
}

@end
