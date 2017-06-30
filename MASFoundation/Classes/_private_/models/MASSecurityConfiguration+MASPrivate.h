//
//  MASSecurityConfiguration+MASPrivate.h
//  MASFoundation
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

@interface MASSecurityConfiguration (MASPrivate)

- (NSArray *)convertCertificatesToData;

- (NSArray *)convertCertificatesToSecCertificateRef;

- (NSArray *)convertPublicKeysToData;

- (NSArray *)convertPublicKeysToSecKeyRef;

- (NSArray *)extractPublicKeyRefFromCertificateRefs:(NSArray *)certificateRef;

@end
