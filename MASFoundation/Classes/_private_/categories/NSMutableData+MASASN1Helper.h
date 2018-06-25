//
//  NSMutableData+MASASN1Helper.h
//  MASFoundation
//
//  Created by Hun Go on 2018-06-18.
//  Copyright © 2018 CA Technologies. All rights reserved.
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
