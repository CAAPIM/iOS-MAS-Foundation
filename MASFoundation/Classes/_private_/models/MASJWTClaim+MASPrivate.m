//
//  MASJWTClaim+MASPrivate.m
//  MASFoundation
//
//  Created by Hun Go on 2017-03-22.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASJWTClaim+MASPrivate.h"

#import "MASAccessService.h"
#import "MASFileService.h"

//  JWT
#import "JWT.h"
#import "JWTCryptoSecurity.h"
#import "JWTCryptoKeyExtractor.h"

//  openssl
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/x509.h>
#include <openssl/pkcs12.h>

@interface MASJWTClaim ()

@property (nonatomic, assign, readwrite) NSInteger iat;

@end

@implementation MASJWTClaim (MASPrivate)

- (NSString * __nullable)buildWithErrorRef:(NSError * __nullable __autoreleasing * __nullable)error
{
    //
    //  Prepare iat at current timestamp
    //
    self.iat = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    
    //
    //  Add all reserved claims
    //
    if (self.iss)
    {
        [payload setObject:self.iss forKey:@"iss"];
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
    
    //
    //  Adding custom claims
    //
    [self.customClaims enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        [payload setObject:obj forKey:key];
    }];
    
    NSString *algorithmName = @"RS256";
    id<JWTRSAlgorithm> algorithm = (id<JWTRSAlgorithm>)[JWTAlgorithmFactory algorithmByName:algorithmName];
    
    NSString *pemPrivateKey = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypePrivateKeyBits];
    //NSString *plainString = [JWTCryptoSecurity keyFromPemFileContent:pemPrivateKey];
    NSData *pemCertificateData = [[MASAccessService sharedService] getAccessValueDataWithType:MASAccessValueTypeSignedPublicCertificateData];
    NSString *pemCertificate = [[NSString alloc] initWithData:pemCertificateData encoding:NSUTF8StringEncoding];
    
    const char *certChars = [pemCertificate cStringUsingEncoding:NSUTF8StringEncoding];
    
    BIO *buffer = BIO_new(BIO_s_mem());
    BIO_puts(buffer, certChars);
    
    X509 *cert = PEM_read_bio_X509(buffer, NULL, 0, NULL);
    
    if (cert != NULL)
    {
        X509_print_fp(stdout, cert);
        
        const char *privateChars = [pemPrivateKey cStringUsingEncoding:NSUTF8StringEncoding];
        BIO *pBuffer = BIO_new_mem_buf(privateChars, -1);
        EVP_PKEY *pKey = PEM_read_bio_PrivateKey(pBuffer, NULL, NULL, 0);
        
        if (X509_check_private_key(cert, pKey))
        {
            
            PKCS12 *p12;
            SSLeay_add_all_algorithms();
            ERR_load_CRYPTO_strings();
            p12 = PKCS12_create("password", "privateKey", pKey, cert, NULL, 0, 0, 0, 0, 0);
            
            NSString *p12FilePath = [[MASFileService sharedService] getFilePathForFileName:@"p12pKey.p12" fileDirectoryType:MASFileDirectoryTypeTemporary];
            
            if (![[NSFileManager defaultManager] createFileAtPath:p12FilePath contents:nil attributes:nil])
            {
                if (error)
                {
                    *error = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:MASFoundationErrorCodeJWTInvalidPrivateKey userInfo:nil];
                }
            }
            else {
                
                //get a FILE struct for the P12 file
                NSFileHandle *outputFileHandle = [NSFileHandle fileHandleForWritingAtPath:p12FilePath];
                FILE *p12File = fdopen([outputFileHandle fileDescriptor], "w");
                
                i2d_PKCS12_fp(p12File, p12);
                PKCS12_free(p12);
                fclose(p12File);
                
                NSData *privateKeyData = [NSData dataWithContentsOfFile:p12FilePath];
                
                JWTBuilder *jwtBuilder = [JWTBuilder encodePayload:payload].privateKeyCertificatePassphrase(@"password").secretData(privateKeyData).algorithmName(@"RS256").algorithm(algorithm);
                
                if (!jwtBuilder.jwtError && jwtBuilder.encode)
                {
                    return jwtBuilder.encode;
                }
            }
        }
        else {
            
            //
            //  Mismatch of private key and cert
            //
            if (error)
            {
                *error = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:MASFoundationErrorCodeJWTInvalidPrivateKey userInfo:nil];
            }
        }
    }
    else {
        
        //
        //  Failure to retrieve certificate
        //
        if (error)
        {
            *error = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:MASFoundationErrorCodeJWTInvalidPrivateKey userInfo:nil];
        }
    }
    
    return nil;
}

@end
