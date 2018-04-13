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


+ (NSData *)pemDataFromCertificateArray:(NSArray *)certificateArray
{
    NSString *base64String = [certificateArray componentsJoinedByString:MASDefaultNewline];
    
    return [self dataFromPEMBase64String:base64String];
}


+ (NSData *)dataFromPEMBase64String:(NSString *)base64String
{
    base64String = [base64String stringByReplacingOccurrencesOfString:MASDefaultNewline withString:@""];
    base64String = [base64String stringByReplacingOccurrencesOfString:MASCertificateBeginPrefix withString:@""];
    base64String = [base64String stringByReplacingOccurrencesOfString:MASCertificateEndSuffix withString:@""];
    
    return [self dataWithBase64EncodedString:base64String];
}


+ (NSData *)converKeyRefToNSData:(SecKeyRef)keyRef
{
    //            Below two lines of codes will replace the rest of PrivateKey conversion which is only available on iOS 10 or above.
    //            Will discuss when we will deprecate and replace the codes.
    //
    //            CFDataRef publicKeyDataRef = SecKeyCopyExternalRepresentation(publicKey, NULL);
    //            publicKeyData = (NSData *)CFBridgingRelease(publicKeyDataRef);
    
    NSData *keyData = nil;
    NSString *temporaryAppTag = @"MASKeyTemporaryTag";
    
    //
    //  SecKeyCopyExternalRepresentation is only availabe on iOS 10 or above; therefore, to extract NSData out of SecKeyRef,
    //  we have to store the SecKeyRef into keychain, and remove it
    //
    
    //
    //  adding public key into keychain storage
    //
    NSMutableDictionary *storeKey = [NSMutableDictionary dictionary];
    [storeKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [storeKey setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    [storeKey setObject:(__bridge id)(kCFBooleanTrue) forKey:(__bridge id)kSecReturnData];
    [storeKey setObject:(__bridge id)keyRef forKey:(__bridge id)kSecValueRef];
    [storeKey setObject:temporaryAppTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    //
    //  retreive the public key from the keychain as CFDataRef type
    //
    if (SecItemAdd((__bridge CFDictionaryRef)storeKey, (void *)&keyData) == errSecSuccess)
    {
        //
        //  make sure to delete the keychain data when it's successfully retrieved
        //
        NSMutableDictionary *removeKey = [NSMutableDictionary dictionary];
        [removeKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [removeKey setObject:(__bridge id)(kCFBooleanFalse) forKey:(__bridge id)kSecReturnData];
        [removeKey setObject:temporaryAppTag forKey:(__bridge id)kSecAttrApplicationTag];
        
        SecItemDelete((__bridge CFDictionaryRef)removeKey);
    }
    
    return keyData;
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
    NSData *PEMData = [NSData dataFromPEMBase64String:PEMCertificate];
    SecCertificateRef certificateRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)PEMData);
    CFDataRef DEREncodedData = SecCertificateCopyData(certificateRef);

    NSData *DERData = (__bridge NSData*)DEREncodedData;
    CFRelease(certificateRef);
    CFRelease(DEREncodedData);
    
    return DERData;
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


- (NSString *)mimeType
{
    uint8_t c;
    [self getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}

#pragma mark - Encryption Methods

- (void)encrypted:(BOOL)value
{
    _encrypted = value;
}

@end
