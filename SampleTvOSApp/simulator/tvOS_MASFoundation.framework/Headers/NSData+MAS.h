//
//  NSData+MAS.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

/**
 *  This category enables encryption methods for the object
 */
@interface NSData (MAS)



///--------------------------------------
/// @name Encrypt and Decrypt
///--------------------------------------

# pragma mark - Encrypt and Decrypt

/**
 *  Encrypts data using a password passed in the parameter
 *
 *  @param data     The NSData object to be encrypted
 *  @param password The NSString used as password during the encryption
 *  @param anError  The NSError variable used for any error returned by the method
 *
 *  @return Return the NSData encrypted object
 */
+ (NSData *_Nullable)encryptData:(NSData *_Nonnull)data password:(NSString *_Nonnull)password error:(NSError *_Nullable __autoreleasing *_Nullable)anError;



/**
 *  Decrypts data using a password passed in the parameter
 *
 *  @param data     The NSData object to be decrypted
 *  @param password The NSString used as password during the decryption
 *  @param anError  The NSError variable used for any error returned by the method
 *
 *  @return Return the NSData decrypted object
 */
+ (NSData *_Nullable)decryptData:(NSData *_Nonnull)data password:(NSString *_Nonnull)password error:(NSError *_Nullable __autoreleasing *_Nullable)anError;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 *  Simple, convenient method to determine if the object is encrypted
 *
 *  @return YES if object is encrypted, NO if otherwise
 */
- (BOOL)isEncrypted;

@end
