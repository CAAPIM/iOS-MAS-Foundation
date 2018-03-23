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

# pragma mark - LifeCycle

+ (MASAuthCredentialsPassword *)initWithUsername:(NSString *)username password:(NSString *)password
{
    MASAuthCredentialsPassword *authCredentials = [[self alloc] initPrivateWithUsername:username password:password];
    
    return authCredentials;
}


- (instancetype)initPrivateWithUsername:(NSString *)username password:(NSString *)password
{
    self = [super initWithCredentialsType:MASGrantTypePassword csrUsername:username canRegisterDevice:YES isReusable:YES];
    
    if (self)
    {
        _username = username;
        _password = password;
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

- (NSDictionary *)getHeaders
{
    NSMutableDictionary *headerInfo = [[super getHeaders] mutableCopy];

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
    }
    
    return parameterInfo;
}

@end
