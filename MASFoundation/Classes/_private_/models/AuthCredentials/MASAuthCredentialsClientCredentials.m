//
//  MASAuthCredentialsClientCredentials.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
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

# pragma mark - LifeCycle

+ (MASAuthCredentialsClientCredentials *)initClientCredentials
{
    MASAuthCredentialsClientCredentials *authCredentials = [[self alloc] initPrivate];
    
    return authCredentials;
}


- (instancetype)initPrivate
{
    self = [super initWithCredentialsType:MASGrantTypeClientCredentials csrUsername:@"clientName" canRegisterDevice:YES isReusable:YES registerEndpoint:[MASConfiguration currentConfiguration].deviceRegisterClientEndpointPath tokenEndpoint:[MASConfiguration currentConfiguration].tokenEndpointPath];
    
    if (self)
    {
        
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
    NSMutableDictionary *headerInfo = [[super getHeaders] mutableCopy];
    
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
    NSMutableDictionary *parameterInfo = [[super getParameters] mutableCopy];
    
    //
    //  For device registration parameter
    //
    if (![MASDevice currentDevice].isRegistered)
    {

    }
    //
    //  For user authentication parameter
    //
    else {
        
        // ClientId
        NSString *clientId = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientId];
        if (clientId)
        {
            parameterInfo[MASClientIdentifierRequestResponseKey] = clientId;
        }
        
        // ClientSecret
        NSString *clientSecret = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientSecret];
        if (clientSecret)
        {
            parameterInfo[MASClientSecretRequestResponseKey] = clientSecret;
        }
    }
    
    return parameterInfo;
}

@end
