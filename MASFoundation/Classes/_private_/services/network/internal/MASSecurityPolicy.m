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

@interface MASSecurityPolicy ()

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
    //return YES;
    NSURL *domainURL = [NSURL URLWithString:domain];
    MASSecurityConfiguration *securityConfiguration = [MASConfiguration securityConfigurationForDomain:domainURL];
    
    //
    //  If there is no security configuration define, cancel request
    //
    if (securityConfiguration == nil)
    {
        return NO;
    }
    
    NSMutableArray *policies = [NSMutableArray array];
    
    //
    //  Set security policy for domain name associated with the server trust
    //
    if (securityConfiguration.validateDomainName)
    {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domainURL.host)];
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
    //
    //  If trustPublicPKI is set to NO, and there is no pinning information defined, reject connection
    //
    else if (!securityConfiguration.trustPublicPKI && (((([securityConfiguration.certificates isKindOfClass:[NSArray class]] && [securityConfiguration.certificates count] == 0)  || securityConfiguration.certificates == nil) && (([securityConfiguration.publicKeyHashes isKindOfClass:[NSArray class]] && [securityConfiguration.publicKeyHashes count] == 0) || securityConfiguration.publicKeyHashes == nil))))
    {
        return NO;
    }
    
    //
    //  Validate all pinning information that are present; even though it's duplicated process.
    //
    BOOL isPinningVerified = YES;
    NSArray *certificateChain = [self extractCertificateDataFromServerTrust:serverTrust];
    
    switch (securityConfiguration.pinningMode) {
        //Tricky case where the default behaviour is still the same as older release. If certificate is set check it or check if atleast public key hash is set, if yes verify public key hash. Not setting both would have errored out in the code above
        case MASSecuritySSLPinningModeCertificate:
        {
            BOOL isPublicKeyHashVerified = NO;
            
            if (securityConfiguration.publicKeyHashes != nil && [securityConfiguration.publicKeyHashes isKindOfClass:[NSArray class]] && [securityConfiguration.publicKeyHashes count] > 0)
            {
                isPublicKeyHashVerified = [self validatePublicKeyHash:serverTrust configuration:securityConfiguration];
            }
            else
            {
                isPublicKeyHashVerified = YES;
            }
            
            if(securityConfiguration.certificates != nil && [securityConfiguration.certificates isKindOfClass:[NSArray class]] && [securityConfiguration.certificates count] > 0)
            {
                isPinningVerified = ([self validateCertPinning:serverTrust configuration:securityConfiguration certChain:certificateChain]) && isPublicKeyHashVerified;
            }
            
        }
            break;
            
        case MASSecuritySSLPinningModeIntermediateCertifcate:
        {
            isPinningVerified = [self validateIntermediateCertPinning:serverTrust configuration:securityConfiguration certChain:certificateChain];
        }
            break;
        case MASSecuritySSLPinningModePublicKeyHash:
        {
            isPinningVerified = [self validatePublicKeyHash:serverTrust configuration:securityConfiguration];
        }
            break;
        
    }
    
    return isPinningVerified;
}


- (BOOL)validateCertPinning:(SecTrustRef)serverTrust configuration:(MASSecurityConfiguration *)securityConfiguration certChain:(NSArray *)certificateChain
{
    //
    //  pinning with certificates
    //
    if (securityConfiguration.certificates != nil && [securityConfiguration.certificates isKindOfClass:[NSArray class]] && [securityConfiguration.certificates count] > 0)
    {
        NSMutableArray *pinnedCertificatesData = [[securityConfiguration convertCertificatesToData] mutableCopy];
        if(![self validateAnchorTrust:serverTrust pinnedCerts:pinnedCertificatesData])
        {
            return NO;
        }
        
        
        //
        //  As of this point, if the configuration forces to validate the entire chain, validate entire chain of certificates
        //
        
        if (![securityConfiguration validateCertificateChain])
        {
            int matchingCertificatesCount = 0;
            
            for(int i=0;i<certificateChain.count;i++){
                NSData* dataVar = [[NSData alloc] initWithData:[certificateChain objectAtIndex:i]];
                NSString* base64String = [dataVar base64Encoding];
                NSLog(@"*************");
                NSLog(@"%@",base64String);
                NSLog(@"/********");
            }
            
            
            for (NSData *pinnedCertData in pinnedCertificatesData)
            {
                if ([certificateChain containsObject:pinnedCertData])
                {
                    matchingCertificatesCount++;
                }
            }
            
            //
            //  If matching certificates are not equal to pinned certificates, reject connection
            //
            if (matchingCertificatesCount != [certificateChain count])
            {
                return NO;
            }
            
            return YES;
        }
    }
    
    return NO;
}


//Validate the intermediate certificate pinning

- (BOOL)validateIntermediateCertPinning:(SecTrustRef)serverTrust configuration:(MASSecurityConfiguration *)securityConfiguration certChain:(NSArray *)certificateChain
{
    if (securityConfiguration.certificates != nil && [securityConfiguration.certificates isKindOfClass:[NSArray class]] && [securityConfiguration.certificates count] > 0)
    {
        NSMutableArray *pinnedCertificatesData = [[securityConfiguration convertCertificatesToData] mutableCopy];
        if(![self validateAnchorTrust:serverTrust pinnedCerts:pinnedCertificatesData])
        {
            return NO;
        }
        
        //
        // Since this part is only pinning intermediate certificates no need to validate the entire chain. Only make sure if the intermediate certs are part of the CertificateChain that server presented
        //
        for (NSData *pinnedCertData in pinnedCertificatesData)
        {
            if (![certificateChain containsObject:pinnedCertData])
            {
                return NO;
            }
        }
        
        return YES;
        
    }
    
    return NO;
}


//Validate server anchor trust based on the certificates that are pinned
- (BOOL)validateAnchorTrust:(SecTrustRef)serverTrust pinnedCerts:(NSArray *)pinnedCertificatesData
{
    //
    //  Set anchor cert with pinned certificates
    //
    NSMutableArray *pinnedCertificates = [NSMutableArray array];
    
    for (NSData *certificateData in pinnedCertificatesData)
    {
        [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
    }
    SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
    
    //
    //  Stop proceeding if validation of server trust against anchor (pinned) certificates
    //
    if (![self validateServerTrust:serverTrust])
    {
        return NO;
    }
    
    return YES;
}

//Pinning based on public key hash
- (BOOL)validatePublicKeyHash:(SecTrustRef)serverTrust configuration:(MASSecurityConfiguration *)securityConfiguration
{
    //
    //  pinning with public key hashes
    //
    if (securityConfiguration.publicKeyHashes != nil && [securityConfiguration.publicKeyHashes isKindOfClass:[NSArray class]] && [securityConfiguration.publicKeyHashes count] > 0)
    {
        
        //
        //  extract the server public key hash from serverTrust
        //
        NSArray *serverPublicKeyHashes = [self extractPublicKeyHashesFromServerTrust:serverTrust];
        
        //
        //  retrieve an array of public key hash strings from configuration
        //
        NSMutableArray *knownPublicKeyHashes = [NSMutableArray array];
        
        for (NSString *publicKeyHashString in securityConfiguration.publicKeyHashes)
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
        
        //
        //  if security configuration is set to not validate entire chain, only validate with the first item
        //
        if (![securityConfiguration validateCertificateChain] && [serverPublicKeyHashes count] > 0)
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
        
        //
        //  if there is no matching public key hash found,
        //  or matching public key hash count is not equal to # of public key presented in server trust while the security configuration expects entire chain to be validated,
        //  reject connection
        //
        if (trustedPublicKeyHashCount == 0 || ([securityConfiguration validateCertificateChain] && trustedPublicKeyHashCount != [serverPublicKeyHashes count]))
        {
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}
    



- (BOOL)validateServerTrust:(SecTrustRef)serverTrust
{
    BOOL isValid = YES;
    SecTrustResultType result = 0;
    CFErrorRef trustErrorRef = NULL;
    
    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){13,0,0}]) {
        
        isValid = SecTrustEvaluateWithError(serverTrust, &trustErrorRef);
    }
    else {
        if (SecTrustEvaluate(serverTrust, &result) != errSecSuccess)
        {
            isValid = NO;
        }
        else {
            isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
        }
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
