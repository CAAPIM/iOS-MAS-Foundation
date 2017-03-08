//
//  QRCodeLoginController.h
//  SampleTvOSApp
//
//  Created by Akshay on 07/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <tvOS_MASFoundation/tvOS MASFoundation.h>
@interface QRCodeLoginController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) MASProximityLoginQRCode *qrCodeProximityLogin;
-(void)masProximityLogin:(NSNotification*)notification;
-(void)userAuthenticated:(NSNotification*)notification;

-(void)QRcodeLogin;

@end
