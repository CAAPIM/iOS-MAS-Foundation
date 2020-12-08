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

@protocol MASTypedBrowserBasedAuthenticationInterface;

/**
 * Utility factory class to build the correct browser type to use
 */
@interface MASTypedBrowserBasedAuthenticationFactory : NSObject

/**
 * Build a new browser used for Browser Based Authentication
 *
 * @param browserBasedAuthenticationType A MASBrowserBasedAuthenticationType object telling the factory what to build information.
 * @return id<MASTypedBrowserBasedAuthenticationInterface> object which can be used to start Browser Based Authentication.
 */
+ (id<MASTypedBrowserBasedAuthenticationInterface>)buildBrowserForType:(MASBrowserBasedAuthenticationType)browserBasedAuthenticationType;

@end
