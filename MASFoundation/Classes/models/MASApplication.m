//
//  MASApplication.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASApplication.h"

#import "MASConfiguration.h"
#import "MASConstantsPrivate.h"
#import "MASModelService.h"


@interface MASApplication ()
    <UIWebViewDelegate>
{
    id _originalDelegate;
}

@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, copy) MASCompletionErrorBlock errorBlock;

@end


@implementation MASApplication


# pragma mark - Current Application

+ (MASApplication *)currentApplication
{
    return [MASModelService sharedService].currentApplication;
}


# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) is registered: %@\n\n        organization: %@\n        name: %@"
        "\n        detailed description: %@\n        identifier: %@\n        environment: %@\n        status: %@"
        "\n        icon url: %@\n        auth url: %@\n        native url: %@\n        redirect uri: %@"
        "\n        registered by: %@\n        scope: %@\n        custom properties: %@",
        [self class], ([self isRegistered] ? @"Yes" : @"No"), [self organization], [self name], [self detailedDescription],
        [self identifier], [self environment], [self status], [self iconUrl], [self authUrl], [self nativeUrl],
        [self redirectUri],[self registeredBy], [self scopeAsString],
        (![self customProperties] ? @"<none>" : [NSString stringWithFormat:@"\n\n%@", [self customProperties]])];
}


# pragma mark - Enterprise Apps

- (void)retrieveEnterpriseApps:(MASObjectsResponseErrorBlock)completion
{
    //
    //  Making sure user has valid session before making a call to retrieve enterprise browser apps
    //
    [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
        
        if (completed && !error)
        {
            [[MASModelService sharedService] retrieveEnterpriseApplications:completion];
        }
        
        else
        {
            if(completion) completion(nil, error);
        }
    }];
}


- (void)enterpriseIconWithImageView:(UIImageView *)imageView completion:(MASCompletionErrorBlock)completion
{
    //
    // Create and add a tap gesture recognizer
    //
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    
    self.errorBlock = completion;
    //
    // Set the icon image
    //
    [imageView setImageWithURL:[NSURL URLWithString:self.iconUrl] placeholderImage:nil];
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:singleTap];
}


- (void)loadWebApp:(UIWebView *)webView completion:(MASCompletionErrorBlock)completion
{
    //
    // Validate URL
    //
    if(![MASApplication isProtectedResource:[NSURL URLWithString:self.authUrl]] )
    {
        // Invalid URL
        NSError *error = [NSError errorEnterpriseBrowserWebAppInvalidURL];

        if (completion) completion(NO,error);
        
        return;
    }
    
    //
    // Create the URL request
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.authUrl]];
    
    //
    // If the UIWebView already has a delegate we must store it
    //
    if(webView.delegate != nil)
    {
        _originalDelegate = webView.delegate;
    }
    
    webView.delegate = self;
    _webView = webView;
    
    if (completion) completion(YES,nil);
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(didReceiveStatusUpdate:)
        name:L7SDidReceiveStatusUpdateNotification
        object:nil];
    */
    
    [webView loadRequest:request];
}


+ (BOOL)isProtectedResource:(NSURL *)resourceURL
{
    NSString *resourceURLHost = [resourceURL host];
    NSString *endpointHost = [MASConfiguration currentConfiguration].gatewayHostName;
    
    //
    // If the url has a prefix
    //
    if([resourceURLHost hasPrefix:endpointHost])
    {
        if( resourceURLHost.length == endpointHost.length ||
            [resourceURLHost isEqualToString:[endpointHost stringByAppendingString:@"."]])
        {
            return YES;
        }
    }
    
    return NO;
}


- (void)singleTapping:(UIGestureRecognizer *)recognizer
{
    //
    //  If a valid native url property exists
    //
    if(self.nativeUrl && self.nativeUrl.length != 0)
    {
        //
        // If the native application be opened
        //
        NSURL *nativeURL = [NSURL URLWithString:self.nativeUrl];
        if(![[UIApplication sharedApplication] canOpenURL:nativeURL])
        {
            // Native app does not exist
            NSError *error = [NSError errorEnterpriseBrowserNativeAppDoesNotExist];

            if (self.errorBlock) {
                self.errorBlock(YES,error);
            }
            
            return;
        }
        
        //
        // Attempt to pen the application
        //
        if(![[UIApplication sharedApplication] openURL:nativeURL])
        {
            // Native app failed to open
            NSError *error = [NSError errorEnterpriseBrowserNativeAppCannotOpen];

            if (self.errorBlock) {
                self.errorBlock(YES,error);
            }
            
            return;
        }
        
        if (self.errorBlock) {
            self.errorBlock(YES,nil);
        }
        return;
    }
    
    //
    // If a valid auth url property exists call the deleget
    //
    if(self.authUrl)
    {

        [self.delegate enterpriseWebApp:self];
        
        if (self.errorBlock) {
            self.errorBlock(YES,nil);
        }
        
        return;
    }
    
    // App doesnot exist
    NSError *error = [NSError errorEnterpriseBrowserAppDoesNotExist];
    if (self.delegate && [self.delegate respondsToSelector:@selector(enterpriseApp:didReceiveError:)]) {
        [self.delegate enterpriseApp:self didReceiveError:error];
    }
    if (self.errorBlock) {
        self.errorBlock(NO,error);
    }
}


# pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"didFailLoadWithError %@",error);
    if(_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        return [_originalDelegate webView:webView didFailLoadWithError:error];
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    if(_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        return [_originalDelegate webViewDidStartLoad:webView];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if(_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        return [_originalDelegate webViewDidFinishLoad:webView];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"shouldStartLoadWithRequest %@",request);
    return (_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)] ?
        
        //
        // Call the original delegate
        //
        [_originalDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType] :
        
        //
        // Just return YES
        //
        YES);
}

@end
