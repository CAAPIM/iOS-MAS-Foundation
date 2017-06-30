//
//  MASSecurityPolicy.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASISecurityPolicy.h"

typedef NS_ENUM(NSUInteger, MASSSLPinningMode) {
    MASSSLPinningModeNone,
    MASSSLPinningModePublicKey,
    MASSSLPinningModePublicKeyHash,
    MASSSLPinningModeCertificate,
};

@interface MASSecurityPolicy : MASISecurityPolicy

@property (readonly, nonatomic, assign) MASSSLPinningMode MASSSLPinningMode;

+ (instancetype)policyWithSecurityConfigurations:(NSDictionary *)configurations;

- (BOOL)evaluateSecurityConfigurationsForServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain;

+ (instancetype)policyWithMASPinningMode:(MASSSLPinningMode)pinningMode;

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust withPublicKeyHashes:(NSArray *)publicKeyHashes forDomain:(NSString *)domain;

@end
