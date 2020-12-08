//
//  MASWebSessionBrowserBasedAuthentication.m
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASWebSessionBrowserBasedAuthentication.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "MASTypedBrowserBasedAuthenticationInterface.h"
#import "MASAuthorizationResponse.h"

API_AVAILABLE(ios(12.0), macCatalyst(13.0), macos(10.15), watchos(6.2))
@interface MASWebSessionBrowserBasedAuthentication()

///--------------------------------------
/// @name Properties
///-------------------------------------

# pragma mark - Properties

@property (nonatomic, strong) ASWebAuthenticationSession *session;


@property (nonatomic, assign) MASAuthCredentialsBlock webLoginBlock;


@property (nonatomic, weak) id window;

@end

API_AVAILABLE(ios(13.0), macos(10.15))
@interface MASWebSessionBrowserBasedAuthentication() <ASWebAuthenticationPresentationContextProviding>
@end


@implementation MASWebSessionBrowserBasedAuthentication

///--------------------------------------
/// @name Start & Stop
///--------------------------------------

# pragma mark - Start & Stop


- (void)startWithURL:(NSURL *)url completion:(MASAuthCredentialsBlock)webLoginBlock
{
    self.session = [[ASWebAuthenticationSession alloc] initWithURL:url callbackURLScheme:nil completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        if (callbackURL != nil) {
            [MASAuthorizationResponse.sharedInstance handleAuthorizationResponseURL:callbackURL];
        } else {
            webLoginBlock(nil, YES, ^(BOOL completed, NSError* error) {
                if(error)
                {
                    DLog("An error occured or the user pressed cancel")
                }
            });
        }
    }];
    if (@available(iOS 13.0, macOS 10.15, *)) {
        self.session.presentationContextProvider = self;
    }

    __weak MASWebSessionBrowserBasedAuthentication* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
#if TARGET_OS_IOS
        weakSelf.window = [[UIApplication sharedApplication] keyWindow];
#else
        weakSelf.window = [[NSApplication sharedApplication] keyWindow];
#endif
        if ([weakSelf.session start]) {
            DLog(@"Successfully displayed login template");
        }
    });

}


- (void)dismiss
{
    [self.session cancel];
}



///--------------------------------------
/// @name ASWebAuthenticationPresentationContextProviding
///--------------------------------------

#pragma mark - ASWebAuthenticationPresentationContextProviding

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session {
    return self.window;
}

@end


