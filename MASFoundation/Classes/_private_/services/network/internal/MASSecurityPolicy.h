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


/**
 Enumeration value definition for SSL pinning

 - MASSSLPinningModeNone: no pinning
 - MASSSLPinningModePublicKey: pinning with public key
 - MASSSLPinningModePublicKeyHash: pinning with public key hash
 - MASSSLPinningModeCertificate: pinning with certificate
 */
typedef NS_ENUM(NSUInteger, MASSSLPinningMode) {
    MASSSLPinningModeNone,
    MASSSLPinningModePublicKey,
    MASSSLPinningModePublicKeyHash,
    MASSSLPinningModeCertificate,
};


/**
 MASSecurityPolicy class is responsible for handling SSL pinning
 */
@interface MASSecurityPolicy : NSObject


/**
 SSL pinning mode enumeration value
 */
@property (readonly, nonatomic, assign) MASSSLPinningMode MASSSLPinningMode;



/**
 Initialize MASSecurityPolicy object with pinning mode

 @param pinningMode MASSSLPinningMode for the security policy
 @return MASSecurityPolicy object
 */
+ (instancetype)policyWithMASPinningMode:(MASSSLPinningMode)pinningMode;



- (BOOL)evaluateSecurityConfigurationsForServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain;

/**
 Evaluate the ServerTrust with defined pinning logic

 @param serverTrust SecTrustRef of ServerTrust
 @param publicKeyHashes Array of public key hashes
 @param domain NSString of host domain name challenged for authentication
 @return BOOL value whether the pinning was successful or not based on defined settings and logic
 */
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust withPublicKeyHashes:(NSArray *)publicKeyHashes forDomain:(NSString *)domain;

@end
