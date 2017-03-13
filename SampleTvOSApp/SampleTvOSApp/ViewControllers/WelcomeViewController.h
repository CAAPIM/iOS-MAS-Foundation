//
//  WelcomeViewController.h
//  SampleTvOSApp
//
//  Created by Akshay on 08/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnUserNamePwd;

- (IBAction)clkUsernamePwd:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnQRcode;

- (IBAction)clkQRcode:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnBLE;
- (IBAction)clkBLE:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;

- (IBAction)clkFacebook:(id)sender;




@end
