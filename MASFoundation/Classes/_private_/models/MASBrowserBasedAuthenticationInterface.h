//
//  MASBrowserBasedAuthenticationInterface.h
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//
#import "MASConstants.h"

/**
 * Interface used to abstract different type of browsers used for Browser Based Authentication
 */
@protocol MASBrowserBasedAuthenticationInterface <NSObject>

/**
 Starts the Browser based authentication with the given url and completion block.

 @param templatizedURL NSURL sent to the browser
 @param completion MASAuthCredentialsBlock object.
 */
- (void)startWithURL:(NSURL *)templatizedURL completion:(MASAuthCredentialsBlock)webLoginBlock;


/**
 Dismisses the currently presented browser.
 */
- (void)dismiss;

@end
