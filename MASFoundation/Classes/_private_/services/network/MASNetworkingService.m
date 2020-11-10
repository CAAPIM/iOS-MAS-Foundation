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

#import "MASAccessService.h"
#import "MASConfigurationService.h"
#import "MASLocationService.h"
#import "MASModelService.h"
#import "MASOTPService.h"

#import "MASINetworking.h"

//  MAS internal network layer
#import "MASURLSessionManager.h"
#import "MASDeleteURLRequest.h"
#import "MASGetURLRequest.h"
#import "MASNetworkMonitor.h"
#import "MASPatchURLRequest.h"
#import "MASPostURLRequest.h"
#import "MASPutURLRequest.h"
#import "MASSecurityPolicy.h"
#import "MASNetworkReachability.h"
#import "MASMultiFactorHandler+MASPrivate.h"
#import "MASMultiPartRequestSerializer.h"
#import "MASDataTask+MASPrivate.h"

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

@property (nonatomic, strong, readwrite) MASURLSessionManager *sessionManager;
@property (nonatomic, strong, readwrite) MASNetworkReachability *gatewayReachabilityManager;
@property (readwrite, nonatomic, strong) MASAuthValidationOperation *authValidationOperation;
@property (atomic, strong) NSMutableDictionary* tasks;

@end


static NSString *kMASNetworkQueueOperationsChanged = @"kMASNetworkQueueOperationsChanged";

@implementation MASNetworkingService

static MASNetworkReachabilityStatusBlock _gatewayReachabilityBlock_;
static NSMutableDictionary *_reachabilityMonitoringBlockForHosts_;
static NSMutableArray *_multiFactorAuthenticators_;


# pragma mark - Network Reachability

+ (void)setGatewayMonitor:(MASGatewayMonitorStatusBlock)monitor
{
    __block MASGatewayMonitorStatusBlock blockMonitor = monitor;
    _gatewayReachabilityBlock_ = ^(MASNetworkReachabilityStatus status){
        
        MASGatewayMonitoringStatus convertedStatus;
        //
        //  Convert MASNetworkReachabilityStatus to MASGatewayMonitoringStatus
        //
        switch (status) {
            case MASNetworkReachabilityStatusNotReachable:
                convertedStatus = MASGatewayMonitoringStatusNotReachable;
                break;
            case MASNetworkReachabilityStatusReachableViaWWAN:
                convertedStatus = MASGatewayMonitoringStatusReachableViaWWAN;
                break;
            case MASNetworkReachabilityStatusReachableViaWiFi:
                convertedStatus = MASGatewayMonitoringStatusReachableViaWiFi;
                break;
            case MASNetworkReachabilityStatusUnknown:
            case MASNetworkReachabilityStatusInitializing:
            default:
                convertedStatus = MASGatewayMonitoringStatusUnknown;
                break;
        }
        
        //
        // Notify the block, if any
        //
        if (blockMonitor)
        {
            blockMonitor(convertedStatus);
        }
    };
    
    if ([MAS MASState] == MASStateDidStart)
    {
        [[MASNetworkingService sharedService] setGatewayReachabilityMonitoringBlock:_gatewayReachabilityBlock_];
    }
}


+ (void)setNetworkReachabilityMonitorForHost:(NSString *)host monitor:(MASNetworkReachabilityStatusBlock)monitor
{
    MASNetworkReachability *reachability = [MASNetworkingService retrieveOrConstructReachabilityForHost:host];
    
    [reachability setReachabilityMonitoringBlock:monitor];
    [reachability startMonitoring];
}


+ (BOOL)isNetworkReachableForHost:(NSString *)host
{
    MASNetworkReachability *reachability = [MASNetworkingService retrieveOrConstructReachabilityForHost:host];
    return reachability.isReachable;
}


- (void)setGatewayReachabilityMonitoringBlock:(MASNetworkReachabilityStatusBlock)monitoringBlock
{
    if (_gatewayReachabilityManager)
    {
        [_gatewayReachabilityManager setReachabilityMonitoringBlock:monitoringBlock];
    }
}


+ (MASNetworkReachability *)retrieveOrConstructReachabilityForHost:(NSString *)host
{
    if (!_reachabilityMonitoringBlockForHosts_)
    {
        _reachabilityMonitoringBlockForHosts_ = [NSMutableDictionary dictionary];
    }
    
    NSString *targetHost = host;
    if (targetHost == nil || [targetHost length] == 0)
    {
        targetHost = @"default";
    }
    
    if ([_reachabilityMonitoringBlockForHosts_.allKeys containsObject:targetHost])
    {
        return [_reachabilityMonitoringBlockForHosts_ objectForKey:targetHost];
    }
    else {
        
        MASNetworkReachability *reachability = nil;
        if ([targetHost isEqualToString:@"default"])
        {
            //
            //  Construct sockaddr for generic network
            //
            struct sockaddr_in genericAddress;
            bzero(&genericAddress, sizeof(genericAddress));
            genericAddress.sin_len = sizeof(genericAddress);
            genericAddress.sin_family = AF_INET;
            
            reachability = [[MASNetworkReachability alloc] initWithAddress:(const struct sockaddr *)&genericAddress];
        }
        else {
            reachability = [[MASNetworkReachability alloc] initWithDomain:targetHost];
        }
        
        if (reachability)
        {
            [_reachabilityMonitoringBlockForHosts_ setObject:reachability forKey:targetHost];
        }
        
        return reachability;
    }
}


# pragma mark - DEBUG

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
        [[MASNetworkMonitor sharedMonitor] startMonitoring];
    }
    //
    // Stop network activity logging
    //
    else
    {
        [[MASNetworkMonitor sharedMonitor] stopMonitoring];
    }
}


# pragma mark - Multi Factor Authenticator

+ (void)registerMultiFactorAuthenticator:(MASObject<MASMultiFactorAuthenticator> *)multiFactorAuthenticator
{
    if (_multiFactorAuthenticators_ == nil)
    {
        _multiFactorAuthenticators_ = [NSMutableArray array];
    }
    
    if ([multiFactorAuthenticator respondsToSelector:@selector(getMultiFactorHandler:response:)] && [multiFactorAuthenticator respondsToSelector:@selector(onMultiFactorAuthenticationRequest:response:handler:)])
    {
        [_multiFactorAuthenticators_ addObject:multiFactorAuthenticator];
    }
}


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

+ (void)load
{
    [MASService registerSubclass:[self class] serviceUUID:MASNetworkServiceUUID];
}


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
    
    if(!self.tasks){
        self.tasks = [[NSMutableDictionary alloc] init];
    }
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
    if (_sessionManager)
    {
        [_sessionManager.operationQueue cancelAllOperations];
        [_gatewayReachabilityManager stopMonitoring];
        _sessionManager = nil;
    }
    [self cleanUpFinishedTasks];
    
    [super serviceWillStop];
}


- (void)serviceDidReset
{
    //
    //
    // Cleanup the internal manager and shared instance
    //
    if (_sessionManager)
    {
        [_sessionManager.operationQueue cancelAllOperations];
        [_gatewayReachabilityManager stopMonitoring];
        _sessionManager = nil;
    }
    
    [super serviceDidReset];
}


# pragma mark - NSObserver

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[NSOperationQueue class]] && [keyPath isEqualToString:@"operations"] && context == &kMASNetworkQueueOperationsChanged)
    {
        NSOperationQueue *thisQueue = (NSOperationQueue *)object;
        if ([thisQueue.operations count] == 0)
        {
            //
            //  Nullify shared operation as all of operations is completed
            //
            _authValidationOperation = nil;
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


# pragma mark - MASAuthValidationOperation

- (MASAuthValidationOperation *)sharedOperation
{
    //
    //  synchronized method to avoid duplicate sharedOperation
    //
    @synchronized (self) {
        
        //
        //  if shared operation was not constructed, create one
        //
        if (!_authValidationOperation)
        {
            _authValidationOperation = [MASAuthValidationOperation sharedOperation];
        }
        //
        //  if shared operation was created, but already executed and cleared, destroy old one and create new one
        //
        else if (_authValidationOperation.isFinished)
        {
            _authValidationOperation = nil;
            _authValidationOperation = [MASAuthValidationOperation sharedOperation];
        }
        
        return _authValidationOperation;
    }
}


# pragma mark - Public

- (void)releaseOperationQueue
{
    if (_sessionManager.operationQueue.isSuspended)
    {
        [_sessionManager.operationQueue setSuspended:NO];
    }
}

- (void)establishURLSession
{
    
    if (_sessionManager == nil)
    {
        //
        //  Setup the security policy
        //
        MASSecurityPolicy *securityPolicy = [[MASSecurityPolicy alloc] init];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.URLCredentialStorage = nil;
        sessionConfig.URLCache = nil;
        
        //
        //  NSURLSessionManager
        //
        _sessionManager = [[MASURLSessionManager alloc] initWithConfiguration:sessionConfig];
        _sessionManager.securityPolicy = securityPolicy;
        [_sessionManager.operationQueue addObserver:self forKeyPath:@"operations" options:0 context:&kMASNetworkQueueOperationsChanged];
        
        //
        // Reachability
        //
        if (_gatewayReachabilityManager != nil)
        {
            [_gatewayReachabilityManager stopMonitoring];
            _gatewayReachabilityManager = nil;
        }
        
        _gatewayReachabilityManager = [[MASNetworkReachability alloc] initWithDomain:[MASConfiguration currentConfiguration].gatewayHostName];
        [_gatewayReachabilityManager setReachabilityMonitoringBlock:_gatewayReachabilityBlock_];
        
        //
        // Begin monitoring
        //
        [_gatewayReachabilityManager startMonitoring];
    }
    else {
        [_sessionManager updateSession];
    }
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    session manager: %@\n    monitoring status: %@",
            [super debugDescription], _sessionManager, [self networkStatusAsString]];
}


# pragma mark - Private

- (MASSessionDataTaskCompletionBlock)sessionDataTaskCompletionBlockWithEndPoint:(NSString *)endPoint
                                                                     parameters:(NSDictionary *)originalParameterInfo
                                                                        headers:(NSDictionary *)originalHeaderInfo
                                                                     httpMethod:(NSString *)httpMethod
                                                                    requestType:(MASRequestResponseType)requestType
                                                                   responseType:(MASRequestResponseType)responseType
                                                                       isPublic:(BOOL)isPublic completionBlock:(MASResponseInfoErrorBlock)completion
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
        
        if (blockResponseType == MASRequestResponseTypeTextPlain && [responseObject isKindOfClass:[NSData class]])
        {
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if (responseString != nil && [responseString length] > 0)
            {
                responseObject = responseString;
            }
        }
        
        //
        // Response header info
        //
        NSDictionary *headerInfo = [httpResponse allHeaderFields];
        NSLog(@"Response headers : %@",headerInfo);
        
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
            
            //  Parsing JSON error returned from the server
            if (blockResponseType == MASRequestResponseTypeTextPlain && responseObject && [responseObject isKindOfClass:[NSString class]])
            {
                NSError *parseError;
                NSData *objectData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&parseError];
                
                if(!parseError)
                {
                    responseObject = json;
                }
            }
        }
        
        __block NSMutableDictionary *responseInfo = [NSMutableDictionary new];
        
        //
        // HTTP header info
        //
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
        
        //
        // NSHTTPURLResponse object
        //
        if (httpResponse)
        {
            [responseInfo setObject:httpResponse forKey:MASNSHTTPURLResponseObjectKey];
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
            else if ([[MASLocationService sharedService] locationServiceStatus] == MASLocationServiceStatusDenied)
            {
                if(blockCompletion)
                {
                    blockCompletion(nil, [NSError errorGeolocationServicesAreUnauthorized]);
                }
            }
            //
            // If location service was authorized, but somehow got an error for geo-location, try to retrieve the location once again.
            //
            else if ([[MASLocationService sharedService] locationServiceStatus] == MASLocationServiceStatusAvailable)
            {
                //
                // If an invalid geolocation result is detected
                //
                if([MASLocationService sharedService].lastKnownLocation == nil)
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
                    if ([MASLocationService sharedService].lastKnownLocation != nil)
                    {
                        blockOriginalHeader[MASGeoLocationRequestResponseKey] = [[MASLocationService sharedService].lastKnownLocation locationAsGeoCoordinates];
                    }
                    
                    //
                    //  Proceed with original request
                    //
                    [blockSelf proceedOriginalRequestWithEndPoint:blockEndPoint
                                                   originalHeader:blockOriginalHeader
                                                originalParameter:blockOriginalParameter
                                                      requestType:blockRequestType
                                                     responseType:blockResponseType
                                                         isPublic:isPublic
                                                       httpMethod:blockHTTPMethod
                                                       completion:blockCompletion];
                }
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
            [_sessionManager.operationQueue setSuspended:YES];
            
            //
            // Remove access_token from keychain
            //
            [[MASAccessService sharedService].currentAccessObj deleteForTokenExpiration];
            [[MASAccessService sharedService].currentAccessObj refresh];
            
            
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
                                                     isPublic:isPublic
                                                   httpMethod:blockHTTPMethod
                                                   completion:blockCompletion];
            }
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
            [_sessionManager.operationQueue setSuspended:YES];
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
                                                         isPublic:isPublic
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
                
                [_sessionManager.operationQueue setSuspended:YES];
                
                //
                //  Remove slave client_id and client_secret from keychain
                //
                [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyClientId];
                [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyClientSecret];
                [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyClientExpiration];
                
                //
                // Remove access_token from keychain
                //
                [[MASAccessService sharedService].currentAccessObj deleteForTokenExpiration];
                [[MASAccessService sharedService].currentAccessObj refresh];
                
                //
                //  Invalidate the current shared validation operation, then reconstruct new validation operation and move all pending operation's dependencies over to the newly created one
                //
                [self reconstructAuthValidationOperation];
                
                //
                //  If failing request was one of MAG system endpoint, deliver the message as it is
                //
                if ([blockSelf isMAGEndpoint:blockEndPoint])
                {
                    blockCompletion(responseInfo, nil);
                }
                //
                //  If failing request was not one of MAG system endpoint, rebuild the request
                //
                else {
                    
                    //
                    //  Proceed with original request
                    //
                    [blockSelf proceedOriginalRequestWithEndPoint:blockEndPoint
                                                   originalHeader:blockOriginalHeader
                                                originalParameter:blockOriginalParameter
                                                      requestType:blockRequestType
                                                     responseType:blockResponseType
                                                         isPublic:isPublic
                                                       httpMethod:blockHTTPMethod
                                                       completion:blockCompletion];
                }
            }
            //
            //  Going into MFA flow if the target API's endpoint is not one of MAG/OTK's system endpoints, and the original request failed.
            //
            else if (![blockSelf isMAGEndpoint:blockEndPoint] && error != nil)
            {
                MASMultiFactorHandler *handler = nil;
                MASRequest *originalRequest = nil;
                MASObject<MASMultiFactorAuthenticator> *authenticator = nil;
                
                //
                //  Loop through multi factor authenticators to identify any authenticator is responding to the error
                //
                for (MASObject<MASMultiFactorAuthenticator> *thisMultiFactorAuthenticator in _multiFactorAuthenticators_)
                {
                    if ([thisMultiFactorAuthenticator respondsToSelector:@selector(getMultiFactorHandler:response:)])
                    {
                        MASRequestBuilder *originalRequestBuilder = [[MASRequestBuilder alloc] initWithHTTPMethod:blockHTTPMethod];
                        originalRequestBuilder.endPoint = blockEndPoint;
                        originalRequestBuilder.header = blockOriginalHeader;
                        originalRequestBuilder.body = blockOriginalParameter;
                        originalRequestBuilder.requestType = blockRequestType;
                        originalRequestBuilder.responseType = blockResponseType;
                        originalRequestBuilder.isPublic = isPublic;
                        originalRequest = [originalRequestBuilder build];
                        handler = [thisMultiFactorAuthenticator getMultiFactorHandler:originalRequest response:response];
                        
                        if (handler != nil)
                        {
                            authenticator = thisMultiFactorAuthenticator;
                            break;
                        }
                    }
                }
                
                //
                //  If the MASMultiFactorHandler was returned (meaning one of MASMultiFactorAuthenticator declares that the class would be responsible for handling MFA),
                //  and implement MFA handling method, proceeds with MFA flow with found MFA class
                //
                if (handler != nil && authenticator != nil && [authenticator respondsToSelector:@selector(onMultiFactorAuthenticationRequest:response:handler:)])
                {
                    [handler setOriginalRequestCompletionBlock:blockCompletion];
                    [authenticator onMultiFactorAuthenticationRequest:originalRequest response:response handler:handler];
                }
                //
                //  Otherwise, proceeds as normal
                //
                else if (blockCompletion)
                {
                    //
                    // notify
                    //
                    blockCompletion(responseInfo, error);
                }
            }
            else if (blockCompletion) {
                
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
    
    if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].userInfoEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].tokenEndpointPath])
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
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].authorizationEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].clientInitializeEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint isEqualToString:[MASConfiguration currentConfiguration].userSessionLogoutEndpointPath])
    {
        isMAGEndpoint = YES;
    }
    else if ([endpoint hasPrefix:@"/auth/device/authorization/"])
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
                                  isPublic:(BOOL)isPublic
                                httpMethod:(NSString *)httpMethod
                                completion:(MASResponseInfoErrorBlock)completion
{
    
    //
    // Retry request
    //
    if ([httpMethod isEqualToString:@"DELETE"])
    {
        [self deleteFrom:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType isPublic:isPublic completion:completion];
    }
    else if ([httpMethod isEqualToString:@"GET"])
    {
        [self getFrom:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType isPublic:isPublic completion:completion];
    }
    else if ([httpMethod isEqualToString:@"PATCH"])
    {
        [self patchTo:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType isPublic:isPublic completion:completion];
    }
    else if ([httpMethod isEqualToString:@"POST"])
    {
        [self postTo:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType isPublic:isPublic completion:completion];
    }
    else if ([httpMethod isEqualToString:@"PUT"])
    {
        [self putTo:endPoint withParameters:originalParameter andHeaders:originalHeader requestType:requestType responseType:responseType isPublic:isPublic completion:completion];
    }
    
    return;
}


- (void)reconstructAuthValidationOperation
{
    if (_authValidationOperation != nil && _authValidationOperation.isExecuting)
    {
        MASAuthValidationOperation *authOperation = [MASAuthValidationOperation sharedOperation];
        
        for (NSOperation *pendingOperation in _sessionManager.operationQueue.operations)
        {
            if (pendingOperation && [pendingOperation.dependencies containsObject:_authValidationOperation])
            {
                [pendingOperation addDependency:authOperation];
            }
        }
        
        [_sessionManager.internalOperationQueue addOperation:authOperation];
        
        [_authValidationOperation cancel];
        _authValidationOperation = nil;
        _authValidationOperation = authOperation;
    }
}


# pragma mark - Network Monitoring

- (BOOL)networkIsReachable
{
    return _gatewayReachabilityManager ? _gatewayReachabilityManager.isReachable : NO;
}


- (NSString *)networkStatusAsString
{
    //
    // Detect status and respond appropriately
    //
    switch(_gatewayReachabilityManager.reachabilityStatus)
    {
            //
            // Not Reachable
            //
        case MASNetworkReachabilityStatusNotReachable:
        {
            return MASGatewayMonitoringStatusNotReachableValue;
        }
            
            //
            // Reachable Via WWAN
            //
        case MASNetworkReachabilityStatusReachableViaWWAN:
        {
            return MASGatewayMonitoringStatusReachableViaWWANValue;
        }
            
            //
            // Reachable Via WiFi
            //
        case MASNetworkReachabilityStatusReachableViaWiFi:
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
            isPublic:NO
     timeoutInterval:MASDefaultNetworkTimeoutConfiguration
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
    [self deleteFrom:endPoint
      withParameters:parameterInfo
          andHeaders:headerInfo
         requestType:requestType
        responseType:responseType
            isPublic:NO
     timeoutInterval:MASDefaultNetworkTimeoutConfiguration
          completion:completion];
}


- (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
          isPublic:(BOOL)isPublic
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
                isPublic:isPublic
         timeoutInterval:MASDefaultNetworkTimeoutConfiguration
              completion:completion];
}


- (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
          isPublic:(BOOL)isPublic
   timeoutInterval:(NSTimeInterval)timeoutInterval
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
                isPublic:isPublic
         timeoutInterval:timeoutInterval
              completion:completion];
}


- (void)httpDeleteFrom:(NSString *)endPoint
        withParameters:(NSDictionary *)parameterInfo
            andHeaders:(NSDictionary *)headerInfo
           requestType:(MASRequestResponseType)requestType
          responseType:(MASRequestResponseType)responseType
              isPublic:(BOOL)isPublic
       timeoutInterval:(NSTimeInterval)timeoutInterval
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
    
    [self httpRequest:@"DELETE" endPoint:endPoint parameters:parameterInfo headers:headerInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval completion:completion];
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
         isPublic:NO
  timeoutInterval:MASDefaultNetworkTimeoutConfiguration
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
    [self getFrom:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:requestType
     responseType:responseType
         isPublic:NO
  timeoutInterval:MASDefaultNetworkTimeoutConfiguration
       completion:completion];
}

- (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
     completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Just passthrough
    //
    [self getFrom:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:requestType
     responseType:responseType
         isPublic:isPublic
  timeoutInterval:MASDefaultNetworkTimeoutConfiguration
       completion:completion];
}

- (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
timeoutInterval:(NSTimeInterval)timeoutInterval
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
             isPublic:isPublic
      timeoutInterval:timeoutInterval
           completion:completion];
}


- (void)httpGetFrom:(NSString *)endPoint
     withParameters:(NSDictionary *)parameterInfo
         andHeaders:(NSDictionary *)headerInfo
        requestType:(MASRequestResponseType)requestType
       responseType:(MASRequestResponseType)responseType
           isPublic:(BOOL)isPublic
    timeoutInterval:(NSTimeInterval)timeoutInterval
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
    
    [self httpRequest:@"GET" endPoint:endPoint parameters:parameterInfo headers:headerInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval completion:completion];
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
         isPublic:NO
  timeoutInterval:MASDefaultNetworkTimeoutConfiguration
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
    [self patchTo:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:requestType
     responseType:responseType
         isPublic:NO
  timeoutInterval:MASDefaultNetworkTimeoutConfiguration
       completion:completion];
}


- (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
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
             isPublic:isPublic
      timeoutInterval:MASDefaultNetworkTimeoutConfiguration
           completion:completion];
}

- (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
timeoutInterval:(NSTimeInterval)timeoutInterval
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
             isPublic:isPublic
      timeoutInterval:timeoutInterval
           completion:completion];
}


- (void)httpPatchTo:(NSString *)endPoint
     withParameters:(NSDictionary *)parameterInfo
         andHeaders:(NSDictionary *)headerInfo
        requestType:(MASRequestResponseType)requestType
       responseType:(MASRequestResponseType)responseType
           isPublic:(BOOL)isPublic
    timeoutInterval:(NSTimeInterval)timeoutInterval
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
    
    [self httpRequest:@"PATCH" endPoint:endPoint parameters:parameterInfo headers:headerInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval completion:completion];
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
        isPublic:NO
 timeoutInterval:MASDefaultNetworkTimeoutConfiguration
      completion:completion];
}


- (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
    completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Just passthrough
    //
    [self postTo:endPoint
  withParameters:parameterInfo
      andHeaders:headerInfo
     requestType:requestType
    responseType:responseType
        isPublic:NO
 timeoutInterval:MASDefaultNetworkTimeoutConfiguration
      completion:completion];
}


- (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
      isPublic:(BOOL)isPublic
    completion:(MASResponseInfoErrorBlock)completion
{
    //DLog(@"called");
    //
    // Just passthrough
    //
    [self postTo:endPoint
  withParameters:parameterInfo
      andHeaders:headerInfo
     requestType:requestType
    responseType:responseType
        isPublic:isPublic
 timeoutInterval:MASDefaultNetworkTimeoutConfiguration
      completion:completion];
}

- (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
      isPublic:(BOOL)isPublic
timeoutInterval:(NSTimeInterval)timeoutInterval
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
            isPublic:isPublic
     timeoutInterval:timeoutInterval
          completion:completion];
}


- (void)httpPostTo:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
          isPublic:(BOOL)isPublic
   timeoutInterval:(NSTimeInterval)timeoutInterval
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
    
    [self httpRequest:@"POST" endPoint:endPoint parameters:parameterInfo headers:headerInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval completion:completion];
}

- (void)httpPostTo:(MASRequest*)request taskBlock:(MASDataTaskBlock)taskBlock completion:(MASResponseInfoErrorBlock)completion
{
    //
    //  endPoint cannot be nil
    //
    if (!request.endPoint)
    {
        //
        // Notify
        //
        if(completion) completion(nil, [NSError errorInvalidEndpoint]);
        
        return;
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
    NSInteger responseType;
    if ([endPoint  isEqual: @"/connect/device/renew"]) {
        responseType = MASRequestResponseTypeTextPlain;
    } else {
        responseType = MASRequestResponseTypeJson;
    }
    [self putTo:endPoint
 withParameters:parameterInfo
     andHeaders:headerInfo
    requestType:MASRequestResponseTypeJson
   responseType:responseType
       isPublic:NO
timeoutInterval:MASDefaultNetworkTimeoutConfiguration
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
    [self putTo:endPoint
 withParameters:parameterInfo
     andHeaders:headerInfo
    requestType:requestType
   responseType:responseType
       isPublic:NO
timeoutInterval:MASDefaultNetworkTimeoutConfiguration
     completion:completion];
}

- (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
  requestType:(MASRequestResponseType)requestType
 responseType:(MASRequestResponseType)responseType
     isPublic:(BOOL)isPublic
   completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Just passthrough
    //
    [self putTo:endPoint
 withParameters:parameterInfo
     andHeaders:headerInfo
    requestType:requestType
   responseType:responseType
       isPublic:isPublic
timeoutInterval:MASDefaultNetworkTimeoutConfiguration
     completion:completion];
}

- (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
  requestType:(MASRequestResponseType)requestType
 responseType:(MASRequestResponseType)responseType
     isPublic:(BOOL)isPublic
timeoutInterval:(NSTimeInterval)timeoutInterval
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
           isPublic:isPublic
    timeoutInterval:timeoutInterval
         completion:completion];
}


- (void)httpPutTo:(NSString *)endPoint
   withParameters:(NSDictionary *)parameterInfo
       andHeaders:(NSDictionary *)headerInfo
      requestType:(MASRequestResponseType)requestType
     responseType:(MASRequestResponseType)responseType
         isPublic:(BOOL)isPublic
  timeoutInterval:(NSTimeInterval)timeoutInterval
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
    
    [self httpRequest:@"PUT" endPoint:endPoint parameters:parameterInfo headers:headerInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval completion:completion];
}


- (void)postMultiPartForm:(NSString*)endPoint withParameters:(NSDictionary *)parameterInfo andHeaders:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic timeoutInterval:(NSTimeInterval)timeoutInterval constructingBodyBlock:(nonnull MASMultiPartFormDataBlock)formDataBlock progress:(MASFileRequestProgressBlock)progress taskBlock:(MASDataTaskBlock)taskBlock completion:(MASResponseObjectErrorBlock)completion
{
    //
    //  endPoint cannot be nil
    //
    if (!endPoint)
    {
        //
        // Notify
        //
        if(completion) completion(nil, nil,[NSError errorInvalidEndpoint]);
        
        return;
    }
    
    [self httpFileUploadRequest:endPoint parameters:parameterInfo headers:headerInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval constructingBodyBlock:formDataBlock progress:progress taskBlock:taskBlock completion:completion];
}


- (void)httpFileUploadRequest:(NSString *)endPoint parameters:(NSDictionary *)parameterInfo headers:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic timeoutInterval:(NSTimeInterval)timeoutInterval constructingBodyBlock:(nonnull MASMultiPartFormDataBlock)formDataBlock progress:(MASFileRequestProgressBlock)progress taskBlock:(MASDataTaskBlock)taskBlock completion:(MASResponseObjectErrorBlock)completion
{
    NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
    
    MASURLRequest *request = nil;
    
    //
    //  if location was successfully retrieved
    //
    if ([MASLocationService sharedService].lastKnownLocation != nil)
    {
        mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [[MASLocationService sharedService].lastKnownLocation locationAsGeoCoordinates];
    }
    
    request = [MASPostFormURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval constructingBodyBlock:formDataBlock];
    
    //
    //  Construct MASSessionDataTaskOperation with request, and completion block to handle any responsive re-authentication or re-registration.
    //
    if(self.httpRedirectionBlock)
    {
        [_sessionManager setSessionDidReceiveHTTPRedirectBlock:self.httpRedirectionBlock];
    }
    
    MASSessionDataTaskOperation *operation = [self.sessionManager fileUploadOperation:request progress:progress completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint parameters:parameterInfo headers:headerInfo httpMethod:request.HTTPMethod requestType:requestType responseType:responseType isPublic:isPublic completionBlock:^(NSDictionary<NSString *,id> * _Nullable responseInfo, NSError * _Nullable error) {
        if (completion)
        {
            completion([responseInfo objectForKey:MASNSHTTPURLResponseObjectKey], responseInfo[MASResponseInfoBodyInfoKey], error);
        }
    }]];
    
    MASDataTask* newDataTask = [[MASDataTask alloc] initWithTask:operation];
    [self cacheDataTask:newDataTask];
    
    
    if (![self isMAGEndpoint:endPoint])
    {
        //
        //  if the request is being made to system endpoint, and is not a public request which requires user credentials (tokens)
        //  then, add dependency on shared validation operation which will validate current session
        //  sharedOperation will only exist one at any given time as long as sharedOperation is being executed
        //
        if (!isPublic)
        {
            //
            //  add dependency
            //
            [operation addDependency:self.sharedOperation];
            
            //
            //  to make sure SDK to not enqueue sharedOperation that is already enqueue and being executed
            //
            if (!self.sharedOperation.isFinished && !self.sharedOperation.isExecuting && ![_sessionManager.internalOperationQueue.operations containsObject:self.sharedOperation])
            {
                //
                //  add sharedOperation into internal operation queue
                //
                [_sessionManager.internalOperationQueue addOperation:self.sharedOperation];
            }
        }
        
        //
        //  add current request into normal operation queue
        //
        [_sessionManager.operationQueue addOperation:operation];
    }
    else {
        //
        //  if the request is being made to any one of system endpoints (registration, and/or authentication), then, add the operation into internal operation queue
        //
        [_sessionManager.internalOperationQueue addOperation:operation];
    }
    
    if(taskBlock){
        taskBlock(newDataTask);
    }
}



- (void)httpRequest:(NSString *)httpMethod endPoint:(NSString *)endPoint parameters:(NSDictionary *)parameterInfo headers:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic
    timeoutInterval:(NSTimeInterval)timeoutInterval completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Update the header
    //
    NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
    
    MASURLRequest *request = nil;
    
    //
    //  if location was successfully retrieved
    //
    if ([MASLocationService sharedService].lastKnownLocation != nil)
    {
        mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [[MASLocationService sharedService].lastKnownLocation locationAsGeoCoordinates];
    }
    
    //
    //  Construct MASURLRequest object per HTTP method
    //
    if ([httpMethod isEqualToString:@"DELETE"])
    {
        request = [MASDeleteURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"GET"])
    {
        request = [MASGetURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"PATCH"])
    {
        request = [MASPatchURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"POST"])
    {
        request = [MASPostURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"PUT"])
    {
        request = [MASPutURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    
    //
    //  Construct MASSessionDataTaskOperation with request, and completion block to handle any responsive re-authentication or re-registration.
    //
    if(self.httpRedirectionBlock)
    {
        [_sessionManager setSessionDidReceiveHTTPRedirectBlock:self.httpRedirectionBlock];
    }
    
    MASSessionDataTaskOperation *operation = [_sessionManager dataOperationWithRequest:request
                                                                     completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:endPoint
                                                                                                                             parameters:parameterInfo
                                                                                                                                headers:headerInfo
                                                                                                                             httpMethod:request.HTTPMethod
                                                                                                                            requestType:requestType
                                                                                                                           responseType:responseType
                                                                                                                               isPublic:isPublic
                                                                                                                        completionBlock:completion]];
    
    
    if (![self isMAGEndpoint:endPoint])
    {
        //
        //  if the request is being made to system endpoint, and is not a public request which requires user credentials (tokens)
        //  then, add dependency on shared validation operation which will validate current session
        //  sharedOperation will only exist one at any given time as long as sharedOperation is being executed
        //
        if (!isPublic)
        {
            //
            //  add dependency
            //
            [operation addDependency:self.sharedOperation];
            
            //
            //  to make sure SDK to not enqueue sharedOperation that is already enqueue and being executed
            //
            if (!self.sharedOperation.isFinished && !self.sharedOperation.isExecuting && ![_sessionManager.internalOperationQueue.operations containsObject:self.sharedOperation])
            {
                //
                //  add sharedOperation into internal operation queue
                //
                [_sessionManager.internalOperationQueue addOperation:self.sharedOperation];
            }
        }
        
        //
        //  add current request into normal operation queue
        //
        [_sessionManager.operationQueue addOperation:operation];
    }
    else {
        //
        //  if the request is being made to any one of system endpoints (registration, and/or authentication), then, add the operation into internal operation queue
        //
        [_sessionManager.internalOperationQueue addOperation:operation];
    }
}


- (void)httpRequestWithCancel:(MASRequest*)request taskBlock:(MASDataTaskBlock)taskBlock completion:(MASResponseInfoErrorBlock)completion
{
    NSMutableDictionary *mutableHeaderInfo;
    //
    // Update the header
    //
    if(request.header){
        mutableHeaderInfo = [request.header mutableCopy];
    }
    else{
        mutableHeaderInfo = [NSMutableDictionary mutableCopy];
    }
    
    
    MASURLRequest* urlRequest = [self getURLRequest:request.httpMethod endPoint:request.endPoint parameters:request.body headers:[NSDictionary dictionary] requestType:request.requestType responseType:request.responseType isPublic:request.isPublic timeoutInterval:request.timeoutInterval];
    
    //
    //  if location was successfully retrieved
    //
    if ([MASLocationService sharedService].lastKnownLocation != nil)
    {
        mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [[MASLocationService sharedService].lastKnownLocation locationAsGeoCoordinates];
    }
    
    if(self.httpRedirectionBlock)
    {
        [_sessionManager setSessionDidReceiveHTTPRedirectBlock:self.httpRedirectionBlock];
    }
    
    MASSessionDataTaskOperation *operation = [_sessionManager dataOperationWithRequest:urlRequest
                                                                     completionHandler:[self sessionDataTaskCompletionBlockWithEndPoint:request.endPoint
                                                                                                                             parameters:request.body
                                                                                                                                headers:request.header
                                                                                                                             httpMethod:urlRequest.HTTPMethod
                                                                                                                            requestType:request.requestType
                                                                                                                           responseType:request.responseType
                                                                                                                               isPublic:request.isPublic                                                                                                                        completionBlock:completion]];
    
    
    MASDataTask* newDataTask = [[MASDataTask alloc] initWithTask:operation];
    DLog(@"MASNetworkingService : created Task with ID %@",newDataTask.taskID);
    [self cacheDataTask:newDataTask];
    
    
    
    if (![self isMAGEndpoint:request.endPoint])
    {
        //
        //  if the request is being made to system endpoint, and is not a public request which requires user credentials (tokens)
        //  then, add dependency on shared validation operation which will validate current session
        //  sharedOperation will only exist one at any given time as long as sharedOperation is being executed
        //
        if (!request.isPublic)
        {
            //
            //  add dependency
            //
            [operation addDependency:self.sharedOperation];
            
            //
            //  to make sure SDK to not enqueue sharedOperation that is already enqueue and being executed
            //
            if (!self.sharedOperation.isFinished && !self.sharedOperation.isExecuting && ![_sessionManager.internalOperationQueue.operations containsObject:self.sharedOperation])
            {
                //
                //  add sharedOperation into internal operation queue
                //
                [_sessionManager.internalOperationQueue addOperation:self.sharedOperation];
            }
        }
        
        //
        //  add current request into normal operation queue
        //
        [_sessionManager.operationQueue addOperation:operation];
    }
    else {
        //
        //  if the request is being made to any one of system endpoints (registration, and/or authentication), then, add the operation into internal operation queue
        //
        [_sessionManager.internalOperationQueue addOperation:operation];
    }
    
    if(taskBlock){
        taskBlock(newDataTask);
    }
    
}


- (void)cacheDataTask:(MASDataTask*)dataTask
{
    //[self cleanUpFinishedTasks];
    if(dataTask.taskID){
        DLog(@"MASNetworkingService : Added Task with ID %@ to the cache",dataTask.taskID);
        [self.tasks setObject:dataTask forKey:dataTask.taskID];
    }
}

- (void)cleanUpFinishedTasks
{
    NSLog(@"cleanUpFinishedTasks : cleaning up tasks");
    NSMutableArray* keysToRemove = [[NSMutableArray alloc] init];
    for (NSString* key in self.tasks){
        if([[self.tasks objectForKey:key] isFinished] || [[self.tasks objectForKey:key] isCancelled]){
            [keysToRemove addObject:key];
            //[self.tasks removeObjectForKey:key];
        }
    }
    [self.tasks removeObjectsForKeys:keysToRemove];
    NSLog(@"cleanUpFinishedTasks : finished cleaning up");
}

- (BOOL)cancelRequest:(MASDataTask*)task error:(NSError**)error;
{
    NSString* taskID = task.taskID;
    if(self.tasks && [self.tasks objectForKey:taskID]){
        MASDataTask* taskToBeCancelled = [self.tasks objectForKey:taskID];
        BOOL isTaskCancelled = [taskToBeCancelled cancelTask];
        [self.tasks removeObjectForKey:taskToBeCancelled.taskID];
        
        if (!isTaskCancelled){
            if (error != NULL){
                *error = [NSError errorDataTaskNotFound];
            }
            return NO;
        }
    }
    else {
        //task not found error
        if (error != NULL){
            *error = [NSError errorDataTaskNotFound];
        }
        return NO;
    }
    
    return YES;
    
}


- (void)cancelAllRequests
{
    NSLog(@"Cancel All Requests");
    [[_sessionManager operationQueue] cancelAllOperations];
    [[_sessionManager internalOperationQueue] cancelAllOperations];
}



- (MASURLRequest*)getURLRequest:(NSString *)httpMethod endPoint:(NSString *)endPoint parameters:(NSDictionary *)parameterInfo headers:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic
                timeoutInterval:(NSTimeInterval)timeoutInterval
{
    //
    // Update the header
    //
    NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
    
    MASURLRequest *request = nil;
    
    //
    //  if location was successfully retrieved
    //
    if ([MASLocationService sharedService].lastKnownLocation != nil)
    {
        mutableHeaderInfo[MASGeoLocationRequestResponseKey] = [[MASLocationService sharedService].lastKnownLocation locationAsGeoCoordinates];
    }
    
    //
    //  Construct MASURLRequest object per HTTP method
    //
    if ([httpMethod isEqualToString:@"DELETE"])
    {
        request = [MASDeleteURLRequest requestForEndpoint:request.endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"GET"])
    {
        request = [MASGetURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"PATCH"])
    {
        request = [MASPatchURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"POST"])
    {
        request = [MASPostURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    else if ([httpMethod isEqualToString:@"PUT"])
    {
        request = [MASPutURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:mutableHeaderInfo requestType:requestType responseType:responseType isPublic:isPublic timeoutInterval:timeoutInterval];
    }
    
    return request;
}

@end
