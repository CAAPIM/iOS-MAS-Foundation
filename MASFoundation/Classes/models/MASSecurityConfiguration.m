//
//  MASSecurityConfiguration.m
//  MASFoundation
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSecurityConfiguration.h"


# pragma mark - Property Constants

static NSString *const MASSecurityConfigurationPinningModeCertificate = @"certificate";
static NSString *const MASSecurityConfigurationPinningModePublicKey = @"publicKey";
static NSString *const MASSecurityConfigurationPinningModePublicKeyHash = @"publicKeyHash";
static NSString *const MASSecurityConfigurationPinningModeNone = @"none";

@interface MASSecurityConfiguration ()

@property (nonatomic, strong, readwrite) NSURL *host;

@end


@implementation MASSecurityConfiguration

@synthesize host = _host;

# pragma mark - Lifecycle

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    
    if (self) {
        self.host = url;
    }
    
    return self;
}


+ (instancetype)defaultConfiguration
{
    
    return nil;
}


- (instancetype)initWithConfiguration:(NSDictionary *)configuration forURL:(NSURL *)url
{
    
    NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", url.scheme, url.host, url.port]];
    
    self = [self initWithURL:targetURL];
    
    if (self) {
        [self setValuesWithConfiguration:configuration];
    }
    
    return self;
}


+ (NSDictionary *)initConfigurationsWithJSON:(NSDictionary *)configurations
{
    return nil;
}


# pragma mark - Private

- (void)setValuesWithConfiguration:(NSDictionary *)configuration
{
    if ([configuration.allKeys containsObject:@"enforcePinning"])
    {
        self.enforcePinning = [[configuration objectForKey:@"enforcePinning"] boolValue];
    }
    
    if ([configuration.allKeys containsObject:@"includeCredentials"])
    {
        self.includeCredentials = [[configuration objectForKey:@"includeCredentials"] boolValue];
    }
    
    if ([configuration.allKeys containsObject:@"validateCertificateChain"])
    {
        self.validateCertificateChain = [[configuration objectForKey:@"validateCertificateChain"] boolValue];
    }
    
    if ([configuration.allKeys containsObject:@"validateDomainName"])
    {
        self.validateDomainName = [[configuration objectForKey:@"validateDomainName"] boolValue];
    }
    
    if ([configuration.allKeys containsObject:@"turstPublicPKI"])
    {
        self.trustPublicPKI = [[configuration objectForKey:@"turstPublicPKI"] boolValue];
    }
    
    if ([configuration.allKeys containsObject:@"pinningMode"])
    {
        self.pinningMode = [MASSecurityConfiguration praseStringToPinningMode:[configuration objectForKey:@"pinningMode"]];
    }
    
    if ([configuration.allKeys containsObject:@"certificate"] && [[configuration objectForKey:@"certificate"] isKindOfClass:[NSArray class]])
    {
        self.certificates = [configuration objectForKey:@"certificate"];
    }
    
    if ([configuration.allKeys containsObject:@"publicKeys"] && [[configuration objectForKey:@"publicKeys"] isKindOfClass:[NSArray class]])
    {
        self.publicKeys = [configuration objectForKey:@"publicKeys"];
    }
    
    if ([configuration.allKeys containsObject:@"publicKeyHashes"] && [[configuration objectForKey:@"publicKeyHashes"] isKindOfClass:[NSArray class]])
    {
        self.publicKeyHashes = [configuration objectForKey:@"publicKeyHashes"];
    }
}


+ (MASSecuritySSLPinningMode)praseStringToPinningMode:(NSString *)pinningMode
{
    MASSecuritySSLPinningMode pinningModeValue = MASSecuritySSLPinningModeNone;
    
    if ([pinningMode isEqualToString:MASSecurityConfigurationPinningModeCertificate])
    {
        pinningModeValue = MASSecuritySSLPinningModeCertificate;
    }
    else if ([pinningMode isEqualToString:MASSecurityConfigurationPinningModePublicKey])
    {
        pinningModeValue = MASSecuritySSLPinningModePublicKey;
    }
    else if ([pinningMode isEqualToString:MASSecurityConfigurationPinningModePublicKeyHash])
    {
        pinningModeValue = MASSecuritySSLPinningModePublicKeyHash;
    }
    
    return pinningModeValue;
}


+ (NSString *)parsePinningModeToString:(MASSecuritySSLPinningMode)pinningMode
{
    switch (pinningMode) {
        case MASSecuritySSLPinningModeCertificate:
            return MASSecurityConfigurationPinningModeCertificate;
            break;
        case MASSecuritySSLPinningModePublicKey:
            return MASSecurityConfigurationPinningModePublicKey;
            break;
        case MASSecuritySSLPinningModePublicKeyHash:
            return MASSecurityConfigurationPinningModePublicKeyHash;
            break;
        case MASSecuritySSLPinningModeNone:
        default:
            return MASSecurityConfigurationPinningModeNone;
            break;
    }
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) for %@\n\nenforcePinning: %@\nincludeCredentials: %@\nvalidateCertificateChain: %@\nvalidateDomainName: %@\ntrustPublicPKI: %@\npinningMode: %@\ncertificates: %@\npublicKeys: %@\npublicKeyHashes: %@\n", [self class], [[self host] absoluteString], self.enforcePinning ? @"YES":@"NO", self.includeCredentials ? @"YES":@"NO", self.validateCertificateChain ? @"YES":@"NO", self.validateDomainName ? @"YES":@"NO", self.trustPublicPKI ? @"YES":@"NO", [MASSecurityConfiguration parsePinningModeToString:self.pinningMode], self.certificates, self.publicKeys, self.publicKeyHashes];
}

@end
