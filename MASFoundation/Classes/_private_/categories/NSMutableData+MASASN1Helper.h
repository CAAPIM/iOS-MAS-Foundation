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

@interface NSMutableData (MASASN1Helper)

# pragma mark - ASN.1 DER hex helper methods

- (void)appendSubjectItem:(uint8_t[])attribute size:(int)size value:(NSString *)value;

- (void)encloseWith:(uint8_t)tag;

- (void)encloseWithSequenceTag;

+ (NSData *)buildPublicKeyForASN1:(NSData *)publicKeyBits;

- (void)appendUTF8String:(NSString *)value;

- (void)appendBITString:(NSData *)data;

@end
