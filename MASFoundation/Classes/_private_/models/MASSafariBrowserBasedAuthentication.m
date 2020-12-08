//
//  MASSafariBrowserBasedAuthentication.m
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <SafariServices/SafariServices.h>
#import "MASSafariBrowserBasedAuthentication.h"
#import "MASTypedBrowserBasedAuthenticationInterface.h"
#import "UIAlertController+MAS.h"

@interface MASSafariBrowserBasedAuthentication() <SFSafariViewControllerDelegate>

@property (nonatomic, strong) SFSafariViewController *safariViewController;
@property (nonatomic, assign) MASAuthCredentialsBlock webLoginBlock;

@end

@implementation MASSafariBrowserBasedAuthentication


- (void)startWithURL:(NSURL *)url completion:(MASAuthCredentialsBlock)webLoginBlock
{
    self.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    self.safariViewController.delegate = self;
    self.webLoginBlock = webLoginBlock;

    __block MASSafariBrowserBasedAuthentication *blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertController rootViewController].modalTransitionStyle = UIModalTransitionStyleCoverVertical;

        [[UIAlertController rootViewController] presentViewController:blockSelf.safariViewController
                                                             animated:YES
                                                           completion:^{
            DLog(@"Successfully displayed login template");
        }];

        return;
    });
}


- (void)dismiss
{
    __block MASSafariBrowserBasedAuthentication *blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [blockSelf.safariViewController dismissViewControllerAnimated:true completion: nil];
    });

}



#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    self.webLoginBlock(nil, YES, ^(BOOL completed, NSError* error){
        if(error)
        {
            DLog(@"Browser cancel clicked");
        }
    });
}

@end

