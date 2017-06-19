//
//  MASAuthCredentialsJWT.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
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
