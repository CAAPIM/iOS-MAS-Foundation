//
//  MASConfiguration.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASConfiguration.h"

#import "MASConstantsPrivate.h"
#import "MASConfigurationService.h"
#import "MASAccessService.h"
#import "MASKeyChainService.h"
#import "MASIKeyChainStore.h"
#import "NSData+MASPrivate.h"

# pragma mark - Gateway Configuration Constants

static NSString *const MASGatewayConfigurationKey = @"server"; // value is Dictionary

static NSString *const MASGatewayCertificatesKey = @"server_certs"; // array
static NSString *const MASGatewayHostNameKey = @"hostname"; // ip address or hostname
static NSString *const MASGatewayPortKey = @"port"; // number
static NSString *const MASGatewayPrefixKey = @"prefix"; // string

static NSString *const MASDefaultHttpsPrefix = @"https";


# pragma mark - Custom Configuration Constants

static NSString *const MASCustomConfigurationKey = @"custom"; // value is Dictionary


# pragma mark - MAG Configuration Constants

static NSString *const MASMAGConfigurationKey = @"mag"; // value is Dictionary

# pragma mark - MAS Configuration Constants

static NSString *const MASConfigurationKey = @"mas"; // value is Dictionary


# pragma mark - BLE Configuration Constants

static NSString *const MASBLEConfigurationKey = @"ble"; // value is Dictionary

static NSString *const MASBLEServiceUUIDConfigurationKey = @"msso_ble_service_uuid"; // string
static NSString *const MASBLECharacteristicUUIDConfigurationKey = @"msso_ble_characteristic_uuid"; // string
static NSString *const MASBLERSSIConfigurationKey = @"msso_ble_rssi"; // string


# pragma mark - Mobile SDK Configuration Constants

static NSString *const MASMobileConfigurationKey = @"mobile_sdk"; // value is Dictionary

static NSString *const MASMobileLocationIsRequiredConfigurationKey = @"location_enabled"; // bool

static NSString *const MASMobileSSOEnabledConfigurationKey = @"sso_enabled"; // bool

static NSString *const MASMobileEnbaledPublicKeyPinning = @"enable_public_key_pinning"; // bool

static NSString *const MASMobileEnbaledTrustedPublicPKI = @"trusted_public_pki"; // bool

static NSString *const MASMobileTrustedCertPinnedPublicKeyHashes = @"trusted_cert_pinned_public_key_hashes"; // array



# pragma mark - OAuth Configuration Constants

static NSString *const MASOAuthConfigurationKey = @"oauth"; // value is Dictionary

static NSString *const MASOAuthApplicationKey = @"client"; // value is Dictionary
static NSString *const MASOAuthApplicationClientId = @"client_id"; // string
static NSString *const MASOAuthApplicationClientIds = @"client_ids"; // array
static NSString *const MASOAuthApplicationClientSecret = @"client_secret"; // string
static NSString *const MASOAuthApplicationNameKey = @"client_name"; // string
static NSString *const MASOAuthApplicationTypeKey = @"client_type"; // string
static NSString *const MASOAuthApplicationDescriptionKey = @"description"; // string
static NSString *const MASOAuthApplicationOrganizationKey = @"organization"; // string
static NSString *const MASOAuthApplicationRegisteredByKey = @"registered_by"; /// string


# pragma mark - SCIM Configuration Constants

static NSString *const MASScimConfigurationKey = @"scim"; // value is Dictionary


# pragma mark - Endpoint Constants

static NSString *const MASProtectedEndpointsConfigurationKey = @"oauth_protected_endpoints"; // value is Dictionary
static NSString *const MASSystemEndpointsConfigurationKey = @"system_endpoints"; // value is Dictionary

static NSString *const MASScimPathEndpoint = @"scim-path"; // value is string
static NSString *const MASStoragePathEndpoint = @"mas-storage-path"; // value is string

static NSString *const MASAuthorizationEndpoint = @"authorization_endpoint_path"; // string
static NSString *const MASClientInitializeEndpoint = @"client_credential_init_endpoint_path"; // string
static NSString *const MASDeviceListEndpoint = @"device_list_endpoint_path"; // string
static NSString *const MASDeviceRegisterEndpoint = @"device_register_endpoint_path"; // string
static NSString *const MASDeviceRegisterClientEndpoint = @"device_client_register_endpoint_path"; // string
static NSString *const MASDeviceRenewEndpoint = @"device_renew_endpoint_path"; // string
static NSString *const MASDeviceRemoveEndpoint = @"device_remove_endpoint_path"; // string
static NSString *const MASEnterpriseBrowserEndpoint = @"enterprise_browser_endpoint_path"; // string
static NSString *const MASTokenEndpoint = @"token_endpoint_path"; // string
static NSString *const MASTokenRevokeEndpoint = @"token_revocation_endpoint_path"; // string
static NSString *const MASUserInfoEndpoint = @"userinfo_endpoint_path"; // string
static NSString *const MASUserSessionLogoutEndpoint = @"usersession_logout_endpoint_path"; // string
static NSString *const MASUserSessionStatusEndpoint = @"usersession_status_endpoint_path"; // string
static NSString *const MASAuthenticateOTPEndpoint = @"authenticate_otp_endpoint_path"; // string

static NSString *const MASUsersLDAPEndpoint = @"users_ldap_endpoint_path"; // string
static NSString *const MASUserGroupsLDAPEndpoint = @"user_groups_ldap_endpoint_path"; // string
static NSString *const MASUsersMSADEndpoint = @"users_msad_endpoint_path"; // string
static NSString *const MASUserGroupsMSADEndpoint = @"user_groups_msad_endpoint_path"; // string



# pragma mark - Property Constants

static NSString *const MASConfigurationIsLoadedPropertyKey = @"isLoaded"; // bool

/**
 *  NSObject category class for key value path with index of array
 */
@implementation NSObject (ValueForKeyPathWithIndexes)


/**
 *  This method helps to find a value in NSDictionary with index in key
 *
 *  @param fullPath NSString of path key for the value.  If the path key contains [], it will search for an element in array with given index.
 *
 *  @return Returns an object found for given path
 */
-(id)valueForKeyPathWithIndexes:(NSString*)fullPath
{
    
    if ([fullPath rangeOfString:@"["].location == NSNotFound)
    {
        return [self valueForKeyPath:fullPath];
    }
    
    NSArray* parts = [fullPath componentsSeparatedByString:@"."];
    id currentObj = self;
    
    for (NSString* part in parts)
    {
        NSRange range = [part rangeOfString:@"["];
        if (range.location == NSNotFound)
        {
            currentObj = [currentObj valueForKey:part];
        }
        else {
            NSString* arrayKey = [part substringToIndex:range.location];
            int index = [[[part substringToIndex:part.length-1] substringFromIndex:range.location+1] intValue];
            currentObj = [[currentObj valueForKey:arrayKey] objectAtIndex:index];
        }
    }
    
    return currentObj;
}

@end


@interface MASConfiguration ()

@property (strong, nonatomic) NSMutableDictionary *endpointKeysToPaths;

@end


@implementation MASConfiguration

static NSDictionary *_configurationInfo_;
static float _systemVersionNumber_;


# pragma mark - Current Configuration

+ (MASConfiguration *)currentConfiguration
{
    return [MASConfigurationService sharedService].currentConfiguration;
}


#pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}


- (id)initWithConfigurationInfo:(NSDictionary *)info
{
    if (self = [super init])
    {
        _configurationInfo_ = info;
        
        [self initializeEndpointsFromInfo:info];
        
        [self setValue:[NSNumber numberWithBool:(_configurationInfo_ && ([_configurationInfo_ count] > 0))] forKey:@"isLoaded"];
    }
    
    [self saveToStorage];
    
    return self;
}


- (void)initializeEndpointsFromInfo:(NSDictionary *)info
{
    //
    // If the dictionary already exists ignore the call
    //
    if (_endpointKeysToPaths)
    {
        return;
    }
    
    //
    // Create the dictionary
    //
    _endpointKeysToPaths = [NSMutableDictionary new];
    
    //
    // OAuth Endpoints
    //
    NSDictionary *oauthInfo = _configurationInfo_[MASOAuthConfigurationKey];
    if (oauthInfo)
    {
        // System Endpoints
        NSDictionary *endpointsInfo = oauthInfo[MASSystemEndpointsConfigurationKey];
        if (endpointsInfo)
        {
            [_endpointKeysToPaths addEntriesFromDictionary:endpointsInfo];
        }
        
        // Protected Endpoints
        endpointsInfo = oauthInfo[MASProtectedEndpointsConfigurationKey];
        if (endpointsInfo)
        {
            [_endpointKeysToPaths addEntriesFromDictionary:endpointsInfo];
        }
    }
    
    
    //
    // MAG Endpoints
    //
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    if (magInfo)
    {
        // System Endpoints
        NSDictionary *endpointsInfo = magInfo[MASSystemEndpointsConfigurationKey];
        if (endpointsInfo)
        {
            [_endpointKeysToPaths addEntriesFromDictionary:endpointsInfo];
        }
        
        // Protected Endpoints
        endpointsInfo = magInfo[MASProtectedEndpointsConfigurationKey];
        if (endpointsInfo)
        {
            [_endpointKeysToPaths addEntriesFromDictionary:endpointsInfo];
        }
    }
    
    //
    // MAS Endpoints
    //
    NSDictionary *masInfo = _configurationInfo_[MASConfigurationKey];
    if (masInfo)
    {
        //
        // currently scim-path is configured as String, maybe later when it comes as dictionary change it
        //
        
        //scim-path
        NSString *scimPathInfo = masInfo[MASScimPathEndpoint];
        if (scimPathInfo)
        {
            [_endpointKeysToPaths addEntriesFromDictionary:@{MASScimPathEndpoint : scimPathInfo}];
        }
        
        //storage-path
        NSString *storagePathInfo = masInfo[MASStoragePathEndpoint];
        if (storagePathInfo)
        {
            [_endpointKeysToPaths addEntriesFromDictionary:@{MASStoragePathEndpoint : storagePathInfo}];
        }
    }
    
    //
    // Custom Endpoints
    //
    NSDictionary *customInfo = _configurationInfo_[MASCustomConfigurationKey];
    if (customInfo)
    {
        [_endpointKeysToPaths addEntriesFromDictionary:customInfo];
    }
    
    if (![[_endpointKeysToPaths allKeys] containsObject:MASDeviceRegisterClientEndpoint])
    {
        //
        // Temporary Hardcoded Endpoints for older MAG version where it does not export device registration endpoint for client credentials
        //
        _endpointKeysToPaths[MASDeviceRegisterClientEndpoint] = @"/connect/device/register/client";
    }
    
    _endpointKeysToPaths[MASUsersLDAPEndpoint] = @"/scim/ldap/v2/users";
    _endpointKeysToPaths[MASUserGroupsLDAPEndpoint] = @"/scim/ldap/v2/groups";
    _endpointKeysToPaths[MASUsersMSADEndpoint] = @"/scim/msad/v2/users";
    _endpointKeysToPaths[MASUserGroupsMSADEndpoint] = @"/scim/msad/v2/groups";
}


+ (MASConfiguration *)instanceFromStorage
{
    MASConfiguration *configuration;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] dataForKey:[MASConfiguration.class description]];
    if (data)
    {
        configuration = (MASConfiguration *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return configuration;
}


- (void)saveToStorage
{
    //
    // Save to the keychain
    //
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (data)
    {
        NSError *error;
        [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] setData:data forKey:[MASConfiguration.class description] error:&error];
        if (error)
        {
            DLog(@"Error attempting to save data: %@", [error localizedDescription]);
        }
    }
}


- (void)reset
{
    [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] removeItemForKey:[MASConfiguration.class description]];
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //
    // Keychain
    //
    MASKeyChainService *keyChainService = [MASKeyChainService keyChainService];
    
    // Configuration
    if (_configurationInfo_)
    {
        [keyChainService setConfiguration:_configurationInfo_];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        MASKeyChainService *keyChainService = [MASKeyChainService keyChainService];
        
        _configurationInfo_ = [keyChainService configuration];
        
        [self initializeEndpointsFromInfo:_configurationInfo_];
        
        [self setValue:[NSNumber numberWithBool:(_configurationInfo_ && ([_configurationInfo_ count] > 0))] forKey:@"isLoaded"];
    }

    return self;
}


+ (BOOL)setSecurityConfiguration:(MASSecurityConfiguration *)securityConfiguration error:(NSError **)error
{
    //
    //  Validate the NSURL host for security configuration.
    //
    if (!securityConfiguration.host || !securityConfiguration.host.port)
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeConfigurationInvalidHostForSecurityConfiguration errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return NO;
    }
    
    //
    //  Validate pinning information for the security configuration.
    //  At least one pinning information (certificates or public key hashes) should be defined, or public PKI should be trusted.
    //
    if (!securityConfiguration.trustPublicPKI && (!securityConfiguration.certificates || [securityConfiguration.certificates count]== 0) && (!securityConfiguration.publicKeyHashes || [securityConfiguration.publicKeyHashes count] == 0))
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeConfigurationInvalidPinningInfoForSecurityConfiguration errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return NO;
    }
    
    [MASConfigurationService setSecurityConfiguration:securityConfiguration];
    
    return YES;
}


+ (void)removeSecurityConfigurationForDomain:(NSURL *)domain
{
    [MASConfigurationService removeSecurityConfigurationForDomain:domain];
}


+ (NSArray *)securityConfigurations
{
    return [MASConfigurationService securityConfigurations];
}


+ (MASSecurityConfiguration *)securityConfigurationForDomain:(NSURL *)domain
{
    return [MASConfigurationService securityConfigurationForDomain:domain];
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)applicationCredentialsAreDynamic
{
    NSString *defaultClientSecret = [self defaultApplicationClientSecret];
    
    return (!defaultClientSecret || defaultClientSecret.length == 0);
}


- (NSArray *)applicationClients
{
    NSDictionary *oauthInfo = _configurationInfo_[MASOAuthConfigurationKey];
    NSDictionary *applicationInfo = oauthInfo[MASOAuthApplicationKey];
    
    return applicationInfo[MASOAuthApplicationClientIds];
}


- (NSString *)applicationName
{
    NSDictionary *oauthInfo = _configurationInfo_[MASOAuthConfigurationKey];
    NSDictionary *applicationInfo = oauthInfo[MASOAuthApplicationKey];
    
    return applicationInfo[MASOAuthApplicationNameKey];
}


- (NSString *)applicationType
{
    NSDictionary *oauthInfo = _configurationInfo_[MASOAuthConfigurationKey];
    NSDictionary *applicationInfo = oauthInfo[MASOAuthApplicationKey];
    
    return applicationInfo[MASOAuthApplicationTypeKey];
}


- (NSString *)applicationDescription
{
    NSDictionary *oauthInfo = _configurationInfo_[MASOAuthConfigurationKey];
    NSDictionary *applicationInfo = oauthInfo[MASOAuthApplicationKey];
    
    return applicationInfo[MASOAuthApplicationDescriptionKey];
}


- (NSString *)applicationOrganization
{
    NSDictionary *oauthInfo = _configurationInfo_[MASOAuthConfigurationKey];
    NSDictionary *applicationInfo = oauthInfo[MASOAuthApplicationKey];
    
    return applicationInfo[MASOAuthApplicationOrganizationKey];
}


- (NSString *)applicationRegisteredBy
{
    NSDictionary *oauthInfo = _configurationInfo_[MASOAuthConfigurationKey];
    NSDictionary *applicationInfo = oauthInfo[MASOAuthApplicationKey];
    
    return applicationInfo[MASOAuthApplicationRegisteredByKey];
}


- (NSArray *)gatewayCertificates
{
    NSDictionary *gatewayInfo = _configurationInfo_[MASGatewayConfigurationKey];
    
    return (NSArray *)gatewayInfo[MASGatewayCertificatesKey];
}


- (NSArray *)gatewayCertificatesAsDERData
{
    NSMutableArray *certificates = [NSMutableArray new];
    for (id PEMCertificate in self.gatewayCertificates)
    {
        @try {
            NSData *cert = [NSData convertPEMCertificateToDERCertificate:[PEMCertificate componentsJoinedByString:MASDefaultNewline]];
            [certificates addObject:cert];
        }
        @catch (NSException *exception) {
            @throw [NSException exceptionWithName:MASFoundationErrorDomainLocal reason:[NSString stringWithFormat:@"%@ Failed to initialize SDK.  PEM may not be well formatted", NSStringFromClass([self class])] userInfo:nil];
        }
    }
    
    return certificates;
}


- (NSArray *)gatewayCertificatesAsPEMData
{
    NSMutableArray *certificates = [NSMutableArray new];
    for (id PEMCertificate in self.gatewayCertificates)
    {
        [certificates addObject:[[PEMCertificate componentsJoinedByString:MASDefaultNewline]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return certificates;
}


- (NSArray *)trustedCertPinnedPublicKeyHashes
{
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    NSDictionary *mobileSDKs = magInfo[MASMobileConfigurationKey];
    
    return (NSArray *)mobileSDKs[MASMobileTrustedCertPinnedPublicKeyHashes];
}


- (NSString *)gatewayHostName
{
    NSDictionary *gatewayInfo = _configurationInfo_[MASGatewayConfigurationKey];
    
    //
    // iOS 8 TLS Cache issue with NSURLSession (https://forums.developer.apple.com/thread/16493)
    // On iOS 8, NSURLSessionManager still caches the TLS information on system-level for 10 minutes, so any subsequent connection with same hostname will be using
    // cached information.  As for the solution, we will be adding trailing dot on host name if the device is registered.
    // we will be using the regular host name without trailing dot if the SDK is running below iOS 9. (Refer: https://developer.apple.com/library/ios/qa/qa1727/_index.html)
    // For IP address format hostname on iOS 8 or below, we will not guarantee that mutual SSL will be established on subsequent calls after the authentication.
    //
    // Please remove the below code when we stop supporting iOS 8.
    //
    // James Go - December 14, 2015
    //
    //    DLog(@"is device registered ? : %@ ", [MASDevice currentDevice].isRegistered ? @"YES":@"NO");
    
    if (!_systemVersionNumber_)
    {
        _systemVersionNumber_ = [[UIDevice currentDevice].systemVersion floatValue];
    }
    
    NSRegularExpression *regexToValidateIP = [NSRegularExpression
                                              regularExpressionWithPattern:@"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
                                              options:0
                                              error:nil];
    NSUInteger numberOfMatches = [regexToValidateIP numberOfMatchesInString:gatewayInfo[MASGatewayHostNameKey] options:0 range:NSMakeRange(0, [gatewayInfo[MASGatewayHostNameKey] length])];
    
    if (_systemVersionNumber_ < 9.0 && numberOfMatches != 1)
    {
        if (![MASDevice currentDevice].isRegistered)
        {
            return [NSString stringWithFormat:@"%@.",gatewayInfo[MASGatewayHostNameKey]];
        }
        else {
            return gatewayInfo[MASGatewayHostNameKey];
        }
    }
    else {
        return gatewayInfo[MASGatewayHostNameKey];
    }
}


- (NSNumber *)gatewayPort
{
    NSDictionary *gatewayInfo = _configurationInfo_[MASGatewayConfigurationKey];
    
    return gatewayInfo[MASGatewayPortKey];
}


- (NSString *)gatewayPrefix
{
    NSDictionary *gatewayInfo = _configurationInfo_[MASGatewayConfigurationKey];
    
    return gatewayInfo[MASGatewayPrefixKey];
}


- (NSURL *)gatewayUrl
{
    if ([self gatewayPrefix] && [self gatewayPrefix].length > 0)
    {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@/%@",
                                     [self gatewayHostName],
                                     [self gatewayPort],
                                     [self gatewayPrefix]]];
    }
    else {
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@",
                                     [self gatewayHostName],
                                     [self gatewayPort]]];
    }
}


# pragma mark - Endpoints

- (NSString *)endpointPathForKey:(NSString *)endpointKey
{
    NSString *endpointPath = _endpointKeysToPaths[endpointKey];
    
    return endpointPath;
}


# pragma mark - Endpoint Properties

- (NSString *)scimPathEndpointPath
{
    return _endpointKeysToPaths[MASScimPathEndpoint];
}


- (NSString *)storagePathEndpointPath
{
    return _endpointKeysToPaths[MASStoragePathEndpoint];
}


- (NSString *)authorizationEndpointPath
{
    return _endpointKeysToPaths[MASAuthorizationEndpoint];
}


- (NSString *)clientInitializeEndpointPath
{
    return _endpointKeysToPaths[MASClientInitializeEndpoint];
}


- (NSString *)authenticateOTPEndpointPath
{
    return _endpointKeysToPaths[MASAuthenticateOTPEndpoint];
}


- (NSString *)deviceListAllEndpointPath
{
    return _endpointKeysToPaths[MASDeviceListEndpoint];
}


- (NSString *)deviceRegisterEndpointPath
{
    return _endpointKeysToPaths[MASDeviceRegisterEndpoint];
}


- (NSString *)deviceRegisterClientEndpointPath
{
    return _endpointKeysToPaths[MASDeviceRegisterClientEndpoint];
}


- (NSString *)deviceRenewEndpointPath
{
    return _endpointKeysToPaths[MASDeviceRenewEndpoint];
}


- (NSString *)deviceRemoveEndpointPath
{
    return _endpointKeysToPaths[MASDeviceRemoveEndpoint];
}


- (NSString *)enterpriseBrowserEndpointPath
{
    return _endpointKeysToPaths[MASEnterpriseBrowserEndpoint];
}


- (NSString *)tokenEndpointPath
{
    return _endpointKeysToPaths[MASTokenEndpoint];
}


- (NSString *)tokenRevokeEndpointPath
{
    return _endpointKeysToPaths[MASTokenRevokeEndpoint];
}


- (NSString *)userInfoEndpointPath
{
    return _endpointKeysToPaths[MASUserInfoEndpoint];
}


- (NSString *)userSessionLogoutEndpointPath
{
    return _endpointKeysToPaths[MASUserSessionLogoutEndpoint];
}


- (NSString *)userSessionStatusEndpointPath
{
    return _endpointKeysToPaths[MASUserSessionStatusEndpoint];
}


# pragma mark - Bluetooth Properties

- (NSString *)bluetoothServiceUuid
{
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    NSDictionary *bleInfo = magInfo[MASBLEConfigurationKey];
    
    return bleInfo[MASBLEServiceUUIDConfigurationKey];
}


- (NSString *)bluetoothCharacteristicUuid
{
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    NSDictionary *bleInfo = magInfo[MASBLEConfigurationKey];
    
    return bleInfo[MASBLECharacteristicUUIDConfigurationKey];
}


- (NSInteger)bluetoothRssi
{
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    NSDictionary *bleInfo = magInfo[MASBLEConfigurationKey];
    
    return [bleInfo[MASBLERSSIConfigurationKey] integerValue];
}


# pragma mark - Location Properties

- (BOOL)locationIsRequired
{
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    NSDictionary *mobileInfo = magInfo[MASMobileConfigurationKey];
    
    return [mobileInfo[MASMobileLocationIsRequiredConfigurationKey] boolValue];
}


# pragma mark - Certificate Pinning

- (BOOL)enabledPublicKeyPinning
{
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    NSDictionary *mobileInfo = magInfo[MASMobileConfigurationKey];
    
    return [mobileInfo[MASMobileEnbaledPublicKeyPinning] boolValue];
}


- (BOOL)enabledTrustedPublicPKI
{
    NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
    NSDictionary *mobileInfo = magInfo[MASMobileConfigurationKey];
    
    return [mobileInfo[MASMobileEnbaledTrustedPublicPKI] boolValue];
}

# pragma mark - SSO Properties

- (BOOL)ssoEnabled
{
    MASAccessService *accessService = [MASAccessService sharedService];
    NSString *ssoEnabledString = [accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyMSSOEnabled];

    if (ssoEnabledString)
    {
        return [ssoEnabledString boolValue];
    }
    else {
        NSDictionary *magInfo = _configurationInfo_[MASMAGConfigurationKey];
        NSDictionary *mobileInfo = magInfo[MASMobileConfigurationKey];

        return [mobileInfo[MASMobileSSOEnabledConfigurationKey] boolValue];
    }
}


- (void)setSsoEnabled:(BOOL)ssoEnabled
{
    MASAccessService *accessService = [MASAccessService sharedService];

    [accessService setAccessValueString:(ssoEnabled ? @"true":@"false") storageKey:MASKeychainStorageKeyMSSOEnabled];
}


# pragma mark - Public

+ (NSError *)validateJSONConfiguration:(NSDictionary *)configuration
{
    NSMutableArray *validationRules = [NSMutableArray array];
    
    //  Server config
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"server.hostname", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"server.port", @"keyPath", [NSNumber class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"server.prefix", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"server.server_certs", @"keyPath", [NSArray class], @"classType", nil]];
    
    //  OAuth config
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.client.organization", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.client.client_ids[0].client_id", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.client.client_ids[0].scope", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.client.client_ids[0].redirect_uri", @"keyPath", [NSString class], @"classType", nil]];
    
    //  OAuth system endpoint
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.system_endpoints.authorization_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.system_endpoints.token_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.system_endpoints.token_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"oauth.system_endpoints.usersession_logout_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    
    //  MAG system endpoint
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.system_endpoints.device_remove_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.system_endpoints.device_register_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.system_endpoints.device_client_register_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.system_endpoints.client_credential_init_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.system_endpoints.authenticate_otp_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    
    //  MAG OAuth protected endpoint
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.oauth_protected_endpoints.enterprise_browser_endpoint_path", @"keyPath", [NSString class], @"classType", nil]];
    
    //  MAG mobile SDK
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.mobile_sdk.sso_enabled", @"keyPath", [NSNumber class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.mobile_sdk.location_enabled", @"keyPath", [NSNumber class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.mobile_sdk.location_provider", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.mobile_sdk.msisdn_enabled", @"keyPath", [NSNumber class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.mobile_sdk.trusted_public_pki", @"keyPath", [NSNumber class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.mobile_sdk.trusted_cert_pinned_public_key_hashes", @"keyPath", [NSArray class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.mobile_sdk.client_cert_rsa_keybits", @"keyPath", [NSNumber class], @"classType", nil]];
    
    //  MAG BLE
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.ble.msso_ble_service_uuid", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.ble.msso_ble_characteristic_uuid", @"keyPath", [NSString class], @"classType", nil]];
    [validationRules addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mag.ble.msso_ble_rssi", @"keyPath", [NSNumber class], @"classType", nil]];
    
    
    //
    //  Iterate each rule
    //
    for (NSDictionary *rule in validationRules)
    {
        //
        //  If the value is not class type that is being expected, return an error
        //
        if (![[configuration valueForKeyPathWithIndexes:[rule objectForKey:@"keyPath"]] isKindOfClass:[rule objectForKey:@"classType"]])
        {
            return [NSError errorConfigurationLoadingFailedJsonValidationWithDescription:[NSString stringWithFormat:@"%@ should be %@; but it is %@", [rule objectForKey:@"keyPath"], NSStringFromClass([rule objectForKey:@"classType"]), NSStringFromClass([[configuration valueForKeyPathWithIndexes:[rule objectForKey:@"keyPath"]] class])]];
        }
        //
        //  If the values is type of NSString, make sure to not allow empty string
        //
        else if ([rule objectForKey:@"classType"] == [NSString class] && ![[rule objectForKey:@"keyPath"] isEqualToString:@"server.prefix"])
        {
            NSString *trimmedString = [[configuration valueForKeyPathWithIndexes:[rule objectForKey:@"keyPath"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (trimmedString.length <= 0)
            {
                return [NSError errorConfigurationLoadingFailedJsonValidationWithDescription:[NSString stringWithFormat:@"%@ cannot be empty string", [rule objectForKey:@"keyPath"]]];
            }
        }
        
    }
    
    return nil;
}


- (NSString *)debugDescription
{
    NSMutableString *endpoints = [[NSMutableString alloc] initWithString:@"\n\n        {\n"];
    
    NSString *keyToEndpoint;
    for (NSString *endpointKey in _endpointKeysToPaths)
    {
        keyToEndpoint = [NSString stringWithFormat:@"            %@ = %@\n", endpointKey, _endpointKeysToPaths[endpointKey]];
        [endpoints appendString:keyToEndpoint];
    }
    [endpoints appendString:@"        }"];
    
    
    return [NSString stringWithFormat:@"(%@) is loaded: %@\n\n        application name: %@\n        application type: %@\n"
            "        application description: %@\n        application organization: %@\n        application registered by: %@\n"
            "        gateway host: %@\n        gateway port: %@\n        gateway prefix: %@\n        gateway url: %@\n"
            "        location is required: %@\n        endpoint keys to paths: %@",
            [self class], ([self isLoaded] ? @"Yes" : @"No"), [self applicationName], [self applicationType],
            [self applicationDescription], [self applicationOrganization], [self applicationRegisteredBy],
            [self gatewayHostName], [self gatewayPort], [self gatewayPrefix], [self gatewayUrl],
            ([self locationIsRequired] ? @"Yes" : @"No"), endpoints];
}


- (NSDictionary *)defaultApplicationClientInfo
{
    NSMutableArray *applicationClientInfoFound = [NSMutableArray new];
    for (NSDictionary *info in self.applicationClients)
    {
        [applicationClientInfoFound addObject:info];
    }
    
    // Should there be two or more allowed in the list that meet that criteria?  Can it happen?
    if (applicationClientInfoFound.count > 1)
    {
        DLog(@"Warning: found %ld iOS clients that are enabled, just choosing first in the list",
             (long)applicationClientInfoFound.count);
    }
    
    // Return the first found or nil if none
    return (applicationClientInfoFound.count > 0 ? applicationClientInfoFound[0] : nil);
}


- (NSString *)defaultApplicationClientIdentifier
{
    return [self defaultApplicationClientInfo][MASOAuthApplicationClientId];
}


- (NSString *)defaultApplicationClientSecret
{
    return [self defaultApplicationClientInfo][MASOAuthApplicationClientSecret];
}


- (BOOL)compareWithCurrentConfiguration:(NSDictionary *)newConfiguration
{
    return [_configurationInfo_ isEqualToDictionary:newConfiguration];
}


- (BOOL)detectServerChangeWithCurrentConfiguration:(NSDictionary *)newConfiguration
{
    NSString *newServerHost = [newConfiguration valueForKeyPathWithIndexes:@"server.hostname"];
    NSString *newServerPort = [newConfiguration valueForKeyPathWithIndexes:@"server.port"];
    NSString *newServerPrefix = [newConfiguration valueForKeyPathWithIndexes:@"server.prefix"];
    
    BOOL isServerChange = NO;
    
    if ([newServerHost isKindOfClass:[NSString class]] && ![newServerHost isEqual:self.gatewayHostName])
    {
        isServerChange = YES;
    }
    else if ([newServerPort isKindOfClass:[NSString class]] && ![newServerPort isEqual:self.gatewayPort])
    {
        isServerChange = YES;
    }
    else if ([newServerPrefix isKindOfClass:[NSString class]] && ![newServerPrefix isEqual:self.gatewayPrefix])
    {
        isServerChange = YES;
    }
    
    return isServerChange;
}


#pragma clang diagnostic pop


# pragma mark - Private

- (NSArray *)generateCertificatesFromPEM:(NSArray *)certificatesAsPEM
{
    NSMutableArray *certificatesAsDER = [NSMutableArray new];
    for (id PEMCertificate in certificatesAsPEM)
    {
        [certificatesAsDER addObject:[NSData convertPEMCertificateToDERCertificate:
                                      [PEMCertificate componentsJoinedByString:MASDefaultNewline]]];
    }
    
    return certificatesAsDER;
}


# pragma mark - Deprecated

+ (void)setSecurityConfiguration:(MASSecurityConfiguration *)securityConfiguration
{
    [self setSecurityConfiguration:securityConfiguration error:nil];
}

@end
