//
//  MASAuthCredentials.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentials.h"

#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"

#import "MASConstants.h"


@interface MASAuthCredentials ()

@property (nonatomic, strong, readwrite) NSString *credentialsType;
@property (nonatomic, strong, readwrite) NSString *csrUsername;
@property (nonatomic, assign, readwrite) BOOL canRegisterDevice;
@property (nonatomic, assign, readwrite) BOOL isReusable;
@property (nonatomic, strong, readwrite) NSString *registerEndpoint;
@property (nonatomic, strong, readwrite) NSString *tokenEndpoint;

@end


@implementation MASAuthCredentials

# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a designated initializer"
                                 userInfo:nil];
    return nil;
}


- (instancetype)initWithCredentialsType:(NSString *)credentialsType csrUsername:(NSString *)csrUsername canRegisterDevice:(BOOL)canRegisterDevice isReusable:(BOOL)isReusable
{
    return [self initWithCredentialsType:credentialsType csrUsername:csrUsername canRegisterDevice:canRegisterDevice isReusable:isReusable registerEndpoint:[MASConfiguration currentConfiguration].deviceRegisterEndpointPath tokenEndpoint:[MASConfiguration currentConfiguration].tokenEndpointPath];
}


- (instancetype)initWithCredentialsType:(NSString *)credentialsType csrUsername:(NSString *)csrUsername canRegisterDevice:(BOOL)canRegisterDevice isReusable:(BOOL)isReusable registerEndpoint:(NSString *)registerEndpoint tokenEndpoint:(NSString *)tokenEndpoint
{
    self = [super init];
    if (self)
    {
        self.credentialsType = credentialsType;
        self.canRegisterDevice = canRegisterDevice;
        self.isReusable = isReusable;
        self.registerEndpoint = registerEndpoint;
        self.tokenEndpoint = tokenEndpoint;
        self.csrUsername = csrUsername;
    }
    
    return self;
}


# pragma mark - Public

- (void)clearCredentials
{
    
}


- (NSDictionary *)getHeaders
{
    NSMutableDictionary *headerInfo = [NSMutableDictionary dictionary];
    
    //
    //  For device registration
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        // Client Authorization with 'client-authorization' header key
        NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
        if (clientAuthorization)
        {
            headerInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
        }
        
        //  Device ID
        NSString *deviceId = [MASDevice deviceIdBase64Encoded];
        if (deviceId)
        {
            headerInfo[MASDeviceIdRequestResponseKey] = deviceId;
        }
        
        //  Device Name
        NSString *deviceName = [MASDevice deviceNameBase64Encoded];
        if (deviceName)
        {
            headerInfo[MASDeviceNameRequestResponseKey] = deviceName;
        }
        
        // Create Session
        headerInfo[MASCreateSessionRequestResponseKey] = [MASConfiguration currentConfiguration].ssoEnabled ? @"true" : @"false";
        
        // Certificate Format
        headerInfo[MASCertFormatRequestResponseKey] = @"pem";
    }
    //
    //  For session authentication (acquiring tokens)
    //
    else {
        // Client Authorization with 'Authorization' header key
        NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
        if (clientAuthorization)
        {
            headerInfo[MASAuthorizationRequestResponseKey] = clientAuthorization;
        }
    }
    
    return headerInfo;
}


- (NSDictionary *)getParameters
{
    NSMutableDictionary *parameterInfo = [NSMutableDictionary dictionary];
    
    //
    //  For device registration
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        // Certificate Signing Request
        MASSecurityService *securityService = [MASSecurityService sharedService];
        [securityService generateKeypair];
        NSString *certificateSigningRequest = [securityService generateCSRWithUsername:self.csrUsername];
        
        if (certificateSigningRequest)
        {
            parameterInfo[MASCertificateSigningRequestResponseKey] = certificateSigningRequest;
        }
    }
    //
    //  For session authentication (acquiring tokens)
    //
    else {
        
        NSString *scope = [[MASApplication currentApplication] scopeAsString];
        
        if ([MASAccess currentAccess].requestingScopeAsString)
        {
            if (scope)
            {
                scope = [scope stringByAppendingString:[NSString stringWithFormat:@" %@",[MASAccess currentAccess].requestingScopeAsString]];
            }
            else {
                scope = [scope stringByAppendingString:[MASAccess currentAccess].requestingScopeAsString];
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
        
        // Grant Type
        parameterInfo[MASGrantTypeRequestResponseKey] = self.credentialsType;
    }
    
    return parameterInfo;
}


# pragma mark - Prviate


@end
