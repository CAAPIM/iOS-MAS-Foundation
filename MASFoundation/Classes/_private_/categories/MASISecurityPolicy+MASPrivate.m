//
//  MASISecurityPolicy+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASISecurityPolicy+MASPrivate.h"

#import <CommonCrypto/CommonDigest.h>

@implementation MASISecurityPolicy (MASPrivate)

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust withPublicKeyHashes:(NSArray *)publicKeyHashes forDomain:(NSString *)domain
{
    //
    //  If no public key hases are not presented
    //
    if ([publicKeyHashes count] == 0)
    {
        return NO;
    }
    
    //
    // From MASISecurityPolicy.m
    //
    if (domain && self.allowInvalidCertificates && self.validatesDomainName && (self.SSLPinningMode == MASISSLPinningModeNone || [self.pinnedCertificates count] == 0)) {
        // https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/OverridingSSLChainValidationCorrectly.html
        //  According to the docs, you should only trust your provided certs for evaluation.
        //  Pinned certificates are added to the trust. Without pinned certificates,
        //  there is nothing to evaluate against.
        //
        //  From Apple Docs:
        //          "Do not implicitly trust self-signed certificates as anchors (kSecTrustOptionImplicitAnchors).
        //           Instead, add your own (self-signed) CA certificate to the list of trusted anchors."
        DLog(@"In order to validate a domain name for self signed certificates, you MUST use pinning.");
        return NO;
    }

    NSMutableArray *policies = [NSMutableArray array];
    if (self.validatesDomainName) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    //
    // END OF MASISecurityPolicy.m
    //
    
    
    if (self.SSLPinningMode != MASISSLPinningModePublicKey) {
        
        NSAssert(self.SSLPinningMode != MASISSLPinningModePublicKey, @"For SSL pinning mode cert or none, use [MASISecurityPolicy evaluateServerTrust:forDomain:] instead.  This method is specifically intended for hashed public key");
        return NO;
    }
    
    
    switch (self.SSLPinningMode) {
            
        case MASISSLPinningModeCertificate:
            return NO;
            break;
        case MASISSLPinningModeNone:
            return NO;
            break;
        case MASISSLPinningModePublicKey:{
            
            NSMutableSet *pinningHashData = [NSMutableSet set];
            
            for (NSString *pinningHash in publicKeyHashes)
            {
                NSData *publicKeyHashData = [[NSData alloc] initWithBase64EncodedString:pinningHash options:(NSDataBase64DecodingOptions)0];
                [pinningHashData addObject:publicKeyHashData];
            }
            
            NSUInteger trustedPublicKeyHashCount = 0;
            NSArray *serverPublicKeys = [self publicKeyTrustChainForServerTrust:serverTrust];
            
            for (id trustChainPublicKey in serverPublicKeys)
            {
                NSData *publicKeyData = nil;
                
                SecKeyRef publicKey = (__bridge SecKeyRef)trustChainPublicKey;
                CFDataRef publicKeyDataRef = NULL;
                
                if (publicKey)
                {
                    publicKeyDataRef = SecKeyCopyExternalRepresentation(publicKey, NULL);
                    
                    if (publicKeyDataRef)
                    {
                        publicKeyData = (NSData *)CFBridgingRelease(publicKeyDataRef);
                        CFRelease(publicKeyDataRef);
                    }
                }
                
                if (!publicKeyData)
                {
                    if (publicKeyDataRef)
                    {
                        CFRelease(publicKeyDataRef);
                    }
                    
                    if (publicKey)
                    {
                        CFRelease(publicKey);
                    }
                    
                    continue;
                }
                else {
                    
//                    NSString *serverPublicKeyString = [NSString stringWithUTF8String:[publicKeyData bytes]];
                    
                    NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
                    CC_SHA256(publicKeyData.bytes, (CC_LONG)publicKeyData.length, sha256Data.mutableBytes);
                    
                    
                    if ([pinningHashData containsObject:sha256Data])
                    {
                        trustedPublicKeyHashCount++;
                    }
                    
                    if (publicKeyDataRef)
                    {
                        CFRelease(publicKeyDataRef);
                    }
                    
                    if (publicKey)
                    {
                        CFRelease(publicKey);
                    }
                }
            }
            
            DLog(@"what?");
            
        }
    }
    
    return NO;
}


//
// From MASISecurityPolicy
//
- (NSArray *)publicKeyTrustChainForServerTrust:(SecTrustRef)serverTrust
{
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray array];
    
    for (CFIndex i = 0; i < certificateCount; i++) {
        
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        
        SecCertificateRef someCertificates[] = {certificate};
        CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);
        
        SecTrustRef trust;
        OSStatus trustCertResult = SecTrustCreateWithCertificates(certificates, policy, &trust);
        
        if (trustCertResult != errSecSuccess)
        {
            continue;
        }
        
        SecTrustResultType result;
        OSStatus trustResult = SecTrustEvaluate(trust, &result);
        
        if (trustResult != errSecSuccess)
        {
            continue;
        }
        
        [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];

        if (trust)
        {
            CFRelease(trust);
        }
        
        if (certificates)
        {
            CFRelease(certificates);
        }
    }
    
    CFRelease(policy);
    
    return trustChain;
}

@end
