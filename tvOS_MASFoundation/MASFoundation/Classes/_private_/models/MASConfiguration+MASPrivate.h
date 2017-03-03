//
//  MASConfiguration+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <tvOS_MASFoundation/tvOS MASFoundation.h>



@interface MASConfiguration (MASPrivate)
    <NSCoding>



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, assign, readwrite) BOOL isLoaded;
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
/// @name Location Properties
///--------------------------------------

# pragma mark - Location Properties

@property (nonatomic, assign, readonly) BOOL locationIsRequired;


///--------------------------------------
/// @name Certificate Pinning Properties
///--------------------------------------

# pragma mark - Certificate Pinning Properties

@property (nonatomic, assign, readonly) BOOL enabledPublicKeyPinning;


@property (nonatomic, assign, readonly) BOOL enabledTrustedPublicPKI;


///--------------------------------------
/// @name SSO Properties
///--------------------------------------

# pragma mark - SSO Properties

@property (nonatomic, assign) BOOL ssoEnabled;



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
 *  The validation method for JSON configuration
 *
 *  @return Returns an NSError of validation result; returns nil if there is no error.
 */
- (NSError *)validateJSONConfiguration;



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
