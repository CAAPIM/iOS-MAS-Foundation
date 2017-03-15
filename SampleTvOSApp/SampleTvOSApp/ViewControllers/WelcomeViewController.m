//
//  WelcomeViewController.m
//  SampleTvOSApp
//
//  Created by Akshay on 08/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SimpleLoginController.h"
#import "QRCodeLoginController.h"
#import "BLELoginController.h"
#import "FBLoginViewController.h"
@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clkUsernamePwd:(id)sender {
    
    SimpleLoginController *VC = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"SimpleLoginController"];
    
    [self presentViewController:VC animated:YES completion:nil];
}
- (IBAction)clkQRcode:(id)sender {
    
    QRCodeLoginController *VC = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeLoginController"];
    
    [self presentViewController:VC animated:YES completion:nil];
}
- (IBAction)clkBLE:(id)sender {
    BLELoginController *VC = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"BLELoginController"];
    [self presentViewController:VC animated:YES completion:nil];
}
- (IBAction)clkFacebook:(id)sender {
    
    FBLoginViewController *VC=[[FBLoginViewController alloc]init];
    [self presentViewController:VC animated:YES completion:nil];
    
}
@end
