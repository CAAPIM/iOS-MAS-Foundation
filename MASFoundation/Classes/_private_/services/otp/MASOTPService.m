//
//  MASOTPService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASOTPService.h"

#import "MASServiceRegistry.h"
#import "NSError+MASPrivate.h"


@interface MASOTPService ()

@property (nonatomic, strong, readwrite) NSArray *currentChannels;

@end


@implementation MASOTPService


static MASOTPChannelSelectionBlock _OTPChannelSelectionBlock_ = nil;
static MASOTPCredentialsBlock _OTPCredentialsBlock_ = nil;


# pragma mark - Properties

+ (void)setOTPChannelSelectionBlock:(MASOTPChannelSelectionBlock)OTPChannelSelector
{
    _OTPChannelSelectionBlock_ = [OTPChannelSelector copy];
}


+ (void)setOTPCredentialsBlock:(MASOTPCredentialsBlock)oneTimePassword
{
    _OTPCredentialsBlock_ = [oneTimePassword copy];
}


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASOTPService alloc] initProtected];
                  });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (NSString *)serviceUUID
{
    return MASOTPServiceUUID;
}


- (void)serviceDidLoad
{
    
    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    
    [super serviceWillStart];
}


- (void)serviceDidReset
{
    
    [super serviceDidReset];
}


# pragma mark - Private

- (void)validateOTPSessionWithResponseHeaders:(NSDictionary *)responseHeaderInfo
                              completionBlock:(MASResponseInfoErrorBlock)completion
{
    //
    // If UI handling framework is not present and handling it continue on with notifying the
    // application it needs to handle this itself
    //
    __block MASOTPService *blockSelf = self;
    __block MASOTPGenerationBlock otpGenerationBlock;
    __block MASOTPFetchCredentialsBlock otpCredentialsBlock;
    
    //
    // OTP Credentials Block
    //
    otpCredentialsBlock = ^(NSString *oneTimePassword, BOOL cancel, MASCompletionErrorBlock otpFetchcompletion)
    {
//        DLog(@"\n\nOTP credentials block called with oneTimePassword: %@ and cancel: %@\n\n",
//             oneTimePassword, (cancel ? @"Yes" : @"No"));
        
        //
        // Cancelled stop here
        //
        if(cancel)
        {
            //
            // Notify UI
            //
            if (otpFetchcompletion)
            {
                otpFetchcompletion(NO, [NSError errorOTPAuthenticationCancelled]);
            }
            
            //
            // Notify
            //
            if(completion)
            {
                completion(nil, [NSError errorOTPAuthenticationCancelled]);
            }
            
            blockSelf.currentChannels = nil;
            
            return;
        }
        
        //
        // Notify UI
        //
        if (otpFetchcompletion)
        {
            otpFetchcompletion(YES, nil);
        }
        
        //
        // Notify
        //
        if(completion)
        {
            NSDictionary *responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          blockSelf.currentChannels, MASHeaderOTPChannelKey,
                                          oneTimePassword, MASHeaderOTPKey, nil];
            completion(responseInfo, nil);
        }
    };
    
    //
    // OTP Generation Block
    //
    otpGenerationBlock = ^(NSArray *otpChannels, BOOL cancel, MASCompletionErrorBlock otpGenerationcompletion)
    {
//        DLog(@"\n\nOTP generation block called with otpChannels: %@ and cancel: %@\n\n",
//             otpChannels, (cancel ? @"Yes" : @"No"));
        
        //
        // Reset the otpChannels
        //
        blockSelf.currentChannels = otpChannels;
        
        //
        // Cancelled stop here
        //
        if(cancel)
        {
            //
            // Notify UI
            //
            if (otpGenerationcompletion)
            {
                otpGenerationcompletion(NO, [NSError errorOTPChannelSelectionCancelled]);
            }
            
            //
            // Notify
            //
            if(completion)
            {
                completion(nil, [NSError errorOTPChannelSelectionCancelled]);
            }
            
            blockSelf.currentChannels = nil;
            
            return;
        }
        
        //
        // Notify UI
        //
        if (otpGenerationcompletion)
        {
            otpGenerationcompletion(YES, nil);
        }
        
        //
        // Endpoint
        //
        NSString *endPoint =
        [MASConfiguration currentConfiguration].authenticateOTPEndpointPath;
        
        //
        // Headers
        //
        MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
        NSString *otpSelectedChannelsStr = [blockSelf.currentChannels componentsJoinedByString:@","];
        [headerInfo setObject:otpSelectedChannelsStr forKey:MASHeaderOTPChannelKey];
        
        //
        // Parameters
        //
        MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
        
        //
        // Trigger the OTP generate request
        //        
        [[MASNetworkingService sharedService] getFrom:endPoint
            withParameters:parameterInfo
            andHeaders:headerInfo
            requestType:MASRequestResponseTypeJson
            responseType:MASRequestResponseTypeJson
            completion:^(NSDictionary *responseInfo, NSError *error)
            {
                //
                // Detect if error, if so stop here
                //
                if(error)
                {
                    //
                    // Notify
                    //
                    if(completion)
                    {
                        completion(responseInfo, error);
                    }
                    
                    return;
                }
                
                MASIMutableOrderedDictionary *responseHeaderInfo =
                [responseInfo objectForKey:MASResponseInfoHeaderInfoKey];
             
                //
                // Check if OTP got generated.
                //
                NSString *otpStatus = nil;
                if ([[responseHeaderInfo allKeys] containsObject:MASHeaderOTPKey])
                {
                    otpStatus = [NSString stringWithFormat:@"%@", [responseHeaderInfo objectForKey:MASHeaderOTPKey]];
                }
             
                //
                // otpStatus = generated
                //
                if ([otpStatus isEqualToString:MASOTPResponseOTPStatusKey])
                {
//                    DLog(@"\n\n\n********************************************************\n\n"
//                         "Waiting for one time password to continue request"
//                         @"\n\n********************************************************\n\n\n");
//                 
                    //
                    // otpError to provide details of the OTP flow handle
                    //
                    NSError *otpError = [NSError errorOTPCredentialsNotProvided];
                 
                    //
                    // If the UI handling framework is present and will handle this stop here
                    //
                    MASServiceRegistry *serviceRegistry = [MASServiceRegistry sharedRegistry];
                    if([serviceRegistry uiServiceWillHandleOTPAuthentication:otpCredentialsBlock error:otpError])
                    {
                        return;
                    }
                 
                    //
                    // Else notify block if available
                    //
                    if(_OTPCredentialsBlock_)
                    {
                        //
                        // Do this is the main queue since the reciever is almost certainly a UI component.
                        // Lets do this for them and not make them figure it out
                        //
                        dispatch_async(dispatch_get_main_queue(),^
                        {
                            _OTPCredentialsBlock_(otpCredentialsBlock, otpError);
                        });
                    }
                    else {
                     
                        //
                        // If the device registration block is not defined, return an error
                        //
                        if (completion)
                        {
                            completion(nil, [NSError errorInvalidOTPCredentialsBlock]);
                        }
                    }
                }
            }];
    };
    
    //
    // Check if MAG error code exists
    //
    NSString *magErrorCode = nil;
    if ([[responseHeaderInfo allKeys] containsObject:MASHeaderErrorKey])
    {
        magErrorCode = [NSString stringWithFormat:@"%@", [responseHeaderInfo objectForKey:MASHeaderErrorKey]];
    }
    
    //
    // OTP Required.
    // Generate OTP with user selected OTP channels and send OTP to continue original request.
    //
    if ([magErrorCode hasSuffix:MASApiErrorCodeOTPNotProvidedSuffix])
    {
//        DLog(@"\n\n\n********************************************************\n\n"
//             "Waiting for channel selection to continue otp generation"
//             @"\n\n********************************************************\n\n\n");
//        
        //
        // Supported channels
        //
        NSArray *supportedChannels =
        [responseHeaderInfo [MASHeaderOTPChannelKey] componentsSeparatedByString:@","];
        
        //
        // If the UI handling framework is present and will handle this stop here
        //
        MASServiceRegistry *serviceRegistry = [MASServiceRegistry sharedRegistry];
        if([serviceRegistry uiServiceWillHandleOTPChannelSelection:supportedChannels otpGenerationBlock:otpGenerationBlock])
        {
            return;
        }
        
        //
        // Else notify block if available
        //
        if(_OTPChannelSelectionBlock_)
        {
            //
            // Do this is the main queue since the reciever is almost certainly a UI component.
            // Lets do this for them and not make them figure it out
            //
            dispatch_async(dispatch_get_main_queue(),^
            {
                _OTPChannelSelectionBlock_(supportedChannels, otpGenerationBlock);
            });
        }
        else {
            
            //
            // If the device registration block is not defined, return an error
            //
            if (completion)
            {
                completion(nil, [NSError errorInvalidOTPChannelSelectionBlock]);
            }
        }
    }
    //
    // Invalid OTP.
    // Prompt for OTP generated and send OTP to continue original request.
    //
    else if ([magErrorCode hasSuffix:MASApiErrorCodeInvalidOTPProvidedSuffix]) {
       
//        DLog(@"\n\n\n********************************************************\n\n"
//             "Waiting for one time password to continue request"
//             @"\n\n********************************************************\n\n\n");
        
        //
        // otpError to provide details of the OTP flow handle
        //
        NSError *otpError = [NSError errorInvalidOTPCredentials];
        
        //
        // If the UI handling framework is present and will handle this stop here
        //
        MASServiceRegistry *serviceRegistry = [MASServiceRegistry sharedRegistry];
        if([serviceRegistry uiServiceWillHandleOTPAuthentication:otpCredentialsBlock error:otpError])
        {
            return;
        }
        
        //
        // Else notify block if available
        //
        if(_OTPCredentialsBlock_)
        {
            //
            // Do this is the main queue since the reciever is almost certainly a UI component.
            // Lets do this for them and not make them figure it out
            //
            dispatch_async(dispatch_get_main_queue(),^
            {
                _OTPCredentialsBlock_(otpCredentialsBlock, otpError);
            });
        }
        else {
            
            //
            // If the device registration block is not defined, return an error
            //
            if (completion)
            {
                completion(nil, [NSError errorInvalidOTPCredentialsBlock]);
            }
        }
    }
    //
    // OTP Provided Expired
    //
    else if ([magErrorCode hasSuffix:MASApiErrorCodeOTPExpiredSuffix]) {
        
        //
        // Notify
        //
        if(completion)
        {
            completion(nil, [NSError errorOTPCredentialsExpired]);
        }
        
        return;
    }
    //
    // OTP Retry Limit Exceeded / Retry Suspended.
    //
    else if ([magErrorCode hasSuffix:MASApiErrorCodeOTPRetryLimitExceededSuffix] ||
             [magErrorCode hasSuffix:MASApiErrorCodeOTPRetryBarredSuffix]) {
        
        //
        // Suspension time
        //
        NSString *suspensionTime = responseHeaderInfo [MASHeaderOTPRetryIntervalKey];
        
        NSError *error = nil;
        [magErrorCode hasSuffix:MASApiErrorCodeOTPRetryLimitExceededSuffix] ?
            (error = [NSError errorOTPRetryLimitExceeded:suspensionTime]) :
            (error = [NSError errorOTPRetryBarred:suspensionTime]);
        
        //
        // Notify
        //
        if(completion)
        {
            completion(nil, error);
        }
        
        return;
    }
    else {
        
        //
        // Notify
        //
        if(completion)
        {
            completion(nil, nil);
        }
        
        return;
    }
}


# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@",
            [super debugDescription]];
}

@end
