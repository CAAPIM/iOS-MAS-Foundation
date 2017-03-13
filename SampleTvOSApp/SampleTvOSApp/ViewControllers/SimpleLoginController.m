//
//  SimpleLoginController
//  SampleTvOSApp
//
//  Created by Akshay on 16/02/17.
//  Copyright © 2017 CA. All rights reserved.
//


#import "SimpleLoginController.h"
#import "ViewControllerMovie.h"
#import <SVProgressHUDTVOS/SVProgressHUD.h>
@interface SimpleLoginController ()



@end

@implementation SimpleLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //proximity
       [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(masProximityLogin:)
                                                 name:@"MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification"
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthenticated:)
                                                 name:@"MASUserDidAuthenticateNotification"
                                               object:nil];
    //UserName/password
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAuthenticated:)
                                                 name:@"MASUserDidAuthenticateNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userFailToAuthenticate:)
                                                 name:@"MASUserDidFailToAuthenticateNotification"
                                               object:nil];
    
    
    
    
    
    //[self.txtFUserName becomeFirstResponder];
    
   
    
   
}


#pragma -Login methods

-(void)loginWithUserNamePassword:(NSString*)UserName passWord:(NSString*)PassWord
{
    [SVProgressHUD show];
    [MAS setGrantFlow:MASGrantFlowPassword];
    
    [MAS startWithDefaultConfiguration:YES
                            completion:^(BOOL completed, NSError * _Nullable error) {
                                
                                
                                [MASUser loginWithUserName:UserName password:PassWord completion:^(BOOL completed, NSError *error) {
                                    [SVProgressHUD dismiss];
                                    if(error)
                                    self.textView.text=error.description;
                                    else
                                    {
                                        
                                        ViewControllerMovie *movieVC = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"MovieViewController"];
                                        
                                        [self presentViewController:movieVC animated:YES completion:nil];
                                        
                                    }
                                    
                                }];
                            }];
    
    
    
    
    
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
   
    return YES;
}



- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    
    if (context.previouslyFocusedView != nil) {
        
        
    }
}


-(void)userFailToAuthenticate:(NSNotification*)notification
{
    if (notification) {
        //
    }
}

- (IBAction)btnClkLogin:(UIButton*)sender {
    
    
    
    
    [self loginWithUserNamePassword:self.txtFUserName.text passWord:self.txtFPassWord.text];
}

- (IBAction)btnClkCancel:(UIButton*)sender {
    //go to back screen
}

-(void)userAuthenticated:(NSNotification*)notification
{
    if (notification) {
        //
    }
}


-(void) simpleLogin
{

    [MAS setGrantFlow:MASGrantFlowPassword];
    
    
    
    [MAS setUserLoginBlock:
     ^(MASBasicCredentialsBlock  _Nonnull basicBlock, MASAuthorizationCodeCredentialsBlock  _Nonnull authorizationCodeBlock) {
         
         basicBlock(@"syed", @"dost1234", NO, nil );
         
     }];
    
    
    
    
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError * _Nullable error) {
        
        
        [[MASDevice currentDevice] deregisterWithCompletion:^(BOOL completed, NSError * _Nullable error){
            
            [[MASDevice currentDevice] resetLocally];
        
            [MAS getFrom:@"/protected/resource/products" withParameters:nil andHeaders:nil completion:^(NSDictionary<NSString *, id> * _Nullable responseInfo, NSError * _Nullable error) {
                NSLog(@"%@",error);
                self.textView.text=error.description;
                
                
            }];
        }];
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

#pragma -QR Code Login

-(void) QRcodeLogin
{
    
    
    
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError * _Nullable error) {
        //
        
        [MASAuthenticationProviders retrieveAuthenticationProvidersWithCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            MASAuthenticationProvider *qrCodeAuthProvider;
            
            for (MASAuthenticationProvider *qr in [object valueForKey:@"providers"]) {
                if ([qr.identifier  isEqualToString:@"qrcode"]) {
                    qrCodeAuthProvider = qr;
                    break;
                }
            }
            
              
              //[MASDevice setProximityLoginDelegate:self];
            
            self.qrCodeProximityLogin = [[MASProximityLoginQRCode alloc] initWithAuthenticationProvider:qrCodeAuthProvider];
            
            
            UIImage *qrCodeImage = [self.qrCodeProximityLogin startDisplayingQRCodeImageForProximityLogin];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imgView setImage:qrCodeImage];
                
                

            });
            NSLog(@"------%@", qrCodeImage);
        }];
    }];
    
    
    
}

#pragma-USing proximity Login delegate

- (void)handleBLEProximityLoginUserConsent:(MASCompletionErrorBlock)completion deviceName:(NSString *)deviceName
{
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    // Construct AlertController
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


-(void)didReceiveAuthorizationCode:(NSString *_Nonnull)authorizationCode
{
    
    self.textView.text=authorizationCode;
   //[self.qrCodeProximityLogin  stopDisplayingQRCodeImageForProximityLogin];
    
}
-(void) didReceiveProximityLoginError:(NSError *)error
{
    self.textView.text=error.description;
}


-(void)masProximityLogin:(NSNotification*)notification
{
    if (notification) {
        
       
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"MAS Proximity Login"
                                                                                 message:@"The session was shared successfully!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        // Construct Grant action
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Continue"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
                                 [self presentViewController:nil animated:YES completion:nil];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
