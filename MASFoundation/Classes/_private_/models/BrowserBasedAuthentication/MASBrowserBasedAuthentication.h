//
//  MASBrowserBasedAuthentication.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import "MASConstants.h"

/**
 MASBrowserBasedAuthentication class is a helper class to utilize SFSafariViewController to launch a customized login template.
 * This class will get the redirection to receive the authorization code to perform login.
 */
@interface MASBrowserBasedAuthentication : NSObject

# pragma mark - Browser Based Authentication

/**
 * Retrieve the shared MASBrowserBasedAuthentication singleton.
 *
 * @return Returns the shared MASBrowserBasedAuthentication singleton.
 */
+ (instancetype)sharedInstance;



/**
 * Method to load the browser with a URL that loads a templatized login page.
 *
 * @param webLoginBlock completion MASCompletionErrorBlock that receives the results.
 */
- (void)loadWebLoginTemplate:(MASAuthCredentialsBlock)webLoginBlock;

@end
