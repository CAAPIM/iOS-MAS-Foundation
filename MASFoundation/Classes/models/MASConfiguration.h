//
//  MASConfiguration.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;
@class MASSecurityConfiguration;

/**
 * The `MASConfiguration` class is a local representation of configuration data.
 */
@interface MASConfiguration : NSObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * This indicates the status of the configuration loading.  YES if it has succesfully loaded and is
 * ready for use. NO if not yet loaded or perhaps an error has occurred during attempting to load.
 */
@property (nonatomic, assign, readonly) BOOL isLoaded;


/**
 * The name of the application.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *applicationName;


/**
 * The type of the application.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *applicationType;


/**
 * The description of the application.
 */
@property (nonatomic, strong, readonly, nullable) NSString *applicationDescription;


/**
 * The organization name of the application.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *applicationOrganization;


/**
 * The name of the entity that registered the application.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *applicationRegisteredBy;


/**
 * The public server certificate of the Gateway as obtained from the configuration.
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *gatewayCertificates;


/**
 *  A list of trusted public key hasehs for certificate pinning.
 */
@property (nonatomic, copy, readonly, nullable) NSArray *trustedCertPinnedPublicKeyHashes;


/**
 * The public server certificate of the Gateway guaraneteed to be in DER format.
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *gatewayCertificatesAsDERData;


/**
 * The public server certificate of the Gateway guaraneteed to be in PEM format.
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *gatewayCertificatesAsPEMData;


/**
 * The host name of the Gateway.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *gatewayHostName;


/**
 * The port assigned on the Gateway.
 */
@property (nonatomic, strong, readonly, nonnull) NSNumber *gatewayPort;


/**
 * The prefix assigned on the Gateway.
 */
@property (nonatomic, strong, readonly, nullable) NSString *gatewayPrefix;


/**
 * The full URL of the Gateway including the prefix, hostname and port
 * in a https://<hostname>:<port>/<prefix (if exists)> format.
 */
@property (nonatomic, strong, readonly, nonnull) NSURL *gatewayUrl;


/**
 * Determines if a user's location coordinates are required.  This read only value 
 * is within the JSON configuration file and is set as a requirement of the application
 * on the Gateway.  This means that a set of location coordinates must be sent in the 
 * header of all protected endpoint HTTP request to the API on the Gateway.
 *
 * If these are not sent when this is YES the Gateway will validate this and return
 * an error response.
 */
@property (nonatomic, assign, readonly) BOOL locationIsRequired;


/**
 *  Determines SDK is enabled for public key pinning for authentication challenge.  This read only value is within
 *  the JSON configuration file.
 */
@property (nonatomic, assign, readonly) BOOL enabledPublicKeyPinning;


/**
 *  Determines SDK is enabled for trusted public PKI for authentication challenge.  This read only value is within
 *  the JSON configuration file.
 */
@property (nonatomic, assign, readonly) BOOL enabledTrustedPublicPKI;


/**
 *  Determines if the client's SSO is enabled or not.  This value
 *  is read from JSON configuration, if there is no value defined in keychain.
 */
@property (nonatomic, assign) BOOL ssoEnabled;



///--------------------------------------
/// @name Current Configuration
///--------------------------------------

# pragma mark - Current Configuration

/**
 * The application's configuration. This is a singleton object.
 *
 * @return Returns a singleton 'MASConfiguration' object.
 */
+ (MASConfiguration *_Nullable)currentConfiguration;


/**
 * Retrieves an endpoint path fragment for a given endpoint key
 *
 * @param endpointKey The key which applies to the endpoint path.
 */
- (NSString *_Nullable)endpointPathForKey:(NSString *_Nonnull)endpointKey;



///--------------------------------------
/// @name Security Configuration
///--------------------------------------

# pragma mark - Security Configuration

/**
 Sets security measure for SSL pinning, and SSL validation for specified host in MASSecurityConfiguration object.

 
 @remark MASSecurityConfiguration must have valid host in NSURL object with port number (port number is mandatory), at least one pinning information (either certificates, or public key hashes), or trust public PKI.  If public PKI is not trusted, and no pinning information is provided, it will fail to store the security configuration object, and eventually fail on evaluating SSL for requests.
 @warning Upon SDK initialization, [MASConfiguration currentConfiguration].gatewayUrl's MASSecurityConfiguration object will be overwritten. If primary gateway's security configuration has to be modified, ensure to set security configuration after SDK initialization.

 @param securityConfiguration MASSecurityConfiguration object with host, and security measure configuration values
 @param error NSError object reference to notify any error occurred while validating MASSecurityConfiguration
 @return YES if security configuration was successfully set
 */
+ (BOOL)setSecurityConfiguration:(MASSecurityConfiguration *_Nonnull)securityConfiguration error:(NSError *__nullable __autoreleasing *__nullable)error;



/**
 Removes security configuration object based on the domain (host, and port number).

 @param domain NSURL object of domain to delete MASSecurityConfiguration.
 */
+ (void)removeSecurityConfigurationForDomain:(NSURL *_Nonnull)domain;



/**
 Returns an array of MASSecurityConfiguration objects for each host.

 @return Returns an array of currently active MASSecurityConfigurations.
 */
+ (NSArray *_Nullable)securityConfigurations;



/**
 Returns MASSecurityConfiguration object for a specific domain.

 @param domain NSURL of the domain for the MASSecurityConfiguration object.
 @return Returns a MASSecurityConfiguration object for the domain.
 */
+ (MASSecurityConfiguration *_Nullable)securityConfigurationForDomain:(NSURL *_Nonnull)domain;



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, assign, readonly) BOOL applicationCredentialsAreDynamic;
@property (nonatomic, copy, readonly, nonnull) NSArray<NSDictionary *> *applicationClients;



///--------------------------------------
/// @name Endpoint Properties
///--------------------------------------

# pragma mark - Endpoint Properties

@property (nonatomic, copy, readonly, nullable) NSString *scimPathEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *storagePathEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *authorizationEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *clientInitializeEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *authenticateOTPEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *deviceListAllEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *deviceRegisterEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *deviceRegisterClientEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *deviceRenewEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *deviceRemoveEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *enterpriseBrowserEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *tokenEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *tokenRevokeEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *userInfoEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *userSessionLogoutEndpointPath;
@property (nonatomic, copy, readonly, nullable) NSString *userSessionStatusEndpointPath;



///--------------------------------------
/// @name Bluetooth Properties
///--------------------------------------

# pragma mark - Bluetooth Properties

@property (nonatomic, copy, readonly, nullable) NSString *bluetoothServiceUuid;
@property (nonatomic, copy, readonly, nullable) NSString *bluetoothCharacteristicUuid;
@property (assign, readonly) NSInteger bluetoothRssi;


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Initializer to perform a default initialization.
 *
 * @param info NSDictionary of configuration information.
 * @return Returns the newly initialized MASConfiguration.
 */
- (instancetype _Nullable)initWithConfigurationInfo:(NSDictionary *_Nonnull)info;


/**
 * Retrieves the instance of MASConfiguration from local storage, it it exists.
 *
 * @return Returns the newly initialized MASConfiguration or nil if none was stored.
 */
+ (MASConfiguration *_Nullable)instanceFromStorage;


/**
 *
 */
- (void)saveToStorage;


/**
 * Remove all traces of the current configuration.
 */
- (void)reset;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * The default application client identifier.
 */
- (NSString *_Nonnull)defaultApplicationClientIdentifier;



/**
 * The default application client secret.
 */
- (NSString *_Nullable)defaultApplicationClientSecret;



/**
 * The default application client information.
 *
 * @returns Returns an NSDictionary of the client information.
 */
- (NSDictionary<NSString *, NSString *> *_Nonnull)defaultApplicationClientInfo;



/**
 *  Compare NSDictionary of JSON configuration with current configuration.
 *
 *  @param newConfiguration NSDictionary of JSON object.
 *
 *  @return Returns BOOL of whether the JSON object is same as current configuration value or not.
 */
- (BOOL)compareWithCurrentConfiguration:(NSDictionary *_Nonnull)newConfiguration;



/**
 *  Compare NSDictionary of JSON configuration with current configuration to detect if it requires to switch the server
 *  This comparison will be based on server.hostname, server.port, and server.prefix values in JSON configuration.
 *
 *  @param newConfiguration NSDictionary of JSON object.
 *
 *  @return BOOL of whether the JSON object has different server environment than the current configuration.
 */
- (BOOL)detectServerChangeWithCurrentConfiguration:(NSDictionary *_Nonnull)newConfiguration;



# pragma mark - Static

+ (NSError *_Nullable)validateJSONConfiguration:(NSDictionary *_Nonnull)configuration;



///--------------------------------------
/// @name Deprecated
///--------------------------------------

# pragma mark - Deprecated

/**
 Sets security measure for SSL pinning, and SSL validation for specified host in MASSecurityConfiguration object
 
 @warning Upon SDK initialization, [MASConfiguration currentConfiguration].gatewayUrl's MASSecurityConfiguration object will be overwritten. If primary gateway's security configuration has to be modified, ensure to set security configuration after SDK initialization.
 @param securityConfiguration MASSecurityConfiguration object with host, and security measure configuration values.
 */
+ (void)setSecurityConfiguration:(MASSecurityConfiguration *_Nonnull)securityConfiguration DEPRECATED_MSG_ATTRIBUTE("[MASConfiguration setSecurityConfiguration:] is deprecated.  Use [MASConfiguration setSecurityConfiguration:error:] instead for better handling of error cases.");

@end
