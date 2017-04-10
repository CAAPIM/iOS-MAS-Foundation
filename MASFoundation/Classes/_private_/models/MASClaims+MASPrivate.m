//
//  MASClaims+MASPrivate.m
//  MASFoundation
//
//  Created by Hun Go on 2017-04-04.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASClaims+MASPrivate.h"

#import "MASAccessService.h"

//  JWT
#import "JWT.h"
#import "JWTCryptoSecurity.h"
#import "JWTCryptoKeyExtractor.h"


@interface MASClaims ()

@property (assign, readwrite) NSInteger iat;

@end


@implementation MASClaims (MASPrivate)

- (NSString * __nullable)buildWithPrivateKey:(NSData * __nonnull)privateKey error:(NSError * __nullable __autoreleasing * __nullable)error
{
    
    //
    //  Prepare iat at current timestamp
    //
    [self setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"iat"];
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    
    //
    //  Add all reserved claims
    //
    if (self.iss)
    {
        [payload setObject:self.iss forKey:@"iss"];
    }
    else {
        
        //
        //  If iss was not prepare upon MASClaims object construction which most likley happened due to registration status of the client,
        //  re-prepare iss with registered client id
        //
        NSString *magIdentifier = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier];
        NSString *clientId = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientId];
        
        if (magIdentifier && clientId)
        {
            [self setValue:[NSString stringWithFormat:@"device://%@/%@", magIdentifier, clientId] forKey:@"iss"];
            [payload setObject:self.iss forKey:@"iss"];
        }
    }
    
    if (self.aud)
    {
        [payload setObject:self.aud forKey:@"aud"];
    }
    
    if (self.sub)
    {
        [payload setObject:self.sub forKey:@"sub"];
    }
    
    if (self.exp)
    {
        [payload setObject:[NSNumber numberWithInteger:self.exp] forKey:@"exp"];
    }
    
    if (self.jti)
    {
        [payload setObject:self.jti forKey:@"jti"];
    }
    
    if (self.iat)
    {
        [payload setObject:[NSNumber numberWithInteger:self.iat] forKey:@"iat"];
    }
    
    if (self.content)
    {
        [payload setObject:self.content forKey:@"content"];
    }
    
    if (self.contentType)
    {
        [payload setObject:self.contentType forKey:@"content-type"];
    }
    
    //
    //  MASClaims will only sign with RS256 which is mutually agreed with
    //
    NSString *algorithmName = @"RS256";
    id<JWTRSAlgorithm> algorithm = (id<JWTRSAlgorithm>)[JWTAlgorithmFactory algorithmByName:algorithmName];
    
    //
    //  Prepare data holder with private key as PEM Base64 in NSData
    //
    id <JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor privateKeyWithPEMBase64].type).algorithm(algorithm).secretData(privateKey);
    
    //
    //  Construct JWT builder with payload and data holder
    //
    JWTCodingBuilder *builder = [JWTEncodingBuilder encodePayload:payload].addHolder(dataHolder);
    
    //
    //  Build
    //
    JWTCodingResultType *signResult = builder.result;
    
    if (signResult.successResult.encoded)
    {
        return signResult.successResult.encoded;
    }
    else {
        *error = signResult.errorResult.error;
        return nil;
    }
}

@end
