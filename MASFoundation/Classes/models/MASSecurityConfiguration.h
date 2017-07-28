//
//  MASSecurityConfiguration.h
//  MASFoundation
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASObject.h"

@interface MASSecurityConfiguration : MASObject

typedef NS_ENUM(NSUInteger, MASSecuritySSLPinningMode) {
    MASSecuritySSLPinningModeNone,
    MASSecuritySSLPinningModePublicKey,
    MASSecuritySSLPinningModePublicKeyHash,
    MASSecuritySSLPinningModeCertificate,
};


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (assign) BOOL isPublic;

@property (assign) BOOL validateCertificateChain;

@property (assign) BOOL validateDomainName;

@property (assign) BOOL trustPublicPKI;

@property (nonatomic, strong, nullable) NSArray *certificates;

@property (nonatomic, strong, nullable) NSArray *publicKeyHashes;

@property (nonatomic, strong, readonly, nonnull) NSURL *host;


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

- (instancetype _Nonnull)initWithURL:(NSURL * _Nonnull)url NS_DESIGNATED_INITIALIZER;

@end
