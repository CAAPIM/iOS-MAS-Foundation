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
@property (nonatomic, strong, readonly) NSString *applicationName;


/**
 * The type of the application.
 */
@property (nonatomic, strong, readonly) NSString *applicationType;


/**
 * The description of the application.
 */
@property (nonatomic, strong, readonly) NSString *applicationDescription;


/**
 * The organization name of the application.
 */
@property (nonatomic, strong, readonly) NSString *applicationOrganization;


/**
 * The name of the entity that registered the application.
 */
@property (nonatomic, strong, readonly) NSString *applicationRegisteredBy;


/**
 * The public server certificate of the Gateway as obtained from the configuration.
 */
@property (nonatomic, copy, readonly) NSArray *gatewayCertificates;


/**
 * The public server certificate of the Gateway guaraneteed to be in DER format.
 */
@property (nonatomic, copy, readonly) NSArray *gatewayCertificatesAsDERData;


/**
 * The public server certificate of the Gateway guaraneteed to be in PEM format.
 */
@property (nonatomic, copy, readonly) NSArray *gatewayCertificatesAsPEMData;


/**
 * The host name of the Gateway.
 */
@property (nonatomic, strong, readonly) NSString *gatewayHostName;


/**
 * The port assigned on the Gateway.
 */
@property (nonatomic, strong, readonly) NSNumber *gatewayPort;


/**
 * The prefix assigned on the Gateway.
 */
@property (nonatomic, strong, readonly) NSString *gatewayPrefix;


/**
 * The full URL of the Gateway including the prefix, hostname and port
 * in a https://<hostname>:<port>/<prefix (if exists)> format.
 */
@property (nonatomic, strong, readonly) NSURL *gatewayUrl;


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
+ (MASConfiguration *)currentConfiguration;


/**
 * Retrieves an endpoint path fragment for a given endpoint key
 *
 * @param endpointKey The key which applies to the endpoint path.
 */
- (NSString *)endpointPathForKey:(NSString *)endpointKey;





///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, assign, readonly) BOOL applicationCredentialsAreDynamic;
@property (nonatomic, copy, readonly) NSArray *applicationClients;



///--------------------------------------
/// @name Endpoint Properties
///--------------------------------------

# pragma mark - Endpoint Properties

@property (nonatomic, copy, readonly) NSString *scimPathEndpointPath;
@property (nonatomic, copy, readonly) NSString *storagePathEndpointPath;
@property (nonatomic, copy, readonly) NSString *authorizationEndpointPath;
@property (nonatomic, copy, readonly) NSString *clientInitializeEndpointPath;
@property (nonatomic, copy, readonly) NSString *authenticateOTPEndpointPath;
@property (nonatomic, copy, readonly) NSString *deviceListAllEndpointPath;
@property (nonatomic, copy, readonly) NSString *deviceRegisterEndpointPath;
@property (nonatomic, copy, readonly) NSString *deviceRegisterClientEndpointPath;
@property (nonatomic, copy, readonly) NSString *deviceRenewEndpointPath;
@property (nonatomic, copy, readonly) NSString *deviceRemoveEndpointPath;
@property (nonatomic, copy, readonly) NSString *enterpriseBrowserEndpointPath;
@property (nonatomic, copy, readonly) NSString *tokenEndpointPath;
@property (nonatomic, copy, readonly) NSString *tokenRevokeEndpointPath;
@property (nonatomic, copy, readonly) NSString *userInfoEndpointPath;
@property (nonatomic, copy, readonly) NSString *userSessionLogoutEndpointPath;
@property (nonatomic, copy, readonly) NSString *userSessionStatusEndpointPath;



///--------------------------------------
/// @name Bluetooth Properties
///--------------------------------------

# pragma mark - Bluetooth Properties

@property (nonatomic, copy, readonly) NSString *bluetoothServiceUuid;
@property (nonatomic, copy, readonly) NSString *bluetoothCharacteristicUuid;
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
- (id)initWithConfigurationInfo:(NSDictionary *)info;


/**
 * Retrieves the instance of MASConfiguration from local storage, it it exists.
 *
 * @return Returns the newly initialized MASConfiguration or nil if none was stored.
 */
+ (MASConfiguration *)instanceFromStorage;


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
- (NSString *)defaultApplicationClientIdentifier;



/**
 * The default application client secret.
 */
- (NSString *)defaultApplicationClientSecret;



/**
 * The default application client information.
 *
 * @returns Returns an NSDictionary of the client information.
 */
- (NSDictionary *)defaultApplicationClientInfo;



/**
 *  Compare NSDictionary of JSON configuration with current configuration.
 *
 *  @param newConfiguration NSDictionary of JSON object.
 *
 *  @return Returns BOOL of whether the JSON object is same as current configuration value or not.
 */
- (BOOL)compareWithCurrentConfiguration:(NSDictionary *)newConfiguration;



/**
 *  Compare NSDictionary of JSON configuration with current configuration to detect if it requires to switch the server
 *  This comparison will be based on server.hostname, server.port, and server.prefix values in JSON configuration.
 *
 *  @param newConfiguration NSDictionary of JSON object.
 *
 *  @return BOOL of whether the JSON object has different server environment than the current configuration.
 */
- (BOOL)detectServerChangeWithCurrentConfiguration:(NSDictionary *)newConfiguration;



# pragma mark - Static

+ (NSError *)validateJSONConfiguration:(NSDictionary *)configuration;


@end
