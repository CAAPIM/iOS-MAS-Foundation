//
//  UIAlertController+MAS.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "UIAlertController+MAS.h"
#import "MASUser.h"
@implementation UIAlertController (MAS)

# pragma mark - Error Alert

+ (UIViewController *) presentedViewController:(id)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self presentedViewController:navigationController.topViewController];
    }
    if ([viewController isKindOfClass:[UIViewController class]])
    {
        if ([viewController presentedViewController])
        {
            if ([[viewController presentedViewController] isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *navigationController = (UINavigationController *)[viewController presentedViewController];
                
                if (navigationController.isBeingDismissed)
                {
                    return viewController;
                }
            }
            
            return [self presentedViewController:[viewController presentedViewController]];
        }
        else {
            return viewController;
        }
    }
    else if ([viewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self presentedViewController:tabBarController.presentedViewController];
    }
    else {
        return nil;
    }
}


# pragma mark - Public

+ (UIViewController *)rootViewController
{
    return [self presentedViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}
@end
