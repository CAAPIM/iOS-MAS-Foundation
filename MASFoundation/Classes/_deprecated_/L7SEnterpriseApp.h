//
//  L7SEnterpriseApps.h
//  sdkdemo
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
@class UIWebView;
@class UIImageView;

/**
 This class features enterprise browser capabilities.  It retrieves enterprise apps that can be configured on the server side, and encapsulates session sharing among web-based mobile apps and native mobile apps,
 */

@protocol L7SEnterpriseAppProtocol;

@interface L7SEnterpriseApp : NSObject

/**
 delegate that implements L7SEnterpriseAppProtocol
 */
@property (nonatomic)id<L7SEnterpriseAppProtocol> delegate DEPRECATED_ATTRIBUTE;

/**
 This is the app's identifier
 */
@property (readwrite, nonatomic) NSString *appId DEPRECATED_ATTRIBUTE;

/**
 This is the app's display name
 */
@property (readwrite, nonatomic) NSString *appName DEPRECATED_ATTRIBUTE;


/**
  This is a JSON object contains custom metadata.

 */
@property (readwrite, nonatomic) id customFields DEPRECATED_ATTRIBUTE;


/**
 This class method returns a list of L7SEnterprise app objects or an error if failed to retrieve the apps
 
  @param block a callback block receiving a list of apps or an error
 */
+ (void) enterpriseAppsWithBlock:(void (^)(NSArray *apps, NSError *error))block DEPRECATED_MSG_ATTRIBUTE("Use [MASApplication retrieveEnterpriseApps:] instead.");

/**
 This method loads an icon into the image view provided
 
 @param imageView an imageView object contains the app icon
 */
- (void) loadIconWithImageView:(UIImageView *) imageView DEPRECATED_MSG_ATTRIBUTE("Use [MASApplication enterpriseIconWithImageView:completion:] instead.");


/**
 This method loads a webapp into a webview
 
 @param webView a webView loading  the web app
 */
- (void) loadWebApp:(UIWebView *) webView DEPRECATED_MSG_ATTRIBUTE("Use [MASApplication loadWebApp:completion:] instead.");

@end

DEPRECATED_ATTRIBUTE
@protocol L7SEnterpriseAppProtocol <NSObject>


/**
 This is the protocol for an app to implement to receive a callback when an enterrpise webView needs to be loaded
 
 @param app the app object needs to be loaded as a webapp
 
 */
- (void) enterpriseWebApp: (L7SEnterpriseApp *) app DEPRECATED_ATTRIBUTE;

@end