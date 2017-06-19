//
//  MAS.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MAS.h"

#import "MASAccessService.h"
#import "MASBluetoothService.h"
#import "MASConfigurationService.h"
#import "MASConstantsPrivate.h"
#import "MASClaims+MASPrivate.h"
#import "MASFileService.h"
#import "MASLocationService.h"
#import "MASModelService.h"
#import "MASOTPService.h"
#import "MASSecurityService.h"
#import "MASServiceRegistry.h"
#import "NSURL+MASPrivate.h"

#import "MASHTTPSessionManager.h"
#import "MASSecurityPolicy.h"
#import "MASGetURLRequest.h"
#import "NSData+MASPrivate.h"
#import "NSURL+MASPrivate.h"
#import "NSString+MASPrivate.h"

#import "L7SBrowserURLProtocol.h"

@implementation MAS


# pragma mark - Properties

+ (void)setConfigurationFileName:(NSString *)fileName
{
    [MASConfigurationService setConfigurationFileName:fileName];
}


+ (void)setGrantFlow:(MASGrantFlow)grantFlow
{
    [MASModelService setGrantFlow:grantFlow];
}


+ (MASGrantFlow)grantFlow
{
    return [MASModelService grantFlow];
}


+ (void)enablePKCE:(BOOL)enable
{
    [MASAccessService enablePKCE:enable];
}


+ (BOOL)isPKCEEnabled
{
    return [MASAccessService isPKCEEnabled];
}


+ (void)setUserAuthCredentials:(MASUserAuthCredentialsBlock _Nullable)userAuthCredentialsBlock
{
    [MASModelService setAuthCredentialsBlock:userAuthCredentialsBlock];
}


+ (void)setUserLoginBlock:(MASUserLoginWithUserCredentialsBlock)login
{
    [MASModelService setUserLoginBlock:login];
}


+ (void)setOTPChannelSelectionBlock:(MASOTPChannelSelectionBlock)OTPChannelSelector
{
    [MASOTPService setOTPChannelSelectionBlock:OTPChannelSelector];
}


+ (void)setOTPCredentialsBlock:(MASOTPCredentialsBlock)oneTimePassword
{
    [MASOTPService setOTPCredentialsBlock:oneTimePassword];
}


+ (void)setGatewayMonitor:(MASGatewayMonitorStatusBlock)monitor
{
    [MASNetworkingService setGatewayMonitor:monitor];
}


+ (MASState)MASState
{
    //
    //  By default, SDK state is set to "not configured" which means no configuration found.
    //
    MASState currentState = MASStateNotConfigured;
    
    //
    //  If SDK is able to locate the configuration either from the local file system based on the default config file name, or
    //  in keychain storage, SDK is configured, but has not initialized yet.
    //
    if ([MASConfigurationService getDefaultConfigurationAsDictionary] || [MASConfiguration instanceFromStorage])
    {
        currentState = MASStateNotInitialized;
    }
    
    //
    //  If service registry state is match with one of the following, adhere the service registry state.
    //
    switch ([MASServiceRegistry sharedRegistry].state) {
        case MASRegistryStateWillStart:
        currentState = MASStateWillStart;
        break;
        
        case MASRegistryStateStarted:
        currentState = MASStateDidStart;
        break;
        
        case MASRegistryStateWillStop:
        currentState = MASStateWillStop;
        break;
        
        case MASRegistryStateStopped:
        currentState = MASStateDidStop;
        break;
            
        case MASRegistryStateShouldStop:
        currentState = MASStateIsBeingStopped;
        break;
        
        default:
        break;
    }
    
    return currentState;
}


#ifdef DEBUG

+ (void)setGatewayNetworkActivityLogging:(BOOL)enabled
{
    [MASNetworkingService setGatewayNetworkActivityLogging:enabled];
}

#endif


# pragma mark - Start & Stop

+ (void)start:(MASCompletionErrorBlock)completion
{
    //DLog(@"called");
    [NSURLProtocol registerClass:[L7SBrowserURLProtocol class]];
    
    //
    // Post the notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASWillStartNotification object:nil];
    
    
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    //
    // Start the services registry
    //
    MASServiceRegistry *registry = [MASServiceRegistry sharedRegistry];
    [registry startWithCompletion:^(BOOL completed, NSError *error) {
        
        //
        // If error stop here
        //
        if(error)
        {
            //
            // Notify
            //
            if(blockCompletion)
            {
                blockCompletion(NO, error);
            }
            return;
        }
        //
        //  If the device is registered, and id_token exists, which means MSSO can be used for this application
        //
        else if ([MASDevice currentDevice].isRegistered && [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeIdToken])
        {
            //
            //  Make sure to register the client (application)
            //
            [[MASModelService sharedService] registerApplication:^(BOOL completed, NSError *error) {
               
                //
                //  If the client registration was successful, perform id_token authentication
                //
                if (completed && !error)
                {
                    NSString *jwt = [MASAccessService sharedService].currentAccessObj.idToken;
                    NSString *tokenType = [MASAccessService sharedService].currentAccessObj.idTokenType;
                    
                    [MASUser loginWithIdToken:jwt tokenType:tokenType completion:^(BOOL completed, NSError * _Nullable error) {
                        
                        //
                        //  Regardless of result of the authentication, should post the successful result to SDK initialization completion block
                        //
                        
                        //
                        // Post the notification
                        //
                        [[NSNotificationCenter defaultCenter] postNotificationName:MASDidStartNotification object:nil];
                        
                        //
                        // Notify
                        //
                        if(blockCompletion){
                            blockCompletion(YES, nil);
                        }
                    }];
                }
                else {
                    //
                    //  Regardless of result of the client registration, should post the successful result to SDK initialization completion block
                    //
                    
                    //
                    // Post the notification
                    //
                    [[NSNotificationCenter defaultCenter] postNotificationName:MASDidStartNotification object:nil];
                    
                    //
                    // Notify
                    //
                    if(blockCompletion){
                        blockCompletion(YES, nil);
                    }
                }
            }];
        }
        else {
            //
            // Post the notification
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDidStartNotification object:nil];
            
            //
            // Notify
            //
            if(blockCompletion){
                blockCompletion(YES, nil);
            }
        }
    }];
}


+ (void)startWithDefaultConfiguration:(BOOL)shouldUseDefault completion:(MASCompletionErrorBlock)completion
{
    //
    // Only check the current and default configurations if we have to force to load the default one.
    //
    if (shouldUseDefault)
    {
        BOOL shouldBroadcastNotification = NO;
        BOOL shouldReloadConfiguration = YES;
        
        //
        // Retrieve the current configuration from keychain storage.
        //
        MASConfiguration *currentConfiguration = [MASConfiguration instanceFromStorage];
        
        //
        // Retrieve the default configuration from JSON file.
        //
        NSDictionary *defaultConfiguration = [MASConfigurationService getDefaultConfigurationAsDictionary];
        
        if (currentConfiguration)
        {
            //
            // Check if we have to reload the configuration.
            //
            shouldReloadConfiguration = ![currentConfiguration compareWithCurrentConfiguration:defaultConfiguration];
            
            if (shouldReloadConfiguration)
            {
                //
                // Change to new configuration, if we have to.
                //
                [MASConfigurationService setNewConfigurationObject:defaultConfiguration];
                
                //
                // Check if this is a server change.
                //
                shouldBroadcastNotification = [currentConfiguration detectServerChangeWithCurrentConfiguration:defaultConfiguration];
            }
        }
        
        if (shouldBroadcastNotification)
        {
            //
            // Broadcast the notification if SDK detects server change.
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASWillSwitchGatewayServerNotification object:nil];
        }
        
        __block MASCompletionErrorBlock blockCompletion = completion;
        __block BOOL blockShouldBroadcastNotification = shouldBroadcastNotification;
        __block BOOL blockShouldReloadConfiguration = shouldReloadConfiguration;
        
        //
        // If SDK hasn't started yet or did fully stop, just start the SDK.
        //
        if ([MAS MASState] == MASStateNotInitialized || [MAS MASState] == MASStateDidStop || !shouldReloadConfiguration)
        {
            [MAS start:^(BOOL completed, NSError *error) {
                
                if (completed && blockShouldBroadcastNotification)
                {
                    //
                    // Broadcast the notification if SDK detects server change.
                    //
                    [[NSNotificationCenter defaultCenter] postNotificationName:MASDidSwitchGatewayServerNotification object:nil];
                }
                
                if (blockCompletion)
                {
                    blockCompletion(completed, error);
                }
            }];
        }
        else {
            
            __block NSDictionary *blockJson = defaultConfiguration;
            
            [MAS stop:^(BOOL completed, NSError *error) {

                if (blockShouldReloadConfiguration)
                {
                    //
                    // Change to new configuration, if we have to.
                    //
                    [MASConfigurationService setNewConfigurationObject:blockJson];
                }
                
                //
                // If there is no error
                //
                if (completed && error == nil)
                {
                    [MAS start:^(BOOL completed, NSError *error) {
                        
                        if (completed && blockShouldBroadcastNotification)
                        {
                            //
                            // Broadcast the notification if SDK detects server change.
                            //
                            [[NSNotificationCenter defaultCenter] postNotificationName:MASDidSwitchGatewayServerNotification object:nil];
                        }
                        
                        if (blockCompletion)
                        {
                            blockCompletion(completed, error);
                        }
                    }];
                }
                //
                // If there is an error and completion block exists
                //
                else if(blockCompletion)
                {
                    blockCompletion(completed, error);
                }
            }];
        }
    }
    //
    // If the developer didn't force to use the default one, behave exactly same as [MAS start:].
    //
    else {
        
        [MAS start:completion];
    }
}


+ (void)startWithJSON:(NSDictionary *)jsonConfiguration completion:(MASCompletionErrorBlock)completion
{
    //
    // Return an error if JSON is nil
    //
    if (!jsonConfiguration)
    {
        completion(NO, [NSError errorInvalidNSDictionary]);
        
        return;
    }
    
    BOOL shouldReloadConfiguration = YES;
    BOOL shouldBroadcastNotification = NO;
    
    //
    // To ensure developer initialize SDK with this method where [MASConfiguration currentConfiguration] is not available,
    // retrieve the configuration from the keychain storage directly.
    //
    MASConfiguration *currentConfiguration = [MASConfiguration instanceFromStorage];
    
    if (currentConfiguration)
    {
        shouldReloadConfiguration = ![currentConfiguration compareWithCurrentConfiguration:jsonConfiguration];
        
        if (shouldReloadConfiguration)
        {
            shouldBroadcastNotification = [currentConfiguration detectServerChangeWithCurrentConfiguration:jsonConfiguration];
        }
    }
    
    if (shouldBroadcastNotification)
    {
        //
        // Broadcast the notification if SDK detects server change.
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MASWillSwitchGatewayServerNotification object:nil];
    }
    
    
    __block MASCompletionErrorBlock blockCompletion = completion;
    __block BOOL blockShouldBroadcastNotification = shouldBroadcastNotification;
    __block BOOL blockShouldReloadConfiguration = shouldReloadConfiguration;
    
    //
    // If SDK hasn't started yet or did fully stop, start the SDK.
    //
    if ([MAS MASState] == MASStateNotInitialized || [MAS MASState] == MASStateDidStop || !shouldReloadConfiguration)
    {
        if (jsonConfiguration)
        {
            //
            // Set JSON configuration object.
            //
            [MASConfigurationService setNewConfigurationObject:jsonConfiguration];
        }
        
        [MAS start:^(BOOL completed, NSError *error) {
            
            if (blockShouldBroadcastNotification)
            {
                //
                // Broadcast the notification if SDK detects server change.
                //
                [[NSNotificationCenter defaultCenter] postNotificationName:MASDidSwitchGatewayServerNotification object:nil];
            }
            
            if (blockCompletion)
            {
                blockCompletion(completed, error);
            }
        }];
    }
    //
    // If SDK is still running or not fully stop, trigger stop process and re-start the SDK once it's fully stopped.
    //
    else {
        
        __block NSDictionary *blockJson = jsonConfiguration;
        
        [MAS stop:^(BOOL completed, NSError *error) {
            
            if (blockShouldReloadConfiguration)
            {
                //
                // Set JSON configuration object.
                //
                [MASConfigurationService setNewConfigurationObject:blockJson];
            }
            
            //
            // If there is no error
            //
            if (completed && error == nil)
            {
                [MAS start:^(BOOL completed, NSError *error) {
                    
                    if (blockShouldBroadcastNotification)
                    {
                        //
                        // Broadcast the notification if SDK detects server change.
                        //
                        [[NSNotificationCenter defaultCenter] postNotificationName:MASDidSwitchGatewayServerNotification object:nil];
                    }
                    
                    if (blockCompletion)
                    {
                        blockCompletion(completed, error);
                    }
                }];
            }
            //
            // If there is an error and completion block exists
            //
            else if(blockCompletion)
            {
                blockCompletion(completed, error);
            }
        }];
    }
}


+ (void)startWithURL:(NSURL *)url completion:(MASCompletionErrorBlock)completion
{
    //
    // If URL is not specified, initialize SDK with the last active configuration
    //
    if (!url)
    {
        //
        //  If SDK was already initialized, stop SDK first.
        //
        if ([MAS MASState] == MASStateNotInitialized || [MAS MASState] == MASStateDidStop)
        {
            [MAS start:completion];
        }
        else {
            
            [MAS stop:^(BOOL completed, NSError * _Nullable error) {
               
                [MAS start:completion];
            }];
        }
    }
    //
    //  If URL is recognized as enrolment URL with http or https protocol, initialize SDK with given enrolment URL.
    //
    else if (url.host)
    {
        //
        //  Extract URL parameters from enrolment URL
        //
        NSMutableDictionary *urlParameters = [[url extractQueryParameters] mutableCopy];
        
        //
        //  If enrolment URL does not contain subjectKeyHash or client_id, SDK cannot proceed the enrollment process
        //
        if (![[urlParameters allKeys] containsObject:MASSubjectKeyHashRequestResponseKey])
        {
            //
            //
            //
            if (completion)
            {
                completion(NO, [NSError errorInvalidEnrollmentURL]);
            }
            
            return;
        }
        
        //
        //  Extract the subjectKeyHash value, and remove it from URL parameter
        //
        __block NSString *subjectKeyHash = [[urlParameters objectForKey:MASSubjectKeyHashRequestResponseKey] URLDecode];
        [urlParameters removeObjectForKey:MASSubjectKeyHashRequestResponseKey];
        
        //
        //  Constrcut baseURL with given scheme, host, and port
        //
        NSString *baseURL = [NSString stringWithFormat:@"%@://%@%@",url.scheme,url.host,url.port ? [NSString stringWithFormat:@":%@", url.port] : @""];

        //
        //  Construct an individual HTTPSessionManager as MASNetworkingService is not initialized at the moment, and it will be used for temporarily
        //  and define authentication challenge block for SSL pinning
        //
        __block MASHTTPSessionManager *sessionManager = [[MASHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        
        [sessionManager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {

            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            
            //
            //  enrolmentURL can only successfully pin SSL with subjectKeyHash, otherwise, the request will be cancelled
            //
            MASSecurityPolicy *masSecurityPolicy = [MASSecurityPolicy policyWithMASPinningMode:MASSSLPinningModePublicKeyHash];
            if ([masSecurityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust withPublicKeyHashes:@[subjectKeyHash] forDomain:challenge.protectionSpace.host])
            {
                disposition = NSURLSessionAuthChallengeUseCredential;
                *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            }
            
            return disposition;
        }];

        //
        //  Invoke enrolmentURL which will return entire JSON configuration file
        //
        [sessionManager GET:url.relativePath parameters:urlParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
            //
            //  If the JSON configuration is successfully retrieved, initialize SDK with JSON
            //
            NSDictionary *configurationObject = (NSDictionary *)responseObject;
            [MAS startWithJSON:configurationObject completion:completion];
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
            //
            //  If the request fails, parse the error object, and notify the block
            //
            if (completion)
            {
                completion(NO, [NSError errorFromApiResponseInfo:nil andError:error]);
            }
        }];
    }
    //
    //  If URL is not nil, and not recognized as valid http URL, it is recognized as local system file URL
    //
    else {
     
        //
        // Convert file URL into NSData
        //
        NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:[url path]];
        NSString *fileName = [[[url path] componentsSeparatedByString:@"/"] lastObject];
        NSDictionary *jsonConfiguration = nil;
        
        //
        // Convert NSData into NSDictionary of JSON configuration object
        //
        if (!jsonData)
        {
            if (completion)
            {
                completion(NO, [NSError errorConfigurationLoadingFailedFileNotFound:fileName]);
            }
            
            return;
        }
        else {
            
            NSError *error = nil;
            jsonConfiguration = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            //
            // If an error is encountered while parsing NSData into NSDictionary
            //
            if (error)
            {
                if (completion)
                {
                    completion(NO, [NSError errorConfigurationLoadingFailedJsonSerialization:fileName description:[error localizedDescription]]);
                }
                
                return;
            }
        }
        
        BOOL shouldReloadConfiguration = YES;
        BOOL shouldBroadcastNotification = NO;
        
        //
        // To ensure developer initialize SDK with this method where [MASConfiguration currentConfiguration] is not available,
        // retrieve the configuration from the keychain storage directly.
        //
        MASConfiguration *currentConfiguration = [MASConfiguration instanceFromStorage];
        
        if (currentConfiguration)
        {
            shouldReloadConfiguration = ![currentConfiguration compareWithCurrentConfiguration:jsonConfiguration];
            
            if (shouldReloadConfiguration)
            {
                shouldBroadcastNotification = [currentConfiguration detectServerChangeWithCurrentConfiguration:jsonConfiguration];
            }
        }
        
        if (shouldBroadcastNotification)
        {
            //
            // Broadcast the notification if SDK detects server change.
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASWillSwitchGatewayServerNotification object:nil];
        }
        
        
        __block MASCompletionErrorBlock blockCompletion = completion;
        __block BOOL blockShouldBroadcastNotification = shouldBroadcastNotification;
        __block BOOL blockShouldReloadConfiguration = shouldReloadConfiguration;
        
        //
        // If SDK hasn't started yet or did fully stop, start the SDK.
        //
        if ([MAS MASState] == MASStateNotInitialized || [MAS MASState] == MASStateDidStop || !shouldReloadConfiguration)
        {
            if (shouldReloadConfiguration || (!currentConfiguration && jsonConfiguration))
            {
                //
                // Set JSON configuration object.
                //
                [MASConfigurationService setNewConfigurationObject:jsonConfiguration];
            }
            
            [MAS start:^(BOOL completed, NSError *error) {
                
                if (blockShouldBroadcastNotification)
                {
                    //
                    // Broadcast the notification if SDK detects server change.
                    //
                    [[NSNotificationCenter defaultCenter] postNotificationName:MASDidSwitchGatewayServerNotification object:nil];
                }
                
                if (blockCompletion)
                {
                    blockCompletion(completed, error);
                }
            }];
        }
        //
        // If SDK is still running or not fully stop, trigger stop process and re-start the SDK once it's fully stopped.
        //
        else {
            
            __block NSDictionary *blockJsonConfiguration = jsonConfiguration;
            
            [MAS stop:^(BOOL completed, NSError *error) {
                
                if (blockShouldReloadConfiguration)
                {
                    //
                    // Set JSON configuration object.
                    //
                    [MASConfigurationService setNewConfigurationObject:blockJsonConfiguration];
                    
                }
                
                //
                // If there is no error
                //
                if (completed && error == nil)
                {
                    [MAS start:^(BOOL completed, NSError *error) {
                        
                        if (blockShouldBroadcastNotification)
                        {
                            //
                            // Broadcast the notification if SDK detects server change.
                            //
                            [[NSNotificationCenter defaultCenter] postNotificationName:MASDidSwitchGatewayServerNotification object:nil];
                        }
                        
                        if (blockCompletion)
                        {
                            blockCompletion(completed, error);
                        }
                    }];
                }
                //
                // If there is an error and completion block exists
                //
                else if(blockCompletion)
                {
                    blockCompletion(completed, error);
                }
            }];
        }
    }
}


+ (void)stop:(MASCompletionErrorBlock)completion
{
    //DLog(@"\n\ncalled\n\n");
    
    //
    // Post the notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASWillStopNotification object:nil];

    //
    // Stop the service registry
    //
    [[MASServiceRegistry sharedRegistry] stopWithCompletion:nil];

    //
    // Post the notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDidStopNotification object:nil];

    //
    // Notify
    //
    if(completion) completion(YES, nil);
}


# pragma mark - Gateway Monitoring

+ (BOOL)gatewayIsReachable
{
    return [[MASNetworkingService sharedService] networkIsReachable];
}


+ (NSString *)gatewayMonitoringStatusAsString
{
    MASNetworkingService *networkManager = [MASNetworkingService sharedService];
   
    return (networkManager ? [networkManager networkStatusAsString] : MASNotStartedYet);
}


# pragma mark - HTTP Requests

+ (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
        completion:(MASResponseInfoErrorBlock)completion
{
    [self deleteFrom:endPoint
      withParameters:parameterInfo
          andHeaders:headerInfo
         requestType:MASRequestResponseTypeJson
        responseType:MASRequestResponseTypeJson
            isPublic:NO
          completion:completion];
}


+ (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(MASResponseInfoErrorBlock)completion
{
    [self deleteFrom:endPoint
      withParameters:parameterInfo
          andHeaders:headerInfo
         requestType:requestType
        responseType:responseType
            isPublic:NO
          completion:completion];
}


+ (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
          isPublic:(BOOL)isPublic
        completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Check for endpoint
    //
    if (!endPoint)
    {
        if (completion)
        {
            completion(nil, [NSError errorInvalidEndpoint]);
            
            return;
        }
    }
    
    //
    // Check if MAS has been started.
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (completion)
        {
            completion(nil, [NSError errorMASIsNotStarted]);
            
            return;
        }
    }
 
    
    //
    // If the request is private API request, do the validation regardless of the server is primary gateway or not, and inject credentials as the request is defined as private
    //
    if (!isPublic)
    {
        __block MASResponseInfoErrorBlock blockCompletion = completion;
        
        //
        //  Validate if new scope has been requested in header
        //
        [MAS validateScopeForRequest:headerInfo completion:^(BOOL completed, NSError *error) {
            //
            // Retrieve a mutable version of the header info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableHeaderInfo = (!headerInfo ? [MASIMutableOrderedDictionary new] : [headerInfo mutableCopy]);
            
            // Client Authorization
            NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
            if(clientAuthorization) mutableHeaderInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
            
            //
            // Retrieve a mutable version of the parameter info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableParameterInfo = (!parameterInfo ? [MASIMutableOrderedDictionary new] : [parameterInfo mutableCopy]);
            
            // todo: add any parameter stuff necessary
            
            //DLog(@"\n\ncalled with endPoint: %@\n  parameters: %@\n\n  headers: %@\n\n", endPoint, mutableParameterInfo, mutableHeaderInfo);
            
            [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
                
                if (error == nil)
                {
                    //
                    // Pass through the call to the network manager
                    //
                    [[MASNetworkingService sharedService] deleteFrom:endPoint
                                                      withParameters:mutableParameterInfo
                                                          andHeaders:mutableHeaderInfo
                                                         requestType:requestType
                                                        responseType:responseType
                                                            isPublic:isPublic
                                                          completion:[self parseTargetAPIErrorForCompletionBlock:blockCompletion]];
                }
                else {
                    
                    if (blockCompletion)
                    {
                        blockCompletion(nil, error);
                    }
                }
            }];
        }];
    }
    else {
        
        [[MASNetworkingService sharedService] deleteFrom:endPoint
                                          withParameters:parameterInfo
                                              andHeaders:headerInfo
                                             requestType:requestType
                                            responseType:responseType
                                                isPublic:isPublic
                                              completion:completion];
    }
}


+ (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
     completion:(MASResponseInfoErrorBlock)completion
{
    [self getFrom:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:MASRequestResponseTypeJson
     responseType:MASRequestResponseTypeJson
         isPublic:NO
       completion:completion];
}


+ (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
     completion:(MASResponseInfoErrorBlock)completion
{
    [self getFrom:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:requestType
     responseType:responseType
         isPublic:NO
       completion:completion];
}


+ (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
     completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Check for endpoint
    //
    if (!endPoint)
    {
        if (completion)
        {
            completion(nil, [NSError errorInvalidEndpoint]);
            
            return;
        }
    }
    
    //
    // Check if MAS has been started.
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (completion)
        {
            completion(nil, [NSError errorMASIsNotStarted]);
            
            return;
        }
    }
    
    
    //
    // If the request is private API request, do the validation regardless of the server is primary gateway or not, and inject credentials as the request is defined as private
    //
    if (!isPublic)
    {
        __block MASResponseInfoErrorBlock blockCompletion = completion;
        
        //
        //  Validate if new scope has been requested in header
        //
        [MAS validateScopeForRequest:headerInfo completion:^(BOOL completed, NSError *error) {
            
            if (!completed || error)
            {
                //
                // Notify
                //
                if(completion) completion(nil, [NSError errorNetworkNotStarted]);
                
                return;
            }
            //
            // Retrieve a mutable version of the header info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableHeaderInfo = (!headerInfo ? [MASIMutableOrderedDictionary new] : [headerInfo mutableCopy]);
            
            //
            // Retrieve a mutable version of the parameter info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableParameterInfo = (!parameterInfo ? [MASIMutableOrderedDictionary new] : [parameterInfo mutableCopy]);
            
            // todo: add any parameter stuff necessary
            
            //DLog(@"\n\ncalled with endPoint: %@\n  parameters: %@\n\n  headers: %@\n\n", endPoint, mutableParameterInfo, mutableHeaderInfo);
            
            [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
                
                if (error == nil)
                {
                    //
                    // Pass through the call to the network manager
                    //
                    [[MASNetworkingService sharedService] getFrom:endPoint
                                                   withParameters:mutableParameterInfo
                                                       andHeaders:mutableHeaderInfo
                                                      requestType:requestType
                                                     responseType:responseType
                                                         isPublic:isPublic
                                                       completion:[self parseTargetAPIErrorForCompletionBlock:blockCompletion]];
                    
                }
                else {
                    
                    if (blockCompletion)
                    {
                        blockCompletion(nil, error);
                    }
                }
            }];
        }];
    }
    else {
        
        [[MASNetworkingService sharedService] getFrom:endPoint
                                       withParameters:parameterInfo
                                           andHeaders:headerInfo
                                          requestType:requestType
                                         responseType:responseType
                                             isPublic:isPublic
                                           completion:completion];
    }
}


+ (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
     completion:(MASResponseInfoErrorBlock)completion
{
    [self patchTo:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:MASRequestResponseTypeJson
     responseType:MASRequestResponseTypeJson
         isPublic:NO
       completion:completion];
}


+ (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
     completion:(MASResponseInfoErrorBlock)completion
{
    [self patchTo:endPoint
   withParameters:parameterInfo
       andHeaders:headerInfo
      requestType:requestType
     responseType:responseType
         isPublic:NO
       completion:completion];
}


+ (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
     completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Check for endpoint
    //
    if (!endPoint)
    {
        if (completion)
        {
            completion(nil, [NSError errorInvalidEndpoint]);
            
            return;
        }
    }
    
    //
    // Check if MAS has been started.
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (completion)
        {
            completion(nil, [NSError errorMASIsNotStarted]);
            
            return;
        }
    }
    
    
    //
    // If the request is private API request, do the validation regardless of the server is primary gateway or not, and inject credentials as the request is defined as private
    //
    if (!isPublic)
    {
        __block MASResponseInfoErrorBlock blockCompletion = completion;
        
        //
        //  Validate if new scope has been requested in header
        //
        [MAS validateScopeForRequest:headerInfo completion:^(BOOL completed, NSError *error) {
            //
            // Retrieve a mutable version of the header info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableHeaderInfo = (!headerInfo ? [MASIMutableOrderedDictionary new] : [headerInfo mutableCopy]);
            
            // Client Authorization
            NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
            if(clientAuthorization) mutableHeaderInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
            
            //
            // Retrieve a mutable version of the parameter info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableParameterInfo = (!parameterInfo ? [MASIMutableOrderedDictionary new] : [parameterInfo mutableCopy]);
            
            // todo: add any parameter stuff necessary
            
            //DLog(@"\n\ncalled with endPoint: %@\n  parameters: %@\n\n  headers: %@\n\n", endPoint, mutableParameterInfo, mutableHeaderInfo);
            
            [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
                
                if (error == nil)
                {
                    //
                    // Pass through the call to the network manager
                    //
                    [[MASNetworkingService sharedService] patchTo:endPoint
                                                   withParameters:mutableParameterInfo
                                                       andHeaders:mutableHeaderInfo
                                                      requestType:requestType
                                                     responseType:responseType
                                                         isPublic:isPublic
                                                       completion:[self parseTargetAPIErrorForCompletionBlock:blockCompletion]];
                    
                }
                else {
                    
                    if (blockCompletion)
                    {
                        blockCompletion(nil, error);
                    }
                }
            }];
        }];
    }
    else {
        
        [[MASNetworkingService sharedService] patchTo:endPoint
                                       withParameters:parameterInfo
                                           andHeaders:headerInfo
                                          requestType:requestType
                                         responseType:responseType
                                             isPublic:isPublic
                                           completion:completion];
    }
}


+ (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
    completion:(MASResponseInfoErrorBlock)completion
{
    [self postTo:endPoint
  withParameters:parameterInfo
      andHeaders:headerInfo
     requestType:MASRequestResponseTypeJson
    responseType:MASRequestResponseTypeJson
        isPublic:NO
      completion:completion];
}


+ (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
    completion:(MASResponseInfoErrorBlock)completion
{
    [self postTo:endPoint
  withParameters:parameterInfo
      andHeaders:headerInfo
     requestType:requestType
    responseType:responseType
        isPublic:NO
      completion:completion];
}


+ (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
      isPublic:(BOOL)isPublic
    completion:(MASResponseInfoErrorBlock)completion
{
    //
    // Check for endpoint
    //
    if (!endPoint)
    {
        if (completion)
        {
            completion(nil, [NSError errorInvalidEndpoint]);
            
            return;
        }
    }
    
    //
    // Check if MAS has been started.
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (completion)
        {
            completion(nil, [NSError errorMASIsNotStarted]);
            
            return;
        }
    }
    
    
    //
    // If the request is private API request, do the validation regardless of the server is primary gateway or not, and inject credentials as the request is defined as private
    //
    if (!isPublic)
    {
        __block MASResponseInfoErrorBlock blockCompletion = completion;
        
        //
        //  Validate if new scope has been requested in header
        //
        [MAS validateScopeForRequest:headerInfo completion:^(BOOL completed, NSError *error) {
            //
            // Retrieve a mutable version of the header info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableHeaderInfo = (!headerInfo ? [MASIMutableOrderedDictionary new] : [headerInfo mutableCopy]);
            
            // Client Authorization
            NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
            if(clientAuthorization) mutableHeaderInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
            
            //
            // Retrieve a mutable version of the parameter info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableParameterInfo = (!parameterInfo ? [MASIMutableOrderedDictionary new] : [parameterInfo mutableCopy]);
            
            // todo: add any parameter stuff necessary
            
            //DLog(@"\n\ncalled with endPoint: %@\n  parameters: %@\n\n  headers: %@\n\n", endPoint, mutableParameterInfo, mutableHeaderInfo);
            
            [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
                
                if (error == nil)
                {
                    //
                    // Pass through the call to the network manager
                    //
                    [[MASNetworkingService sharedService] postTo:endPoint
                                                  withParameters:mutableParameterInfo
                                                      andHeaders:mutableHeaderInfo
                                                     requestType:requestType
                                                    responseType:responseType
                                                        isPublic:isPublic
                                                      completion:[self parseTargetAPIErrorForCompletionBlock:completion]];
                    
                }
                else {
                    
                    if (blockCompletion)
                    {
                        blockCompletion(nil, error);
                    }
                }
            }];
        }];
    }
    else {
        
        [[MASNetworkingService sharedService] postTo:endPoint
                                      withParameters:parameterInfo
                                          andHeaders:headerInfo
                                         requestType:requestType
                                        responseType:responseType
                                            isPublic:isPublic
                                          completion:completion];
    }
}


+ (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
   completion:(MASResponseInfoErrorBlock)completion
{
    [self putTo:endPoint
 withParameters:parameterInfo
     andHeaders:headerInfo
    requestType:MASRequestResponseTypeJson
   responseType:MASRequestResponseTypeJson
       isPublic:NO
     completion:completion];
}


+ (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
  requestType:(MASRequestResponseType)requestType
 responseType:(MASRequestResponseType)responseType
   completion:(MASResponseInfoErrorBlock)completion
{
    [self putTo:endPoint
 withParameters:parameterInfo
     andHeaders:headerInfo
    requestType:requestType
   responseType:responseType
       isPublic:NO
     completion:completion];
}


+ (void)putTo:(nonnull NSString *)endPoint
withParameters:(nullable NSDictionary *)parameterInfo
   andHeaders:(nullable NSDictionary *)headerInfo
  requestType:(MASRequestResponseType)requestType
 responseType:(MASRequestResponseType)responseType
     isPublic:(BOOL)isPublic
   completion:(nullable MASResponseInfoErrorBlock)completion
{
    //
    // Check for endpoint
    //
    if (!endPoint)
    {
        if (completion)
        {
            completion(nil, [NSError errorInvalidEndpoint]);
            
            return;
        }
    }
    
    //
    // Check if MAS has been started.
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (completion)
        {
            completion(nil, [NSError errorMASIsNotStarted]);
            
            return;
        }
    }
    
    
    //
    // If the request is private API request, do the validation regardless of the server is primary gateway or not, and inject credentials as the request is defined as private
    //
    if (!isPublic)
    {
        __block MASResponseInfoErrorBlock blockCompletion = completion;
        
        //
        //  Validate if new scope has been requested in header
        //
        [MAS validateScopeForRequest:headerInfo completion:^(BOOL completed, NSError *error) {
            
            //
            // Retrieve a mutable version of the header info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableHeaderInfo = (!headerInfo ? [MASIMutableOrderedDictionary new] : [headerInfo mutableCopy]);
            
            // Client Authorization
            NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
            if(clientAuthorization) mutableHeaderInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
            
            //
            // Retrieve a mutable version of the parameter info, create a new one if nil
            //
            // We must guarantee standard security headers are added here
            //
            MASIMutableOrderedDictionary *mutableParameterInfo = (!parameterInfo ? [MASIMutableOrderedDictionary new] : [parameterInfo mutableCopy]);
            
            // todo: add any parameter stuff necessary
            
            //DLog(@"\n\ncalled with endPoint: %@\n  parameters: %@\n\n  headers: %@\n\n", endPoint, mutableParameterInfo, mutableHeaderInfo);
            
            [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
                
                if (error == nil)
                {
                    //
                    // Pass through the call to the network manager
                    //
                    [[MASNetworkingService sharedService] putTo:endPoint
                                                 withParameters:mutableParameterInfo
                                                     andHeaders:mutableHeaderInfo
                                                    requestType:requestType
                                                   responseType:responseType
                                                       isPublic:isPublic
                                                     completion:[self parseTargetAPIErrorForCompletionBlock:blockCompletion]];
                    
                }
                else {
                    
                    if (blockCompletion)
                    {
                        blockCompletion(nil, error);
                    }
                }
            }];
        }];
    }
    //
    // If the request is a public API request, or not made to the primary gateway, bypass the validation process
    //
    else {
        
        [[MASNetworkingService sharedService] putTo:endPoint
                                     withParameters:parameterInfo
                                         andHeaders:headerInfo
                                        requestType:requestType
                                       responseType:responseType
                                           isPublic:isPublic
                                         completion:completion];
    }
}


# pragma mark - Private


+ (MASResponseInfoErrorBlock)parseTargetAPIErrorForCompletionBlock:(MASResponseInfoErrorBlock)completionBlock
{
    MASResponseInfoErrorBlock errorParsingBlock = ^(NSDictionary *responseInfo, NSError *error){
        
        NSError *targetAPIError = nil;
        
        if (error)
        {
            targetAPIError = [NSError errorForFoundationWithResponseInfo:responseInfo error:error errorDomain:MASFoundationErrorDomainTargetAPI];
        }
        
        if(completionBlock) completionBlock(responseInfo, targetAPIError);
    };
    
    return errorParsingBlock;
}


+ (void)validateScopeForRequest:(NSDictionary *)mutableHeader completion:(MASCompletionErrorBlock)originalCompletion
{
    
    //
    //  If no header defined, skip the validation
    //
    if (mutableHeader == nil)
    {
        if(originalCompletion) originalCompletion(YES,nil);
        
        return;
    }
    
    //
    //  If header contains extra scope
    //
    if ([[mutableHeader allKeys] containsObject:MASScopeRequestResponseKey])
    {
        //
        //  Explode the scope into array
        //
        NSArray *requestingScopes = [[mutableHeader objectForKey:MASScopeRequestResponseKey] componentsSeparatedByString:@" "];
        
        BOOL requestingNewScope = NO;
        
        for (NSString *requestingScope in requestingScopes)
        {
            //
            // Check if the requestingScope is empty string or not
            //
            if (![[requestingScope stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
            {
                //
                //  Check if grantedScope for the access_token contains the requested scope
                //
                if (![[MASAccess currentAccess].scope containsObject:requestingScope])
                {
                    requestingNewScope = YES;
                }
            }
        }
        
        //
        //  If the granted scope does not contain the requested scope
        //
        if (requestingNewScope)
        {
            //
            //  Set requesting scope in MASAccess object
            //
            [MASAccess currentAccess].requestingScopeAsString = [mutableHeader objectForKey:MASScopeRequestResponseKey];
            
            //
            //  Invalidate current tokens (access_token, refresh_token)
            //
            [[MASAccess currentAccess] deleteForLogOff];
            
            //
            //  Validate the user's session for requesting new access_token with given scope
            //
            [[MASModelService sharedService] validateCurrentUserSession:originalCompletion];
        }
        
        //
        //  Else, process as it is
        //
        else
        {
            if(originalCompletion) originalCompletion(YES,nil);
        }
    }
    
    else
    {
        //
        //  If no extra scope was defined in header, process as it is
        //
        if(originalCompletion) originalCompletion(YES,nil);
    }
    
    return;
}


# pragma mark - JWT Signing

+ (NSString * _Nullable)signWithClaims:(MASClaims *_Nonnull)claims error:(NSError *__nullable __autoreleasing *__nullable)error
{
    //
    // Check if MAS has been started.
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (error)
        {
            *error = [NSError errorMASIsNotStarted];
        }
        
        return nil;
    }
    
    //
    //  Check device registration status
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        if (error)
        {
            *error = [NSError errorDeviceNotRegistered];
        }
        
        return nil;
    }
    
    //
    //  Retrieve private key from registered device's client certificate
    //
    SecKeyRef pemPrivateRef = [[MASAccessService sharedService] getAccessValueCryptoKeyWithType:MASAccessValueTypePrivateKey];
    NSData *privateKeyData = [NSData converKeyRefToNSData:pemPrivateRef];
 
    return [self signWithClaims:claims privateKey:privateKeyData error:error];
}


+ (NSString * _Nullable)signWithClaims:(MASClaims *_Nonnull)claims privateKey:(NSData *_Nonnull)privateKey error:(NSError *__nullable __autoreleasing *__nullable)error
{
    //
    // Check if MAS has been started.
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (error)
        {
            *error = [NSError errorMASIsNotStarted];
        }
        
        return nil;
    }
    
    //
    //  Check if the client registration status
    //
    if (![MASApplication currentApplication].isRegistered)
    {
        if (error)
        {
            *error = [NSError errorApplicationNotRegistered];
        }
        
        return nil;
    }
    
    //
    //  Check device registration status
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        if (error)
        {
            *error = [NSError errorDeviceNotRegistered];
        }
        
        return nil;
    }
    
    //
    //  Validate MASClaims object
    //
    if (claims == nil)
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeJWTInvalidClaims errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return nil;
    }
    
    return [claims buildWithPrivateKey:privateKey error:error];
}


#ifdef DEBUG

# pragma mark - Debug only

+ (void)currentStatusToConsole
{
    MASServiceRegistry *registry = [MASServiceRegistry sharedRegistry];
    MASConfigurationService *configurationService = [MASConfigurationService sharedService];
    MASBluetoothService *bluetoothService = [MASBluetoothService sharedService];
    MASFileService *fileService = [MASFileService sharedService];
    MASLocationService *locationService = [MASLocationService sharedService];
    MASModelService *modelService = [MASModelService sharedService];
    MASNetworkingService *networkingService = [MASNetworkingService sharedService];
    
    DLog(@"\n\n\n%@\n\n  ****************************** Services Summary ******************************\n\n\n"
         "  %@\n\n\n  %@\n\n\n  %@\n\n\n  %@\n\n\n  %@\n\n\n  %@\n\n\n  %@\n\n\n",
         (registry ? [registry debugDescription] : @"(Service Registry Not Initialized"),
         (configurationService ? [configurationService debugDescription] : @"(Configuration Service Not Initialized)\n\n"),
         (networkingService ? [networkingService debugDescription] : @"(Networking Service Not Initialized)\n\n"),
         (locationService ? [locationService debugDescription] : @"(Location Service Not Initialized)\n\n"),
         (bluetoothService ? [bluetoothService debugDescription] : @"(Bluetooth Service Not Initialized)\n\n"),
         (modelService ? [modelService debugDescription] : @"(Model Service Not Initialized)\n\n"),
         (fileService ? [fileService debugDescription] : @"(File Service Not Initialized)\n\n"),
         [[MASAccessService sharedService] debugSecuredDescription]);
}

#endif

@end
