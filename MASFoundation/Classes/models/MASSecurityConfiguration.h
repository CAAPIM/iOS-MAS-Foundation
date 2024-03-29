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
 validateDomainName: YES,
 trustPublicPKI: NO.
 */
@interface MASSecurityConfiguration : MASObject


/**
 * Different SSL pinning modes that can be opted.
 */
typedef NS_ENUM(NSUInteger, MASSecuritySSLPinningMode) {
    /**
     * SSL pinning based on Public Key Hash.
     */
    MASSecuritySSLPinningModePublicKeyHash,
    
    /**
     * SSL pinning based on Leaf Certificate.
     */
    MASSecuritySSLPinningModeCertificate,
    
    /**
     * SSL pinning based on Intermediate Certificate.
     */
    MASSecuritySSLPinningModeIntermediateCertifcate,
};


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 BOOL value that determines whether or not to include sensitive credentials from primary gateway in the network communication with the target host.
 */
@property (assign) BOOL isPublic;


/**
 BOOL value that determines whether or not to allow to perform SSL Pinning i.e. Evaluate Server Trust with pinned Server Certificates.
 */
@property (assign) BOOL allowSSLPinning;


/**
 BOOL value that determines whether or not to validate the domain name of the certificate on the server trust.
 */
@property (assign) BOOL validateDomainName;


/**
 BOOL value that determines whether or not to validate the server trust against iOS' trusted root certificates.
 */
@property (assign) BOOL trustPublicPKI;

/**
 enum value that determines the SSL pinning mode. The Certifcates array needs to be set accordingly with the certificates that needs to be pinned. If MASSecuritySSLPinningModeIntermediateCertifcate is chosen, then the certificates array should contain intermediate certificate.
 @see certificates
 */
@property (assign) MASSecuritySSLPinningMode pinningMode;


/**
 NSArray value of pinned certificates.  Certificates must be in PEM encoded CRT; each line should be an item of the certificate array.
 */
@property (nonatomic, strong, nullable) NSArray *certificates;


/**
 NSArray value of pinned public key hashes.  Public key hashes must be in string format.
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

 @discussion default values for designated initializer are: isPublic: NO, trustPublicPKI: NO, validateDomainName: YES.
 @param url NSURL of the target domain
 @return MASSecurityConfiguration object
 */
- (instancetype _Nonnull)initWithURL:(NSURL * _Nonnull)url NS_DESIGNATED_INITIALIZER;

@end
