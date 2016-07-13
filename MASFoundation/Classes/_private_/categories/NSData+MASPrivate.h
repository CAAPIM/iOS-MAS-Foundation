//
//  NSData+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;


@interface NSData (MASPrivate)



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public


/**
 *
 */
- (NSData *)dataFormattedAsCertificate;



/**
 *
 */
+ (NSData *)dataFromCertificateArray:(NSArray *)certificateArray;



/**
 * Encode the incoming data string with Base64 encoding.
 *
 * Padding '=' characters are optional. Whitespace is ignored.
 *
 * @param dataAsString The data in NSString, UTF8Encoded format.
 * @returns Returns the NSData with Base64 encoding.
 */
+ (id)dataWithBase64EncodedString:(NSString *)dataAsString;



/**
 * Retrieve the existing NSData as a Base64 encoded NSString.
 *
 * @returns Returns the Base64 encoded NSString.
 */
- (NSString *)base64Encoding;



/**
 * Converts PEM-Certificate into DER-Certificate (removing -----BEGIN CERTIFICATE----- wrappers)
 *
 * @returns Returns NSData format of DER-Certificate
 */
+ (NSData *)convertPEMCertificateToDERCertificate:(NSString *)PEMCertificate;



+ (NSData *)sign:(NSString *)data key:(NSString *)key;

#pragma mark - Encryption Methods

/**
 *  This method is used to change the internal variable to True (encrypted) or False (not encrypted)
 *
 *  @param value The boolean value True / False
 */
- (void)encrypted:(BOOL)value;

@end
