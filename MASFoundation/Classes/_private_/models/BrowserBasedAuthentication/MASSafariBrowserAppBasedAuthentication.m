//
//  MASSafariBrowserAppBasedAuthentication.m
//  MASFoundation
//
//  Created by SY653660 on 12/11/21.
//  Copyright © 2021 CA Technologies. All rights reserved.
//

#import "MASSafariBrowserAppBasedAuthentication.h"
#import "MASTypedBrowserBasedAuthenticationInterface.h"

@import UIKit;


@interface MASSafariBrowserAppBasedAuthentication()

///--------------------------------------
/// @name Properties
///-------------------------------------

# pragma mark - Properties


@property (nonatomic, assign) MASAuthCredentialsBlock webLoginBlock;

@end


@implementation MASSafariBrowserAppBasedAuthentication


///--------------------------------------
/// @name Start & Stop
///--------------------------------------

# pragma mark - Start & Stop


- (void)startWithURL:(NSURL *)url completion:(MASAuthCredentialsBlock)webLoginBlock
{
    self.webLoginBlock = webLoginBlock;
    
    __weak MASSafariBrowserAppBasedAuthentication *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url
                                               options:[NSDictionary dictionary]
                                     completionHandler:^(BOOL success) {
                
                weakSelf.webLoginBlock(nil, success ? NO : YES, ^(BOOL completed, NSError * _Nullable error) {
                    
                    if (error) {
                        DLog(@"Browser cancel clicked");
                    }
                });
            }];
        }
        else {
            
            weakSelf.webLoginBlock(nil, YES, ^(BOOL completed, NSError * _Nullable error) {
                
                if (error) {
                    DLog(@"Browser cancel clicked");
                }
            });
        }
        
        return;
    });
    
}


- (void)dismiss
{

}


@end
