//
//  MASProximityLoginQRCode+MASPrivate.m
//  MASFoundation
//
//  Created by Hun Go on 2016-06-03.
//  Copyright © 2016 CA Technologies. All rights reserved.
//

#import "MASProximityLoginQRCode+MASPrivate.h"

#import <objc/runtime.h>
#import "MASNetworkingService.h"
#import "NSError+MASPrivate.h"

# pragma mark - Property Constants

static NSString *const kMASProximityLoginQRCodeAuthenticationUrlKey = @"authenticationUrl"; // string
static NSString *const kMASProximityLoginQRCodePollUrlKey = @"pollUrl"; // string
static NSString *const kMASProximityLoginQRCodePollingDelayKey = @"pollingDelay"; // string
static NSString *const kMASProximityLoginQRCodePollingIntervalKey = @"pollingInterval"; // string
static NSString *const kMASProximityLoginQRCodePollingLimitKey = @"pollingLimit"; // string
static NSString *const kMASProximityLoginQRCodeCurrentPollingCounterKey = @"currentPollingCounter"; // string
static NSString *const kMASProximityLoginQRCodeIsPollingKey = @"isPolling"; // string

@implementation MASProximityLoginQRCode (MASPrivate)


# pragma mark - Lifecycle

- (instancetype)initPrivateWithAuthenticationUrl:(NSString *)authUrl pollingUrl:(NSString *)pollingUrl initialDelay:(NSNumber *)initDelay pollingInterval:(NSNumber *)pollingInterval pollingLimit:(NSNumber *)pollingLimit
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    self.authenticationUrl = authUrl;
    self.pollUrl = pollingUrl;
    self.pollingDelay = initDelay;
    self.pollingInterval = pollingInterval;
    self.pollingLimit = pollingLimit;
    
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
        
        self.isPolling = YES;
        
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
    self.isPolling = NO;
    
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
    self.currentPollingCounter++;
    
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


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)authenticationUrl
{
    return objc_getAssociatedObject(self, &kMASProximityLoginQRCodeAuthenticationUrlKey);
}


- (void)setAuthenticationUrl:(NSString *)authenticationUrl
{
    objc_setAssociatedObject(self, &kMASProximityLoginQRCodeAuthenticationUrlKey, authenticationUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)pollUrl
{
    return objc_getAssociatedObject(self, &kMASProximityLoginQRCodePollUrlKey);
}


- (void)setPollUrl:(NSString *)pollUrl
{
    objc_setAssociatedObject(self, &kMASProximityLoginQRCodePollUrlKey, pollUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSNumber *)pollingDelay
{
    return objc_getAssociatedObject(self, &kMASProximityLoginQRCodePollingDelayKey);
}


- (void)setPollingDelay:(NSNumber *)pollingDelay
{
    objc_setAssociatedObject(self, &kMASProximityLoginQRCodePollingDelayKey, pollingDelay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSNumber *)pollingInterval
{
    return objc_getAssociatedObject(self, &kMASProximityLoginQRCodePollingIntervalKey);
}


- (void)setPollingInterval:(NSNumber *)pollingInterval
{
    objc_setAssociatedObject(self, &kMASProximityLoginQRCodePollingIntervalKey, pollingInterval, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSNumber *)pollingLimit
{
    return objc_getAssociatedObject(self, &kMASProximityLoginQRCodePollingLimitKey);
}


- (void)setPollingLimit:(NSNumber *)pollingLimit
{
    objc_setAssociatedObject(self, &kMASProximityLoginQRCodePollingLimitKey, pollingLimit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (int)currentPollingCounter
{
    return [objc_getAssociatedObject(self, &kMASProximityLoginQRCodeCurrentPollingCounterKey) intValue];
}


- (void)setCurrentPollingCounter:(int)currentPollingCounter
{
    objc_setAssociatedObject(self, &kMASProximityLoginQRCodeCurrentPollingCounterKey, [NSNumber numberWithInt:currentPollingCounter], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)isPolling
{
    return [objc_getAssociatedObject(self, &kMASProximityLoginQRCodeIsPollingKey) boolValue];
}


- (void)setIsPolling:(BOOL)isPolling
{
    objc_setAssociatedObject(self, &kMASProximityLoginQRCodeIsPollingKey, [NSNumber numberWithBool:isPolling], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASProximityLoginQRCode *qrCode = [super copyWithZone:zone];
    
    qrCode.authenticationUrl = self.authenticationUrl;
    qrCode.pollUrl = self.pollUrl;
    qrCode.pollingDelay = self.pollingDelay;
    qrCode.pollingInterval = self.pollingInterval;
    qrCode.pollingLimit = self.pollingLimit;
    
    return qrCode;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder]; //ObjectID is encoded in the super class MASObject
    
    if (self.authenticationUrl) [aCoder encodeObject:self.authenticationUrl forKey:kMASProximityLoginQRCodeAuthenticationUrlKey];
    if (self.pollUrl) [aCoder encodeObject:self.pollUrl forKey:kMASProximityLoginQRCodePollUrlKey];
    if (self.pollingDelay) [aCoder encodeObject:self.pollingDelay forKey:kMASProximityLoginQRCodePollingDelayKey];
    if (self.pollingInterval) [aCoder encodeObject:self.pollingInterval forKey:kMASProximityLoginQRCodePollingIntervalKey];
    if (self.pollingLimit) [aCoder encodeObject:self.pollingLimit forKey:kMASProximityLoginQRCodePollingLimitKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) //ObjectID is decoded in the super class MASObject
    {
        self.authenticationUrl = [aDecoder decodeObjectForKey:kMASProximityLoginQRCodeAuthenticationUrlKey];
        self.pollUrl = [aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollUrlKey];
        self.pollingDelay = [aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollingDelayKey];
        self.pollingInterval = [aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollingIntervalKey];
        self.pollingLimit = [aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollingLimitKey];
    }
    
    return self;
}


@end
