//
//  MASApplication.h
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASObject.h"

@class UIImageView;
@class UIWebView;


@protocol MASEnterpriseAppProtocol;


/**
 *  MASAuthenticationStatus states the authentication status of the application.
 */
typedef NS_ENUM(NSInteger, MASAuthenticationStatus) {
    /**
     *  MASAuthenticationStatusNotLoggedIn represents that the app has not been authenticated.
     */
    MASAuthenticationStatusNotLoggedIn = -1,
    /**
     *  MASAuthenticationStatusLoginWithUser represents that the app has been authenticated with user.
     */
    MASAuthenticationStatusLoginWithUser,
    /**
     *  MASAuthenticationStatusLoginAnonymously represents that the app has been authenticated with client credentials.
     */
    MASAuthenticationStatusLoginAnonymously
};


/**
 * The `MASApplication` class is a local representation of application data.
 */
@interface MASApplication : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 * Is the MASApplication registered.
 */
@property (nonatomic, assign, readonly) BOOL isRegistered;


/**
 * The MASApplication organization.
 */
@property (nonatomic, copy, readonly) NSString *organization;


/**
 * The MASApplication name.
 */
@property (nonatomic, copy, readonly) NSString *name;


/**
 * The MASApplication identifier.
 */
@property (nonatomic, copy, readonly) NSString *identifier;


/**
 * The MASApplication description.
 */
@property (nonatomic, copy, readonly) NSString *detailedDescription;


/**
 * The MASApplication icon url.
 */
@property (nonatomic, copy, readonly) NSString *iconUrl;


/**
 * The MASApplication auth url.
 */
@property (nonatomic, copy, readonly) NSString *authUrl;


/**
 * The MASApplication native url.
 */
@property (nonatomic, copy, readonly) NSString *nativeUrl;


/**
 * The MASApplication custom properties.
 */
@property (nonatomic, copy, readonly) NSDictionary *customProperties;


/**
 * The MASApplication environment.
 */
@property (nonatomic, copy, readonly) NSString *environment;


/**
 * The MASApplication redirect URL.
 */
@property (nonatomic, copy, readonly) NSURL *redirectUri;


/**
 * The MASApplication registeredBy identifier.
 */
@property (nonatomic, copy, readonly) NSString *registeredBy;


/**
 * The MASApplication scope array.
 */
@property (nonatomic, copy, readonly) NSArray *scope;


/**
 * The MASApplication scope array as a space seperated string.
 */
@property (nonatomic, copy, readonly) NSString *scopeAsString;


/**
 * The MASApplication status.
 */
@property (nonatomic, copy, readonly) NSString *status;


/**
 *  The MASApplication authentication status for Client Credentials.
 */
@property (nonatomic, assign, readonly) BOOL isAuthenticated;


/**
 *  MASAuthenticationStatus represents the application's authentication status
 */
@property (nonatomic, assign, readonly) MASAuthenticationStatus authenticationStatus;


/**
 * The MASEnterpriseAppProtocol delegate.
 */
@property id<MASEnterpriseAppProtocol> delegate;


///--------------------------------------
/// @name Current Application
///--------------------------------------

# pragma mark - Current Application

/**
 *  This application. This is a singleton object.
 *
 *  @return Returns a singleton 'MASApplication' object.
 */
+ (MASApplication *)currentApplication;

///--------------------------------------
/// @name Enterprise App
///--------------------------------------

# pragma mark - Enterprise App

/**
 *  Retrieve the currently registered enterprise applications.
 *
 *  @param completion The MASObjectsResponseErrorBlock (NSArray *objects, NSError *error) completion block.
 */
- (void)retrieveEnterpriseApps:(MASObjectsResponseErrorBlock)completion;


/**
 * Loads the app icon into a UIImageView to enable enterprise app funcationality.
 *
 * @param imageView an imageView object contains the app icon.
 *
 * @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
- (void)enterpriseIconWithImageView:(UIImageView *)imageView completion:(MASCompletionErrorBlock)completion;


/**
 * Loads a web application representing this application into a UIWebView.
 *
 * @param webView a webView loading the web app.
 *
 * @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
- (void)loadWebApp:(UIWebView *)webView completion:(MASCompletionErrorBlock)completion;

@end


@protocol MASEnterpriseAppProtocol <NSObject>


/**
 * This is the protocol for an app to implement to receive a callback when an enterpise web view needs to be loaded.
 *
 * @param app The app object needs to be loaded as a web app.
 */
- (void)enterpriseWebApp:(MASApplication *)app;

/**
 * This is the protocol for an app to implement to receive a error callback while loading the icon or webapp.
 *
 * @param app The app object.
 * @param error object which has the details of the error.
 */
- (void)enterpriseApp:(MASApplication *)app didReceiveError:(NSError *)error;

@end
