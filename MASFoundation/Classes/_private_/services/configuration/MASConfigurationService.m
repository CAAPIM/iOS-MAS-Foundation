//
//  MASConfigurationService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASConfigurationService.h"



@implementation MASConfigurationService

static NSString *_configurationFileName_ = @"msso_config";
static NSString *_configurationFileType_ = @"json";
static NSDictionary *_newConfigurationObject_ = nil;
static BOOL _newConfigurationDetected_ = NO;
static NSMutableDictionary *_networkConfigurations_;
static NSMutableDictionary *_securityConfigurations_;
static BOOL _enableIdTokenValidation_ = YES;

# pragma mark - Properties

+ (void)enableIdTokenValidation:(BOOL)enable
{
    _enableIdTokenValidation_ = enable;
}


+ (BOOL)isIdTokenValidationEnabled
{
    return _enableIdTokenValidation_;
}


+ (void)setConfigurationFileName:(NSString *)fileName
{
    _configurationFileName_ = fileName;
}


+ (void)setNewConfigurationObject:(NSDictionary *)configuration
{
    _newConfigurationObject_ = configuration;
    _newConfigurationDetected_ = YES;
}


+ (NSDictionary *)getDefaultConfigurationAsDictionary
{
    //
    // Retrieve the path to the required json file
    //
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:_configurationFileName_
                                                         ofType:_configurationFileType_];
    
    if(!jsonPath)
    {
        return nil;
    }
    
    //
    // Retrieve the data in the json file
    //
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    //
    // Detect json configuration file serialization error and stop here
    //
    if(!info || error)
    {
        return nil;
    }
    
    return info;
}


# pragma mark - Network Configuration

+ (void)setNetworkConfiguration:(MASNetworkConfiguration *)networkConfiguration
{
    if (!_networkConfigurations_)
    {
        _networkConfigurations_ = [NSMutableDictionary dictionary];
    }
    
    if ([networkConfiguration.host absoluteString])
    {
        [_networkConfigurations_ setObject:networkConfiguration forKey:[networkConfiguration.host absoluteString]];
    }
}


+ (void)removeNetworkConfigurationForDomain:(NSURL *)domain
{
    NSURL *thisDomain = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", domain.scheme, domain.host, domain.port]];
    [_networkConfigurations_ removeObjectForKey:[thisDomain absoluteString]];
}


+ (NSArray *)networkConfigurations
{
    return _networkConfigurations_ ? [_networkConfigurations_ allValues] : nil;
}


+ (MASNetworkConfiguration *)networkConfigurationForDomain:(NSURL *)domain
{
    NSURL *thisDomain = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", domain.scheme, domain.host, domain.port]];
    return thisDomain ? [_networkConfigurations_ objectForKey:[thisDomain absoluteString]] : nil;
}


# pragma mark - Security Configuration

+ (void)setSecurityConfiguration:(MASSecurityConfiguration *)securityConfiguration
{
    if (!_securityConfigurations_)
    {
        _securityConfigurations_ = [NSMutableDictionary dictionary];
    }
    
    if ([securityConfiguration.host absoluteString])
    {
        [_securityConfigurations_ setObject:securityConfiguration forKey:[securityConfiguration.host absoluteString]];
    }
}


+ (void)removeSecurityConfigurationForDomain:(NSURL *)domain
{
    NSURL *thisDomain = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", domain.scheme, domain.host, domain.port]];
    [_securityConfigurations_ removeObjectForKey:[thisDomain absoluteString]];
}


+ (NSArray *)securityConfigurations
{
    return _securityConfigurations_ ? [_securityConfigurations_ allValues] : nil;
}


+ (MASSecurityConfiguration *)securityConfigurationForDomain:(NSURL *)domain
{
    NSURL *thisDomain = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", domain.scheme, domain.host, domain.port]];
    return thisDomain ? [_securityConfigurations_ objectForKey:[thisDomain absoluteString]] : nil;
}


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[MASConfigurationService alloc] initProtected];
    });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (void)load
{
    [MASService registerSubclass:[self class] serviceUUID:MASConfigurationServiceUUID];
}


+ (NSString *)serviceUUID
{
    return MASConfigurationServiceUUID;
}


- (void)serviceDidLoad
{

    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    //
    // Attempt to retrieve the current configuration from local storage
    //
    _currentConfiguration = [MASConfiguration instanceFromStorage];
    
    //DLog(@"called and retrieved stored configuration: %@\n\n", [_currentConfiguration debugDescription]);
    
    //
    // If found but it is an unloaded version that was somehow stored remove
    // it to start fresh below ... just a safety precaution as it can get into
    // a weird state if this happens
    //
    if(!self.currentConfiguration.isLoaded)
    {
        [self.currentConfiguration reset];
        _currentConfiguration = nil;
    }
    //
    // If the configuration is being loaded dynamically by JSON as parameter,
    // reset the current configuration and load it from the object.
    //
    else if (_newConfigurationDetected_)
    {
        [self.currentConfiguration reset];
        _currentConfiguration = nil;
    }
    
    //
    // If no locally stored configuration is found
    //
    if(!self.currentConfiguration)
    {
        NSDictionary *info = nil;
        
        //
        // If the JSON configuration object was set
        //
        if (_newConfigurationObject_ && _newConfigurationDetected_)
        {
            info = _newConfigurationObject_;
            _newConfigurationDetected_ = NO;
        }
        //
        // Otherwise, load it from default configuration file
        //
        else {
            NSString *fileName = [NSString stringWithFormat:@"%@.%@", _configurationFileName_, _configurationFileType_];
            
            //
            // Retrieve the path to the required json file
            //
            NSString *jsonPath = [[NSBundle mainBundle] pathForResource:_configurationFileName_
                                                                 ofType:_configurationFileType_];
            
            //
            // Detect json configuration file missing and stop here
            //
            if(!jsonPath)
            {
                [self serviceDidFailWithError:[NSError errorConfigurationLoadingFailedFileNotFound:fileName]];
                
                return;
            }
            
            //
            // Retrieve the data in the json file
            //
            NSData *data = [NSData dataWithContentsOfFile:jsonPath];
            NSError *error = nil;
            info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            //
            // Detect json configuration file serialization error and stop here
            //
            if(!info || error)
            {
                [self serviceDidFailWithError:[NSError errorConfigurationLoadingFailedJsonSerialization:fileName description:[error localizedDescription]]];
                
                return;
            }
        }
        
        //
        //  Validate JSON content for given rules
        //
        NSError *validationError = [MASConfiguration validateJSONConfiguration:info];
        
        //
        //  If there is any error from validation, return an error
        //
        if (validationError)
        {
            [self serviceDidFailWithError:validationError];
            
            return;
        }
        
        //
        // Create a new configuration object
        //
        _currentConfiguration = [[MASConfiguration alloc] initWithConfigurationInfo:info];
        
        //
        //  Catch an exception for parsing certificate
        //
        @try {
            NSArray *gatewayCert = _currentConfiguration.gatewayCertificatesAsDERData;
            DLog(@"gateway cert : %@", gatewayCert);
        }
        @catch (NSException *exception) {
            
            NSError * certError = [NSError errorWithDomain:exception.name code:MASExceptionErrorCodeInvalidCertificate userInfo:@{NSLocalizedDescriptionKey:exception.description}];
            
            [self serviceDidFailWithError:certError];
            
            return;
        }
        
        //
        // If created then store it to local storage
        //
        if(_currentConfiguration)
        {
           [_currentConfiguration saveToStorage];
        }
    }
    
    
    NSURL *currentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", _currentConfiguration.gatewayUrl.scheme, _currentConfiguration.gatewayHostName, _currentConfiguration.gatewayPort]];
    
    //
    //  Construct and set MASNetworkConfiguration for the primary gateway
    //
    MASNetworkConfiguration *defaultNetworkConfiguration = [[MASNetworkConfiguration alloc] initWithURL:currentURL];
    [MASConfiguration setNetworkConfiguration:defaultNetworkConfiguration error:nil];
    
    //
    //  Construct and set MASSecurityConfiguration for the primary gateway
    //
    MASSecurityConfiguration *defaultSecurityConfiguration = [[MASSecurityConfiguration alloc] initWithURL:currentURL];
    defaultSecurityConfiguration.allowSSLPinning = _currentConfiguration.allowSSLPinning;
    defaultSecurityConfiguration.trustPublicPKI = _currentConfiguration.enabledTrustedPublicPKI;
    defaultSecurityConfiguration.publicKeyHashes = _currentConfiguration.trustedCertPinnedPublicKeyHashes;
    defaultSecurityConfiguration.certificates = _currentConfiguration.gatewayCertificates;
    
    [MASConfiguration setSecurityConfiguration:defaultSecurityConfiguration error:nil];
    
    //DLog(@"\n\ndone and current configuration is:\n\n%@\n\n", [_currentConfiguration debugDescription]);
    
    [super serviceWillStart];
}


- (void)serviceDidReset
{
    //DLog(@"called");
    
    if(self.currentConfiguration)
    {
        [self.currentConfiguration reset];
        _currentConfiguration = nil;
    }
    
    [super serviceDidReset];
}


- (void)serviceDidStop
{
    //
    //  Remove the security configuration upon SDK termination
    //
    NSURL *thisDomain = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", _currentConfiguration.gatewayUrl.scheme, _currentConfiguration.gatewayUrl.host, _currentConfiguration.gatewayUrl.port]];
    MASSecurityConfiguration *securityConfiguration = [MASConfigurationService securityConfigurationForDomain:thisDomain];
    if (thisDomain && securityConfiguration)
    {
        [_securityConfigurations_ removeObjectForKey:[thisDomain absoluteString]];
    }
    
    if (_newConfigurationObject_)
    {
        _newConfigurationObject_ = nil;
    }
    
    [super serviceDidStop];
}

# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    configuration: %@",
        [super debugDescription],
        [self.currentConfiguration debugDescription]];
}

@end
