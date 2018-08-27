//
//  MASASN1Decoder.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import "MASObject.h"

//
//  enumeration values for ASN.1 tags
//  Actual values can be found in following link, converted from decimal to hexadecimal value
//  https://www.obj-sys.com/asn1tutorial/node124.html
//
typedef NS_ENUM(uint8_t, MASASN1Tag)
{
    MASASN1TagEnumerated = 0x0A,
    MASASN1TagEmbeddedPdv = 0x0B,
    MASASN1TagUTF8Str = 0x0C,
    MASASN1TagRelativeOID = 0x0D,
    MASASN1TagISO64Str = 0x1A,
    MASASN1TagGeneralStr = 0x1B,
    MASASN1TagUniversalStr = 0x1C,
    MASASN1TagCharStr = 0x1D,
    MASASN1TagBMPStr = 0x1E,
    MASASN1TagEOC = 0x00,
    MASASN1TagBoolean = 0x01,
    MASASN1TagInt = 0x02,
    MASASN1TagBitStr = 0x03,
    MASASN1TagOctetStr = 0x04,
    MASASN1TagNull = 0x05,
    MASASN1TagObjId = 0x06,
    MASASN1TagObjDesc = 0x07,
    MASASN1TagExternal = 0x08,
    MASASN1TagReal = 0x09,
    MASASN1TagSequence = 0x10,
    MASASN1TagSet = 0x11,
    MASASN1TagNumericStr = 0x12,
    MASASN1TagPrintableStr = 0x13,
    MASASN1TagT61Str = 0x14,
    MASASN1TagVideoTextStr = 0x15,
    MASASN1TagIA5Str = 0x16,
    MASASN1TagUTCTime = 0x17,
    MASASN1TagGeneralizedTime = 0x18,
    MASASN1TagGraphicStr = 0x19
};



/**
 MASASN1Decoder is an internal class that decodes NSData of DER format of certificate into understandable MASASN1Object(s) structure.
 */
@interface MASASN1Decoder : MASObject



/**
 Initialization method of MASASN1Decoder object

 @param certData NSData of DER format of certificate to be decoded
 @return MASASN1Decoder object
 */
- (instancetype)initWithDERData:(NSData *)certData;



/**
 A method to be used to decode NSData of DER format of certificate

 @return NSArray containing MASASN1Object that represents entire certificate data structure
 */
- (NSArray *)decodeASN1;

@end
