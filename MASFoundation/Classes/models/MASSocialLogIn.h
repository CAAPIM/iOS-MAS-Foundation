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

DEPRECATED_ATTRIBUTE
@protocol MASSocialLoginDelegate <NSObject>

@required

/**
 *  Delegation method to notify with authorization code when the authentication process is done.
 *
 *  @param code NSString of authorization code
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
- (void)didReceiveAuthorizationCode:(NSString *)code DEPRECATED_ATTRIBUTE;



@optional

/**
 *  Delegation method to notify when an error is encountered during the authentication process.
 *
 *  @param error NSError object of the encountered error
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
- (void)didReceiveError:(NSError *)error DEPRECATED_ATTRIBUTE;



/**
 *  Delegation method to notify when WKWebView starts loading.
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
- (void)didStartLoadingWebView DEPRECATED_ATTRIBUTE;



/**
 *  Delegation method to notify when WKWebView stops loading.
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
- (void)didStopLoadingWebView DEPRECATED_ATTRIBUTE;

@end



/**
 *  The 'MASSocialLogin' class is a helper class to utilize WKWebView object for social network authentication.
 *  The WKNavigationDelegate will be re-delegated to this class during authentication process, and will be assigned back to the original delegation.
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
DEPRECATED_ATTRIBUTE
@interface MASSocialLogin : MASObject


/**
 *  MASAuthentication property for social login
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
@property (nonatomic, strong) MASAuthenticationProvider *provider DEPRECATED_ATTRIBUTE;


/**
 *  MASSocialLoginDelegate property for delegation of MASSocialLogin protocols
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
@property (nonatomic, weak) id<MASSocialLoginDelegate> delegate DEPRECATED_ATTRIBUTE;



/**
 *  Initialize the object with MASAuthenticationProvider and WKWebView.
 *
 *  @param provider MASAuthenticationProvider for which social network login to be performed
 *  @param webView  WKWebView to process the social login
 *
 *  @return MASSocialLogin object
 *
 *  @deprecated Use `SFSafariViewController` and `MASAuthorizationResponse` with MASAuthenticationProvider to present social login view instead.
 */
- (instancetype)initWithAuthenticationProvider:(MASAuthenticationProvider *)provider webView:(WKWebView *)webView DEPRECATED_ATTRIBUTE;

@end


