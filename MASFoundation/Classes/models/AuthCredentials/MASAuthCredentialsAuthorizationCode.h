//
//  MASAuthCredentialsAuthorizationCode.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentialsAuthorizationCode : MASAuthCredentials


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 * Credential, authorization code.
 */
@property (nonatomic, copy, readonly, nullable) NSString *authorizationCode;



/**
 Designated factory method to construct MASAuthCredentials object for authorization code credentials

 @param authorizationCode NSString of authorization code for credentials
 @return MASAuthCredentialsAuthorizationCode object that can be used as auth credentials to register or login
 */
+ (MASAuthCredentialsAuthorizationCode * _Nullable)initWithAuthorizationCode:(NSString * _Nonnull)authorizationCode;

@end
