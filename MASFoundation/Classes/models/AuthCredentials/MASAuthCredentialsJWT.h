//
//  MASAuthCredentialsJWT.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentialsJWT : MASAuthCredentials

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 * Credential, JWT.
 */
@property (nonatomic, copy, readonly, nullable) NSString *jwt;


/**
 * Credential, token type.
 */
@property (nonatomic, copy, readonly, nullable) NSString *tokenType;



/**
 Designated factory method to construct MASAuthCredentials object for JWT credentials
 
 @param jwt NSString of JWT for credentials
 @param tokenType NSString of JWT's token type for credentials
 @return MASAuthCredentialsJWT object that can be used as auth credentials to register or login
 */
+ (MASAuthCredentialsJWT * _Nullable)initWithJWT:(NSString * _Nonnull)jwt tokenType:(NSString * _Nullable)tokenType;

@end
