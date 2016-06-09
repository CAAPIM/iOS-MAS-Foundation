//
//  MASOTPService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASOTPService.h"

#import "MASServiceRegistry.h"
#import "NSError+MASPrivate.h"


@interface MASOTPService ()


# pragma mark - Properties

/**
 *  Blocked original request details - originalEndPoint, originalParameterInfo, 
 *  originalHeaderInfo, originalHTTPMethod, originalRequestResponseContentType
 */
@property (strong, nonatomic, readwrite) NSMutableDictionary *originalRequestInfo;


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

- (void)validateOTPSessionWithEndPoint:(NSString *)endPoint
                            parameters:(NSDictionary *)originalParameterInfo
                               headers:(NSDictionary *)originalHeaderInfo
                            httpMethod:(NSString *)httpMethod
                           requestType:(MASRequestResponseType)requestType
                          responseType:(MASRequestResponseType)responseType
                       responseHeaders:(NSDictionary *)responseHeaderInfo
                       completionBlock:(MASResponseInfoErrorBlock)completion
{
    
    NSString *otpStatus = nil;
    NSString *magErrorCode = nil;
    
    //
    // Check if OTP got generated.
    //
    if ([[responseHeaderInfo allKeys] containsObject:MASHeaderOTPKey])
    {
        otpStatus = [NSString stringWithFormat:@"%@", [responseHeaderInfo objectForKey:MASHeaderOTPKey]];
    }
    
    //
    // Check if MAG error code exists
    //
    if ([[responseHeaderInfo allKeys] containsObject:MASHeaderErrorKey])
    {
        magErrorCode = [NSString stringWithFormat:@"%@", [responseHeaderInfo objectForKey:MASHeaderErrorKey]];
    }
    
    __block NSMutableDictionary *newRequestInfo = [NSMutableDictionary new];
    
    if ((magErrorCode && [magErrorCode hasPrefix:MASApiErrorCodeOTPPrefix]) ||
        (otpStatus && [otpStatus isEqualToString:MASOTPResponseOTPStatusKey]))
    {
        //
        // OTP Required - Save original request.
        // Generate OTP with user selected OTP channels.
        //
        if ([magErrorCode hasSuffix:MASApiErrorCodeOTPNotProvidedSuffix])
        {
            //
            // If UI handling framework is not present and handling it continue on with notifying the
            // application it needs to handle this itself
            //
            
            __block MASOTPGenerationBlock otpGenerationBlock;
            
            otpGenerationBlock = ^(NSArray *otpChannels, BOOL cancel, MASCompletionErrorBlock otpGenerationcompletion)
            {
                DLog(@"\n\nOTP generation block called with otpChannels: %@ and cancel: %@\n\n",
                     otpChannels, (cancel ? @"Yes" : @"No"));
                
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
                        otpGenerationcompletion(NO, nil);
                    }
                    
                    //
                    // Notify
                    //
                    if(completion)
                    {
                        completion(nil, nil);
                    }
                    
                    return;
                }
                
                //
                // Endpoint
                //
                NSString *endPoint =
                    [MASConfiguration currentConfiguration].authenticateOTPEndpointPath;
                
                //
                // Selected channels
                //
                NSMutableDictionary *headerInfo = [NSMutableDictionary new];
                NSString *otpChannelsStr = [otpChannels componentsJoinedByString:@","];
                [headerInfo setObject:otpChannelsStr forKey:MASHeaderOTPChannelKey];
                
                //
                // OTP generate request
                //
                newRequestInfo =
                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 endPoint, MASOTPRequestEndpointKey,
                 [NSDictionary dictionary], MASOTPRequestParameterInfoKey,
                 headerInfo, MASOTPRequestHeaderInfoKey,
                 @"GET", MASOTPRequestHTTPMethodKey,
                 MASRequestResponseTypeJson, MASOTPRequestTypeKey,
                 MASRequestResponseTypeJson, MASOTPResponseTypeKey, nil];

                //
                // Notify UI
                //
                if (otpGenerationcompletion)
                {
                    otpGenerationcompletion(YES, nil);
                }
                
                //
                // Notify
                //
                if(completion)
                {
                    completion(newRequestInfo, nil);
                }
            };
            
            //
            // Save the original request
            //
            self.originalRequestInfo =
                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    endPoint, MASOTPRequestEndpointKey,
                    originalParameterInfo, MASOTPRequestParameterInfoKey,
                    originalHeaderInfo, MASOTPRequestHeaderInfoKey,
                    httpMethod, MASOTPRequestHTTPMethodKey,
                    requestType, MASOTPRequestTypeKey,
                    responseType, MASOTPResponseTypeKey, nil];
         
            DLog(@"\n\n\n********************************************************\n\n"
                 "Waiting for channel selection to continue otp generation"
                 @"\n\n********************************************************\n\n\n");
            
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
        // OTP Generated / Invalid OTP
        // Prompt for OTP generated and use OTP with saved original request.
        //
        else if ([magErrorCode hasSuffix:MASApiErrorCodeInvalidOTPProvidedSuffix] ||
                 [otpStatus isEqualToString:MASOTPResponseOTPStatusKey]) {
                    
            //
            // If UI handling framework is not present and handling it continue on with notifying the
            // application it needs to handle this itself
            //
            __block MASOTPFetchCredentialsBlock otpCredentialsBlock;
            
            otpCredentialsBlock = ^(NSString *oneTimePassword, BOOL cancel, MASCompletionErrorBlock otpFetchcompletion)
            {
                DLog(@"\n\nOTP credentials block called with oneTimePassword: %@ and cancel: %@\n\n",
                     oneTimePassword, (cancel ? @"Yes" : @"No"));
                
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
                        otpFetchcompletion(NO, nil);
                    }
                    
                    //
                    // Notify
                    //
                    if(completion)
                    {
                        completion(nil, nil);
                    }
                    
                    return;
                }
                
                //
                // Set the OTP
                //
                NSMutableDictionary *headerInfo =
                [self.originalRequestInfo [@"headerInfo"] mutableCopy];
                
                if (!headerInfo)
                {
                    headerInfo = [NSMutableDictionary new];
                }
                
                [headerInfo setObject:oneTimePassword forKey:MASHeaderOTPKey];
                self.originalRequestInfo [@"header_info"] = headerInfo;
                
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
                    completion(self.originalRequestInfo, nil);
                }
            };
            
            DLog(@"\n\n\n********************************************************\n\n"
                 "Waiting for one time password to continue request"
                 @"\n\n********************************************************\n\n\n");
            
            //
            // otpError to provide details of the OTP flow handle
            //
            NSError *otpError = nil;
            if ([magErrorCode hasSuffix:MASApiErrorCodeInvalidOTPProvidedSuffix])
            {
                otpError = [NSError errorInvalidOTPCredentials];
            }
            else if ([otpStatus isEqualToString:MASOTPResponseOTPStatusKey]) {
                
                otpError = [NSError errorOTPCredentialsNotProvided];
            }
            
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
                                   _OTPCredentialsBlock_(otpCredentialsBlock);
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
            
            //
            // Notify
            //
            if(completion)
            {
                completion(nil, [NSError errorOTPRetryLimitExceeded:suspensionTime]);
            }
            
            return;
        }
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
