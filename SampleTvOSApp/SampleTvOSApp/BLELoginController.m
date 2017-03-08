//
//  BLELoginController.m
//  SampleTvOSApp
//
//  Created by Akshay on 07/03/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import "BLELoginController.h"

@interface BLELoginController ()

@end

@implementation BLELoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)proximityBLELogin
{
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError * _Nullable error) {
        [MASDevice setProximityLoginDelegate:self];
        
        [[MASDevice currentDevice] startAsBluetoothCentral];
        
        // [[MASDevice currentDevice] startAsBluetoothCentralWithAuthenticationProvider:<#(MASAuthenticationProvider * _Nonnull)#>];
        
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
        //
    }
    
    
}
-(void) didReceiveProximityLoginError:(NSError *)error
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

@end
