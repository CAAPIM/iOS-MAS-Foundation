//
//  MASSocialLogin.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSocialLogin.h"

#import <WebKit/WKNavigationDelegate.h>

#import "MASAccessService.h"
#import "NSError+MASPrivate.h"


static NSString *const MASSocialLoginAuthenticationProvider = @"provider"; // string
static NSString *const MASSocialLoginWebview = @"webview"; // string
static NSString *const MASSocialLoginOriginalDelegate = @"originalDelegate"; // string


@interface MASSocialLogin () <WKNavigationDelegate, UIWebViewDelegate>

@property (nonatomic, weak) id originalDelegate;
@property (nonatomic, weak) WKWebView *webView;

@end


@implementation MASSocialLogin

#if TARGET_OS_IOS
- (instancetype)initWithAuthenticationProvider:(MASAuthenticationProvider *)provider webView:(WKWebView *)webView
{
    self = [super init];
    
    if (self)
    {
        //
        // Keep the original delegate if there is
        //
        if (webView.navigationDelegate)
        {
            self.originalDelegate = webView.navigationDelegate;
        }
        
        //
        // Set the navigation delegate to this object to handle the operation
        //
        webView.navigationDelegate = self;
        
        self.provider = provider;
        self.webView = webView;
        
        
        //
        // Get all data type
        //
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        
        //
        // Date from
        //
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        //
        // Execute
        //
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
            NSURLRequest *request = [NSURLRequest requestWithURL:self.provider.authenticationUrl];
            [self.webView loadRequest:request];
        }];

    }
    
    return self;
}

#endif
# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
    [super encodeWithCoder:aCoder];
    
    if (self.webView)
    {
        [aCoder encodeObject:self.webView forKey:MASSocialLoginWebview];
    }
    
    if (self.provider)
    {
        [aCoder encodeObject:self.provider forKey:MASSocialLoginAuthenticationProvider];
    }
    
    if (self.originalDelegate)
    {
        [aCoder encodeObject:self.originalDelegate forKey:MASSocialLoginOriginalDelegate];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //DLog(@"\n\ncalled\n\n");
    
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.webView = [aDecoder decodeObjectForKey:MASSocialLoginWebview];
        self.provider = [aDecoder decodeObjectForKey:MASSocialLoginAuthenticationProvider];
        self.originalDelegate = [aDecoder decodeObjectForKey:MASSocialLoginOriginalDelegate];
    }
    
    return self;
}


#
# pragma mark - Debug description
#

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) auth provider: %@\n        webview: %@\n        webview delegate: %@"
            "\n        original delegate: @\n",
            [self class], self.provider, self.webView, self.originalDelegate];
}


#
# pragma mark - WKNavigationDelegate
#

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    //
    // Notify delegate for start of loading webview
    //
    if (_delegate && [_delegate respondsToSelector:@selector(didStartLoadingWebView)])
    {
        [_delegate didStartLoadingWebView];
    }
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    //
    // Notify delegate for stop of loading webview
    //
    if (_delegate && [_delegate respondsToSelector:@selector(didStopLoadingWebView)])
    {
        [_delegate didStopLoadingWebView];
    }
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    //
    // Notify delegate for an error from webview
    //
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveError:)])
    {
        [_delegate didReceiveError:error];
    }
}


- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
   // DLog(@"server redirect : %@", [webView.URL description]);
    
    NSRange range = [[webView.URL description] rangeOfString:[MASApplication currentApplication].redirectUri.absoluteString];
    
    if (range.length>0){
        
        //DLog(@"request matches the registered the rediect URI");
        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponentsSeperatedwithQuestionMark = [[webView.URL description] componentsSeparatedByString:@"?"];
        NSString *redirect_uri = urlComponentsSeperatedwithQuestionMark[0];
        NSArray *urlComponents = [urlComponentsSeperatedwithQuestionMark[1] componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [queryStringDictionary setObject:value forKey:key];
        }
        
        if([redirect_uri isEqualToString:[MASApplication currentApplication].redirectUri.absoluteString]){
            
            if (_webView)
            {
                //
                //  Stop loading webview for further request
                //
                [_webView stopLoading];
                
                //
                //  Replace the navigationDelegate of the webview to its original one, if it exsits
                //
                if (_originalDelegate)
                {
                    _webView.navigationDelegate = _originalDelegate;
                }
                //
                //  Otherwise, nullify the delegate of the webview
                //
                else {
                    _webView.navigationDelegate = nil;
                }
            }
            
            //
            // Validate PKCE state value
            // If either one of request or response states is present, validate it; otherwise, ignore
            //
            if ([queryStringDictionary objectForKey:MASPKCEStateRequestResponseKey] || [[MASAccessService sharedService].currentAccessObj retrievePKCEState])
            {
                NSString *responseState = [queryStringDictionary objectForKey:MASPKCEStateRequestResponseKey];
                NSString *requestState = [[MASAccessService sharedService].currentAccessObj retrievePKCEState];
                
                NSError *pkceError = nil;
                
                //
                // If response or request state is nil, invalid request and/or response
                //
                if (responseState == nil || requestState == nil)
                {
                    pkceError = [NSError errorInvalidAuthorization];
                }
                //
                // verify that the state in the response is the same as the state sent in the request
                //
                else if (![[queryStringDictionary objectForKey:MASPKCEStateRequestResponseKey] isEqualToString:[[MASAccessService sharedService].currentAccessObj retrievePKCEState]])
                {
                    pkceError = [NSError errorInvalidAuthorization];
                }
                
                //
                // If the validation fail, notify
                //
                if (pkceError)
                {
                    
                    //
                    // Notify delegate for an error from webview
                    //
                    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveError:)])
                    {
                        [_delegate didReceiveError:pkceError];
                    }
                    
                    return;
                }
            }
            
            //
            // Notify delegate for stop of loading webview
            //
            if (_delegate && [_delegate respondsToSelector:@selector(didStopLoadingWebView)])
            {
                [_delegate didStopLoadingWebView];
            }
            
            //
            // Notify delegate for receive of an authorization code
            //
            if (_delegate && [_delegate respondsToSelector:@selector(didReceiveAuthorizationCode:)])
            {
                [_delegate didReceiveAuthorizationCode:[queryStringDictionary objectForKey:@"code"]];
            }
        }
    }
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        disposition = NSURLSessionAuthChallengeUseCredential;
    }
    
    completionHandler(disposition, credential);
}

@end
