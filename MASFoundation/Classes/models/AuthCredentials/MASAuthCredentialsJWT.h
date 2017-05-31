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



+ (MASAuthCredentialsJWT * _Nullable)initWithJWT:(NSString * _Nonnull)jwt tokenType:(NSString * _Nonnull)tokenType;

@end
