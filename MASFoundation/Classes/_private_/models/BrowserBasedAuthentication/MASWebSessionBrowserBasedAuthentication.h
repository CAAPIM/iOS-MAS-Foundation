//
//  MASWebSessionBrowserBasedAuthentication.h
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN



@protocol MASTypedBrowserBasedAuthenticationInterface;

/**
 * A Browser Based Authentication type utilising an ASWebAuthenticationSession
 */
API_AVAILABLE(ios(12.0), macCatalyst(13.0), macos(10.15), watchos(6.2))
@interface MASWebSessionBrowserBasedAuthentication : NSObject <MASTypedBrowserBasedAuthenticationInterface>


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Initializer to perform default initialization.
 *
 * @param callbackURLScheme NSString containing the callback url scheme to use.
 * @return Returns the newly initialized MASWebSessionBrowserBasedAuthentication.
 */
- (instancetype)initWithCallbackURLScheme:(NSString *)callbackURLScheme;

@end



NS_ASSUME_NONNULL_END
