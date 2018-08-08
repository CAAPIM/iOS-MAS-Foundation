//
//  NSMutableData+MASASN1Helper.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//
#import <Foundation/Foundation.h>


/**
 NSMutableData+MASASN1Helper category class is a cateogry class to help to encode and wrtie data into ASN.1 format
 */
@interface NSMutableData (MASASN1Helper)



///--------------------------------------
/// @name ASN.1 DER hex helper methods
///--------------------------------------

# pragma mark - ASN.1 DER hex helper methods


/**
 Append subject item into self (NSMutableData) with given subject name

 @param attribute Hexadecimal value of subject name
 @param size int that represents the size of the hexadecimal attribute
 @param value NSString value of actual value of the subject item
 */
- (void)appendSubjectItem:(uint8_t[])attribute size:(int)size value:(NSString *)value;


/**
 Enclose self (NSMutableData) with given tag

 @param tag Hexadecimal format of tag
 */
- (void)encloseWith:(uint8_t)tag;



/**
 Builds public key bits into ASN.1 encoded NSData

 @param publicKeyBits NSData of public key bits
 @return NSData of ASN.1 encoded public key
 */
+ (NSData *)buildPublicKeyForASN1:(NSData *)publicKeyBits;



/**
 Append UTF8 string value into self (NSMutableData) as ASN.1 encoded format

 @param value NSString of UTF8 string
 */
- (void)appendUTF8String:(NSString *)value;



/**
 Append BIT string value into self (NSMutableData) as ASN.1 encoded format

 @param data NSData of Bit string
 */
- (void)appendBITString:(NSData *)data;

@end
