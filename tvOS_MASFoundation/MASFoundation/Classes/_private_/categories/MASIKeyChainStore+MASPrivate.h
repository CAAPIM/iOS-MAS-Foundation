//
//  MASIKeyChainStore+Addition.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASIKeyChainStore.h"

NS_ASSUME_NONNULL_BEGIN


@interface MASIKeyChainStore (MASPrivate)



///--------------------------------------
/// @name Certificate
///--------------------------------------

# pragma mark - Certificate


/**
 * Set a new certificate for a specific key.
 * 
 * @param data The certificate value in data format.
 * @param key The key that maps to the certificate value.
 * @return Yes if set successfully, No if not.
 */
- (BOOL)setCertificate:(NSData *)data forKey:(NSString *)key;



/**
 * Retrieve an existing certificate for a specific key.
 * 
 * @param key The key that maps to the desired certificate.
 * @return An array of certificates that map to the key.
 */
- (NSArray *)certificateForKey:(NSString *)key;



/**
 *  Retrieve security identities for given certificate's label key.
 *
 *  @param certificateLabel NSString of label key for a certificate
 *
 *  @return An array of identities for given certificate's label
 */
- (NSArray *)identitiesWithCertificateLabel:(NSString *)certificateLabel;



/**
 *  Clearing all certificates and identities in all keychain for given label key for certificate
 *
 *
 *  @param labelKey NSString of label key for certificate
 */
- (void)clearCertificatesAndIdentitiesWithCertificateLabelKey:(NSString *)labelKey;



/**
 *  Set crypto key data with application tag into keychain
 *
 *  @param keyData        SecKeyRef data of the crypto key
 *  @param applicationTag NSData of the application tag which will be used as unique identifier for the crypto key in keychain
 *
 *  @return Boolean of the result
 */
- (BOOL)setCryptoKey:(SecKeyRef)keyData forApplicationTag:(NSData *)applicationTag;



/**
 *  Retrieve the crypto key data from keychain
 *
 *  @param applicationTag NSData of the application tag which is being used as unique identifier for the crypto key in keychain
 *
 *  @return SecKeyRef of the crypto key from keychain
 */
- (SecKeyRef)cryptoKeyForApplicationTag:(NSData *)applicationTag;

- (nullable NSString *)stringForKey:(NSString *)key userOperationPrompt:(nullable NSString *)userOperationPrompt error:(NSError * __nullable __autoreleasing * __nullable)error;

@end

NS_ASSUME_NONNULL_END
