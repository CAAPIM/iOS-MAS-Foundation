//
//  MASConfigurationService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"

#import "MASConstantsPrivate.h"



@interface MASConfigurationService : MASService



///--------------------------------------
/// @name Network Configuration
///--------------------------------------

# pragma mark - Network Configuration

/**
Sets network timeout for specified host in MASNetworkConfiguration object

@warning Upon SDK initialization, [MASConfiguration currentConfiguration].gatewayUrl's MASNetworkConfiguration object will be overwritten. If primary gateway's network configuration has to be modified, ensure to set network configuration after SDK initialization.
@param networkConfiguration MASNetworkConfiguration object with host, and network configuration values.
*/
+ (void)setNetworkConfiguration:(MASNetworkConfiguration *)networkConfiguration;



/**
 Removes network configuration object based on the domain.

 @param domain NSURL of the domain to delete network configuration.
 */
+ (void)removeNetworkConfigurationForDomain:(NSURL *)domain;



/**
 Returns an array of MASNetworkConfiguration objects for each host.
 
 @return Returns an array of currently active MASNetworkConfigurations.
 */
+ (NSArray *)networkConfigurations;



/**
 Returns MASNetworkConfiguration object for a specific domain.
 
 @param domain NSURL of the domain for the MASNetworkConfiguration object.
 @return Returns a MASNetworkConfiguration object for the domain.
 */
+ (MASNetworkConfiguration *)networkConfigurationForDomain:(NSURL *)domain;



///--------------------------------------
/// @name Security Configuration
///--------------------------------------

# pragma mark - Security Configuration

/**
 Sets security measure for SSL pinning, and SSL validation for specified host in MASSecurityConfiguration object
 
 @warning Upon SDK initialization, [MASConfiguration currentConfiguration].gatewayUrl's MASSecurityConfiguration object will be overwritten. If primary gateway's security configuration has to be modified, ensure to set security configuration after SDK initialization.
 @param securityConfiguration MASSecurityConfiguration object with host, and security measure configuration values.
 */
+ (void)setSecurityConfiguration:(MASSecurityConfiguration *)securityConfiguration;




/**
 Removes security configuration object based on the domain.

 @param domain NSURL of the domain to delete security configuration.
 */
+ (void)removeSecurityConfigurationForDomain:(NSURL *)domain;



/**
 Returns an array of MASSecurityConfiguration objects for each host.
 
 @return Returns an array of currently active MASSecurityConfigurations.
 */
+ (NSArray *)securityConfigurations;



/**
 Returns MASSecurityConfiguration object for a specific domain.
 
 @param domain NSURL of the domain for the MASSecurityConfiguration object.
 @return Returns a MASSecurityConfiguration object for the domain.
 */
+ (MASSecurityConfiguration *)securityConfigurationForDomain:(NSURL *)domain;



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The available configurations by named key.
 */
@property (nonatomic, copy, readonly) NSArray *availableConfigurations;


/**
 * The current configuration singleton.
 */
@property (nonatomic, strong, readonly) MASConfiguration *currentConfiguration;



/**
 Sets boolean indicator of enforcing id_token validation upon device registration/user authentication. id_token is being validated as part of authentication/registration process against known signing algorithm.
 Mobile SDK currently supports following algorithm(s):
 - HS256
 
 Any other signing algorithm will cause authentication/registration failure due to unknown signing algorithm.  If the server side is configured to return a different or custom algorithm, ensure to disable id_token validation to avoid any failure on Mobile SDK.
 
 By default, id_token validation is enabled and enforced in authentication and/or registration process; it can be opted-out.
 
 @param enable BOOL value of indicating whether id_token validation is enabled or not.
 */
+ (void)enableIdTokenValidation:(BOOL)enable;



/**
 Gets boolean indicator of enforcing id_token validation upon device registration/user authentication. id_token is being validated as part of authentication/registration process against known signing algorithm.
 Mobile SDK currently supports following algorithm(s):
 - HS256
 
 Any other signing algorithm will cause authentication/registration failure due to unknown signing algorithm.  If the server side is configured to return a different or custom algorithm, ensure to disable id_token validation to avoid any failure on Mobile SDK.
 
 By default, id_token validation is enabled and enforced in authentication and/or registration process; it can be opted-out.
 
 @return BOOL value of indicating whether id_token validation is enabled or not.
 */
+ (BOOL)isIdTokenValidationEnabled;



/**
 * Set the configuration file's name to a custom value.
 */
+ (void)setConfigurationFileName:(NSString *)fileName;



/**
 *  Set the configuration object to a custom value.  This will overwrite the value in keychain storage.
 *
 *  @param configuration NSDictionary of JSON configuration object.
 */
+ (void)setNewConfigurationObject:(NSDictionary *)configuration;



/**
 *  Retrieve NSDictionary of JSON configuration.
 *  The default configuration will be retrieved from msso_config.json or the file name defined through [MAS setConfigurationFileName:].
 *
 *  @return NSDictionary of default JSON configuration.
 */
+ (NSDictionary *)getDefaultConfigurationAsDictionary;

@end
