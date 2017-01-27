//
// MASFoundationService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASNetworkingService.h"

#import "MASConstantsPrivate.h"
#import "MASConfigurationService.h"

#import "MASAccessService.h"
#import "MASDeleteURLRequest.h"
#import "MASGetURLRequest.h"
#import "MASPatchURLRequest.h"
#import "MASPostURLRequest.h"
#import "MASPutURLRequest.h"
#import "MASHTTPSessionManager.h"
#import "MASLocationService.h"
#import "MASModelService.h"
#import "MASOTPService.h"
#import "MASINetworking.h"
#import "MASINetworkActivityLogger.h"


# pragma mark - Configuration Constants

//
// Defaults
//
static NSString *const kMASDefaultConfigurationFilename = @"msso_config";
static NSString *const kMASDefaultConfigurationFilenameExtension = @"json";
static NSString *const kMASDefaultNewline = @"\n";
static NSString *const kMASDefaultEmptySpace = @" ";


//
// Network Configuration Keys
//
static NSString *const kMASOAuthConfigurationKey = @"oauth"; // value is Dictionary

# pragma mark - Network Monitoring Constants

NSString *const MASGatewayMonitoringStatusUnknownValue = @"Unknown";
NSString *const MASGatewayMonitoringStatusNotReachableValue = @"Not Reachable";
NSString *const MASGatewayMonitoringStatusReachableViaWWANValue = @"Reachable Via WWAN";
NSString *const MASGatewayMonitoringStatusReachableViaWiFiValue = @"Reachable Via WiFi";



@interface MASNetworkingService ()

# pragma mark - Properties

@property (nonatomic, strong, readonly) MASIHTTPSessionManager *manager;

@end


@implementation MASNetworkingService

static MASGatewayMonitorStatusBlock _gatewayStatusMonitor_;


# pragma mark - Properties

+ (void)setGatewayMonitor:(MASGatewayMonitorStatusBlock)monitor
{
    _gatewayStatusMonitor_ = monitor;
}


#ifdef DEBUG

+ (void)setGatewayNetworkActivityLogging:(BOOL)enabled
{
    //
    // If network activity logging is enabled start it
    //
    if(enabled)
    {
        //
        // Begin logging
        //
        [[MASINetworkActivityLogger sharedLogger] startLogging];
        [[MASINetworkActivityLogger sharedLogger] setLevel:MASILoggerLevelDebug];
    }
    
    //
    // Stop network activity logging
    //
    else
    {
        [[MASINetworkActivityLogger sharedLogger] stopLogging];
    }
}

#endif


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASNetworkingService alloc] initProtected];
                  });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (NSString *)serviceUUID
{
    return MASNetworkServiceUUID;
}


- (void)serviceDidLoad
{
    
    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    //
    // establish URLSession with configuration's host name and start networking monitoring
    //
    [self establishURLSession];
    
    [super serviceWillStart];
}


- (void)serviceWillStop
{
    //
    // Cleanup the internal manager and shared instance
    //
    [self.manager.operationQueue cancelAllOperations];
    [self.manager.reachabilityManager stopMonitoring];
    [self.manager.reachabilityManager setReachabilityStatusChangeBlock:nil];
    _manager = nil;
    
    [super serviceWillStop];
}


- (void)serviceDidReset
{
    //
    //
    // Cleanup the internal manager and shared instance
    //
    [self.manager.operationQueue cancelAllOperations];
    [self.manager.reachabilityManager stopMonitoring];
    [self.manager.reachabilityManager setReachabilityStatusChangeBlock:nil];
    _manager = nil;
    
    //
    // Reset the value
    //
    _monitoringStatus = MASGatewayMonitoringStatusUnknown;
    
    [super serviceDidReset];
}


# pragma mark - Public

- (void)establishURLSession
{
    
    //
    // Cleanup the internal manager and shared instance
    //
    [self.manager.operationQueue cancelAllOperations];
    [self.manager.reachabilityManager stopMonitoring];
    [self.manager.reachabilityManager setReachabilityStatusChangeBlock:nil];
    _manager = nil;
    
    //
    // Retrieve the configuration
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    
    //
    //  Setup the security policy
    //
    //  Certificate Pinning Mode
    //
    
    MASISSLPinningMode pinningMode = MASISSLPinningModeCertificate;
    
    if (configuration.enabledTrustedPublicPKI)
    {
        pinningMode = MASISSLPinningModeNone;
    }
    else if (configuration.enabledPublicKeyPinning) {
        
        pinningMode = MASISSLPinningModePublicKey;
    }
    
    MASISecurityPolicy *policy = [MASISecurityPolicy policyWithPinningMode:pinningMode];
    
    [policy setAllowInvalidCertificates:(pinningMode == MASISSLPinningModeNone ? NO : YES)];
    [policy setValidatesDomainName:NO];
    [policy setValidatesCertificateChain:NO];
    [policy setPinnedCertificates:configuration.gatewayCertificatesAsDERData];
    
    //
    // Create the network manager
    //
    _manager = [[MASHTTPSessionManager alloc] initWithBaseURL:configuration.gatewayUrl];
    _manager.securityPolicy = policy;
    
    //
    // Reachability
    //
    [_manager.reachabilityManager setReachabilityStatusChangeBlock:^(MASINetworkReachabilityStatus status){
        //
        // Set the new value, this should be a direct mapping of MASI and MAS types
        //
        _monitoringStatus = (long)status;
        
        //
        // Make sure it is on the main thread
        //
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           //
                           // Notify the block, if any
                           //
                           if(_gatewayStatusMonitor_) _gatewayStatusMonitor_((long)status);
                       });
    }];
    
    //
    // Begin monitoring
    //
    [_manager.reachabilityManager startMonitoring];
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    base url: %@\n    monitoring status: %@",
            [super debugDescription], _manager.baseURL, [self networkStatusAsString]];
}


# pragma mark - Private

- (MASSessionDataTaskCompletionBlock)sessionDataTaskCompletionBlockWithEndPoint:(NSString *)endPoint
                                                                     parameters:(NSDictionary *)originalParameterInfo
                                                                        headers:(NSDictionary *)originalHeaderInfo
                                                                     httpMethod:(NSString *)httpMethod
                                                                    requestType:(MASRequestResponseType)requestType
                                                                   responseType:(MASRequestResponseType)responseType
                                                                completionBlock:(MASResponseInfoErrorBlock)completion
{
    __block MASRequestResponseType blockResponseType = responseType;
    __block MASRequestResponseType blockRequestType = requestType;
    __block NSString *blockEndPoint = endPoint;
    __block NSString *blockHTTPMethod = httpMethod;
    __block NSMutableDictionary *blockOriginalParameter = [originalParameterInfo mutableCopy];
    __block NSMutableDictionary *blockOriginalHeader = [originalHeaderInfo mutableCopy];
    __block MASResponseInfoErrorBlock blockCompletion = completion;
    __block MASNetworkingService *blockSelf = self;
    
    MASSessionDataTaskCompletionBlock taskCompletionBlock = ^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        MASIHTTPResponseSerializer *responseSerializer = [MASURLRequest responseSerializerForType:blockResponseType];
        [responseSerializer validateResponse:httpResponse data:responseObject error:&error];
        
        //
        // Response header info
        //
        NSDictionary *headerInfo = [httpResponse allHeaderFields];
        
        //
        //  If the error exists from the server, inject http status code in error userInfo
        //
        if (error)
        {
            //  Mutable copy of userInfo
            NSMutableDictionary *errorUserInfo = [error.userInfo mutableCopy];
            
            //  Add status code
            [errorUserInfo setObject:[NSNumber numberWithInteger:httpResponse.statusCode] forKey:MASErrorStatusCodeRequestResponseKey];
            
            //  Create new error
            NSError *newError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:errorUserInfo];
            error = newError;
        }

        __block NSMutableDictionary *responseInfo = [NSMutableDictionary new];
        
        if (headerInfo)
        {
            [responseInfo setObject:headerInfo forKey:MASResponseInfoHeaderInfoKey];
        }
        
        //
        // Response body info
        //
        if (responseObject)
        {
            [responseInfo setObject:responseObject forKey:MASResponseInfoBodyInfoKey];
        }
        
        NSString *magErrorCode = nil;
        
        //
        // Check if MAG error code exists
        //
        if ([[headerInfo allKeys] containsObject:MASHeaderErrorKey])
        {
            magErrorCode = [NSString stringWithFormat:@"%@", [headerInfo objectForKey:MASHeaderErrorKey]];
        }
        
        //
        // For geo-fencing, MAG backend service returns with specific HTTP status code for an error; not as in x-ca-err format in the header.
        // Therefore, SDK should look into the specific status code for the geo-location related error; and behaves accordingly.
        //
        if (httpResponse.statusCode == 449)
        {
            //
            // If geo-location is disabled from msso_config.json, SDK will NOT attempt to retrieve the geo-location information.
            // Developers should re-configure the msso_config.json properly.
            //
            if (![MASConfiguration currentConfiguration].locationIsRequired)
            {
                if(blockCompletion)
                {
                    blockCompletion(nil, [NSError errorGeolocationServiceIsNotConfigured]);
                }
            }
            //
            // If location service on the device is denied for the app, there is nothing that app nor SDK can do. Simply return an error.
            //
            else if ([MASLocationService isLocationMonitoringDenied])
            {
                if(blockCompletion)
                {
                    blockCompletion(nil, [NSError errorGeolocationServicesAreUnauthorized]);
                }
            }
            //
            // If location service was authorized, but somehow got an error for geo-location, try to retrieve the location once again.
            //
            else if ([MASLocationService isLocationMonitoringAuthorized])
            {
                //
                // Retrieve the geo-location coordinates
                //
                [[MASLocationService sharedService] startSingleLocationUpdate:^(CLLocation * _Nonnull location, MASLocationMonitoringAccuracy accuracy, MASLocationMonitoringStatus status) {
                    
                    //
                    // If an invalid geolocation result is detected
                    //
                    if((status != MASLocationMonitoringStatusSuccess && status != MASLocationMonitoringStatusTimedOut) ||
                       !location)
                    {
                        //
                        // Notify
                        //
                        if(blockCompletion)
                        {
                            blockCompletion(nil, [NSError errorGeolocationIsInvalid]);
                        }
                    }
                    else {
                        
                        //
                        // Inject geo-location information in the header
                        //
                        [blockOriginalHeader setObject:[location locationAsGeoCoordinates] forKey:MASGeoLocationRequestResponseKey];
                        
                        //
                        //  Proceed with original request
                        //
                        [blockSelf proceedOriginalRequestWithEndPoint:blockEndPoint
                                                       originalHeader:blockOriginalHeader
                                                    originalParameter:blockOriginalParameter
                                                          requestType:blockRequestType
                                                         responseType:blockResponseType
                                                           httpMethod:blockHTTPMethod
                                                           completion:blockCompletion];
                    }
                }];
            }
            //
            // All other cases (which unlikely happen), return the original error from the server to the client
            //
            else {
                
                if(blockCompletion)
                {
                    blockCompletion(nil, error);
                }
            }
        }
        //
        // If MAG error code exists, and it ends with 990, it means that the token is invalid.
        // Then, try re-validate user's session and retry the request.
        //
        else if (magErrorCode && [magErrorCode hasSuffix:@"990"])
        {
            
            //
            // Remove access_token from keychain
            //
            [[MASAccessService sharedService].currentAccessObj deleteForTokenExpiration];
            [[MASAccessService sharedService].currentAccessObj refresh];
            
            //
            // Validate user's session
            //
            [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
                
                //
                // If it fails to re-validate session, notify user
                //
                if (!completed || error)
                {
                    if(blockCompletion)
                    {
                        blockCompletion(responseInfo, error);
                    }
                }
                else {
                    
                    if ([blockSelf isMAGEndpoint:blockEndPoint])
                    {
                        blockCompletion(responseInfo, nil);
                    }
                    else {
                        
                        //
                        //  Proceed with original request
                        //
                        [blockSelf proceedOriginalRequestWithEndPoint:blockEndPoint
                                                       originalHeader:blockOriginalHeader
                                                    originalParameter:blockOriginalParameter
                                                          requestType:blockRequestType
                                                         responseType:blockResponseType
                                                           httpMethod:blockHTTPMethod
                                                           completion:blockCompletion];
                    }
                }
            }];
        }
        //
        // If MAG error code exists, and it ends with 140/142/143/144/145,
        // it means that the OTP is required to proceed with the request.
        // Then, try validate OTP session and retry the request.
        //
        else if (magErrorCode &&
                 ([magErrorCode hasSuffix:@"140"] ||
                  [magErrorCode hasSuffix:@"142"] || [magErrorCode hasSuffix:@"143"] ||
                  [magErrorCode hasSuffix:@"144"] || [magErrorCode hasSuffix:@"145"])) {
                     
                     [[MASOTPService sharedService] validateOTPSessionWithResponseHeaders:headerInfo
                                                                          completionBlock:^(NSDictionary *responseInfo, NSError *error)
                      {
                          
                          NSString *oneTimePassword = [responseInfo objectForKey:MASHeaderOTPKey];
                          NSArray *otpChannels = [responseInfo objectForKey:MASHeaderOTPChannelKey];
                          
                          //
                          // If it fails to fetch OTP, notify user
                          //
                          if (!oneTimePassword || error)
                          {
                              if(blockCompletion)
                              {
                                  blockCompletion(responseInfo, error);
                              }
                          }
                          else {
                              
                              NSString *otpSelectedChannelsStr = [otpChannels componentsJoinedByString:@","];
                              
                              [blockOriginalHeader setObject:oneTimePassword forKey:MASHeaderOTPKey];
                              [blockOriginalHeader setObject:otpSelectedChannelsStr forKey:MASHeaderOTPChannelKey];
                              
                              //
                              //  Proceed with original request
                              //
                              [blockSelf proceedOriginalRequestWithEndPoint:blockEndPoint
                                                             originalHeader:blockOriginalHeader
                                                          originalParameter:blockOriginalParameter
                                                                requestType:blockRequestType
                                                               responseType:blockResponseType
                                                                 httpMethod:blockHTTPMethod
                                                                 completion:blockCompletion];
                          }
                      }
                      ];
                 }
        //
        // If the MAG error code exists, and it ends with 206
        // it means that the signed client certificate used to establish mutual SSL has been expired.
        // Client SDK is responsible to renew the client certificate with given mag-identifier within grace period (defined by the server).
        // If the renewing certificate fails, the client certificate is responsible to fallback to validation logic for registration and/or authentication.
        //
        else if (magErrorCode && [magErrorCode hasSuffix:@"206"] && ![blockEndPoint isEqualToString:[MASConfiguration currentConfiguration].deviceRenewEndpointPath])
        {
            //
            // Renew the client certificate, if the renew endpoint fails,
            //
            [[MASModelService sharedService] renewClientCertificateWithCompletion:^(BOOL completed, NSError *error) {
                
                //
                // If it fails to renew the client certificate or other registration/authentication, notify user
                //
                if (!completed || error)
                {
                    if(blockCompletion)
                    {
                        blockCompletion(responseInfo, error);
                    }
                }
                else {
                    
                    //
                    //  Proceed with original request
                    //
                    [blockSelf proceedOriginalRequestWithEndPoint:blockEndPoint
                                                   originalHeader:blockOriginalHeader
                                                originalParameter:blockOriginalParameter
                                                      requestType:blockRequestType
                                                     responseType:blockResponseType
                                                       httpMethod:blockHTTPMethod
                                                       completion:blockCompletion];
                }
            }];
        }
        else {
            //
            // If the server complains that client_secret or client_id is invalid, we have to clear the client_id and client_secret
            //
            if (magErrorCode && [magErrorCode hasSuffix:@"201"]) {
                
                [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeClientId];
                [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeClientSecret];
                [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeClientExpiration];
                
                //
                // Remove access_token from keychain
                //
                [[MASAccessService sharedService].currentAccessObj deleteForTokenExpiration];
                [[MASAccessService sharedService].currentAccessObj refresh];
                
                //
                // Validate user's session
                //
                [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
                    
                    //
                    // If it fails to re-validate session, notify user
                    //
                    if (!completed || error)
                    {
                        if(blockCompletion)
                        {
                            blockCompletion(responseInfo, error);
                        }
                    }
                    else {
                        
                        if ([blockSelf isMAGEndpoint:blockEndPoint])
                        {
                            blockCompletion(responseInfo, nil);
                        }
                        else {
                            
                            //
                            // If the original header contains the clientAuthorizationHeader, which is invalid;
                            // replace with the newly generated clientAuthorizationHeader for the retry request.
                            //
                            if ([[blockOriginalHeader allKeys] containsObject:MASAuthorizationRequestResponseKey] && ![[blockOriginalHeader objectForKey:MASAuthorizationRequestResponseKey] isEqualToString:[[MASApplication currentApplication] clientAuthorizationBasicHeaderValue]])
                            {
                                [blockOriginalHeader setObject:[[MASApplication currentApplication] clientAuthorizationBasicHeaderValue] forKey:MASAuthorizationRequestResponseKey];
                            }
                            
                            if ([[blockOriginalParameter allKeys] containsObject:MASClientKeyRequestResponseKey] && ![[blockOriginalParameter objectForKey:MASClientKeyRequestResponseKey] isEqualToString:[[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientId]])
                            {
                                [blockOriginalParameter setObject:[[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientId] forKey:MASClientKeyRequestResponseKey];
                            }
                            
                            //
                            //  Proceed with original request
                            //
                            [blockSelf proceedOriginalRequestWithEndPoint:blockEndPoint
                                                           originalHeader:blockOriginalHeader
                                                        originalParameter:blockOriginalParameter
                                                              requestType:blockRequestType
                                                             responseType:blockResponseType
                                                               httpMethod:blockHTTPMethod
                                                               completion:blockCompletion];
                        }
                    }
                }];
            }
            else if (blockCompletion)
            {
                
                //
                // notify
                //
                blockCompletion(responseInfo, error);
            }
        }
    };
    
    return taskCompletionBlock;
}


- (BOOL)isMAGEndpoint:(NSString *)endpoint
{
    BOOL isMAGEndpoint = NO;
    
    if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].tokenEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].tokenRevokeEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].deviceRemoveEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].deviceRegisterEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].deviceRegisterClientEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    //    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].authorizationEndpointPath])
    //    {
    //        isMAGEndpoint = YES;
    //    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].clientInitializeEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    
    return isMAGEndpoint;
}


- (void)proceedOriginalRequestWithEndPoint:(NSString *)endPoint
                            originalHeader:(NSMutableDictionary *)originalHeader
                         originalParameter:(NSMutableDictionary *)originalParameter
                               requestType:(MASRequestResponseType)requestType
                              responseType:(MASRequestResponseType)responseType
                                httpMethod:(NSString *)httpMethod
                                completion:(MASResponseInfoErrorBlock)completion
{
    
    //
    // Retry request
    //
    if ([httpMethod isEqualToString:@"DELETE"])
    {
        [self deleteFrom:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType completion:completion];
    }
    else if ([httpMethod isEqualToString:@"GET"])
    {
        [self getFrom:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType completion:completion];
    }
    else if ([httpMethod isEqualToString:@"PATCH"])
    {
        [self patchTo:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType completion:completion];
    }
    else if ([httpMethod isEqualToString:@"POST"])
    {
        [self postTo:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType completion:completion];
    }
    else if ([httpMethod isEqualToString:@"PUT"])
    {
        [self putTo:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType completion:completion];
    }
    
    return;
}


# pragma mark - Network Monitoring

- (BOOL)networkIsReachable
{
    return (self.monitoringStatus == MASGatewayMonitoringStatusReachableViaWWAN ||
            self.monitoringStatus == MASGatewayMonitoringStatusReachableViaWiFi);
}


- (NSString *)networkStatusAsString
{
    //
    // Detect status and respond appropriately
    //
    switch(self.monitoringStatus)
    {
            //
            // Not Reachable
            //
        case MASGatewayMonitoringStatusNotReachable:
        {
            return MASGatewayMonitoringStatusNotReachableValue;
        }
            
            //
            // Reachable Via WWAN
            //
        case MASGatewayMonitoringStatusReachableViaWWAN:
        {
            return MASGatewayMonitoringStatusReachableViaWWANValue;
        }
            
            //
            // Reachable Via WiFi
            //
        case MASGatewayMonitoringStatusReachableViaWiFi:
        {
            return MASGatewayMonitoringStatusReachableViaWiFiValue;
        }
            
            //
            // Default
            //
        default:
        {
            return MASGatewayMonitoringStatusUnknownValue;
        }
    }
}


# pragma mark - HTTP Requests

- (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
        completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Default types
    //
    [self deleteFrom:endPoint
      withParameters:parameterInfo
          andHeaders:headerInfo
         requestType:MASRequestResponseTypeJson
        responseType:MASRequestResponseTypeJson
          completion:completion];
}


- (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Just passthrough
    //
    [self httpDeleteFrom:endPoint
          withParameters:parameterInfo
              andHeaders:headerInfo
             requestType:requestType
            responseType:responseType
              completion:completion];
}


- (void)httpDeleteFrom:(NSString *)endPoint
        withParameters:(NSDictionary *)parameterInfo
            andHeaders:(NSDictionary *)headerInfo
           requestType:(MASRequestResponseType)requestType
          responseType:(MASRequestResponseType)responseType
            completion:(MASResponseInfoErrorBlock)completion
{
    //DLog(@"called");
    
    //
    //  endPoint cannot be nil
    //
    if (!endPoint)
    {
        //
        // Notify
        //
        if(completion) completion(nil, [NSError errorInvalidEndpoint]);
        
        return;
    }
    
    //
    // Determine if we need to add the geo-location header value
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    if(configuration.locationIsRequired)
    {
        
        //
        // Request the one time, currently available location before proceeding
        //
        [[MASLocationService sharedService] startSingleLocationUpdate:^(CLLocation *location, MASLocationMonitoringAccuracy accuracy, MASLocationMonitoringStatus status)
         {
             
             //
             // Update the header
             //
             NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
             
             //
             // If a valid geolocation result is detected
             //
             if (status == MASLocationMonitoringStatusSuccess && location)
             {
                 mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [location locationAsGeoCoordinates];
             }
             
             //
             // create request
             //
             MASDeleteURLRequest *request = [MASDeleteURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType];
             
             //
             // create dataTask
             //
             NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                          completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                                  parameters:parameterInfo
                                                                                                                     headers:headerInfo
                                                                                                                  httpMethod:request.HTTPMethod
                                                                                                                 requestType:requestType
                                                                                                                responseType:responseType
                                                                                                             completionBlock:completion]];
             
             //
             // resume dataTask
             //
             [dataTask resume];
         }];
    }
    else {
        
        //
        // create request
        //
        MASDeleteURLRequest *request = [MASDeleteURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:requestType responseType:responseType];
        
        //
        // create dataTask
        //
        NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                     completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                             parameters:parameterInfo
                                                                                                                headers:headerInfo
                                                                                                             httpMethod:request.HTTPMethod
                                                                                                            requestType:requestType
                                                                                                           responseType:responseType
                                                                                                        completionBlock:completion]];
        //
        // resume dataTask
        //
        [dataTask resume];
    }
}


- (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
     completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Default types
    //
    [self getFrom:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:MASRequestResponseTypeJson
     responseType:MASRequestResponseTypeJson
       completion:completion];
}


- (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
     completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Just passthrough
    //
    [self httpGetFrom:endPoint
       withParameters:parameterInfo
           andHeaders:headerInfo
          requestType:requestType
         responseType:responseType
           completion:completion];
}


- (void)httpGetFrom:(NSString *)endPoint
     withParameters:(NSDictionary *)parameterInfo
         andHeaders:(NSDictionary *)headerInfo
        requestType:(MASRequestResponseType)requestType
       responseType:(MASRequestResponseType)responseType
         completion:(MASResponseInfoErrorBlock)completion
{
    //DLog(@"called");
    
    //
    //  endPoint cannot be nil
    //
    if (!endPoint)
    {
        //
        // Notify
        //
        if(completion) completion(nil, [NSError errorInvalidEndpoint]);
        
        return;
    }
    
    //
    // Determine if we need to add the geo-location header value
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    if(configuration.locationIsRequired)
    {
        
        //
        // Request the one time, currently available location before proceeding
        //
        [[MASLocationService sharedService] startSingleLocationUpdate:^(CLLocation *location, MASLocationMonitoringAccuracy accuracy, MASLocationMonitoringStatus status)
         {
             
             //
             // Update the header
             //
             NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
             
             //
             // If a valid geolocation result is detected
             //
             if (status == MASLocationMonitoringStatusSuccess && location)
             {
                 mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [location locationAsGeoCoordinates];
             }
             
             //
             // create request
             //
             MASGetURLRequest *request = [MASGetURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType];
             
             //
             // create dataTask
             //
             NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                          completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                                  parameters:parameterInfo
                                                                                                                     headers:headerInfo
                                                                                                                  httpMethod:request.HTTPMethod
                                                                                                                 requestType:requestType
                                                                                                                responseType:responseType
                                                                                                             completionBlock:completion]];
             
             //
             // resume dataTask
             //
             [dataTask resume];
         }];
    }
    else {
        
        //
        // Else just create the request
        //
        MASGetURLRequest *request = [MASGetURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:requestType responseType:responseType];
        
        //
        // create dataTask
        //
        NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                     completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                             parameters:parameterInfo
                                                                                                                headers:headerInfo
                                                                                                             httpMethod:request.HTTPMethod
                                                                                                            requestType:requestType
                                                                                                           responseType:responseType
                                                                                                        completionBlock:completion]];
        
        //
        // resume dataTask
        //
        [dataTask resume];
    }
}


- (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
     completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Default types
    //
    [self patchTo:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:MASRequestResponseTypeJson
     responseType:MASRequestResponseTypeJson
       completion:completion];
}


- (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
     completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Just passthrough
    //
    [self httpPatchTo:endPoint
       withParameters:parameterInfo
           andHeaders:headerInfo
          requestType:requestType
         responseType:responseType
           completion:completion];
}


- (void)httpPatchTo:(NSString *)endPoint
     withParameters:(NSDictionary *)parameterInfo
         andHeaders:(NSDictionary *)headerInfo
        requestType:(MASRequestResponseType)requestType
       responseType:(MASRequestResponseType)responseType
         completion:(MASResponseInfoErrorBlock)completion
{
    //
    //  endPoint cannot be nil
    //
    if (!endPoint)
    {
        //
        // Notify
        //
        if(completion) completion(nil, [NSError errorInvalidEndpoint]);
        
        return;
    }
    
    //
    // Determine if we need to add the geo-location header value
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    if(configuration.locationIsRequired)
    {
        
        //
        // Request the one time, currently available location before proceeding
        //
        [[MASLocationService sharedService] startSingleLocationUpdate:^(CLLocation *location, MASLocationMonitoringAccuracy accuracy, MASLocationMonitoringStatus status)
         {
             
             //
             // Update the header
             //
             NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
             
             //
             // If a valid geolocation result is detected
             //
             if (status == MASLocationMonitoringStatusSuccess && location)
             {
                 mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [location locationAsGeoCoordinates];
             }
             
             //
             // create request
             //
             MASPatchURLRequest *request = [MASPatchURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType];
             
             //
             // create dataTask
             //
             NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                          completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                                  parameters:parameterInfo
                                                                                                                     headers:headerInfo
                                                                                                                  httpMethod:request.HTTPMethod
                                                                                                                 requestType:requestType
                                                                                                                responseType:responseType
                                                                                                             completionBlock:completion]];
             
             //
             // resume dataTask
             //
             [dataTask resume];
         }];
    }
    else {
        
        //
        // create request
        //
        MASPatchURLRequest *request = [MASPatchURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:requestType responseType:responseType];
        
        //
        // create dataTask
        //
        NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                     completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                             parameters:parameterInfo
                                                                                                                headers:headerInfo
                                                                                                             httpMethod:request.HTTPMethod
                                                                                                            requestType:requestType
                                                                                                           responseType:responseType
                                                                                                        completionBlock:completion]];
        
        //
        // resume dataTask
        //
        [dataTask resume];
    }
}


- (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
    completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Default types
    //
    [self postTo:endPoint
  withParameters:parameterInfo
      andHeaders:headerInfo
     requestType:MASRequestResponseTypeJson
    responseType:MASRequestResponseTypeJson
      completion:completion];
}


- (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
    completion:(MASResponseInfoErrorBlock)completion
{
    //DLog(@"called");
    //
    // Just passthrough
    //
    [self httpPostTo:endPoint
      withParameters:parameterInfo
          andHeaders:headerInfo
         requestType:requestType
        responseType:responseType
          completion:completion];
}


- (void)httpPostTo:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(MASResponseInfoErrorBlock)completion
{
    //DLog(@"called");
    
    //
    //  endPoint cannot be nil
    //
    if (!endPoint)
    {
        //
        // Notify
        //
        if(completion) completion(nil, [NSError errorInvalidEndpoint]);
        
        return;
    }
    
    //
    // Determine if we need to add the geo-location header value
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    if(configuration.locationIsRequired)
    {
        
        //
        // Request the one time, currently available location before proceeding
        //
        [[MASLocationService sharedService] startSingleLocationUpdate:^(CLLocation *location, MASLocationMonitoringAccuracy accuracy, MASLocationMonitoringStatus status)
         {
             
             //
             // Update the header
             //
             NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
             
             //
             // If a valid geolocation result is detected
             //
             if (status == MASLocationMonitoringStatusSuccess && location)
             {
                 mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [location locationAsGeoCoordinates];
             }
             
             //
             // create request
             //
             MASPostURLRequest *request = [MASPostURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType];
             
             //
             // create dataTask
             //
             NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                          completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                                  parameters:parameterInfo
                                                                                                                     headers:headerInfo
                                                                                                                  httpMethod:request.HTTPMethod
                                                                                                                 requestType:requestType
                                                                                                                responseType:responseType
                                                                                                             completionBlock:completion]];
             
             //
             // resume dataTask
             //
             [dataTask resume];
             
         }];
    }
    else {
        
        //
        // create request
        //
        MASPostURLRequest *request = [MASPostURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:requestType responseType:responseType];
        
        //
        // create dataTask
        //
        NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                     completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                             parameters:parameterInfo
                                                                                                                headers:headerInfo
                                                                                                             httpMethod:request.HTTPMethod
                                                                                                            requestType:requestType
                                                                                                           responseType:responseType
                                                                                                        completionBlock:completion]];
        
        //
        // resume dataTask
        //
        [dataTask resume];
    }
}


- (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
   completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Default types
    //
    [self putTo:endPoint
 withParameters:parameterInfo
     andHeaders:headerInfo
    requestType:MASRequestResponseTypeJson
   responseType:MASRequestResponseTypeJson
     completion:completion];
}


- (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
  requestType:(MASRequestResponseType)requestType
 responseType:(MASRequestResponseType)responseType
   completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Just passthrough
    //
    [self httpPutTo:endPoint
     withParameters:parameterInfo
         andHeaders:headerInfo
        requestType:requestType
       responseType:responseType
         completion:completion];
}


- (void)httpPutTo:(NSString *)endPoint
   withParameters:(NSDictionary *)parameterInfo
       andHeaders:(NSDictionary *)headerInfo
      requestType:(MASRequestResponseType)requestType
     responseType:(MASRequestResponseType)responseType
       completion:(MASResponseInfoErrorBlock)completion
{
    //
    //  endPoint cannot be nil
    //
    if (!endPoint)
    {
        //
        // Notify
        //
        if(completion) completion(nil, [NSError errorInvalidEndpoint]);
        
        return;
    }
    
    //
    // Determine if we need to add the geo-location header value
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    if(configuration.locationIsRequired)
    {
        
        //
        // Request the one time, currently available location before proceeding
        //
        [[MASLocationService sharedService] startSingleLocationUpdate:^(CLLocation *location, MASLocationMonitoringAccuracy accuracy, MASLocationMonitoringStatus status)
         {
             
             //
             // Update the header
             //
             NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
             
             //
             // If a valid geolocation result is detected
             //
             if (status == MASLocationMonitoringStatusSuccess && location)
             {
                 mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [location locationAsGeoCoordinates];
             }
             
             //
             // create request
             //
             MASPutURLRequest *request = [MASPutURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType];
             
             //
             // create dataTask
             //
             NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                          completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                                  parameters:parameterInfo
                                                                                                                     headers:headerInfo
                                                                                                                  httpMethod:request.HTTPMethod
                                                                                                                 requestType:requestType
                                                                                                                responseType:responseType
                                                                                                             completionBlock:completion]];
             
             //
             // resume dataTask
             //
             [dataTask resume];
         }];
    }
    else {
        
        //
        // create request
        //
        MASPutURLRequest *request = [MASPutURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:requestType responseType:responseType];
        
        //
        // create dataTask
        //
        NSURLSessionDataTask *dataTask = [_manager dataTaskWithRequest:request
                                                     completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                             parameters:parameterInfo
                                                                                                                headers:headerInfo
                                                                                                             httpMethod:request.HTTPMethod
                                                                                                            requestType:requestType
                                                                                                           responseType:responseType
                                                                                                        completionBlock:completion]];
        
        //
        // resume dataTask
        //
        [dataTask resume];
    }
}

@end
