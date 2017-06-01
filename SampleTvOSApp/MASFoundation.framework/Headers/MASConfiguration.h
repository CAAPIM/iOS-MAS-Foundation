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

@end
