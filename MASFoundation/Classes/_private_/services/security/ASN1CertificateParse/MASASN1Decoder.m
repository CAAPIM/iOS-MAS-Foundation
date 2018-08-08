//
//  MASASN1Decoder.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASASN1Decoder.h"
#import "MASASN1Object.h"

@interface MASASN1Decoder ()

@property (strong, nonatomic) NSData *certData;

@end


//
//  General Reference for ASN1 structure, and decoding:
//  http://www.oss.com/asn1/resources/reference/asn1-reference-card.html
//  https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One
//
//  ASN.1 Decoding Tool Reference:
//
//  https://holtstrom.com/michael/tools/asn1decoder.php
//  https://lapo.it/asn1js
//

@implementation MASASN1Decoder

- (instancetype)initWithDERData:(NSData *)certData
{
    self = [super init];
    
    if (self)
    {
        self.certData = certData;
    }
    
    return self;
}


- (NSArray *)decodeASN1
{
    if (self.certData)
    {
        return [self parseWithRange:NSMakeRange(0, [self.certData length])];
    }
    else {
        return nil;
    }
}


- (NSMutableArray *)parseWithRange:(NSRange)range
{
    NSUInteger location = range.location;
    NSMutableArray *elements = [NSMutableArray array];
    
    do
    {
        MASASN1Object *thisObject = [[MASASN1Object alloc] init];
        
        //
        //  Get first bytes to determine ASN.1 tag
        //
        uint8_t firstByte;
        [self.certData getBytes:&firstByte range:NSMakeRange(location, 1)];
        MASASN1Tag tag = (firstByte & 0x1F);
        thisObject.tag = tag;
        
        //
        //  Determine the element size of length
        //
        location++;
        NSUInteger lengthSize = 0;
        NSUInteger length = [self parseElementFromLocation:location lengthSize:&lengthSize];
        location += lengthSize;
        
        //
        //  Get sub range for the element content
        //
        NSRange subRange = NSMakeRange(location, length);
        
        //
        //  Constructive
        //
        if ((firstByte >> 5) & 1)
        {
            thisObject.sub = [self parseWithRange:subRange];
        }
        //
        //  Primitive
        //
        else {
            
            NSData *subContentData =  [self.certData subdataWithRange:subRange];
            
            switch (tag)
            {
                case MASASN1TagEOC:
                    return elements;
                    break;
                case MASASN1TagInt:
                {
                    if (subContentData.length <= sizeof(unsigned long long))
                    {
                        unsigned long long thisValue = 0;
                        const uint8_t *intBytes = [subContentData bytes];
                        for (int i = 0; i < subContentData.length; i++)
                        {
                            thisValue <<= 8;
                            thisValue += intBytes[i];
                        }
                        NSNumber *thisNumber = [NSNumber numberWithUnsignedLongLong:thisValue];
                        thisObject.value = thisNumber;
                    }
                    break;
                }
                case MASASN1TagNull:
                    thisObject.value = nil;
                    break;
                case MASASN1TagObjId:{
                    
                    //
                    //  https://msdn.microsoft.com/en-us/library/bb540809%28v=vs.85%29.aspx
                    //
                    NSMutableString *objectId = [NSMutableString string];
                  
                    const char *oidBytes = [subContentData bytes];
                    [objectId appendFormat:@"%d.%d", ((int)oidBytes[0] / 40), ((int)oidBytes[0] % 40)];
                    
                    for (int i = 1; i < [subContentData length]; i++)
                    {
                        int value = 0;
                        BOOL flag = NO;
                        
                        do
                        {
                            uint8_t b = oidBytes[i];
                            value = value * 128;
                            value += (b & 0x7f);
                            
                            flag = ((b & 0x80) == 0x80);
                            
                            if (flag)
                            {
                                i ++;
                            }
                        } while (flag);
                        
                        [objectId appendFormat:@".%d",value];
                    }
                    thisObject.value = objectId;
                    break;
                }
                case MASASN1TagUTF8Str:
                case MASASN1TagPrintableStr:
                case MASASN1TagNumericStr:
                case MASASN1TagGeneralStr:
                case MASASN1TagUniversalStr:
                case MASASN1TagCharStr:
                case MASASN1TagT61Str:
                {
                    //
                    // utf8 str
                    //
                    NSString *thisStr = [[NSString alloc] initWithData:subContentData encoding:NSUTF8StringEncoding];
                    thisObject.value = thisStr;
                    break;
                }
                case MASASN1TagBMPStr:
                {
                    //
                    // unicode str
                    //
                    NSString *thisStr = [[NSString alloc] initWithData:subContentData encoding:NSUnicodeStringEncoding];
                    thisObject.value = thisStr;
                    break;
                }
                case MASASN1TagISO64Str:
                case MASASN1TagIA5Str:
                {
                    //
                    // ascii str
                    //
                    NSString *thisStr = [[NSString alloc] initWithData:subContentData encoding:NSASCIIStringEncoding];
                    thisObject.value = thisStr;
                    break;
                }
                case MASASN1TagBitStr:
                {
                    NSData *dataWithoutUnusedBit = [subContentData subdataWithRange:NSMakeRange(1, [subContentData length]-1)];
                    thisObject.value = dataWithoutUnusedBit;
                    break;
                }
                case MASASN1TagBoolean:
                {
                    uint8_t firstBooleanByte;
                    [subContentData getBytes:&firstBooleanByte range:NSMakeRange(0, 1)];
                    thisObject.value = [NSNumber numberWithBool:(firstBooleanByte > 0)];
                    break;
                }
                case MASASN1TagGeneralizedTime:
                {
                    NSArray *formats = @[@"yyMMddHHmmssZ", @"yyMMddHHmmZ"];
                    NSString *dateString = [[NSString alloc] initWithData:subContentData encoding:NSUTF8StringEncoding];
                    
                    for (NSString *format in formats)
                    {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                        formatter.dateFormat = format;
                        
                        if ([formatter dateFromString:dateString])
                        {
                            thisObject.value = [formatter dateFromString:dateString];
                        }
                    }
                    break;
                }
                case MASASN1TagUTCTime:
                {
                    NSString *dateString = [[NSString alloc] initWithData:subContentData encoding:NSUTF8StringEncoding];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyMMddHHmmss'Z'";
                    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
                    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                    NSDate *thisDate = [formatter dateFromString:dateString];
                    thisObject.value = thisDate;
                    break;
                }
                case MASASN1TagExternal:
                case MASASN1TagOctetStr:
                case MASASN1TagSequence:
                case MASASN1TagEnumerated:
                case MASASN1TagGraphicStr:
                case MASASN1TagEmbeddedPdv:
                case MASASN1TagRelativeOID:
                case MASASN1TagVideoTextStr:
                case MASASN1TagSet:
                case MASASN1TagObjDesc:
                case MASASN1TagReal:
                default:
                    //
                    //  Not implemented
                    //
                    break;
            }
        }
        
        [elements addObject:thisObject];
        
        location += length;
        
    } while (location < NSMaxRange(range));
    
    return elements;
}


- (NSUInteger)parseElementFromLocation:(NSUInteger)location lengthSize:(NSUInteger *)lengthSize
{
    //
    //  Get first byte
    //
    uint8_t firstByte;
    [self.certData getBytes:&firstByte range:NSMakeRange(location, 1)];
    
    //
    //  element length is longer than 1 byte
    //
    if ((firstByte & 0x80) != 0)
    {
        uint8_t octetsToRead = firstByte - 0x80;
        NSData *positionData = [self.certData subdataWithRange:NSMakeRange(location+1, (NSUInteger)octetsToRead)];
        
        if (positionData.length > 8)
        {
            if (lengthSize)
            {
                *lengthSize = 0;
            }
            
            return 0;
        }
        
        int position = [self parseIntFromData:positionData];
        
        if (lengthSize)
        {
            //
            //  actual length bytes + first byte indicating the length of the length bytes
            //
            *lengthSize = (NSUInteger)octetsToRead+1;
        }
        
        return (NSUInteger)position;
    }
    //
    //  element length is just one byte
    //
    else {
        
        if (lengthSize)
        {
            *lengthSize = (NSUInteger)1;
        }
        
        return (NSUInteger)firstByte;
    }
}


//
//  Reference: https://stackoverflow.com/a/12635759
//
- (unsigned)parseIntFromData:(NSData *)data
{
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    
    return intData;
}

@end
