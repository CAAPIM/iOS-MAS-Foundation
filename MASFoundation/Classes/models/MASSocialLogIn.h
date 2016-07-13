//
//  MASSocialLogin.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

#import <WebKit/WebKit.h>

@protocol MASSocialLoginDelegate <NSObject>

@required

/**
 *  Delegation method to notify with authorization code when the authentication process is done.
 *
 *  @param code NSString of authorization code
 */
- (void)didReceiveAuthorizationCode:(NSString *)code;



@optional

/**
 *  Delegation method to notify when an error is encountered during the authentication process.
 *
 *  @param error NSError object of the encountered error
 */
- (void)didReceiveError:(NSError *)error;



/**
 *  Delegation method to notify when WKWebView starts loading.
 */
- (void)didStartLoadingWebView;



/**
 *  Delegation method to notify when WKWebView stops loading.
 */
- (void)didStopLoadingWebView;

@end



/**
 *  The 'MASSocialLogin' class is a helper class to utilize WKWebView object for social network authentication.
 *  The WKNavigationDelegate will be re-delegated to this class during authentication process, and will be assigned back to the original delegation.
 */
@interface MASSocialLogin : MASObject


/**
 *  MASAuthentication property for social login
 */
@property (nonatomic, strong) MASAuthenticationProvider *provider;


/**
 *  MASSocialLoginDelegate property for delegation of MASSocialLogin protocols
 */
@property (nonatomic, weak) id<MASSocialLoginDelegate> delegate;



/**
 *  Initialize the object with MASAuthenticationProvider and WKWebView.
 *
 *  @param provider MASAuthenticationProvider for which social network login to be performed
 *  @param webView  WKWebView to process the social login
 *
 *  @return MASSocialLogin object
 */
- (instancetype)initWithAuthenticationProvider:(MASAuthenticationProvider *)provider webView:(WKWebView *)webView;

@end


