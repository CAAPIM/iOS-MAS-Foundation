//
//  UIAlertController+MAS.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
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
