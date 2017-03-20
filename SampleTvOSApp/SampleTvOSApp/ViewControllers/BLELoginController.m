//
//  BLELoginController.m
//  SampleTvOSApp
//
//  Created by Akshay on 07/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import "BLELoginController.h"
#import "ViewControllerMovie.h"

@interface BLELoginController ()

@end

@implementation BLELoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAuthorizationCode:) name:MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification  object:nil];
   [[MASDevice currentDevice] startAsBluetoothCentral];
    [self proximityBLELogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)proximityBLELogin
{
    
    [SVProgressHUD show];
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError * _Nullable error) {
        //
        
        [MASAuthenticationProviders retrieveAuthenticationProvidersWithCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            MASAuthenticationProvider *AuthProvider;
            
            for (MASAuthenticationProvider *qr in [object valueForKey:@"providers"]) {
                if ([qr.identifier  isEqualToString:@"qrcode"]) {
                    AuthProvider = qr;
                    break;
                }
            }
            
            [[MASDevice currentDevice]startAsBluetoothCentralWithAuthenticationProvider:AuthProvider];
            
            
        }];
    }];
    
    
    
    
    
}
- (void)didReceiveBLEProximityLoginStateUpdate:(MASBLEServiceState)state
{
    
    switch (state) {
            
        case  MASBLEServiceStateUnknown:
            break;
        case   MASBLEServiceStateCentralStarted:
            break;
        case  MASBLEServiceStateCentralStopped:
            break;
            
        case MASBLEServiceStateCentralDeviceDetected:
            break;
        case  MASBLEServiceStateCentralDeviceConnected:
            break;
        case  MASBLEServiceStateCentralDeviceDisconnected:
            break;
        case  MASBLEServiceStateCentralServiceDiscovered:
            break;
        case  MASBLEServiceStateCentralCharacteristicDiscovered:
            break;
        case  MASBLEServiceStateCentralCharacteristicWritten:
            break;
        case  MASBLEServiceStateCentralAuthorizationSucceeded:
            break;
        case MASBLEServiceStateCentralAuthorizationFailed:
            break;
        case   MASBLEServiceStatePeripheralSubscribed:
            break;
        case    MASBLEServiceStatePeripheralUnsubscribed:
            break;
        case    MASBLEServiceStatePeripheralStarted:
            break;
        case    MASBLEServiceStatePeripheralStopped:
            break;
        case    MASBLEServiceStatePeripheralSessionAuthorized:
            break;
        case  MASBLEServiceStatePeripheralSessionNotified:
            break;
        default:
            break;
    }
    
    
}


-(void)didReceiveAuthorizationCode:(NSString *_Nonnull)authorizationCode
{
    
    if(authorizationCode)
    {
        [SVProgressHUD dismiss];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"MAS Proximity Login"
                                                                                 message:@"The session was shared successfully!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        // Construct Grant action
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Continue"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
                                 
                                 ViewControllerMovie *movieVC = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"MovieViewController"];
                                 
                                 [self presentViewController:movieVC animated:YES completion:nil];
                                 
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:nil];       // Add grant action
        
        
        
        [alertController addAction:ok];
        
        
        // Add deny action
        [alertController addAction:cancel];
        // Present Alert
        [self presentViewController:alertController animated:YES completion:nil];
        
        //
    }
    
    
}
-(void) didReceiveProximityLoginError:(NSError *)error
{
    [SVProgressHUD dismiss];
}
- (void)handleBLEProximityLoginUserConsent:(MASCompletionErrorBlock)completion deviceName:(NSString *)deviceName
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clkLogout:(id)sender {
    
   // [self.qrCodeProximityLogin stopDisplayingQRCodeImageForProximityLogin];
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
