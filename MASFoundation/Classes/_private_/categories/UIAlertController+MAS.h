//
//  UIAlertController+MAS.h
//  MASFoundation
//
//  Created by nimma01 on 11/10/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (MAS)
///--------------------------------------
/// @name Authentication Alerts
///-------------------------------------

# pragma mark - Authentication Alerts

/**
 * Displays on screen an authentication UIAlertController modally in the currently
 * visible UIViewController.
 */
+ (void)popupAuthenticationAlert;


/**
 * Displays on screen an authentication UIAlertController modally in the selected
 * UIViewController modally.
 *
 * @param viewController The UIViewController in which to present the modal UIAlertController.
 */
+ (void)popupAuthenticationAlertInViewController:(UIViewController *)viewController;



///--------------------------------------
/// @name Error Alerts
///-------------------------------------

# pragma mark - Error Alerts

/**
 * Displays on screen an error UIAlertController modally in the currently
 * visible UIViewController.
 */
+ (void)popupErrorAlert:(NSError *)error;


/**
 * Displays on screen an error UIAlertController modally in the selected
 * UIViewController modally.
 *
 * @param error The NSError contents to show in the UIAlertController.
 * @param viewController The UIViewController in which to present the modal UIAlertController.
 */
+ (void)popupErrorAlert:(NSError *)error inViewController:(UIViewController *)viewController;



///--------------------------------------
/// @name Public
///-------------------------------------

# pragma mark - Public

/**
 * Retrieve the currently visible UIViewController.
 */
+ (UIViewController *)rootViewController;
@end
