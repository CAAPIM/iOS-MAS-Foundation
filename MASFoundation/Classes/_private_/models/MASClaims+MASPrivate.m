//
//  MASClaims+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASClaims+MASPrivate.h"

#import "MASAccessService.h"

//  JWT
#import "JWT.h"
#import "JWTCryptoSecurity.h"
#import "JWTCryptoKeyExtractor.h"


@interface MASClaims ()

@end


@implementation MASClaims (MASPrivate)

- (NSString * __nullable)buildWithPrivateKey:(NSData * __nonnull)privateKey error:(NSError * __nullable __autoreleasing * __nullable)error
{
    
    //
    //  Prepare iat at current timestamp
    //
    [self setValue:[NSDate date] forKey:@"iat"];
    
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
    
    if (self.jti)
    {
        [payload setObject:self.jti forKey:@"jti"];
    }
    
    if (self.exp)
    {
        [payload setObject:[NSNumber numberWithInteger:[self.exp timeIntervalSince1970]] forKey:@"exp"];
    }
    
    if (self.iat)
    {
        [payload setObject:[NSNumber numberWithInteger:[self.iat timeIntervalSince1970]] forKey:@"iat"];
    }
    
    if (self.nbf)
    {
        [payload setObject:[NSNumber numberWithInteger:[self.nbf timeIntervalSince1970]] forKey:@"nbf"];
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
    //  Adding custom claims
    //
    [self.customClaims enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        [payload setObject:obj forKey:key];
    }];
    
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
