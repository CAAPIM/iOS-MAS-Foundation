//
//  NSMutableData+MASASN1Helper.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "NSMutableData+MASASN1Helper.h"

static uint8_t sequenceTag = 0x30;
static uint8_t setTag = 0x31;
static uint8_t rsaEncryptionNULL[13] = {0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00};

@implementation NSMutableData (MASASN1Helper)

# pragma mark - ASN.1 DER hex helper methods

- (void)appendSubjectItem:(uint8_t[])attribute size:(int)size value:(NSString *)value
{
    NSMutableData *subjectItem = [[NSMutableData alloc] initWithCapacity:128];
    [subjectItem appendBytes:attribute length:size];
    [subjectItem appendUTF8String:value];
    [subjectItem encloseWith:sequenceTag];
    [subjectItem encloseWith:setTag];
    
    [self appendData:subjectItem];
}


- (void)encloseWith:(uint8_t)tag
{
    NSMutableData *newData = [[NSMutableData alloc]  initWithCapacity:[self length] + 4];
    [newData appendBytes:&tag length:1];
    [newData appendDERLength:[self length]];
    [newData appendData:self];
    
    [self setData:newData];
}


- (void)encloseWithSequenceTag
{
    [self encloseWith:sequenceTag];
}


+ (NSData *)buildPublicKeyForASN1:(NSData *)publicKeyBits
{
    NSMutableData *publicKeyData = [[NSMutableData alloc] initWithCapacity:390];
    
    [publicKeyData appendBytes:rsaEncryptionNULL length:sizeof(rsaEncryptionNULL)];
    [publicKeyData encloseWith:sequenceTag];
    
    NSMutableData *publicKeyASN = [[NSMutableData alloc] initWithCapacity:260];
    
    //
    //  Add public key's mod info
    //
    NSData *mod = [NSMutableData getPublicKeyMod:publicKeyBits];
    char integer = 0x02; // Integer
    [publicKeyASN appendBytes:&integer length:1];
    [publicKeyASN appendDERLength:[mod length]];
    [publicKeyASN appendData:mod];
    
    //
    //  Add public key exp info
    //
    NSData *exp = [NSMutableData getPublicKeyExp:publicKeyBits];
    
    [publicKeyASN appendBytes:&integer length:1];
    [publicKeyASN appendDERLength:[exp length]];
    [publicKeyASN appendData:exp];
    
    [publicKeyASN encloseWith:sequenceTag];
    [publicKeyASN prependByte:0x00];
    
    [publicKeyData appendBITString:publicKeyASN];
    [publicKeyData encloseWith:sequenceTag];
    
    return publicKeyData;
}


- (void)appendUTF8String:(NSString *)value
{
    //
    // UTF8STRING type
    //
    char strtype = 0x0C;
    [self appendBytes:&strtype length:1];
    [self appendDERLength:[value lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    [self appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
}


- (void)appendBITString:(NSData *)data
{
    //
    //  BIT string
    //
    char strtype = 0x03;
    [self appendBytes:&strtype length:1];
    [self appendDERLength:[data length]];
    [self appendData:data];
}


# pragma mark - Private ASN.1 DER hex helper methods

- (void)appendDERLength:(size_t)length
{
    if (length < 128)
    {
        uint8_t d = length;
        [self appendBytes:&d length:1];
    }
    else if (length < 0x100)
    {
        uint8_t d[2] = {0x81, length & 0xFF};
        [self appendBytes:&d length:2];
    }
    else if (length < 0x8000)
    {
        uint8_t d[3] = {0x82, (length & 0xFF00) >> 8, length & 0xFF};
        [self appendBytes:&d length:3];
    }
}


- (void)prependByte:(uint8_t)byte
{
    NSMutableData* newdata = [[NSMutableData alloc]initWithCapacity:[self length]+1];
    
    [newdata appendBytes:&byte length:1];
    [newdata appendData:self];
    
    [self setData:newdata];
}


+ (int)derEncodingGetSizeFrom:(NSData*)buf at:(int*)iterator
{
    const uint8_t* data = [buf bytes];
    int itr = *iterator;
    int num_bytes = 1;
    int ret = 0;
    
    if (data[itr] > 0x80)
    {
        num_bytes = data[itr] - 0x80;
        itr++;
    }
    
    for (int i = 0 ; i < num_bytes; i++)
    {
        ret = (ret * 0x100) + data[itr + i];
    }
    
    *iterator = itr + num_bytes;
    return ret;
}


+ (NSData *)getPublicKeyMod:(NSData *)publicKeyBits
{
    int iterator = 0;
    
    iterator++;
    [self derEncodingGetSizeFrom:publicKeyBits at:&iterator];
    
    iterator++;
    int mod_size = [self derEncodingGetSizeFrom:publicKeyBits at:&iterator];
    
    return [publicKeyBits subdataWithRange:NSMakeRange(iterator, mod_size)];
}


+ (NSData *)getPublicKeyExp:(NSData *)publicKeyBits
{
    int iterator = 0;
    
    iterator++;
    [self derEncodingGetSizeFrom:publicKeyBits at:&iterator];
    
    iterator++;
    int mod_size = [self derEncodingGetSizeFrom:publicKeyBits at:&iterator];
    iterator += mod_size;
    
    iterator++;
    int exp_size = [self derEncodingGetSizeFrom:publicKeyBits at:&iterator];
    
    return [publicKeyBits subdataWithRange:NSMakeRange(iterator, exp_size)];
}

@end
