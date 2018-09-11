//
//  MASDERCertificate.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDERCertificate.h"

#import "MASASN1Decoder.h"
#import "MASASN1Object.h"

@interface MASDERCertificate ()

@property (strong, nonatomic) NSData *certData;
@property (strong, nonatomic) NSArray *certElements;

@end


@implementation MASDERCertificate

# pragma mark - Lifecycle

- (instancetype)initWithDERCertificateData:(NSData *)certData
{
    self = [super init];
    
    if (self)
    {
        self.certData = certData;
    }
    
    return self;
}


- (instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`-init` is not available. Use `-initWithRequest:` instead"
                                 userInfo:nil];
    return nil;
}


+ (instancetype)new
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`+new` is not available. Use `-initWithRequest:` instead"
                                 userInfo:nil];
    return nil;
}


# pragma mark - Public

- (void)parseCertificateData
{
    if (self.certData)
    {
        MASASN1Decoder *decoder = [[MASASN1Decoder alloc] initWithDERData:self.certData];
        self.certElements = [decoder decodeASN1];
        
        if (self.certElements != nil && [self.certElements count] > 0)
        {
            MASASN1Object *certificate = [self.certElements firstObject];
            MASASN1Object *certificateInfoBlock;
            
            if (certificate != nil && [certificate.sub count] > 0)
            {
                certificateInfoBlock = [[certificate sub] firstObject];
            }
            
            if (certificateInfoBlock != nil)
            {
                //
                //  ASN1 Structure for X509 block
                //
                //  0 = version
                //  1 = serial number
                //  2 = signature algorithm
                //  3 = issuer
                //  4 = not before / not after date
                //  5 = subject
                //  6 = public key
                //  7 = extension
                //
                
                //
                //  Issuer section
                //
                NSMutableArray *mutableIssuer = nil;
                if (certificateInfoBlock && [certificateInfoBlock.sub count] > 4)
                {
                    mutableIssuer = [NSMutableArray array];
                    MASASN1Object *issuerObject = [certificateInfoBlock.sub objectAtIndex:3];
                    
                    for (MASASN1Object *subObject in issuerObject.sub)
                    {
                        MASASN1Object *subSet = [[subObject sub] firstObject];
                        MASASN1Object *setObjId = [[subSet sub] firstObject];
                        
                        if (setObjId.tag == MASASN1TagObjId && [[subSet sub] count] == 2)
                        {
                            MASASN1Object *objValue = [[subSet sub] objectAtIndex:1];
                            [mutableIssuer addObject:[NSDictionary dictionaryWithObject:objValue.value forKey:setObjId.value]];
                        }
                    }
                }
                self.issuer = mutableIssuer;
                
                //
                //  Validity section
                //
                if (certificateInfoBlock && [certificateInfoBlock.sub count] > 5)
                {
                    MASASN1Object *validityObject = [certificateInfoBlock.sub objectAtIndex:4];
                    MASASN1Object *notBefore = [validityObject.sub objectAtIndex:0];
                    MASASN1Object *notAfter = [validityObject.sub objectAtIndex:1];
                    
                    if ([notBefore.value isKindOfClass:[NSDate class]])
                    {
                        self.notBefore = notBefore.value;
                    }
                    
                    if ([notAfter.value isKindOfClass:[NSDate class]])
                    {
                        self.notAfter = notAfter.value;
                    }
                }
                
                //
                //  Subject section
                //
                NSMutableArray *mutableSubject = nil;
                if (certificateInfoBlock && [certificateInfoBlock.sub count] > 6)
                {
                    mutableSubject = [NSMutableArray array];
                    MASASN1Object *subjectObject = [certificateInfoBlock.sub objectAtIndex:5];
                    
                    for (MASASN1Object *subObject in subjectObject.sub)
                    {
                        MASASN1Object *subSet = [[subObject sub] firstObject];
                        MASASN1Object *setObjId = [[subSet sub] firstObject];
                        
                        if (setObjId.tag == MASASN1TagObjId && [[subSet sub] count] == 2)
                        {
                            MASASN1Object *objValue = [[subSet sub] objectAtIndex:1];
                            [mutableSubject addObject:[NSDictionary dictionaryWithObject:objValue.value forKey:setObjId.value]];
                        }
                    }
                }
                self.subject = mutableSubject;
            }
        }
    }
}

@end
