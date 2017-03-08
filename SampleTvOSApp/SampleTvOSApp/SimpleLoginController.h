//
//  ViewController.h
//  SampleTvOSApp
//
//  Created by Akshay on 16/02/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <tvOS_MASFoundation/tvOS MASFoundation.h>

@interface SimpleLoginController : UIViewController<MASProximityLoginDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@property (weak, nonatomic) IBOutlet UITextField *txtFPassWord;
@property (strong, nonatomic) MASProximityLoginQRCode *qrCodeProximityLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtFUserName;
-(void)masProximityLogin:(NSNotification*)notification;
-(void)userAuthenticated:(NSNotification*)notification;
-(void)userFailToAuthenticate:(NSNotification*)notification;
- (IBAction)btnClkLogin:(id)sender;
- (IBAction)btnClkCancel:(id)sender;

-(void)simpleLogin;
-(void)proximityBLELogin;
-(void)QRcodeLogin;
-(void)loginWithUserNamePassword:(NSString*)UserName passWord:(NSString*)PassWord;

@end

