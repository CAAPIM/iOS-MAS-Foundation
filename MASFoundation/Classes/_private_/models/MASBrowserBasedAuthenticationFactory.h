//
//  MASTypedBrowserBasedAuthenticationFactory.h
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import "MASConstants.h"

@protocol MASBrowserBasedAuthenticationInterface;

/**
 * Utility factory class to build the correct browser type to use
 */
@interface MASBrowserBasedAuthenticationFactory : NSObject

/**
 * Build a new browser used for Browser Based Authentication
 *
 * @param browserType MASBrowserBasedAuthenticationBrowserType object used to indicate type of browser built
 * @return id<MASTypedBrowserBasedAuthenticationInterface> object which can be used to start Browser Based Authentication.
 */
+ (id<MASBrowserBasedAuthenticationInterface>)buildBrowserOfBrowserType:(MASBrowserBasedAuthenticationBrowserType)browserType;

@end
