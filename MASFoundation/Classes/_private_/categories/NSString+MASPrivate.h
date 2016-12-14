//
//  NSString+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;


@interface NSString (MASPrivate)



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 *  Generates random string with given length
 *
 *  @param length   int length of random string
 *
 *  @return Returns randomly generated string with given length
 */
+ (NSString *)randomStringWithLength:(int)length;



/**
 *  Check if the string is empty string.
 *
 *  @return Returns YES if string is empty or NO if string is not empty.
 */
- (BOOL)isEmpty;



/**
 *  Create MD5 hash string from NSString
 *
 *  @return Returns md5 hashsed NSString
 */
- (NSString *)md5String;



/**
 *  Creates SHA256 hash NSData from NSString
 *
 *  @return Returns sha256 hashed NSData
 */
- (NSData *)sha256Data;



/**
 *  Encode string with Base64 URL encoded
 *
 *  @return Returns base64 URL encoded NSString
 */
- (NSString *)base64URL;



/**
 *  Encode NSData with Base64 URL encoded and convert it to NSString
 *
 *  @return Returns base64 URL encoded NSString
 */
+ (NSString *)base64URLWithNSData:(NSData *)data;



- (NSString *)replaceStringWithRegexPattern:(NSString *)pattern withString:(NSString *)string;


@end
