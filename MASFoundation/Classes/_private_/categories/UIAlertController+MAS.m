//
//  UIAlertController+MAS.m
//  MASFoundation
//
//  Created by nimma01 on 11/10/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
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
