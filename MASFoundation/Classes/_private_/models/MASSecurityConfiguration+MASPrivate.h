//
//  MASSecurityConfiguration+MASPrivate.h
//  MASFoundation
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

@interface MASSecurityConfiguration (MASPrivate)

/**
 Converts MASSecurityConfiguration's array of certificate array into array of NSData

 @return NSArray of NSData for certificate instance property.
 */
- (NSArray *)convertCertificatesToData;



/**
 Converts MASSecurityConfiguration's array of certificate array into array of SecCertificateRef

 @return NSArray of SecCertificateRef for certificate instance property.
 */
- (NSArray *)convertCertificatesToSecCertificateRef;



/**
 Extracts public key as SecKeyRef from array of SecCertificateRef

 @param certificateRef NSArray of SecCertificateRef
 @return NSArray of SecKeyRef for public keys
 */
- (NSArray *)extractPublicKeyRefFromCertificateRefs:(NSArray *)certificateRef;

@end
