//
//  FBLoginViewController.m
//  SampleTvOSApp
//
//  Created by Akshay on 13/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import "FBLoginViewController.h"
#import "ViewControllerMovie.h"
@interface FBLoginViewController ()<FBSDKDeviceLoginButtonDelegate>
- (UIViewController*) topMostController ;
@end

@implementation FBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FBSDKDeviceLoginButton *button = [[FBSDKDeviceLoginButton alloc] initWithFrame:CGRectZero];
    button.readPermissions = @[@"email"]; //optional.
    button.center = self.view.center;
    [self.view addSubview:button];
    button.delegate=self;

}


- (void)deviceLoginButtonDidCancel:(FBSDKDeviceLoginButton *)button
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)deviceLoginButtonDidLogIn:(FBSDKDeviceLoginButton *)button
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ViewControllerMovie *movieVC = [storyboard instantiateViewControllerWithIdentifier:@"MovieViewController"];
    [self presentViewController:movieVC animated:YES completion:nil];
    
}

- (void)deviceLoginButtonDidLogOut:(FBSDKDeviceLoginButton *)button
{
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)deviceLoginButtonDidFail:(FBSDKDeviceLoginButton *)button error:(NSError *)error{
    
}

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
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

@end
