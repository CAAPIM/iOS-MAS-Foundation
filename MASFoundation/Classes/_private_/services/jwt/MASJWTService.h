//
//  MASJWTService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"

#import "MASJWKSet.h"
#import "MASConstantsPrivate.h"


NS_ASSUME_NONNULL_BEGIN

@interface MASJWTService : MASService


/**
 * The current JWKSet singleton.
 */
@property (nonatomic, strong, readonly) MASJWKSet *currentJWKSet;



/**
 * Sets boolean indicator of enforcing JWKS loading upon MAS Start.
 * JWK Set - A JSON object that represents a set of JWKs.
 * JWK -  A JSON object that represents a cryptographic key.
 * The members of the object represent properties of the key, including its value.
 *
 * By default, JWKSet loading is disabled.
 *
 * @param enable BOOL value of indicating whether JWKSet loading is enabled or not.
 */
+ (void)enableJWKSetLoading:(BOOL)enable;



/**
 * Gets boolean indicator of enforcing JWKS loading upon MAS Start.
 * JWK Set - A JSON object that represents a set of JWKs.
 * JWK -  A JSON object that represents a cryptographic key.
 * The members of the object represent properties of the key, including its value.
 *
 * By default, JWKSet loading is disabled.
 *
 * @return BOOL value of indicating whether JWKSet loading is enabled or not.
 */
+ (BOOL)isJWKSetLoadingEnabled;



/**
 *  Decode id_token
 *
 *  @param token NSString of id_token value
 *  @param keyId NSString of unique identifier of the json web key value
 *  @param skipVerification BOOL value whether JWT signature verification be skipped.
 *
 *  @return NSDictionary of Header and Payload Dictionary.
 */
- (NSDictionary *)decodeToken:(NSString *)token
                        keyId:(NSString *)keyId
    skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
