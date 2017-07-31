//
//  MASSecurityConfiguration.h
//  MASFoundation
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASObject.h"


/**
 MASSecurityConfiguration class is an object that determines security measures for communication between the target host.
 The class is mainly responsible for SSL pinning mechanism, as well as for including/excluding credentials from primary gateway in the network communication to the target host.
 
 Default configuration value for designated initializer, [[MASSecurityConfiguration alloc] initWithURL:], would be:
 isPublic: NO,
 validateCertificateChain: NO,
 validateDomainName: YES,
 trustPublicPKI: NO.

 @warning If validateCertificateChain is set to YES, ALL of certificates and/or public key hashes in the chain MUST be added. If no pinning information is set (either certificates, or public key hashes), and trustPublicPKI is set to NO, the connection will be rejected due to lack of security measure.
 */
@interface MASSecurityConfiguration : MASObject


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 BOOL value that determines whether or not to include sensitive credentials from primary gateway in the network communication with the target host.
 */
@property (assign) BOOL isPublic;


/**
 BOOL value that determines whether or not to validate entire certificate chain of the server trust.  If validateCertiicateChain is set to YES, ensure to include ALL certificate information, and/or public key hash information from the root to the leaf.
 
 @warning If validateCertificateChain is set to YES, ALL of certificates and/or public key hashes in the chain MUST be added.
 */
@property (assign) BOOL validateCertificateChain;


/**
 BOOL value that determines whether or not to validate the domain name of the certificate on the server trust.
 */
@property (assign) BOOL validateDomainName;


/**
 BOOL value that determines whether or not to validate the server trust against iOS' trusted root certificates.
 */
@property (assign) BOOL trustPublicPKI;


/**
 NSArray value of pinned certificates.  Certificates must be in PEM encoded CRT; each line should be an item of the certificate array.

 @warning If validateCertificateChain is set to YES, ALL of certificates in the chain MUST be added.  If certificates, and publicKeyHashes are both set, SDK will validate BOTH provided information.
 */
@property (nonatomic, strong, nullable) NSArray *certificates;


/**
 NSArray value of pinned public key hashes.  Public key hashes must be in string format.
 
 @warning If validateCertificateChain is set to YES, ALL of certificates' public key hashes in the chain MUST be added.  If certificates, and publicKeyHashes are both set, SDK will validate BOTH provided information.
 */
@property (nonatomic, strong, nullable) NSArray *publicKeyHashes;


/**
 NSURL value of the target host.
 */
@property (nonatomic, strong, readonly, nonnull) NSURL *host;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 Designated initializer for MASSecurityConfiguration.

 @discussion default values for designated initializer are: isPublic: NO, trustPublicPKI: NO, validateCertificateChain: NO, validateDomainName: YES.
 @param url NSURL of the target domain
 @return MASSecurityConfiguration object
 */
- (instancetype _Nonnull)initWithURL:(NSURL * _Nonnull)url NS_DESIGNATED_INITIALIZER;

@end
