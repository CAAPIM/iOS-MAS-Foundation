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
/// @name Public
///-------------------------------------

# pragma mark - Public

/**
 * Retrieve the currently visible UIViewController.
 */
+ (UIViewController *)rootViewController;
@end
