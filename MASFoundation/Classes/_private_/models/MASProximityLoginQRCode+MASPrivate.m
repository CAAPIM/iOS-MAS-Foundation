//
//  MASProximityLoginQRCode+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASProximityLoginQRCode+MASPrivate.h"

#import <objc/runtime.h>
#import "MASAccessService.h"
#import "MASNetworkingService.h"
#import "NSError+MASPrivate.h"

@implementation MASProximityLoginQRCode (MASPrivate)


# pragma mark - Lifecycle

- (instancetype)initPrivateWithAuthenticationUrl:(NSString *)authUrl pollingUrl:(NSString *)pollingUrl initialDelay:(NSNumber *)initDelay pollingInterval:(NSNumber *)pollingInterval pollingLimit:(NSNumber *)pollingLimit
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    [self setValue:authUrl forKey:@"authenticationUrl"];
    [self setValue:pollingUrl forKey:@"pollUrl"];
    [self setValue:initDelay forKey:@"pollingDelay"];
    [self setValue:pollingInterval forKey:@"pollingInterval"];
    [self setValue:pollingLimit forKey:@"pollingLimit"];

    return self;
}


# pragma mark - Start/Stop displaying QR Code image : Private

- (UIImage *)startPrivateDisplayingQRCodeImageForProximityLogin
{
    // Convert NSString to NSData
    NSData *stringData = [self.authenticationUrl dataUsingEncoding:NSUTF8StringEncoding];
    
    UIImage *qrCodeImage = nil;
    
    @try {
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
        
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrFilter.outputImage fromRect:qrFilter.outputImage.extent];
        
        UIGraphicsBeginImageContext(CGSizeMake(qrFilter.outputImage.extent.size.width * [[UIScreen mainScreen] scale], qrFilter.outputImage.extent.size.width * [[UIScreen mainScreen] scale]));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        // Get the image out
        qrCodeImage = UIGraphicsGetImageFromCurrentImageContext();
        // Tidy up
        UIGraphicsEndImageContext();
        CGImageRelease(cgImage);
        
        [self setValue:[NSNumber numberWithBool:YES] forKey:@"isPolling"];
        
        //
        // Start polling
        //
        dispatch_time_t pollTimer = dispatch_time(DISPATCH_TIME_NOW, [self.pollingDelay intValue] * NSEC_PER_SEC);
        dispatch_after(pollTimer, dispatch_get_main_queue(), ^{
            
            //
            // Call polling method
            //
            [self makePollingRequest];
            
            //
            // Send notification
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MASProximityLoginQRCodeDidStartDisplayingQRCodeImage object:nil userInfo:nil];
            });
        });
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    
    return qrCodeImage;
}


- (void)stopPrivateDisplayingQRCodeImageForProximityLogin
{
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isPolling"];
    
    //
    // Send notification that polling stopped
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MASProximityLoginQRCodeDidStopDisplayingQRCodeImage object:nil userInfo:nil];
    });
}


# pragma mark - Private

- (void)makePollingRequest
{
    
    //
    // If stop request was made
    //
    if (!self.isPolling)
    {
        return;
    }
    
    //
    // If authenticationUrl is being used with other session sharing (BLE), ignore it
    //
    if ([MASDevice currentDevice].isBeingAuthorized)
    {
        return;
    }
    
    //
    // Increment the polling counter
    //
    [self setValue:[NSNumber numberWithInt:self.currentPollingCounter+1] forKey:@"currentPollingCounter"];
    
    NSString *pollPath = [self.pollUrl stringByReplacingOccurrencesOfString:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString withString:@""];
    
    __block MASProximityLoginQRCode *blockSelf = self;
    
    //
    // Instead of making a request through [MAS getFrom:..] public interface, call directly the networking service to bypass validation process
    //
    [[MASNetworkingService sharedService] getFrom:pollPath
                                   withParameters:nil
                                       andHeaders:nil
                                      requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                     responseType:MASRequestResponseTypeJson
                                       completion:^(NSDictionary *responseInfo, NSError *error) {
                                           
                                           if (error)
                                           {
                                               NSError * pollError = [NSError errorForFoundationCode:MASFoundationErrorCodeQRCodeProximityLoginAuthorizationPollingFailed info:error.userInfo errorDomain:MASFoundationErrorDomain];
                                               //
                                               // Stop polling and displaying the QR Code image
                                               //
                                               [blockSelf stopPrivateDisplayingQRCodeImageForProximityLogin];
                                               
                                               //
                                               // If MASDevice's BLE delegate is set, and method is implemented, notify the delegate
                                               //
                                               if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(didReceiveProximityLoginError:)])
                                               {
                                                   [[MASDevice proximityLoginDelegate] didReceiveProximityLoginError:pollError];
                                               }
                                               
                                               //
                                               // Send the notification with authorization code
                                               //
                                               [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidReceiveErrorFromProximityLoginNotification object:pollError];
                                           }
                                           else {
                                               
                                               //
                                               // Validate PKCE state value
                                               // If either one of request or response states is present, validate it; otherwise, ignore
                                               //
                                               if ([responseInfo objectForKey:MASPKCEStateRequestResponseKey] || [[MASAccessService sharedService].currentAccessObj retrievePKCEState])
                                               {
                                                   NSString *responseState = [responseInfo objectForKey:MASPKCEStateRequestResponseKey];
                                                   NSString *requestState = [[MASAccessService sharedService].currentAccessObj retrievePKCEState];
                                                   
                                                   NSError *pkceError = nil;
                                                   
                                                   //
                                                   // If response or request state is nil, invalid request and/or response
                                                   //
                                                   if (responseState == nil || requestState == nil)
                                                   {
                                                       pkceError = [NSError errorInvalidAuthorization];
                                                   }
                                                   //
                                                   // verify that the state in the response is the same as the state sent in the request
                                                   //
                                                   else if (![[responseInfo objectForKey:MASPKCEStateRequestResponseKey] isEqualToString:[[MASAccessService sharedService].currentAccessObj retrievePKCEState]])
                                                   {
                                                       pkceError = [NSError errorInvalidAuthorization];
                                                   }
                                                   
                                                   //
                                                   // If the validation fail, notify
                                                   //
                                                   if (pkceError)
                                                   {
                                                       //
                                                       // Stop polling and displaying the QR Code image
                                                       //
                                                       [blockSelf stopPrivateDisplayingQRCodeImageForProximityLogin];
                                                       
                                                       //
                                                       // If MASDevice's BLE delegate is set, and method is implemented, notify the delegate
                                                       //
                                                       if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(didReceiveProximityLoginError:)])
                                                       {
                                                           [[MASDevice proximityLoginDelegate] didReceiveProximityLoginError:pkceError];
                                                       }
                                                       
                                                       //
                                                       // Send the notification with authorization code
                                                       //
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidReceiveErrorFromProximityLoginNotification object:pkceError];
                                                       
                                                       return;
                                                   }
                                               }
                                               
                                               //
                                               // Retrieve authorization code
                                               //
                                               NSString *code = [responseInfo[MASResponseInfoBodyInfoKey] valueForKey:@"code"];
                                               
                                               if (code == nil || [code length] == 0)
                                               {
                                                   
                                                   //
                                                   // re trigger polling if no authorization code is found; if the counter did not exceed the limit
                                                   //
                                                   
                                                   if (blockSelf.currentPollingCounter < [blockSelf.pollingLimit intValue])
                                                   {
                                                       dispatch_time_t pollTimer = dispatch_time(DISPATCH_TIME_NOW, [self.pollingDelay intValue] * NSEC_PER_SEC);
                                                       dispatch_after(pollTimer, dispatch_get_main_queue(), ^{
                                                           
                                                           [blockSelf makePollingRequest];
                                                       });
                                                   }
                                               }
                                               else {
                                                   
                                                   //
                                                   // If the delegate is set, send the authorization code to delegation method
                                                   //
                                                   if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(didReceiveAuthorizationCode:)])
                                                   {
                                                       [[MASDevice proximityLoginDelegate] didReceiveAuthorizationCode:code];
                                                   }
                                                   
                                                   //
                                                   // Send the notification with authoriation code
                                                   //
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification object:@{@"code" : code}];
                                                   
                                               }
                                               
                                               //
                                               // If the current polling count exceeds pollLimit
                                               //
                                               if (blockSelf.currentPollingCounter >= [blockSelf.pollingLimit intValue])
                                               {
                                                   //
                                                   // Stop polling and displaying the QR Code image
                                                   //
                                                   [blockSelf stopPrivateDisplayingQRCodeImageForProximityLogin];
                                               }
                                           }
                                       }];
}

@end
