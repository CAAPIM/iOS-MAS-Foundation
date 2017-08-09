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
