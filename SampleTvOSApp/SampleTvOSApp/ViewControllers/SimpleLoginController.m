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
bool bVar=TRUE;
@implementation SimpleLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //proximity
    
    
    //[self.txtFUserName becomeFirstResponder];
    
   
    
   
}


#pragma -Login methods

-(void)loginWithUserNamePassword:(NSString*)UserName passWord:(NSString*)PassWord
{
[SVProgressHUD show];
[MAS setGrantFlow:MASGrantFlowPassword];

[MAS startWithDefaultConfiguration:YES
                    completion:^(BOOL completed, NSError * _Nullable error)
{
                        
    if(completed)
    {
       
        [MASUser loginWithUserName:UserName password:PassWord completion:^(BOOL completed, NSError *error)
         {
             [SVProgressHUD dismiss];
             if(error)
                 self.textView.text=error.description;
             else 
             {
                 ///
                 NSString * str=[NSString stringWithFormat:@"%@, %@",[UserName  uppercaseString],@"Logged in Successfully"];
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TVOS APP"
                                                                                          message:str
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                 // Construct Grant action
                 UIAlertAction* ok = [UIAlertAction
                                      actionWithTitle:@"Ok"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * _Nonnull action) {
                                          ViewControllerMovie *movieVC = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"MovieViewController"];
                                          
                                          [self presentViewController:movieVC animated:YES completion:nil];
                                      }];
                    // Add grant action
                 
                 
                 
                 [alertController addAction:ok];
                 
                 
                 // Add deny action
                 //[alertController addAction:cancel];
                 // Present Alert
                 [self presentViewController:alertController animated:YES completion:nil];
                 
                 ///
                
                 
             }
             
         }];
    }
 }];






}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
//    [self.view endEditing:YES];
//    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
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
    if(textField.tag==2)
        
    {
//        [textField resignFirstResponder];
//        [self.btnLogin setNeedsFocusUpdate];
//        [self.btnLogin updateFocusIfNeeded];
         bVar=FALSE;
        
    }
    else
         bVar=TRUE;
    
    return YES;
}
-(UIView *)preferredFocusedView
{
    if(!bVar)

    return self.btnLogin;
    else
    return nil;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    
    if (context.previouslyFocusedView != nil) {
        
        
    }
}




- (IBAction)btnClkLogin:(UIButton*)sender {
    
    
    [self loginWithUserNamePassword:self.txtFUserName.text passWord:self.txtFPassWord.text];
}

- (IBAction)btnClkCancel:(UIButton*)sender {
    //go to back screen
    [self dismissViewControllerAnimated:self completion:nil];
}



//-(void) simpleLogin
//{
//
//    [MAS setGrantFlow:MASGrantFlowPassword];
//    
//    
//    
//    [MAS setUserLoginBlock:
//     ^(MASBasicCredentialsBlock  _Nonnull basicBlock, MASAuthorizationCodeCredentialsBlock  _Nonnull authorizationCodeBlock) {
//         
//         basicBlock(@"syed", @"dost1234", NO, nil );
//         
//     }];
//    
//    
//    
//    
//    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError * _Nullable error) {
//        
//        
//        [[MASDevice currentDevice] deregisterWithCompletion:^(BOOL completed, NSError * _Nullable error){
//            
//            [[MASDevice currentDevice] resetLocally];
//        
//            [MAS getFrom:@"/protected/resource/products" withParameters:nil andHeaders:nil completion:^(NSDictionary<NSString *, id> * _Nullable responseInfo, NSError * _Nullable error) {
//                NSLog(@"%@",error);
//                self.textView.text=error.description;
//                
//                
//            }];
//        }];
//    }];
//}














- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clkLogout:(id)sender {
     [SVProgressHUD dismiss];
     [self dismissViewControllerAnimated:YES completion:nil];
//    [[MASUser currentUser] logoutWithCompletion:^(BOOL completed, NSError *error)
//    {
//        if(!error)
//        {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }];
}
@end
