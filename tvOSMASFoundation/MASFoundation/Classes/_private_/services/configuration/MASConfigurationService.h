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
