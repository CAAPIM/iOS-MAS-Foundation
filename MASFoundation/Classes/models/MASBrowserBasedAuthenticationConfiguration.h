//
//  MASBrowserBasedAuthenticationConfigurationInterface.h
//  MASFoundation
//
//  Created by sander saelmans on 21/12/2020.
//  Copyright © 2020 CA Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 MASBrowserBasedAuthenticationConfigurationInterface protocol is used to define a set of object which can be used to configure the preferred browser based authentication behaviour
 */
@protocol MASBrowserBasedAuthenticationConfigurationInterface <NSObject>
@end



/**
 MASSafariBrowserBasedAuthenticationConfiguration class is used to present a SFSafariViewController browser based login
 */
@interface MASSafariBrowserBasedAuthenticationConfiguration : NSObject <MASBrowserBasedAuthenticationConfigurationInterface>

@end




API_AVAILABLE(ios(12.0), macCatalyst(13.0), macos(10.15), watchos(6.2)) API_UNAVAILABLE(tvos)
/**
 MASSafariBrowserBasedAuthenticationConfiguration class is used to present a ASWebAuthenticationSession browser based login
 @note You have to provide a valid callback url scheme in order for this configuration to work properly.
 */
@interface MASWebSessionBrowserBasedAuthenticationConfiguration : NSObject <MASBrowserBasedAuthenticationConfigurationInterface>


@property (nonatomic, strong, nonnull) NSString *callbackURLScheme;


/**
 * Initialises a MASWebSessionBrowserBasedAuthenticationConfiguration with the provided callback url scheme
 *
 * @param callbackURLScheme Nonnull NSString object represeting the callback url scheme used to notify the login session has concluded.
 * @return Returns an initialized MASWebSessionBrowserBasedAuthenticationConfiguration
 */
- (instancetype _Nonnull)initWithCallbackURLScheme:(NSString * _Nonnull)callbackURLScheme;


- (instancetype _Null_unspecified)init NS_UNAVAILABLE;


+ (instancetype _Null_unspecified)new NS_UNAVAILABLE;

@end
