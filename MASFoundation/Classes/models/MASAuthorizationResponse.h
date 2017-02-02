//
//  MASAuthorizationResponse.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



/**
 MASAuthorizationResponseDelegate protocol is an optional protocol that may be implemented to handle the response of authorization code from social login provider's authorization.
 These protocols may be implemented in the designated class where social login authentication is being processed.
 
 Alternatively, NSNotification can be subscribed to perform exactly the same behaviour.
 
 - (void)didReceiveAuthorizationCode:(NSString *)code : subscribe MASAuthorizationResponseDidReceiveAuthorizationCodeNotification NSNotification's notification name.  Object of the notification will be delivered as NSDictionary object.  Authorization code will be placed in with the key, "code".
 
 - (void)didReceiveError:(NSError *)error : subscribe MASAuthorizationResponseDidReceiveErrorNotification for NSNotification's notification name.  Any error occurred during the parsing will be delievered as NSError object in NSNotification's object property.
 */
@protocol MASAuthorizationResponseDelegate <NSObject>

/**
 *  Delegation method to notify with authorization code when the authentication process is done.
 *
 *  @param code NSString of authorization code
 */
- (void)didReceiveAuthorizationCode:(NSString *_Nonnull)code;



/**
 *  Delegation method to notify when an error is encountered during the authentication process.
 *
 *  @param error NSError object of the encountered error
 */
- (void)didReceiveError:(NSError *_Nonnull)error;

@end




/**
 MASAuthorizationResponse class is designed to handle application's interaction with other applications (SFSafariViewController) for social login functionality of MASFoundation SDK.
 
 MASAuthorizationResponse method should be properly invoked in [UIApplicationDelegate application:openURL:options:] method of AppDelegate for the application.
 If the method is not invoked, social login functionality may not work properly.
 */
@interface MASAuthorizationResponse : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  MASAuthorizationResponseDelegate property for delegation of MASAuthorizationResponse protocols
 */
@property (nonatomic, weak, nullable) id<MASAuthorizationResponseDelegate> delegate;


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Retrieve the shared MASAuthorizationResponse singleton.
 *
 * Note, subclasses should override this version of the method.
 *
 * @return Returns the shared MASAuthorizationResponse singleton.
 */
+ (instancetype _Nullable)sharedInstance;



NS_ASSUME_NONNULL_BEGIN

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_3
/**
 * Prase returned URL from SFSafariViewController with authorization code and OAuth state.
 * Call this method inside [UIApplicationDelegate application:openURL:options:] of the AppDelegate for the application.
 * This method should be invoked in order to properly perform social login in MASFoundation SDK.
 *
 * @param app     UIApplication object as passed in [UIApplicationDelegate application:openURL:options:].
 * @param url     NSURL object as passed in [UIApplicationDelegate application:openURL:options:].
 * @param options NSDictionary as passed in [UIApplicationDelegate application:openURL:options:].
 *
 * @return BOOL value whether the URL is specific for social login in MASFoundation or not.
 */
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;
#endif



/**
 * Prase returned URL from SFSafariViewController with authorization code and OAuth state.
 * Call this method inside [UIApplicationDelegate application:openURL:sourceApplication:annotation:] of the AppDelegate for the application.
 * This method should be invoked in order to properly perform social login in MASFoundation SDK.
 *
 * @param application       UIApplication object as passed in [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 * @param url               NSURL object as passed in [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 * @param sourceApplication NSDictionary as passed in [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 * @param annotation        annotation as passed in [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 *
 * @return BOOL value whether the URL is specific for social login in MASFoundation or not.
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

NS_ASSUME_NONNULL_END

@end
