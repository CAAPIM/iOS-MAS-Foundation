//
//  NSData+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "NSData+MASPrivate.h"

#import "MASConstantsPrivate.h"

#import <CommonCrypto/CommonHMAC.h>
#import <objc/runtime.h>
#include <openssl/x509.h>
#include <openssl/evp.h>
#include <openssl/pem.h>

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation NSData (MASPrivate)

bool _encrypted = NO;

# pragma mark - Public

- (NSData *)dataFormattedAsCertificate
{
    NSMutableArray *stringAsArray = [NSMutableArray new];
 
    //
    // Convert data to string format
    //
    NSString *dataAsString = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
   
    DLog(@"\n\nCertificate data as string: %@\n\n", dataAsString    );
   
    //
    // Needs certificate prefix?
    //
    NSRange range = [dataAsString rangeOfString:MASCertificateBeginPrefix];
    if(range.location == NSNotFound)
    {
        [stringAsArray addObject:MASCertificateBeginPrefix];
    }
   
    //
    // Handle certificate data
    //
    NSString *substring;
    NSUInteger remaining;
    int blockSize = 76;
    for (int index = 0; index < dataAsString.length; index += blockSize)
    {
        remaining = dataAsString.length - index;

        range = (remaining > blockSize ? NSMakeRange(index, blockSize) : NSMakeRange(index, remaining));
        substring = [dataAsString substringWithRange:range];
        
        [stringAsArray addObject:substring];
    }
    
    //
    // Needs certificate suffix?
    //
    range = [dataAsString rangeOfString:MASCertificateEndSuffix];
    if(range.location == NSNotFound)
    {
        [stringAsArray addObject:MASCertificateEndSuffix];
    }
    
    DLog(@"\n\nCertificate data is: %@\n\n", stringAsArray);
    
    return [NSData dataFromCertificateArray:stringAsArray];
}


+ (NSData *)dataFromCertificateArray:(NSArray *)certificateArray
{
    NSString *certificateAsString = [certificateArray componentsJoinedByString:MASDefaultNewline];
    
    return [certificateAsString dataUsingEncoding:NSUTF8StringEncoding];
}


+ (id)dataWithBase64EncodedString:(NSString *)dataAsString
{
    //DLog(@"\n\ncalled with data as string:\n\n%@\n\n from:\n\n%@\n\n", dataAsString, [NSThread callStackSymbols]);
    
    //
    // The data string cannot be nil under any circumstance
    //
    NSParameterAssert(dataAsString);
    
    //
    // If it is an empty string then just return a base NSData instance
    //
    if ([dataAsString length] == 0)
    {
        return [NSData data];
    }

    static char *decodingTable = NULL;
    
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
        {
            return nil;
        }
        
        memset(decodingTable, CHAR_MAX, 256);
        for (NSUInteger i = 0; i < 64; i++)
        {
            decodingTable[(short)encodingTable[i]] = i;
        }
    }
  
    const char *characters = [dataAsString cStringUsingEncoding:NSASCIIStringEncoding];
    
    //
    // If not an ASCII string
    //
    if (characters == NULL)
    {
        return nil;
    }
    
    char *bytes = malloc((([dataAsString length] + 3) / 4) * 3);
    if (bytes == NULL)
    {
        return nil;
    }
    
    NSUInteger length = 0;
  
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
            break;
            if (isspace(characters[i]) || characters[i] == '=')
            {
                continue;
            }
            
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
    
        if (bufferLength == 0)
        {
            break;
        }
        
        if (bufferLength == 1)
        {
            free(bytes);
            return nil;
        }
    
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
        {
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        }
    
        if (bufferLength > 3)
        {
            bytes[length++] = (buffer[2] << 6) | buffer[3];
        }
    }
    
    return [NSData dataWithBytesNoCopy:bytes length:length];
}


- (NSString *)base64Encoding
{
    //
    // A zero length NSData will return a zero length NSString
    //
    if ([self length] == 0)
    {
        return @"";
    }
  
    char *characters = malloc((([self length] + 2) / 3) * 4);
    if (characters == NULL)
    {
        return nil;
    }
  
    NSUInteger length = 0;
  
    NSUInteger i = 0;
    while (i < [self length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [self length])
        {
            buffer[bufferLength++] = ((char *)[self bytes])[i++];
        }
        
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
        {
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        }
        
        else
        {
            characters[length++] = '=';
        }
        
        if (bufferLength > 2)
        {
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        }
        
        else
        {
            characters[length++] = '=';
        }
    }
  
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

+ (NSData *)convertPEMCertificateToDERCertificate:(NSString *)PEMCertificate
{
    BIO *pemCertificateBio = BIO_new(BIO_s_mem());
    BIO_write(pemCertificateBio, [PEMCertificate UTF8String], (int)strlen([PEMCertificate UTF8String]));
    
    X509 *x = PEM_read_bio_X509(pemCertificateBio,NULL,0,NULL);
    BIO *outDerBio = BIO_new(BIO_s_mem());
    i2d_X509_bio(outDerBio, x);
    
    int len = BIO_pending(outDerBio);
    char *out = calloc(len + 1, 1);
    int i = BIO_read(outDerBio, out, len);
    
    return [NSData dataWithBytes:out length:i];
}


+ (NSData *)sign:(NSString *)data key:(NSString *)key
{
    if(key==nil || data == nil){
        return nil;
    }
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACSignature = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return HMACSignature;
}

#pragma mark - Encryption Methods

- (void)encrypted:(BOOL)value
{
    _encrypted = value;
}

@end
