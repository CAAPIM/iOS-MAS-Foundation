//
//  MASAuthCredentialsJWT.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentialsJWT.h"

#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"


@implementation MASAuthCredentialsJWT

# pragma mark - LifeCycle

+ (MASAuthCredentialsJWT *)initWithJWT:(NSString *)jwt tokenType:(NSString *)tokenType
{
    MASAuthCredentialsJWT *authCredentials = [[self alloc] initPrivateWithJWT:jwt tokenType:tokenType];
    
    return authCredentials;
}


- (instancetype)initPrivateWithJWT:(NSString *)jwt tokenType:(NSString *)tokenType
{
    self = [super initWithCredentialsType:tokenType ? tokenType : @"urn:ietf:params:oauth:grant-type:jwt-bearer" csrUsername:@"socialLogin" canRegisterDevice:YES isReusable:NO];
    
    if (self)
    {
        _jwt = jwt;
        _tokenType = tokenType;
        
        if (!_tokenType || [_tokenType length] == 0)
        {
            _tokenType = @"urn:ietf:params:oauth:grant-type:jwt-bearer";
        }
    }
    
    return self;
}


# pragma mark - Public

- (void)clearCredentials
{
    _jwt = nil;
    _tokenType = nil;
}


# pragma mark - Private

- (void)loginWithCredential:(MASCompletionErrorBlock)completion
{
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    [super loginWithCredential:^(BOOL completed, NSError *error) {
    
        if (error)
        {
            //
            // If there is an error from the server complaining about invalid token,
            // invalidate local id_token and id_token_type and revalidate the user's session.
            //
            [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdToken];
            [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdTokenType];
            [[MASAccessService sharedService].currentAccessObj refresh];
        }
        
        if (blockCompletion)
        {
            blockCompletion(completed, error);
        }
    }];
}


- (NSDictionary *)getHeaders
{
    NSMutableDictionary *headerInfo = [[super getHeaders] mutableCopy];
    
    //
    //  For device registration headers
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        // Authorization with 'Authorization' header key
        NSString *authorization = [NSString stringWithFormat:@"Bearer %@", _jwt];
        if (_jwt)
        {
            headerInfo[MASAuthorizationRequestResponseKey] = authorization;
        }
        
        if (_tokenType)
        {
            headerInfo[MASAuthorizationTypeRequestResponseKey] = _tokenType;
        }
    }
    //
    //  For user authentication headers
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
        
        // JWT
        if (_jwt)
        {
            parameterInfo[MASAssertionRequestResponseKey] = _jwt;
        }
    }
    
    return parameterInfo;
}

@end
