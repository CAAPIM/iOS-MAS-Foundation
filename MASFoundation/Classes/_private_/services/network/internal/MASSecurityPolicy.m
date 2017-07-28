//
//  MASSecurityPolicy.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSecurityPolicy.h"

#import "MASConstantsPrivate.h"
#import "MASSecurityConfiguration.h"
#import "MASSecurityConfiguration+MASPrivate.h"
#import "NSData+MASPrivate.h"

#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

#define MAS_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface MASSecurityPolicy ()

@property (readwrite, nonatomic, assign) MASSSLPinningMode MASSSLPinningMode;
@property (nonatomic, strong) NSDictionary *securityConfigurations;

@end

@implementation MASSecurityPolicy

static unsigned char rsa2048Asn1Header[] = {
    0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
};


+ (instancetype)policyWithSecurityConfigurations:(NSDictionary *)configurations
{
    MASSecurityPolicy *securityPolicy = [[MASSecurityPolicy alloc] init];
    securityPolicy.securityConfigurations = [configurations copy];
    
    return securityPolicy;
}


- (BOOL)evaluateSecurityConfigurationsForServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    MASSecurityConfiguration *securityConfiguration = [_securityConfigurations objectForKey:domain];
    
    //
    //  If there is no security configuration define, cancel request
    //
    if (securityConfiguration == nil)
    {
        return NO;
    }
    
    //
    //  Proceed if pinning mode is set to none
    //
    if (securityConfiguration.pinningMode == MASSecuritySSLPinningModeNone)
    {
        return YES;
    }
    
    NSMutableArray *policies = [NSMutableArray array];
    
    //
    //  Set security policy for domain name associated with the server trust
    //
    if (securityConfiguration.validateDomainName)
    {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    //
    //  Validate server trust validity
    //
    if (securityConfiguration.trustPublicPKI && ![self validateServerTrust:serverTrust])
    {
        return NO;
    }
    
    BOOL isPinningVerified = NO;
    NSArray *certificateChain = [self extractCertificateDataFromServerTrust:serverTrust];
    
    switch (securityConfiguration.pinningMode) {
        case MASSecuritySSLPinningModeCertificate:
        {
            //
            //  If certificate is not found from configuration, cancel request
            //
            if ([securityConfiguration.certificates count] == 0)
            {
                isPinningVerified = NO;
            }
            else {
                
                NSMutableArray *pinnedCertificates = [[securityConfiguration convertCertificatesToSecCertificateRef] mutableCopy];
                NSMutableArray *pinnedCertificatesData = [[securityConfiguration convertCertificatesToData] mutableCopy];
                
                SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
                
                //
                //  Stop proceeding if validation of server trust against anchor (pinned) certificates
                //
                if (![self validateServerTrust:serverTrust])
                {
                    return NO;
                }
                
                //
                //  As of this point, if the configuration doesn't force to validate the entire chain, proceeds the request
                //
                if (!securityConfiguration.validateCertificateChain)
                {
                    return YES;
                }
                else {
                    
                    int matchingCertificatesCount = 0;
                    
                    for (NSData *trustCertData in certificateChain)
                    {
                        if ([pinnedCertificatesData containsObject:trustCertData])
                        {
                            matchingCertificatesCount++;
                        }
                    }
                    
                    return matchingCertificatesCount == [pinnedCertificatesData count];
                }
            }
        }
            break;
        case MASSecuritySSLPinningModePublicKey:
        {
            
            NSArray *pinnedPublicKeyRefs = [securityConfiguration convertPublicKeysToSecKeyRef];
            NSArray *certificateRefArray = [self extractCertificateRefFromServerTrust:serverTrust];
            NSArray *serverTrustPublicKeyRefs = [securityConfiguration extractPublicKeyRefFromCertificateRefs:certificateRefArray];
            
            if ([pinnedPublicKeyRefs count] != [serverTrustPublicKeyRefs count])
            {
                return NO;
            }
            else {
                int matchingPublicKeysCouont = 0;
                
                if (!securityConfiguration.validateDomainName && [serverTrustPublicKeyRefs count] > 0)
                {
                    serverTrustPublicKeyRefs = @[[serverTrustPublicKeyRefs firstObject]];
                }
                
                for (id serverTrustPublicKey in serverTrustPublicKeyRefs)
                {
                    for (id pinnedPublicKey in pinnedPublicKeyRefs)
                    {
                        NSData *pinnedKeyData = [NSData converKeyRefToNSData:(__bridge SecKeyRef)pinnedPublicKey];
                        NSData *trustKeyData = [NSData converKeyRefToNSData:(__bridge SecKeyRef)serverTrustPublicKey];
                        
                        if ([pinnedKeyData isEqual:trustKeyData])
                        {
                            matchingPublicKeysCouont++;
                        }
                    }
                }
                
                return matchingPublicKeysCouont == [serverTrustPublicKeyRefs count];
            }
        }
            break;
        case MASSecuritySSLPinningModePublicKeyHash:
        {
            
        }
            break;
        default:
            break;
    }
    
    return isPinningVerified;
}


+ (instancetype)policyWithMASPinningMode:(MASSSLPinningMode)pinningMode
{
    MASISSLPinningMode masISSLPinningMode;
    
    switch (pinningMode) {
        case MASSSLPinningModeCertificate:
        masISSLPinningMode = MASISSLPinningModeCertificate;
        break;
        
        case MASSSLPinningModeNone:
        masISSLPinningMode = MASISSLPinningModeNone;
        break;
        
        case MASSSLPinningModePublicKey:
        masISSLPinningMode = MASISSLPinningModePublicKey;
        break;
        
        case MASSSLPinningModePublicKeyHash:
        masISSLPinningMode = MASISSLPinningModePublicKey;
        break;
        
        default:
        masISSLPinningMode = MASISSLPinningModeNone;
        break;
    }
    
    MASSecurityPolicy *securityPolicy = [super policyWithPinningMode:masISSLPinningMode];
    securityPolicy.MASSSLPinningMode = pinningMode;
    
    [securityPolicy setPinnedCertificates:[self defaultPinnedCertificates]];
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesCertificateChain = NO;
    
    return securityPolicy;
}


+ (NSArray *)defaultPinnedCertificates {
    static NSArray *_defaultPinnedCertificates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
        
        NSMutableArray *certificates = [NSMutableArray arrayWithCapacity:[paths count]];
        for (NSString *path in paths) {
            NSData *certificateData = [NSData dataWithContentsOfFile:path];
            [certificates addObject:certificateData];
        }
        
        _defaultPinnedCertificates = [[NSArray alloc] initWithArray:certificates];
    });
    
    return _defaultPinnedCertificates;
}


- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust withPublicKeyHashes:(NSArray *)publicKeyHashes forDomain:(NSString *)domain
{
    //
    //  If no public key hases are not presented
    //
    if ([publicKeyHashes count] == 0)
    {
        return NO;
    }
    
    if (self.MASSSLPinningMode != MASSSLPinningModePublicKeyHash) {
        
        NSAssert(self.SSLPinningMode != MASSSLPinningModePublicKeyHash, @"For SSL pinning mode cert, plain public key, or none, use [MASISecurityPolicy evaluateServerTrust:forDomain:] instead.  This method is specifically intended for hashed public key");
        return NO;
    }
    
    //
    // From MASISecurityPolicy.m
    //
    if (domain && self.allowInvalidCertificates && self.validatesDomainName && (self.MASSSLPinningMode == MASSSLPinningModeNone || ([self.pinnedCertificates count] == 0 && [publicKeyHashes count] == 0))) {
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
    
    if (![self validateServerTrust:serverTrust] && !self.allowInvalidCertificates)
    {
        return NO;
    }
    //
    // END OF MASISecurityPolicy.m
    //
    
    
        
    //
    //  extract the server public key hash from serverTrust
    //
    NSArray *serverPublicKeyHashes = [self extractPublicKeyHashesFromServerTrust:serverTrust];
    
    //
    //  retrieve an array of public key hash strings from configuration
    //
    NSMutableArray *knownPublicKeyHashes = [NSMutableArray array];
    
    for (NSString *publicKeyHashString in publicKeyHashes)
    {
        //
        //  create NSData based on base64 encoded public key hash
        //
        NSMutableData *publicKeyHashData = [[NSMutableData alloc] initWithBase64EncodedString:publicKeyHashString options:(NSDataBase64DecodingOptions)0];
        
        //
        //  make sure that the public keys are SHA256 hashed
        //
        if ([publicKeyHashData length] == CC_SHA256_DIGEST_LENGTH)
        {
            [knownPublicKeyHashes addObject:publicKeyHashData];
        }
    }
    
    //
    //  SDK will continue only when the set of the trust chain form the challenge is a subset of the public key hashes on the client side
    //
    NSUInteger trustedPublicKeyHashCount = 0;
    
    if (!self.validatesCertificateChain && [serverPublicKeyHashes count] > 0)
    {
        serverPublicKeyHashes = @[[serverPublicKeyHashes firstObject]];
    }
    
    for (NSData *serverPublicKeyHash in serverPublicKeyHashes)
    {
        if ([knownPublicKeyHashes containsObject:serverPublicKeyHash])
        {
            trustedPublicKeyHashCount++;
        }
    }
    
    return trustedPublicKeyHashCount > 0 && ((self.validatesCertificateChain && trustedPublicKeyHashCount == [serverPublicKeyHashes count]) || (!self.validatesCertificateChain && trustedPublicKeyHashCount >= 1));
}


- (BOOL)validateServerTrust:(SecTrustRef)serverTrust
{
    BOOL isValid = YES;
    SecTrustResultType result = 0;
    
    if (SecTrustEvaluate(serverTrust, &result) != errSecSuccess)
    {
        isValid = NO;
    }
    else {
        isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    }
    
    return isValid;
}


- (NSArray *)extractCertificateRefFromServerTrust:(SecTrustRef)serverTrust
{
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *certificateChain = [NSMutableArray array];
    
    for (CFIndex i = 0; i < certificateCount; i++)
    {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        [certificateChain addObject:(__bridge id _Nonnull)(certificate)];
    }
    
    return certificateChain;
}


- (NSArray *)extractCertificateDataFromServerTrust:(SecTrustRef)serverTrust
{
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *certificateChain = [NSMutableArray array];
    
    for (CFIndex i = 0; i < certificateCount; i++)
    {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        [certificateChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
    }
    
    return certificateChain;
}


- (NSArray<NSData *> *)extractPublicKeyHashesFromServerTrust:(SecTrustRef)serverTrust
{
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *serverPublicKeyHashes = [NSMutableArray array];
    
    //
    //  loop through the certificate chain
    //
    for (CFIndex i = 0; i < certificateCount; i++)
    {
        //
        //  retrieve an individual certificate and convert the cert into public key hased NSData
        //
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        NSData *publicKeyHashData = [self getPublicKeyFromCertificateRef:certificate];
        
        if (publicKeyHashData)
        {
            [serverPublicKeyHashes addObject:publicKeyHashData];
        }
    }
    
    return serverPublicKeyHashes;
}


- (NSData *)getPublicKeyFromCertificateRef:(SecCertificateRef)certificate
{
    //
    //  Create publicKey, temporary server trust, and policy references
    //
    SecKeyRef publicKey = NULL;
    SecTrustRef serverTrust = NULL;
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    
    //
    //  Declare the public key data
    //
    NSData *publicKeyHashData = nil;
    
    //
    //  if creating server trust with the provided policy, continue on hashing public key
    //
    if (policy && SecTrustCreateWithCertificates(certificate, policy, &serverTrust) == noErr)
    {
        //
        //  extract public key out of the trust
        //
        publicKey = SecTrustCopyPublicKey(serverTrust);
        
        if (publicKey)
        {
            NSData *publicKeyData = [NSData converKeyRefToNSData:publicKey];
            
            if (publicKeyData)
            {
                //
                //  construct NSMutableData for SHA256 digest length
                //
                publicKeyHashData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
                CC_SHA256_CTX shaCtx;
                CC_SHA256_Init(&shaCtx);
                
                //
                //  adding RSA 2048 ASN.1 header
                //
                CC_SHA256_Update(&shaCtx, rsa2048Asn1Header, sizeof(rsa2048Asn1Header));
                
                CC_SHA256_Update(&shaCtx, [publicKeyData bytes], (unsigned int)[publicKeyData length]);
                CC_SHA256_Final((unsigned char *)[publicKeyHashData bytes], &shaCtx);
            }
        }
    }
    
    if (policy)
    {
        CFRelease(policy);
    }
    
    if (serverTrust)
    {
        CFRelease(serverTrust);
    }
    
    if (publicKey)
    {
        CFRelease(publicKey);
    }
    
    return publicKeyHashData;
}

@end
