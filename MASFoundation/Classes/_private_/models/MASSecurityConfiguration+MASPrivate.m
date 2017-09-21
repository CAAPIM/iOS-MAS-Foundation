//
//  MASSecurityConfiguration+MASPrivate.m
//  MASFoundation
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


#import "MASSecurityConfiguration+MASPrivate.h"

#import "NSData+MASPrivate.h"

@implementation MASSecurityConfiguration (MASPrivate)

- (NSArray *)convertCertificatesToData
{
    NSMutableArray *certsAsData = [NSMutableArray array];
    
    for (id certificate in self.certificates)
    {
        if ([certificate isKindOfClass:[NSArray class]])
        {
            NSData *certificateAsData = [NSData pemDataFromCertificateArray:certificate];
            
            if (certificateAsData)
            {
                [certsAsData addObject:certificateAsData];
            }
        }
        else if ([certificate isKindOfClass:[NSString class]])
        {
            NSData *certificateAsData = [NSData dataFromPEMBase64String:certificate];

            if (certificateAsData)
            {
                [certsAsData addObject:certificateAsData];
            }
        }
        else if ([certificate isKindOfClass:[NSData class]])
        {
            [certsAsData addObject:certificate];
        }
    }
    
    return [certsAsData count] > 0 ? certsAsData : nil;
}


- (NSArray *)convertCertificatesToSecCertificateRef
{
    NSMutableArray *certAsData = [[self convertCertificatesToData] mutableCopy];
    NSMutableArray *certAsRef = [NSMutableArray array];
    
    for (NSData *certificate in certAsData)
    {
        CFDataRef certificateAsDataRef = (__bridge CFDataRef)certificate;
        SecCertificateRef certRef = SecCertificateCreateWithData(NULL, certificateAsDataRef);
        
        if (certRef)
        {
            [certAsRef addObject:(__bridge_transfer id)certRef];
        }
    }
    
    return [certAsRef count] > 0 ? certAsRef : nil;
}


- (NSArray *)extractPublicKeyRefFromCertificateRefs:(NSArray *)certificateRef
{
    if ([certificateRef count] == 0)
    {
        return nil;
    }
    
    NSMutableArray *keysAsRef = [NSMutableArray array];
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    
    for (id certItem in certificateRef)
    {
        SecCertificateRef certificate = (__bridge SecCertificateRef)certItem;
        SecTrustRef serverTrust = NULL;
        
        if (SecTrustCreateWithCertificates(certificate, policy, &serverTrust) == noErr)
        {
            SecKeyRef publicKey = SecTrustCopyPublicKey(serverTrust);
            [keysAsRef addObject:(__bridge_transfer id)publicKey];
        }
        
        if (serverTrust)
        {
            CFRelease(serverTrust);
        }
    }
    
    if (policy)
    {
        CFRelease(policy);
    }
    
    return [keysAsRef count] > 0 ? keysAsRef : nil;
}


- (BOOL)validateCertificateChain
{
    return NO;
}

@end
