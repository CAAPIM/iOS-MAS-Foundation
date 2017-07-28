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
        self.isPublic = NO;
        self.trustPublicPKI = NO;
        self.validateCertificateChain = NO;
        self.validateDomainName = NO;
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
    
    if ([configuration.allKeys containsObject:@"isPublic"])
    {
        self.isPublic = [[configuration objectForKey:@"isPublic"] boolValue];
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
    
    if ([configuration.allKeys containsObject:@"certificate"] && [[configuration objectForKey:@"certificate"] isKindOfClass:[NSArray class]])
    {
        self.certificates = [configuration objectForKey:@"certificate"];
    }
    
    if ([configuration.allKeys containsObject:@"publicKeyHashes"] && [[configuration objectForKey:@"publicKeyHashes"] isKindOfClass:[NSArray class]])
    {
        self.publicKeyHashes = [configuration objectForKey:@"publicKeyHashes"];
    }
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) for %@\n\nisPublic: %@\nvalidateCertificateChain: %@\nvalidateDomainName: %@\ntrustPublicPKI: %@\ncertificates: %@\npublicKeyHashes: %@\n", [self class], [[self host] absoluteString], self.isPublic ? @"YES":@"NO", self.validateCertificateChain ? @"YES":@"NO", self.validateDomainName ? @"YES":@"NO", self.trustPublicPKI ? @"YES":@"NO", self.certificates, self.publicKeyHashes];
}

@end
