//
//  MASAuthenticationProviders.h
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

@class MASAuthenticationProvider;


/**
 * The `MASAuthenticationProviders` class is a representation of all available providers.
 */
@interface MASAuthenticationProviders : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The MASAuthenticationProvider instances.
 */
@property (nonatomic, copy, readonly) NSArray *providers;


/**
 *  idp value indicates which social media should be available for the device.
 */
@property (nonatomic, copy, readonly) NSString *idp;



///--------------------------------------
/// @name Current Providers
///--------------------------------------

# pragma mark - Current Providers

/**
 * The application's currently configured authentication providers. This is a singleton object.
 *
 * @return Returns a singleton 'MASAuthenticationProviders' object.
 */
+ (MASAuthenticationProviders *)currentProviders;



///--------------------------------------
/// @name Proximity Login
///--------------------------------------

# pragma mark - Proximity Login

/**
 *  Retrieves the instance of MASAuthenticationProvider for BLE/QR Code Proximity Login.
 *
 *  @return Returns MASAuthenticationProvider for BLE/QA Code Proximity Login.
 */
- (MASAuthenticationProvider *)retrieveAuthenticationProviderForProximityLogin;

@end
