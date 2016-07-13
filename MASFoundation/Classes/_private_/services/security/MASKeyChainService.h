//
//  MASKeyChainService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

@class MASIKeyChainStore;


# pragma mark - Local Constants

static NSString *const kMASKeyChainConfiguration = @"kMASKeyChainConfiguration";

static NSString *const kMASKeyChainAccessToken = @"kMASKeyChainAccessToken";
static NSString *const kMASKeyChainRefreshToken = @"kMASKeyChainRefreshToken";
static NSString *const kMASKeyChainScope = @"kMASKeyChainScope";
static NSString *const kMASKeyChainTokenType = @"kMASKeyChainTokenType";
static NSString *const kMASKeyChainExpiresIn = @"kMASKeyChainExpiresIn";
static NSString *const kMASKeyChainTokenExpiration = @"kMASKeyChainTokenExpiration";
static NSString *const kMASKeyChainIdToken = @"kMASKeyChainIdToken";
static NSString *const kMASKeyChainIdTokenType = @"kMASKeyChainIdTokenType";
static NSString *const kMASKeyChainClientExpiration = @"kMASKeyChainClientExpiration";
static NSString *const kMASKeyChainClientId = @"kMASKeyChainClientId";
static NSString *const kMASKeyChainClientSecret = @"kMASKeyChainClientSecret";

# pragma mark - Shared Constants

static NSString *const kMASKeyChainJwt = @"kMASKeyChainJwt";
static NSString *const kMASKeyChainMagIdentifier = @"kMASKeyChainMagIdentifier";
static NSString *const kMASKeyChainPrivateKey = @"kMASKeyChainPrivateKey";
static NSString *const kMASKeyChainPublicKey = @"kMASKeyChainPublicKey";
static NSString *const kMASKeyChainTrustedServerCertificate = @"kMASKeyChainTrustedServerCertificate";
static NSString *const kMASKeyChainSignedPublicCertificate = @"kMASKeyChainSignedPublicCertificate";


@interface MASKeyChainService : NSObject
{
    MASIKeyChainStore *_localStorage;
    MASIKeyChainStore *_sharedStorage;
}


# pragma mark - Properties

@property (nonatomic, assign, readonly) BOOL isConfigured;
@property (nonatomic, assign, readonly) BOOL isSharedStorageActive;


# pragma mark - Lifecycle

+ (MASKeyChainService *)keyChainService;


# pragma mark - Configuration

- (NSDictionary *)configuration;


- (void)setConfiguration:(NSDictionary *)configuration;


- (id)certificates;


- (id)identities;


# pragma mark - Local

- (NSString *)accessToken;


- (void)setAccessToken:(NSString *)accessToken;


- (NSString *)refreshToken;


- (void)setRefreshToken:(NSString *)refreshToken;


- (NSString *)scope;


- (void)setScope:(NSString *)scope;


- (NSString *)tokenType;


- (void)setTokenType:(NSString *)tokenType;


- (NSNumber *)expiresIn;


- (void)setExpiresIn:(NSNumber *)expiratesIn;


- (NSDate *)expiresInDate;


- (void)setExpiresInDate:(NSDate *)expiresInDate;


- (NSString *)idToken;


- (void)setIdToken:(NSString *)idToken;


- (NSString *)idTokenType;


- (void)setIdTokenType:(NSString *)idTokenType;


- (NSNumber *)clientExpiration;


- (void)setClientExpiration:(NSNumber *)clientExpiration;


- (NSString *)clientId;


- (void)setClientId:(NSString *)clientId;


- (NSString *)clientSecret;


- (void)setClientSecret:(NSString *)clientSecret;


# pragma mark - Shared

- (NSString *)jwt;


- (void)setJwt:(NSString *)jwt;


- (NSString *)magIdentifier;


- (void)setMagIdentifier:(NSString *)magIdentifier;


- (NSData *)privateKey;


- (void)setPrivateKey:(NSData *)privateKey;


- (NSData *)publicKey;


- (void)setPublicKey:(NSData *)publicKey;


- (NSData *)signedPublicCertificate;


- (NSData *)setSignedPublicCertificate:(NSData *)certificate;


- (NSData *)trustedServerCertificate;


- (void)setTrustedServerCertificate:(NSData *)certificate;


#ifdef DEBUG

# pragma mark - Debug only

- (void)clearLocal;


- (void)clearShared;


- (NSString *)debugSecuredDescription;

#endif

@end
