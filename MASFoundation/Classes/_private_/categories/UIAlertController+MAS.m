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
# pragma mark - Authentication Alerts

+ (void)popupAuthenticationAlert
{
    [self popupAuthenticationAlertInViewController:[self rootViewController]];
}


+ (void)popupAuthenticationAlertInViewController:(UIViewController *)viewController
{
    //
    // Ensure this is done in the main UI thread.  We don't know where the call is coming from
    //
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //
                       // Create alert controller
                       //
                       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sign In (MASUI)"
                                                                                                message:@"You need to sign in with your user credentials"
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       
                       //
                       // Username text field
                       //
                       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
                        {
                            textField.placeholder = NSLocalizedString(@"username", nil);
                        }];
                       
                       //
                       // Password text field
                       //
                       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
                        {
                            textField.placeholder = NSLocalizedString(@"password", nil);
                            textField.secureTextEntry = YES;
                        }];
                       
                       //
                       // OK Action
                       //
                       UIAlertAction *okAction = [UIAlertAction
                                                  actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action)
                                                  {
                                                      UITextField *usernameTextField = alertController.textFields.firstObject;
                                                      UITextField *passwordTextField = alertController.textFields.lastObject;
                                                      
                                                      //
                                                      // Attempt to authenticate
                                                      //
                                                      [MASUser loginWithUserName:usernameTextField.text password:passwordTextField.text completion:^(BOOL completed, NSError *error) {
                                                          
                                                          DLog(@"viewController received authentication response completed: %@ or error: %@",
                                                               (completed ? @"Yes" : @"No"), [error debugDescription]);
                                                          
                                                          if(error)
                                                          {
                                                              [UIAlertController popupErrorAlert:error];
                                                              return;
                                                          }
                                                      }];
                                                  }];
                       
                       [alertController addAction:okAction];
                       
                       //
                       // Cancel Action
                       //
                       UIAlertAction *cancelAction = [UIAlertAction
                                                      actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                      style:UIAlertActionStyleDefault
                                                      handler:nil];
                       
                       [alertController addAction:cancelAction];
                       
                       [viewController presentViewController:alertController animated:YES completion:nil];
                   });
}


# pragma mark - Error Alert

+ (void)popupErrorAlert:(NSError *)error
{
    [self popupErrorAlert:error inViewController:[self rootViewController]];
}


+ (void)popupErrorAlert:(NSError *)error inViewController:(UIViewController *)viewController
{
    //
    // Ensure this is done in the main UI thread.  We don't know where the call is coming from
    //
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                                message:[error localizedDescription]
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       
                       UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"OK"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action)
                                            {
                                                [alertController dismissViewControllerAnimated:YES completion:nil];
                                            }];
                       
                       [alertController addAction:ok];
                       
                       [viewController presentViewController:alertController animated:NO completion:nil];
                   });
}


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
