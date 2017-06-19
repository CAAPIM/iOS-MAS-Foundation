//
//  MASAuthCredentialsClientCredentials.m
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentialsClientCredentials.h"

#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"

#import "MASConstants.h"
#import "MASDevice.h"

@implementation MASAuthCredentialsClientCredentials

@synthesize credentialsType = _credentialsType;
@synthesize canRegisterDevice = _canRegisterDevice;
@synthesize isReuseable = _isReuseable;


# pragma mark - LifeCycle

+ (MASAuthCredentialsClientCredentials *)initClientCredentials
{
    MASAuthCredentialsClientCredentials *authCredentials = [[self alloc] initPrivate];
    
    return authCredentials;
}


- (instancetype)initPrivate
{
    self = [super initPrivate];
    
    if(self) {
        _credentialsType = MASGrantTypeClientCredentials;
        _canRegisterDevice = YES;
        _isReuseable = YES;
    }
    
    return self;
}


# pragma mark - Public

- (void)clearCredentials
{
    
}


# pragma mark - Private

- (NSDictionary *)getHeaders
{
    NSMutableDictionary *headerInfo = [NSMutableDictionary dictionary];
    
    //
    //  For device registration header
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        
    }
    //
    //  For user authentication header
    //
    else {
        
        headerInfo[MASAuthorizationRequestResponseKey] = @"";
    }
    
    return headerInfo;
}


- (NSDictionary *)getParameters
{
    NSMutableDictionary *parameterInfo = [NSMutableDictionary dictionary];
    
    //
    //  For device registration parameter
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        // Certificate Signing Request
        MASSecurityService *securityService = [MASSecurityService sharedService];
        [securityService deleteAsymmetricKeys];
        [securityService generateKeypair];
        
        NSString *certificateSigningRequest = [securityService generateCSRWithUsername:@"clientName"];
        if (certificateSigningRequest)
        {
            parameterInfo[MASCertificateSigningRequestResponseKey] = certificateSigningRequest;
        }
    }
    //
    //  For user authentication parameter
    //
    else {
        
        // ClientId
        NSString *clientId = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientId];
        if (clientId)
        {
            parameterInfo[MASClientIdentifierRequestResponseKey] = clientId;
        }
        
        // ClientSecret
        NSString *clientSecret = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientSecret];
        if (clientSecret)
        {
            parameterInfo[MASClientSecretRequestResponseKey] = clientSecret;
        }
        
        // Grant Type
        parameterInfo[MASGrantTypeRequestResponseKey] = MASGrantTypeClientCredentials;
    }
    
    return parameterInfo;
}


- (NSString *)getRegisterEndpoint
{
    return [MASConfiguration currentConfiguration].deviceRegisterClientEndpointPath;
}


- (NSString *)getTokenEndpoint
{
    return [MASConfiguration currentConfiguration].tokenEndpointPath;
}

@end
