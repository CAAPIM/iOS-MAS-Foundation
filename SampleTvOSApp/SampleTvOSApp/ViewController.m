//
//  ViewController.m
//  SampleTvOSApp
//
//  Created by Akshay on 16/02/17.
//  Copyright © 2017 CA. All rights reserved.
//

#import "ViewController.h"
#import <tvOS_MASFoundation/tvOS MASFoundation.h>

@interface ViewController ()
-(void)simpleLogin;
-(void)proximityBLELogin;
-(void)QRcodeLogin;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    [self QRcodeLogin];
   
}

#pragma -Login methods

-(void) simpleLogin
{

    [MAS setGrantFlow:MASGrantFlowPassword];
    
    
    
    [MAS setUserLoginBlock:
     ^(MASBasicCredentialsBlock  _Nonnull basicBlock, MASAuthorizationCodeCredentialsBlock  _Nonnull authorizationCodeBlock) {
         
         basicBlock(@"syed", @"dost1234", NO, nil );
         
     }];
    
    
    
    
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError * _Nullable error) {
        
        
//        [[MASDevice currentDevice] deregisterWithCompletion:^(BOOL completed, NSError * _Nullable error){
//            
//            [[MASDevice currentDevice] resetLocally];
        
            [MAS getFrom:@"/protected/resource/products" withParameters:nil andHeaders:nil completion:^(NSDictionary<NSString *, id> * _Nullable responseInfo, NSError * _Nullable error) {
                NSLog(@"%@",error);
                self.textView.text=error.description;
                
                
            }];
       // }];
    }];
}


#pragma -BLE Login
-(void)proximityBLELogin
{
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError * _Nullable error) {
        [MASDevice setProximityLoginDelegate:self];
        
        [[MASDevice currentDevice] startAsBluetoothCentral];
        
       // [[MASDevice currentDevice] startAsBluetoothCentralWithAuthenticationProvider:<#(MASAuthenticationProvider * _Nonnull)#>];
        
    }];
    
   
    
    
}



#pragma-USing proximity Login delegate

- (void)handleBLEProximityLoginUserConsent:(MASCompletionErrorBlock)completion deviceName:(NSString *)deviceName
{
//    __block MASCompletionErrorBlock blockCompletion = completion;
//    
//    // Construct AlertController
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"BLE Proximity Login"
//                                                                             message:[NSString stringWithFormat:@"Grant a permission to share your session with %@?", deviceName]
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    // Construct Grant action
//    UIAlertAction *grantAction = [UIAlertAction actionWithTitle:@"Grant"
//                                                          style:UIAlertActionStyleDefault
//                                                        handler:^(UIAlertAction * _Nonnull action) {
//                                                            
//                                                            blockCompletion(YES, nil);
//                                                        }];
//    // Construct Deny action
//    UIAlertAction *denyAction = [UIAlertAction actionWithTitle:@"Deny"
//                                                         style:UIAlertActionStyleDestructive
//                                                       handler:^(UIAlertAction * _Nonnull action) {
//                                                           
//                                                           blockCompletion(NO, nil);
//                                                       }];
//    // Add grant action
//    [alertController addAction:grantAction];
//    // Add deny action
//    [alertController addAction:denyAction];
//    // Present Alert
//    [self presentViewController:alertController animated:YES completion:nil];
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

- (void)startAsBluetoothCentralWithAuthenticationProvider:(MASAuthenticationProvider *)provider
{
    
    
    
    
}


- (void)didReceiveAuthorizationCode:(NSString *_Nonnull)authorizationCode
{
    
    self.textView.text=authorizationCode;
    
}
-(void) didReceiveProximityLoginError:(NSError *)error
{
    self.textView.text=error.description;
}


#pragma -QR Code Login

-(void) QRcodeLogin
{
    
    //+ (void)retrieveAuthenticationProvidersWithCompletion:(MASObjectResponseErrorBlock _Nullable)completion;


    //MASAuthenticationProvider *qrCodeAuthProvider = [[MASAuthenticationProviders currentProviders] retrieveAuthenticationProviderForProximityLogin];
    
    [MAS start:^(BOOL completed, NSError * _Nullable error) {
        //
        
        [MASAuthenticationProviders retrieveAuthenticationProvidersWithCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            MASAuthenticationProvider *qrCodeAuthProvider;
            
            for (MASAuthenticationProvider *qr in [object valueForKey:@"providers"]) {
                if ([qr.identifier  isEqualToString:@"qrcode"]) {
                    qrCodeAuthProvider = qr;
                    break;
                }
            }
            MASProximityLoginQRCode *qrCodeProximityLogin = [[MASProximityLoginQRCode alloc] initWithAuthenticationProvider:qrCodeAuthProvider];
            
            UIImage *qrCodeImage = [qrCodeProximityLogin startDisplayingQRCodeImageForProximityLogin];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imgView setImage:qrCodeImage];
            });
            NSLog(@"------%@", qrCodeImage);
        }];
    }];
    
    
   
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
