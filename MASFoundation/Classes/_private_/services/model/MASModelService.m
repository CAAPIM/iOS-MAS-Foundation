//
//  MASModelService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASModelService.h"
#import "MASAccessService.h"
#import "MASConfigurationService.h"
#import "MASConstants.h"
#import "MASFileService.h"
#import "MASSecurityService.h"
#import "MASServiceRegistry.h"
#import "MASIKeyChainStore.h"
#import "MASDevice+MASPrivate.h"
#import "NSString+MASPrivate.h"
#import "NSData+MASPrivate.h"

#import "MASAuthCredentials+MASPrivate.h"
#import "MASAuthCredentialsClientCredentials.h"

static NSString *const MASEnterpriseAppsKey = @"enterprise-apps";
static NSString *const MASEnterpriseAppKey = @"app";



@interface MASModelService ()

@property (nonatomic, strong, readwrite) MASAuthenticationProviders *currentProviders;


@end


@implementation MASModelService

static MASGrantFlow _grantFlow_ = MASGrantFlowClientCredentials;
static MASUserAuthCredentialsBlock _userAuthCredentialsBlock_ = nil;
static BOOL _isBrowserBasedAuthentication_ = NO;
static MASBrowserBasedAuthenticationType _browserBasedAuthenticationType_ = MASBrowserBasedAuthenticationTypeSafari;

# pragma mark - Properties


+ (MASGrantFlow)grantFlow
{
    return _grantFlow_;
}


+ (void)setGrantFlow:(MASGrantFlow)grantFlow
{
    _grantFlow_ = grantFlow;
}


+ (void)setAuthCredentialsBlock:(MASUserAuthCredentialsBlock)authCredentialsBlock
{
    _userAuthCredentialsBlock_ = [authCredentialsBlock copy];
}


- (void)setUserObject:(MASUser *)user
{
    if (_currentUser)
    {
        _currentUser = nil;
    }
    
    _currentUser = user;
}


+ (void)setBrowserBasedAuthentication : (BOOL)browserBasedAuthentication
{
    _isBrowserBasedAuthentication_ = browserBasedAuthentication;
}


+ (BOOL)browserBasedAuthentication
{
    return _isBrowserBasedAuthentication_;
}


+ (void)setBrowserBasedAuthenticationType:(MASBrowserBasedAuthenticationType)browserBasedAuthenticationType
{
    _browserBasedAuthenticationType_ = browserBasedAuthenticationType;
}


+ (MASBrowserBasedAuthenticationType)browserBasedAuthenticationType
{
    return _browserBasedAuthenticationType_;
}


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[MASModelService alloc] initProtected];
    });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (void)load
{
    [MASService registerSubclass:[self class] serviceUUID:MASModelServiceUUID];
}


+ (NSString *)serviceUUID
{
    return MASModelServiceUUID;
}


- (void)serviceDidLoad
{
    
    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    //
    // Attempt to retrieve the currently archived MASApplication, if none found
    // then initialize with default configuration
    //
    _currentApplication = [MASApplication instanceFromStorage];
    
    if (!_currentApplication)
    {
        _currentApplication = [[MASApplication alloc] initWithConfiguration];
    }
    
    //
    // Attempt to retrieve the currently archived MASDevice, if none found
    // then initialize with default configuration
    //
    _currentDevice = [MASDevice instanceFromStorage];
    if (!_currentDevice)
    {
        _currentDevice = [[MASDevice alloc] initWithConfiguration];
    }
    
    //
    // Attempt to retrieve the currently archived MASUser, if any
    // currently authenticated.  If not, leave empty.
    //
    _currentUser = [MASUser instanceFromStorage];
    
    //
    // Attempt to retrieve the currently archived MASAuthenticationProviders, if any
    // were previously retrieved and archived.  If not, leave empty.
    //
    _currentProviders = [MASAuthenticationProviders instanceFromStorage];
    
    
    //
    // Attempt to retrieve the most recent client data from keychain
    //
    MASApplication *keychainApplication;
    
    NSData *data = [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] dataForKey:[MASApplication.class description]];
    
    if (data)
    {
        keychainApplication = (MASApplication *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    //
    // If the instanceFromStorage and the actual keychain data are different;
    // the msso master client id has recently changed, and credientials should now be reset.
    //
    if (![keychainApplication.identifier isEqualToString:_currentApplication.identifier])
    {
        [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyClientId];
        [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyClientSecret];
        [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyClientExpiration];
        
        [[MASModelService sharedService] clearCurrentUserForLogout];
    }
    
    [super serviceWillStart];
}


- (void)serviceDidReset
{
    //
    // If the current providers exists
    //
    if (self.currentProviders)
    {
        [self.currentProviders reset];
        _currentProviders = nil;
    }
    
    //
    // If the current user exists
    //
    if (self.currentUser)
    {
        [self.currentUser reset];
        _currentUser = nil;
    }
    
    //
    // If the current device exists
    //
    if (self.currentDevice)
    {
        [self.currentDevice reset];
        _currentDevice = nil;
    }
    
    //
    // If the current application exists
    //
    if (self.currentApplication)
    {
        [self.currentApplication reset];
        _currentApplication = nil;
    }
    
    [super serviceDidReset];
}


# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    current application: %@\n\n    current device: %@\n\n    current user: %@\n\n    current providers: %@",
        [super debugDescription],
        (self.currentApplication ? [self.currentApplication debugDescription] : @"none found"),
        (self.currentDevice ? [self.currentDevice debugDescription] : @"none founed"),
        (self.currentUser ? [self.currentUser debugDescription] : @"none found"),
        (self.currentProviders ? [self.currentProviders debugDescription] : @"none found")];
}


# pragma mark - Application

- (void)registerApplication:(MASCompletionErrorBlock)completion
{
    //
    // If attempting to register a second time while there is a current applicaton record
    // with valid credentials stop here
    //
    if (self.currentApplication && ![self.currentApplication isExpired])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        return;
    }
    
    // ClientId
    NSString *clientId = [[MASConfiguration currentConfiguration] defaultApplicationClientIdentifier];
    
    // ClientSecret
    NSString *clientSecret = [[MASConfiguration currentConfiguration] defaultApplicationClientSecret];
    
    //
    //  If the clientId and clientSecret are both in JSON configuration, it means that the application is configured to be non-dynamic client_id.
    //  In this case, use both client_id and client_secret from JSON configuration and set the expiration time to infinite.
    //
    if (clientId && clientId.length > 0 && clientSecret && clientSecret.length > 0 && ![clientId isEqualToString:clientSecret])
    {
        NSMutableDictionary *applicationInfo = [NSMutableDictionary dictionary];
        
        [applicationInfo setObject:clientId forKey:MASClientIdentifierRequestResponseKey];
        [applicationInfo setObject:clientSecret forKey:MASClientSecretRequestResponseKey];
        [applicationInfo setObject:[NSNumber numberWithInt:0] forKey:MASClientExpirationRequestResponseKey];
        
        //
        // Updated with latest application info
        //
        [self.currentApplication saveWithUpdatedInfo:@{MASResponseInfoBodyInfoKey : applicationInfo}];
        
        //
        // Post the notification
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MASApplicationDidRegisterNotification object:self];
        
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        return;
    }
    
    //
    // Post the notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASApplicationWillRegisterNotification object:self];
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].clientInitializeEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    // Client Authorization
    NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
    if (clientAuthorization)
    {
        headerInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
    }
    
    // DeviceId
    NSString *deviceId = [MASDevice deviceIdBase64Encoded];
    if (deviceId)
    {
        headerInfo[MASDeviceIdRequestResponseKey] = deviceId;
    }
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];

    if (clientId)
    {
        parameterInfo[MASClientKeyRequestResponseKey] = clientId;
    }
    
    // Nonce
    NSString *nonce = [NSString stringWithFormat:@"%d", (arc4random() % 10000)];
    if (nonce)
    {
        parameterInfo[MASNonceRequestResponseKey] = nonce;
    }
    
    //
    // Trigger the request
    //
    __block MASModelService *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] postTo:endPoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
                                     requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                    responseType:MASRequestResponseTypeJson
                                      completion:^(NSDictionary *responseInfo, NSError *error) {
                                          //
                                          // If error stop here
                                          //
                                          if (error)
                                          {
                                              //
                                              // Post the notification
                                              //
                                              [[NSNotificationCenter defaultCenter] postNotificationName:MASApplicationDidFailToRegisterNotification object:blockSelf];
                                              
                                              //
                                              // Notify
                                              //
                                              if (blockCompletion)
                                              {
                                                  blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                              }
                                              
                                              return;
                                          }
                                          
                                          //
                                          // Updated with latest application info
                                          //
                                          [blockSelf.currentApplication saveWithUpdatedInfo:responseInfo];
                                          
                                          //
                                          // Post the notification
                                          //
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MASApplicationDidRegisterNotification object:blockSelf];
                                          
                                          //
                                          // Notify
                                          //
                                          if (blockCompletion)
                                          {
                                              blockCompletion(YES, nil);
                                          }
                                      }];
}


- (void)retrieveAuthenticationProviders:(MASObjectResponseErrorBlock)completion
{
    
    //
    // If the user was already authenticated, we don't have to retrieve the authentication provider
    //
    if (([MASApplication currentApplication].isAuthenticated && [MASApplication currentApplication].authenticationStatus == MASAuthenticationStatusLoginWithUser) || [MASAccess currentAccess].isSessionLocked || _isBrowserBasedAuthentication_)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(nil, nil);
        }
        return;
    }
    
    //DLog(@"\n\nNO detected cached providers, retreiving from server\n\n");

    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].authorizationEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // ClientId
    parameterInfo[MASClientKeyRequestResponseKey] = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientId];
    
    // RedirectUri
    parameterInfo[MASRedirectUriRequestResponseKey] = [[MASApplication currentApplication].redirectUri absoluteString];
    
    // Scope
    NSString *scope = [MASApplication currentApplication].scopeAsString;
    
    //
    // Workaround - msso_register scope should NOT be used to retrieve authenticationProviders when it is going to be used to "authenticate"
    // msso_register scope should only contain for device registration with authorizationCode.
    // When the authroizationCode was granted with msso_register scope and used to retrieve the tokens, it will FAIL with unknown error from the server.
    //
    if (scope && self.currentDevice.isRegistered)
    {
        scope = [scope replaceStringWithRegexPattern:@"\\bmsso_register\\b" withString:@""];
    }
    
    //
    //  If sso is disabled, manually remove msso scope, as it will create id_token with msso scope
    //
    if (scope && ![MASConfiguration currentConfiguration].ssoEnabled)
    {
        scope = [scope replaceStringWithRegexPattern:@"\\bmsso\\b" withString:@""];
    }
    
    parameterInfo[MASScopeRequestResponseKey] = scope;
    
    // ResponseType
    parameterInfo[MASRequestResponseTypeRequestResponseKey] = @"code";
    
    // Display
    parameterInfo[MASDisplayRequestResponseKey] = @"social_login";
    
    // PKCE Support - generate code verifier
    [[MASAccessService sharedService].currentAccessObj generateCodeVerifier];
    
    // PKCE Support - generate state
    [[MASAccessService sharedService].currentAccessObj generatePKCEState];
    
    // Retrieve code verifier
    NSString *codeVerifier = [[MASAccessService sharedService].currentAccessObj retrieveCodeVerifier];
    
    // Retrieve state
    NSString *pkceState = [[MASAccessService sharedService].currentAccessObj retrievePKCEState];
    
    if (codeVerifier)
    {
        // SHA256 the code verifier and encode it with base64url
        NSString *codeChallenge = [NSString base64URLWithNSData:[codeVerifier sha256Data]];
        
        if (codeChallenge)
        {
            parameterInfo[MASPKCECodeChallengeRequestResponseKey] = codeChallenge;
            //
            // code_challenge_method should be S256 if the code challenge is hashed;
            //
            // Otherwise, make code_challenge = code_verifier, and send code_challenge_method as plan, MASPKCECodeChallengeMethodPlainKey
            //
            parameterInfo[MASPKCECodeChallengeMethodRequestResponseKey] = MASPKCECodeChallengeMethodSHA256Key;
            
            parameterInfo[MASPKCEStateRequestResponseKey] = pkceState;
        }
    }
    
    //
    // Trigger the request
    //
    // Note that security credentials are added automatically by this method
    //
    __block MASModelService *blockSelf = self;
    __block MASObjectResponseErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] getFrom:endPoint
                                   withParameters:parameterInfo
                                       andHeaders:headerInfo
                                      requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                     responseType:MASRequestResponseTypeJson
                                       completion:^(NSDictionary *responseInfo, NSError *error) {
                                           //
                                           // Detect if error, if so stop here
                                           //
                                           if(error)
                                           {
                                               //
                                               // Notify
                                               //
                                               if (blockCompletion)
                                               {
                                                   blockCompletion(nil, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                               }
                                               return;
                                           }
                                           
                                           //
                                           // Retrieve the body info
                                           //
                                           NSDictionary *bodyInfo = responseInfo[MASResponseInfoBodyInfoKey];
                                           
                                           if (bodyInfo)
                                           {
                                               //
                                               // Instantiate the new list of authentication providers
                                               //
                                               blockSelf.currentProviders = [[MASAuthenticationProviders alloc] initWithInfo:bodyInfo];
                                               
                                               //
                                               // Notify
                                               //
                                               if (blockCompletion)
                                               {
                                                   blockCompletion(blockSelf.currentProviders, nil);
                                               }
                                           }
                                           else {
                                               //
                                               // Notify
                                               //
                                               if (blockCompletion)
                                               {
                                                   blockCompletion(nil, nil);
                                               }
                                           }
                                       }];
}


- (void)retrieveAuthenticationProvidersIfNeeded:(MASObjectResponseErrorBlock)completion
{
    if (_grantFlow_ == MASGrantFlowPassword)
    {
        [self retrieveAuthenticationProviders:completion];
    }
    else {
        completion(nil, nil);
    }
}


- (void)retrieveEnterpriseApplications:(MASObjectsResponseErrorBlock)completion
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].enterpriseBrowserEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];

    //
    // Trigger the request
    //
    // Note that security credentials are added automatically by this method
    //
    __block MASObjectsResponseErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] getFrom:endPoint
                                   withParameters:nil
                                       andHeaders:headerInfo
                                       completion:^(NSDictionary *responseInfo, NSError *error) {
                                           //
                                           // Detect if error, if so stop here
                                           //
                                           if (error)
                                           {
                                               //
                                               // Notify
                                               //
                                               if (blockCompletion)
                                               {
                                                   blockCompletion(nil, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                               }
                                               return;
                                           }
                                           
                                           //
                                           // Retrieve the body info
                                           //
                                           NSDictionary *bodyInfo = responseInfo[MASResponseInfoBodyInfoKey];
                                           
                                           //
                                           // Retrieve the enterprise apps
                                           //
                                           NSArray *appsInfo = bodyInfo[MASEnterpriseAppsKey];
                                           
                                           NSMutableArray *applications = [NSMutableArray new];
                                           MASApplication *application;
                                           for (NSDictionary *appInfo in appsInfo)
                                           {
                                               //
                                               // Create a specific enterprise app and store it
                                               //
                                               application = [[MASApplication alloc] initWithEnterpriseInfo:appInfo[MASEnterpriseAppKey]];
                                               if (application)
                                               {
                                                   [applications addObject:application];
                                               }
                                           }
                                           
                                           //
                                           // Notify
                                           //
                                           if (blockCompletion)
                                           {
                                               blockCompletion(applications, nil);
                                           }
                                       }];
}


# pragma mark - Device

// This will only be accurate after the configuration has been loaded
+ (BOOL)isGrantFlowSupported:(MASGrantFlow)grantFlow
{
    //DLog(@"\n\ncalled with registration type: %@\n\n", [self registrationTypeToString:registrationType]);
    
    //
    // Detect type and respond appropriately
    //
    switch (grantFlow)
    {
        //
        // Client Credentials
        //
        case MASGrantFlowClientCredentials:
        {
            return ([[MASApplication currentApplication] isScopeTypeMssoClientRegisterSupported]);
        }
        
        //
        // User Credentials
        //
        case MASGrantFlowPassword:
        {
            return YES;
        }
        
        //
        // Default
        //
        default: return NO;
    }
}


+ (NSString *)grantFlowToString:(MASGrantFlow)grantFlow
{
    //
    // Detect the type and respond appropriately
    //
    switch (grantFlow)
    {
        //
        // Client Credentials Registration
        //
        case MASGrantFlowClientCredentials: return @"Client credentials registration";
        
        //
        // User Credentials Registration
        //
        case MASGrantFlowPassword: return @"User credentials registration";
        
        //
        // Default
        //
        default: return @"Unknown";
    }
}


- (void)deregisterCurrentDeviceWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Detect if there is a device registered, if not stop here
    //
    if (![self.currentDevice isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceNotRegistered]);
        }
        
        return;
    }
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceRemoveEndpointPath;
    
    //
    // No additional, custom headers or parameters to add here
    //
    
    //
    // Retrieve a mutable version of the header info, create a new one if nil
    //
    // We must guarantee standard security headers are added here
    //
    MASIMutableOrderedDictionary *mutableHeaderInfo = [MASIMutableOrderedDictionary new];
    
    //
    // Post the Mobile SDK will attempt to deregister device
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceWillDeregisterNotification object:self];
    
    __block MASModelService *blockSelf = self;
    
    //
    // Trigger the request
    //
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] deleteFrom:endPoint
                                      withParameters:nil
                                          andHeaders:mutableHeaderInfo
                                          completion:^(NSDictionary *responseInfo, NSError *error) {
            //
            // Detect if error, if so stop here
            //
            if (error)
            {
                //
                // Post the did fail to deregister in cloud notification
                //
                [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidFailToDeregisterNotification object:self];
                
                //
                // Notify
                //
                if (blockCompletion)
                {
                    blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                }
                return;
            }
            
            //
            // Clear currentUser object upon log-out
            //
            [blockSelf clearCurrentUserForLogout];
            
            //
            // Clear all currently registered device's information upon de-registration
            //
            [[MASDevice currentDevice] clearCurrentDeviceForDeregistration];
                                              
            //
            // Remove PKCE Code Verifier and state
            //
            [[MASAccessService sharedService].currentAccessObj deleteCodeVerifier];
            [[MASAccessService sharedService].currentAccessObj deletePKCEState];
            
            //
            // KeyChain
            //
            [[MASAccessService sharedService] clearLocal];
            [[MASAccessService sharedService] clearShared];
            
            //
            // re-establish URL session
            //
            [[MASNetworkingService sharedService] establishURLSession];
            
            //
            // Post the did deregister on device notification
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidDeregisterOnDeviceNotification object:self];
            
            //
            // Post the did deregister in cloud notification
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidDeregisterInCloudNotification object:self];
            
            //
            // Post the did deregister overall notification
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidDeregisterNotification object:self];
        
            //
            // Notify
            //
            if (blockCompletion)
            {
                blockCompletion(YES, nil);
            }
        }
    ];
}


- (void)registerDeviceWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Check if the client certificate is expired, if so, renew
    //
    if ([MASDevice currentDevice].isClientCertificateExpired && [MASDevice currentDevice].isRegistered)
    {
        [self renewClientCertificateWithCompletion:completion];
        
        return;
    }
    
    //
    // If already registered stop here
    //
    if ([[MASDevice currentDevice] isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        return;
    }
    
    //
    // Check if the current MASGrantFlow is NOT supported by the registered Scope for the
    // application record
    //
    if (![MASModelService isGrantFlowSupported:_grantFlow_])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceRegistrationAttemptedWithUnregisteredScope]);
        }
        return;
    }
    
    switch (_grantFlow_) {
        case MASGrantFlowPassword:
        {
            __block MASModelService *blockSelf = self;
            __block MASCompletionErrorBlock blockCompletion = completion;
            
            __block MASAuthCredentialsBlock authCredentialsBlock = ^(MASAuthCredentials *authCredentials, BOOL cancel, MASCompletionErrorBlock authCompletion)
            {
                //
                //  When the authentication process was explicitly cancelled by user
                //
                if (cancel)
                {
                    if (blockCompletion)
                    {
                        blockCompletion(NO, [NSError errorLoginProcessCancelled]);
                    }
                    
                    if (authCompletion)
                    {
                        authCompletion(NO, [NSError errorLoginProcessCancelled]);
                    }
                    
                    return;
                }
                
                __block MASCompletionErrorBlock blockAuthCompletion = authCompletion;
                __block MASAuthCredentials *blockAuthCredentials = authCredentials;
                
                //
                //  Perform device registration with auth credentials
                //
                [blockSelf registerDeviceWithAuthCredentials:authCredentials completion:^(BOOL completed, NSError * _Nullable error) {
                    
                    if (error)
                    {
                        if (blockAuthCompletion)
                        {
                            blockAuthCompletion(NO, error);
                        }
                        
                        return;
                    }
                    
                    if (blockAuthCredentials.isReusable)
                    {
                        [blockSelf loginWithAuthCredentials:blockAuthCredentials completion:^(BOOL completed, NSError * _Nullable error) {
                           
                            //
                            //  Clear credentials after first attempt if it is not reuseable
                            //
                            [blockAuthCredentials clearCredentials];
                            
                            if (error)
                            {
                                if (blockAuthCompletion)
                                {
                                    blockAuthCompletion(NO, error);
                                }
                                
                                return;
                            }
                            
                            if (blockCompletion)
                            {
                                blockCompletion(YES, nil);
                            }
                            
                            if (blockAuthCompletion)
                            {
                                blockAuthCompletion(YES, nil);
                            }
                        }];
                    }
                    else {
                        
                        //
                        //  Clear credentials after first attempt if it is not reuseable
                        //
                        [blockAuthCredentials clearCredentials];
                        
                        if (blockCompletion)
                        {
                            blockCompletion(YES, nil);
                        }
                        
                        if (blockAuthCompletion)
                        {
                            blockAuthCompletion(YES, nil);
                        }
                    }
                }];
            };
            
            DLog(@"\n\n\n********************************************************\n\n"
                 "Waiting for credentials response to continue registration"
                 @"\n\n********************************************************\n\n\n");
            
            //
            // If the UI handling framework or browser based login is present and will handle this stop here
            //
            MASServiceRegistry *serviceRegistry = [MASServiceRegistry sharedRegistry];
            
            if ([serviceRegistry browserBasedLoginWillHandleAuthentication:authCredentialsBlock])
            {
                return;
            }
            
            if ([serviceRegistry uiServiceWillHandleWithAuthCredentialsBlock:authCredentialsBlock])
            {
                return;
            }
            
            
            //
            // Else notify block if available
            //
            if(_userAuthCredentialsBlock_)
            {
                //
                // Do this is the main queue since the reciever is almost certainly a UI component.
                // Lets do this for them and not make them figure it out
                //
                dispatch_async(dispatch_get_main_queue(),^
                               {
                                   _userAuthCredentialsBlock_(authCredentialsBlock);
                               });
            }
            //
            //
            //  Technically above portion of logic is deprecated as of MAS 1.5/MAG 4.1
            //
            //
            else {
                
                //
                // If the device registration block is not defined, return an error
                //
                if (completion)
                {
                    completion(NO, [NSError errorInvalidUserLoginBlock]);
                }
            }
            
            break;
        }
        case MASGrantFlowClientCredentials:
        {
            __block MASCompletionErrorBlock blockCompletion = completion;
            MASAuthCredentialsClientCredentials *clientAuthCredentials = [MASAuthCredentialsClientCredentials initClientCredentials];
            [self registerDeviceWithAuthCredentials:clientAuthCredentials completion:^(BOOL completed, NSError * _Nullable error) {
                
                //
                // Error
                //
                if (error)
                {
                    //
                    // Notify
                    //
                    if (blockCompletion)
                    {
                        blockCompletion(NO, error);
                    }
                    
                    return;
                }
                
                //
                // Notify
                //
                if (blockCompletion)
                {
                    blockCompletion(YES, nil);
                }
            }];
        
            break;
        }
        case MASGrantFlowCount:
        case MASGrantFlowUnknown:
        default:
        {
            DLog(@"\n\nError detecting unknown registration type: %@\n\n",
                 [MASModelService grantFlowToString:_grantFlow_]);
            //
            // Notify
            //
            if (completion)
            {
                completion(NO, [NSError errorFlowTypeUnsupported]);
            }
            
            break;
        }
    }
}


- (void)renewClientCertificateWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceRenewEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    // Certificate Format
    headerInfo[MASCertFormatRequestResponseKey] = @"pem";
    
    //
    // Post the will renew client certificate notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceWillRenewClientCerficiateNotification object:self];
    
    //
    // Trigger the request
    //
    __block MASModelService *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] putTo:endPoint
                                 withParameters:nil
                                     andHeaders:headerInfo
                                     completion:^(NSDictionary *responseInfo, NSError *error) {
                                        
                                         //
                                         // Detect if error, if so stop here
                                         //
                                         if (error)
                                         {
                                             //
                                             // Parse the error object
                                             //
                                             NSError *requestError = [NSError errorFromApiResponseInfo:responseInfo andError:error];
                                             
                                             //
                                             // If the error is coming from the server, and not from local, clear all credentials from keychain storage
                                             //
                                             if (![requestError.domain isEqualToString:MASFoundationErrorDomainLocal])
                                             {
                                                 
                                                 //
                                                 // Remove all files and keychain data for the registration and authentication records
                                                 //
                                                 [[MASAccessService sharedService] clearLocal];
                                                 [[MASAccessService sharedService] clearShared];
                                                 
                                                 //
                                                 // Trigger validation process to re-register the device for currently set flow
                                                 //
                                                 [blockSelf validateCurrentUserSession:blockCompletion];
                                             }
                                             //
                                             // If the error is local domain, return the error
                                             //
                                             else if (blockCompletion)
                                             {
                                                 blockCompletion(NO, requestError);
                                             }
                                             
                                             //
                                             // Post the did fail to renew client certificate notification
                                             //
                                             [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidFailToRenewClientCertificateNotification object:blockSelf];
                                             
                                             return;
                                         }
                                         
                                         //
                                         // Remove signed client certificate from the keychain storage
                                         //
                                         [[MASAccessService sharedService] setAccessValueData:nil storageKey:MASKeychainStorageKeyPublicCertificateData];
                                         [[MASAccessService sharedService] setAccessValueCertificate:nil storageKey:MASKeychainStorageKeySignedPublicCertificate];
                                         [[MASAccessService sharedService] setAccessValueNumber:[NSNumber numberWithInt:0] storageKey:MASKeychainStorageKeyPublicCertificateExpirationDate];
                                         
                                         //
                                         // Updated with latest info
                                         //
                                         [blockSelf.currentDevice saveWithUpdatedInfo:responseInfo];
                                         
                                         //
                                         // re-establish URLSession to trigger URL authentication
                                         //
                                         [[MASNetworkingService sharedService] establishURLSession];
                                         
                                         //
                                         // Post the did renew client certificate notification
                                         //
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidRenewClientCertificateNotification object:blockSelf];
                                         
                                         //
                                         // Notify
                                         //
                                         if (blockCompletion)
                                         {
                                             blockCompletion((self.currentDevice.isRegistered), nil);
                                         }
                                     }];
}


- (void)retrieveRegisteredDevices:(MASObjectsResponseErrorBlock)completion
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceListAllEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];

    //
    // Trigger the request
    //
    // Note that security credentials are added automatically by this method
    //
    __block MASObjectsResponseErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] getFrom:endPoint
                                   withParameters:nil
                                       andHeaders:headerInfo
                                       completion:^(NSDictionary *responseInfo, NSError *error)
        {
            //
            // Detect if error, if so stop here
            //
            if (error)
            {
                //DLog(@"Error detected attempting to request registration of the device: %@",
                //    [error localizedDescription]);
            
                //
                // Notify
                //
                if (blockCompletion)
                {
                    blockCompletion(nil, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                }
            
                return;
            }
       
            //
            // Retrieve the body info
            //
            //NSDictionary *bodyInfo = responseInfo[MASResponseInfoBodyInfoKey];
            
            NSMutableArray *devices = [NSMutableArray new];
            
            //
            // Notify
            //
            if (blockCompletion)
            {
                blockCompletion(devices, nil);
            }
        }
    ];
}


- (void)logoutDevice:(BOOL)force completion:(MASCompletionErrorBlock)completion
{
    
    MASAccessService *accessService = [MASAccessService sharedService];
    
    //
    // Detect if device is already logged out (which is basically checking if id_token exists), if so stop here
    //
    if (![accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdToken])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceNotLoggedIn]);
        }
        return;
    }
    
    //
    //  Post notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASUserWillLogoutNotification object:self];
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].userSessionLogoutEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    // Client Authorization
    NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
    if (clientAuthorization)
    {
        headerInfo[MASAuthorizationRequestResponseKey] = clientAuthorization;
    }
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // Logout_apps flag
    parameterInfo[MASDeviceLogoutAppRequestResponseKey] = [MASConfiguration currentConfiguration].ssoEnabled ? @"true" : @"false";
    
    // IdToken
    NSString *idToken = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdToken];
    if (idToken)
    {
        parameterInfo[MASIdTokenBodyRequestResponseKey] = idToken;
    }
    
    // IdTokenType
    NSString *idTokenType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdTokenType];
    if (idTokenType)
    {
        parameterInfo[MASIdTokenTypeBodyRequestResponseKey]= idTokenType;
    }

    //
    // Trigger the request
    //
    __block MASModelService *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] postTo:endPoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
                                     requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                    responseType:MASRequestResponseTypeJson
                                      completion:^(NSDictionary *responseInfo, NSError *error) {
                                          //
                                          // Detect if error, if so stop here
                                          //
                                          if (error)
                                          {
                                              //DLog(@"Error detected attempting to request registration of the device: %@",
                                              //    [error localizedDescription]);
                                              
                                              //
                                              // If forced, clear credentials
                                              //
                                              if(force)
                                              {
                                                  //
                                                  // Clear currentUser object upon log-out
                                                  //
                                                  [blockSelf clearCurrentUserForLogout];
                                                  
                                                  //
                                                  // Set id_token and id_token_type to nil
                                                  //
                                                  [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdToken];
                                                  [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdTokenType];
                                                  
                                                  [[MASAccessService sharedService].currentAccessObj refresh];
                                              }
                                              
                                              //
                                              // Notify
                                              //
                                              if (blockCompletion)
                                              {
                                                  blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                              }
                                              
                                              //
                                              // Post the notification
                                              //
                                              [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToLogoutNotification object:blockSelf];
                                              
                                              return;
                                          }
                                    
                                          //
                                          // Clear currentUser object upon log-out
                                          //
                                          [blockSelf clearCurrentUserForLogout];
                                          
                                          //
                                          // Set id_token and id_token_type to nil
                                          //
                                          [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdToken];
                                          [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdTokenType];
                                          
                                          [[MASAccessService sharedService].currentAccessObj refresh];
                                          
                                          //
                                          // Post the notification
                                          //
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidLogoutNotification object:blockSelf];
                                          
                                          //
                                          // Notify
                                          //
                                          if (blockCompletion)
                                          {
                                              blockCompletion(YES, nil);
                                          }
                                      }];
}


- (void)addAttribute:(NSDictionary *)attribute completion:(MASObjectResponseErrorBlock)completion
{    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceMetadataEndpointPath;

    //
    // Retrieve a mutable version of the header info, create a new one if nil
    //
    // We must guarantee standard security headers are added here
    //
    MASIMutableOrderedDictionary *mutableHeaderInfo = [MASIMutableOrderedDictionary new];

    //
    // Trigger the request
    //
    __block MASObjectResponseErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] putTo:endPoint
                                withParameters:attribute
                                    andHeaders:mutableHeaderInfo
                                    completion:^(NSDictionary *responseInfo, NSError *error) {
                                          //
                                          // Detect if error, if so stop here
                                          //
                                          if (error)
                                          {
                                              //
                                              // Notify
                                              //
                                              if (blockCompletion)
                                              {
                                                  blockCompletion([responseInfo objectForKey:MASResponseInfoBodyInfoKey], [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                              }
                                              return;
                                          }
                                        
                                          //
                                          // Notify
                                          //
                                          if (blockCompletion)
                                          {
                                              blockCompletion([responseInfo objectForKey:MASResponseInfoBodyInfoKey], nil);
                                          }
                                      }
     ];
}


- (void)removeAttribute:(NSString *)name completion:(MASCompletionErrorBlock)completion
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceMetadataEndpointPath;

    //
    // Build URL
    //
    name = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *resourcePath = [endPoint stringByAppendingString:[NSString stringWithFormat:@"/%@", name]];
    
    [self removeAttributeWithEndpoint:resourcePath completion:completion];
}


- (void)removeAllAttributes:(MASCompletionErrorBlock)completion
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceMetadataEndpointPath;
    
    [self removeAttributeWithEndpoint:endPoint completion:completion];
}


/*
 * Remove attributes for the current device using the given endpoint
 *
 * @param endPoint NSString containing the path for the attribute to be removed or default path to remove all attributes
 * @param completion The MASCompletionErrorBlock (BOOL completed, NSError *error) block that receives the results.
 */
- (void)removeAttributeWithEndpoint:(NSString *)endPoint completion:(MASCompletionErrorBlock)completion
{
    //
    // Retrieve a mutable version of the header info, create a new one if nil
    //
    // We must guarantee standard security headers are added here
    //
    MASIMutableOrderedDictionary *mutableHeaderInfo = [MASIMutableOrderedDictionary new];
    
    //
    // Trigger the request
    //
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] deleteFrom:endPoint
                                      withParameters:nil
                                          andHeaders:mutableHeaderInfo
                                         requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                        responseType:MASRequestResponseTypeTextPlain
                                          completion:^(NSDictionary *responseInfo, NSError *error) {
                                              
                                              //
                                              // Detect if error, if so stop here
                                              //
                                              if (error)
                                              {
                                                  NSError *apiError = [NSError errorFromApiResponseInfo:responseInfo andError:error];
                                                  
                                                  //
                                                  // Notify
                                                  //
                                                  if (blockCompletion)
                                                  {
                                                      //
                                                      // If error was found with 1016156: no attrbiute found, ignore the error
                                                      //
                                                      if (apiError.code == 1016156)
                                                      {
                                                          blockCompletion(YES, nil);
                                                      }
                                                      else {
                                                          blockCompletion(NO, apiError);
                                                      }
                                                  }
                                                  return;
                                              }
                                              
                                              //
                                              // Notify
                                              //
                                              if (blockCompletion)
                                              {
                                                  blockCompletion(YES, nil);
                                              }
                                          }
     ];
}


- (void)getAttribute:(NSString *)name completion:(MASObjectResponseErrorBlock)completion
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceMetadataEndpointPath;
    
    //
    // Build URL
    //
    name = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *resourcePath = [endPoint stringByAppendingString:[NSString stringWithFormat:@"/%@", name]];
    
    [self getAttributeWithEndpoint:resourcePath completion:completion];
}


- (void)getAttributes:(MASObjectResponseErrorBlock)completion
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceMetadataEndpointPath;
    
    [self getAttributeWithEndpoint:endPoint completion:completion];
}


/*
 * Get attributes for the current device using the given endpoint
 *
 * @param endPoint NSString containing the path for the attribute to be retrieved or default path to retrieve all attributes
 * @param completion The MASCompletionErrorBlock (BOOL completed, NSError *error) block that receives the results.
 */
- (void)getAttributeWithEndpoint:(NSString *)endPoint completion:(MASObjectResponseErrorBlock)completion
{
    //
    // Retrieve a mutable version of the header info, create a new one if nil
    //
    // We must guarantee standard security headers are added here
    //
    MASIMutableOrderedDictionary *mutableHeaderInfo = [MASIMutableOrderedDictionary new];
    
    //
    // Trigger the request
    //
    __block MASObjectResponseErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] getFrom:endPoint
                                   withParameters:nil
                                       andHeaders:mutableHeaderInfo
                                       completion:^(NSDictionary *responseInfo, NSError *error) {
                                        
                                           //
                                           // Detect if error, if so stop here
                                           //
                                           if (error)
                                           {
                                               NSError *apiError = [NSError errorFromApiResponseInfo:responseInfo andError:error];
                                               
                                               //
                                               // Notify
                                               //
                                               if (blockCompletion)
                                               {
                                                   //
                                                   // If error was found with 1016156: no attrbiute found, ignore the error
                                                   //
                                                   if (apiError.code == 1016156)
                                                   {
                                                       blockCompletion([NSDictionary dictionary], nil);
                                                   }
                                                   else {
                                                       blockCompletion([responseInfo objectForKey:MASResponseInfoBodyInfoKey], apiError);
                                                   }
                                               }
                                               return;
                                           }
                                           
                                           //
                                           // Notify
                                           //
                                           if (blockCompletion)
                                           {
                                               blockCompletion([responseInfo objectForKey:MASResponseInfoBodyInfoKey], nil);
                                           }
                                       }
     ];
}


# pragma mark - Login & Logout

- (void)loginUsingUserCredentials:(MASCompletionErrorBlock)completion
{
    
    //
    // If the user is already authenticated with user credentials
    // And the access_token is still valid
    //
    if (self.currentUser && self.currentUser.accessToken && [MASApplication currentApplication].authenticationStatus == MASAuthenticationStatusLoginWithUser && [MASAccess currentAccess].isAccessTokenValid)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        return;
    }
    
    //
    // MASAccessService
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    [accessService.currentAccessObj refresh];
    
    //
    // refresh_token
    //
    NSString *refreshToken = accessService.currentAccessObj.refreshToken;
    
    //
    // If the current user is NOT authenticated as user credentials
    // And NOT logged off, and refresh_token exists, authenticate with refresh_token
    //
    if (self.currentUser && refreshToken)
    {
        
        // if refresh_token exists
        if (refreshToken)
        {
            //
            // Refresh
            //
            [self loginAsRefreshTokenWithCompletion:completion];
            return;
        }
    }
    
    //
    // id_token
    //
    NSString *idToken = accessService.currentAccessObj.idToken;
    NSString *idTokenType = accessService.currentAccessObj.idTokenType;
    
    //
    // If the refresh token does not exist and if the id_token exists, authenticate with id_token
    // Do NOT validate id_token as it contains client_secret, and it will fail when MSSO enabled, and other app tries to authenticate the user with id_token
    //
    if (idToken)// && [MASAccessService validateIdToken:idToken])
    {
        //
        // Login with id token
        //
        __block MASModelService *blockSelf = self;
        __block MASCompletionErrorBlock blockCompletion = completion;
    
        __block MASAuthCredentialsJWT *authCredentials = [MASAuthCredentialsJWT initWithJWT:idToken tokenType:idTokenType];
        [self loginWithAuthCredentials:authCredentials completion:^(BOOL completed, NSError * _Nullable error) {
            
            //
            //  Clear credentials after first attempt if it is not reuseable
            //
            [authCredentials clearCredentials];
            
            if ([error.domain isEqualToString:MASFoundationErrorDomain])
            {
                [blockSelf validateCurrentUserSession:blockCompletion];
            }
            else if (blockCompletion)
            {
                blockCompletion(completed, error);
            }
        }];
        
        return;
    }

    //
    // If we fail to get the access token from id_token we check for the flow and clear the current user. Then fall back to CC
    // flow.
    //
    if (_grantFlow_ == MASGrantFlowClientCredentials)
    {
        if ([MASApplication currentApplication].authenticationStatus == MASAuthenticationStatusLoginAnonymously)
        {
            if (completion)
            {
                completion(YES, nil);
            }
            
            return;
        }
        else {
            
            //
            // Clear the current user.
            //
            [self clearCurrentUserForLogout];
            
            MASAuthCredentialsClientCredentials *authCredentials = [MASAuthCredentialsClientCredentials initClientCredentials];
            [self loginWithAuthCredentials:authCredentials completion:completion];
            
            return;
        }
    }
    
    //
    // if refresh_token, and id_token did not work, ask developer to provide username and password for authentication
    //
    // If UI handling framework is not present and handling it continue on with notifying the
    // application it needs to handle this itself
    //
    __block MASModelService *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    __block MASAuthCredentialsBlock authCredentialsBlock = ^(MASAuthCredentials *authCredentials, BOOL cancel, MASCompletionErrorBlock authCompletion)
    {
        //
        //  When the authentication process was explicitly cancelled by user
        //
        if (cancel)
        {
            if (blockCompletion)
            {
                blockCompletion(NO, [NSError errorLoginProcessCancelled]);
            }
            
            if (authCompletion)
            {
                authCompletion(NO, [NSError errorLoginProcessCancelled]);
            }
            
            return;
        }
        
        __block MASCompletionErrorBlock blockAuthCompletion = authCompletion;
        __block MASAuthCredentials *blockAuthCredentials = authCredentials;
        
        //
        //  Perform user authentication with auth credentials
        //
        [blockSelf loginWithAuthCredentials:authCredentials completion:^(BOOL completed, NSError * _Nullable error) {
        
            //
            //  Clear credentials after first attempt if it is not reuseable
            //
            [blockAuthCredentials clearCredentials];
            
            if (error)
            {
                if (blockAuthCompletion)
                {
                    blockAuthCompletion(NO, error);
                }
                
                return;
            }
            
            if (blockCompletion)
            {
                blockCompletion(YES, nil);
            }
            
            if (blockAuthCompletion)
            {
                blockAuthCompletion(YES, nil);
            }
        }];
    };
    
    
    DLog(@"\n\n\n********************************************************\n\n"
         "Waiting for credentials response to continue registration"
         @"\n\n********************************************************\n\n\n");
    
    //
    // If the UI handling framework is present and will handle this stop here
    //
    MASServiceRegistry *serviceRegistry = [MASServiceRegistry sharedRegistry];
    if ([serviceRegistry browserBasedLoginWillHandleAuthentication:authCredentialsBlock])
    {
        return;
    }
    
    if ([serviceRegistry uiServiceWillHandleWithAuthCredentialsBlock:authCredentialsBlock])
    {
        return;
    }
    
    if (_userAuthCredentialsBlock_)
    {
        //
        // Do this is the main queue since the reciever is almost certainly a UI component.
        // Lets do this for them and not make them figure it out
        //
        dispatch_async(dispatch_get_main_queue(),^
                       {
                           _userAuthCredentialsBlock_(authCredentialsBlock);
                       });
    }
    else {
        
        //
        // If the device registration block is not defined, return an error
        //
        if (completion)
        {
            completion(NO, [NSError errorInvalidUserLoginBlock]);
        }
    }
    
    return;
}


/**
 *  Re-authenticate a specifc user with the refresh token.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)loginAsRefreshTokenWithCompletion:(MASCompletionErrorBlock)completion
{
    DLog(@"called");
    
    //
    // The application must be registered else stop here
    //
    if (![self.currentApplication isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorApplicationNotRegistered]);
        }
        return;
    }

    //
    // The device must be registered else stop here
    //
    if (![self.currentDevice isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceNotRegistered]);
        }
        return;
    }

    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].tokenEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    // Client Authorization with 'Authorization' header key
    NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
    if (clientAuthorization)
    {
        headerInfo[MASAuthorizationRequestResponseKey] = clientAuthorization;
    }
    
    // MAG Identifier
    NSString *magIdentifier = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier];
    if (magIdentifier)
    {
        headerInfo[MASMagIdentifierRequestResponseKey] = magIdentifier;
    }
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // Scope
    NSString *scope = [[MASApplication currentApplication] scopeAsString];
    
    //
    //  Check if MASAccess has additional requesting scope to be added as part of the authentication call
    //
    if ([MASAccess currentAccess].requestingScopeAsString)
    {
        if (scope)
        {
            //  Making sure that the new scope has an leading space
            scope = [scope stringByAppendingString:[NSString stringWithFormat:@" %@",[MASAccess currentAccess].requestingScopeAsString]];
        }
        else {
            scope = [MASAccess currentAccess].requestingScopeAsString;
        }
        
        //
        //  Nullify the requestingScope
        //
        [MASAccess currentAccess].requestingScopeAsString = nil;
    }
    
    //
    //  If sso is disabled, manually remove msso scope, as it will create id_token with msso scope
    //
    if (scope && ![MASConfiguration currentConfiguration].ssoEnabled)
    {
        scope = [scope replaceStringWithRegexPattern:@"\\bmsso\\b" withString:@""];
    }
    
    if (scope)
    {
        parameterInfo[MASScopeRequestResponseKey] = scope;
    }
    
    // Refresh Token
    NSString *refreshToken = [MASAccessService sharedService].currentAccessObj.refreshToken;
    if (refreshToken)
    {
        parameterInfo[MASUserRefreshTokenRequestResponseKey] = refreshToken;
    }
    
    // Grant Type
    parameterInfo[MASGrantTypeRequestResponseKey] = MASGrantTypeRefreshToken;
    
    //
    // Trigger the request
    //
    __block MASModelService *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] postTo:endPoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
                                     requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                    responseType:MASRequestResponseTypeJson
                                      completion:^(NSDictionary *responseInfo, NSError *error) {
                                          //
                                          // Detect if error, if so stop here
                                          //
                                          if (error)
                                          {
                                              //
                                              // If authenticate user with refresh_token, we should invalidate local refresh_token, and re-validate the user's session with alternative method.
                                              //
                                              [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyRefreshToken];
                                              [[MASAccessService sharedService].currentAccessObj refresh];
                                              [blockSelf validateCurrentUserSession:completion];
                                              
                                              return;
                                          }
                                          
                                          //
                                          // Remove PKCE Code Verifier and state
                                          //
                                          [[MASAccessService sharedService].currentAccessObj deleteCodeVerifier];
                                          [[MASAccessService sharedService].currentAccessObj deletePKCEState];
                                          
                                          //
                                          // Validate id_token when received from server.
                                          //
                                          NSDictionary *bodayInfo = responseInfo[MASResponseInfoBodyInfoKey];
                                          
                                          if ([bodayInfo objectForKey:MASIdTokenBodyRequestResponseKey] &&
                                              [bodayInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] &&
                                              [[bodayInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] isEqualToString:MASIdTokenTypeToValidateConstant] &&
                                              [MASConfigurationService isIdTokenValidationEnabled])
                                          {
                                              NSError *idTokenValidationError = nil;
                                              BOOL isIdTokenValid = [MASAccessService validateIdToken:[bodayInfo objectForKey:MASIdTokenBodyRequestResponseKey]
                                                                                        magIdentifier:[[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier]
                                                                                                error:&idTokenValidationError];
                                              
                                              if (!isIdTokenValid && idTokenValidationError)
                                              {
                                                  //
                                                  // Post the notification
                                                  //
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToAuthenticateNotification object:blockSelf];
                                                  
                                                  if (blockCompletion)
                                                  {
                                                      blockCompletion(NO, idTokenValidationError);
                                                      return;
                                                  }
                                              }
                                          }
                                          
                                          //
                                          // Update the current user
                                          //
                                          [_currentUser saveWithUpdatedInfo:responseInfo];
                                          
                                          //
                                          // Post the notification
                                          //
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidAuthenticateNotification object:blockSelf];
                                          
                                          [self requestUserInfoWithCompletion:^(MASUser *user, NSError *error) {
                                              
                                              //
                                              // Requesting additional userInfo upon successful authentication
                                              // and do not depend on the result of userInfo call.
                                              // This a workaround to fix other frameworks' dependency issue on userInfo.
                                              // James Go @ April 4, 2016
                                              //
                                              
                                              //
                                              // Notify
                                              //
                                              if (blockCompletion)
                                              {
                                                  blockCompletion(YES, nil);
                                              }
                                          }];
                                      }];
}


/**
 *  Logout the current access credentials via asynchronous request.
 *
 *  This will remove the user available from 'currentUser' upon a successful result if one exists.
 *
 *  @param force BOOL Clear local tokens no matter the logout call to the server success or not.
 *  @param completion The completion block that receives the results.
 */
- (void)logout:(BOOL)force completion:(MASCompletionErrorBlock)completion
{
    //
    // The application must be registered else stop here
    //
    if (![MASApplication currentApplication].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorApplicationNotRegistered]);
        }
        return;
    }
    
    //
    // The device must be registered else stop here
    //
    if(![MASDevice currentDevice].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceNotRegistered]);
        }
        return;
    }
    
    //
    // The current user must be authenticated by username/password or client credentials (anonymously authenticated) else stop here
    //
    if(![MASApplication currentApplication].isAuthenticated)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorUserNotAuthenticated]);
        }
        return;
    }
    
    //
    //  Post notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASUserWillLogoutNotification object:self];
    
    //
    // Attempt to revoke access token
    //
    __block MASModelService *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASAccessService sharedService] revokeTokensWithCompletion:^(NSDictionary *responseInfo, NSError *error) {
        //
        // Detect if error, if so stop here
        //
        if (error)
        {
            //
            // Post the notification
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToLogoutNotification object:blockSelf];
            
            //
            // Clear currentUser object if forced
            //
            if(force)
            {
                [blockSelf clearCurrentUserForLogout];
            }
            
            //
            // Notify
            //
            if (blockCompletion)
            {
                blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
            }
            return;
        }
        
        //
        // Clear currentUser object upon log-out
        //
        [blockSelf clearCurrentUserForLogout];
        
        //
        // Post the notification
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidLogoutNotification object:blockSelf];
        
        //
        // Notify
        //
        if (blockCompletion)
        {
            blockCompletion(YES, nil);
        }
    }];
    
}


/**
 *  Request the current user's information via asynchronous request.
 *
 *  This will update the user available from 'currentUser' upon a successful result.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)requestUserInfoWithCompletion:(MASUserResponseErrorBlock)completion
{
    //
    // The application must be registered else stop here
    //
    if (![MASApplication currentApplication].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(nil, [NSError errorApplicationNotRegistered]);
        }
        return;
    }
    
    //
    // The device must be registered else stop here
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(nil, [NSError errorDeviceNotRegistered]);
        }
        return;
    }
    
    //
    // The current user must be authenticated else stop here
    //
    if (![MASApplication currentApplication].isAuthenticated)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(nil, [NSError errorUserNotAuthenticated]);
        }
        return;
    }
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].userInfoEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];

    //
    // Trigger the request
    //
    __block MASModelService *blockSelf = self;
    __block MASUserResponseErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] getFrom:endPoint
                                   withParameters:nil
                                       andHeaders:headerInfo
                                       completion:^(NSDictionary *responseInfo, NSError *error) {
                                           //
                                           // Detect if error, if so stop here
                                           //
                                           if (error)
                                           {
                                               //
                                               // Post the notification
                                               //
                                               [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToUpdateInformationNotification object:blockSelf];
                                               
                                               //
                                               // Notify
                                               //
                                               if (blockCompletion)
                                               {
                                                   blockCompletion(nil, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                               }
                                               return;
                                           }
                                           
                                           //
                                           // Update the current user
                                           //
                                           [blockSelf.currentUser saveWithUpdatedInfo:responseInfo];
                                           
                                           //
                                           // Post the notification
                                           //
                                           [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidUpdateInformationNotification object:blockSelf];
                                           
                                           //
                                           // Notify
                                           //
                                           if (completion)
                                           {
                                               completion(self.currentUser, nil);
                                           }
                                       }];
}


- (void)clearCurrentUserForLogout
{
    //
    // If the current user exists, clear out
    //
    if (self.currentUser)
    {
        //
        // Set the logged off state
        //
        [self.currentUser setWasLoggedOffAndSave:YES];
        
        //
        // Reset currentUser's credentials from keychain
        //
        [self.currentUser reset];
        
        //
        // Nullify the currentUser object
        //
        _currentUser = nil;
    }
}


# pragma mark - Authentication Validation


- (void)validateCurrentUserSession:(MASCompletionErrorBlock)originalCompletion
{
    
    __block MASModelService *blockSelf = self;
    
    //
    // Go through registeration, authentication logic
    //
    [self registerApplication:^(BOOL completed, NSError *error) {
        
        if (!completed || error != nil)
        {
            if (originalCompletion)
            {
                originalCompletion(NO, error);
            }
        }
        else {
            
            void (^registrationAndAuthenticationBlock)(void) = ^{
                
                //
                //  Check device registration status
                //
                [blockSelf registerDeviceWithCompletion:^(BOOL completed, NSError *error) {
                     //
                     // If the registration status is correct, and the device is currently locked, generate an error
                     //
                     if (!error && [MASAccess currentAccess].isSessionLocked)
                     {
                         error = [NSError errorUserSessionIsCurrentlyLocked];
                         completed = NO;
                     }
                     
                     if (!completed || error != nil)
                     {
                         if (originalCompletion)
                         {
                             originalCompletion(NO, error);
                         }
                     }
                     else {
                         
                         //
                         // retrieve authentication providers for password grant flow only
                         // retrieving authentication providers should be available for client credentials flow, but since this flow is implicit authentication flow,
                         // we are only retreiving the providers for the password grant flow
                         //
                         [blockSelf retrieveAuthenticationProvidersIfNeeded:^(id  _Nullable object, NSError * _Nullable error) {
                             
                             if (error != nil)
                             {
                                 if (originalCompletion)
                                 {
                                     originalCompletion(NO, error);
                                 }
                             }
                             else {
                                 
                                 //
                                 //  Check login status
                                 //
                                 [blockSelf loginUsingUserCredentials:^(BOOL completed, NSError *error) {
                                     
                                     if (!completed || error != nil)
                                     {
                                         if (originalCompletion)
                                         {
                                             originalCompletion(completed, error);
                                         }
                                     }
                                     else {
                                         if (originalCompletion)
                                         {
                                             originalCompletion(completed, error);
                                         }
                                     }
                                 }];
                             }
                         }];
                     }
                 }];
            };
            
            //
            // retrieve authentication providers for password grant flow only
            // retrieving authentication providers should be available for client credentials flow, but since this flow is implicit authentication flow,
            // we are only retreiving the providers for the password grant flow
            //
            [blockSelf retrieveAuthenticationProvidersIfNeeded:^(id  _Nullable object, NSError * _Nullable error) {
                
                if (error != nil)
                {
                    if (originalCompletion)
                    {
                        originalCompletion(NO, error);
                    }
                }
                else {
                    
                    registrationAndAuthenticationBlock();
                }
            }];
        }
    }];
}


# pragma mark - Authentication flow with MASAuthCredentials

- (void)validateCurrentUserSessionWithAuthCredentials:(MASAuthCredentials *)authCredentials completion:(MASCompletionErrorBlock)completion
{
    //
    //  Validate if the current session is locked
    //
    if ([MASUser currentUser].isSessionLocked)
    {
        if (completion)
        {
            completion(NO, [NSError errorUserSessionIsCurrentlyLocked]);
        }
        
        return;
    }
    
    __block MASCompletionErrorBlock blockCompletion = completion;
    __block MASAuthCredentials *blockAuthCredentials = authCredentials;
    __block MASModelService *blockSelf = self;
    
    //
    //  Go through registration and authentication process with auth credential object.
    //
    [self registerApplication:^(BOOL completed, NSError * _Nullable error) {
        
        //
        //  If an error occurred while client registration
        //
        if (!completed || error != nil)
        {
            //
            //  Clear credentials after first attempt if it is not reuseable
            //
            [blockAuthCredentials clearCredentials];
            
            if (blockCompletion)
            {
                blockCompletion(NO, error);
            }
        }
        //
        //  Othersiwe,
        //
        else {
            
            //
            //  If device is already registered, perform authentication instead
            //
            if ([MASDevice currentDevice].isRegistered)
            {
                [blockSelf loginWithAuthCredentials:blockAuthCredentials completion:^(BOOL completed, NSError * _Nullable error) {
                    
                    //
                    //  Clear credentials after first attempt if it is not reuseable
                    //
                    [blockAuthCredentials clearCredentials];
                    
                    //
                    //  Notify
                    //
                    if (blockCompletion)
                    {
                        blockCompletion(completed, error);
                    }
                }];
            }
            else {
                
                //
                //  Register device with auth credentials object
                //
                [self registerDeviceWithAuthCredentials:blockAuthCredentials completion:^(BOOL completed, NSError * _Nullable error) {
                    
                    //
                    //  If an error occurred while device registration
                    //
                    if (!completed || error != nil)
                    {
                        //
                        //  Clear credentials after first attempt if it is not reuseable
                        //
                        [blockAuthCredentials clearCredentials];
                        
                        if (blockCompletion)
                        {
                            blockCompletion(NO, error);
                        }
                    }
                    //
                    //  Otherwsie,
                    //
                    else {
                        
                        //
                        //  If auth credentials is reuseable, perform login with same credentials
                        //
                        if (blockAuthCredentials.isReusable)
                        {
                            [blockSelf loginWithAuthCredentials:blockAuthCredentials completion:^(BOOL completed, NSError * _Nullable error) {
                                
                                //
                                //  Clear credentials after first attempt if it is not reuseable
                                //
                                [blockAuthCredentials clearCredentials];
                                
                                //
                                //  Notify
                                //
                                if (blockCompletion)
                                {
                                    blockCompletion(completed, error);
                                }
                            }];
                        }
                        else {
                            
                            //
                            //  Clear credentials after first attempt if it is not reuseable
                            //
                            [blockAuthCredentials clearCredentials];
                            
                            //
                            //  Fallback to user authentication
                            //
                            [self loginUsingUserCredentials:blockCompletion];
                        }
                    }
                }];
            }
        }
    }];
}


- (void)registerDeviceWithAuthCredentials:(MASAuthCredentials *)authCredentials completion:(MASCompletionErrorBlock)completion
{
    //
    //  Refresh access obj
    //
    [[MASAccessService sharedService].currentAccessObj refresh];
    
    //
    // The application must be registered else stop here
    //
    if (![[MASApplication currentApplication] isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorApplicationNotRegistered]);
        }
        
        return;
    }
    
    //
    // Detect if device is already registered, if so stop here
    //
    if ([[MASDevice currentDevice] isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        
        return;
    }
    
    //
    //  Validate to see if auth credentials can register device
    //
    if (!authCredentials.canRegisterDevice)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceCanNotRegisterWithGivenAuthCredentials]);
        }
        
        return;
    }
    
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    //
    //  Perform registration
    //
    [authCredentials registerDeviceWithCredential:^(BOOL completed, NSError * _Nullable error) {
        
        //
        //  Notify
        //
        if (blockCompletion)
        {
            blockCompletion(completed, error);
        }
    }];
}


- (void)loginWithAuthCredentials:(MASAuthCredentials *)authCredentials completion:(MASCompletionErrorBlock)completion
{
    //
    //  Refresh access obj
    //
    [[MASAccessService sharedService].currentAccessObj refresh];
    
    //
    // The device must be registered else stop here
    //
    if (![[MASDevice currentDevice] isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceNotRegistered]);
        }
        
        return;
    }
    
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    //
    //  Perform authentication
    //
    [authCredentials loginWithCredential:^(BOOL completed, NSError * _Nullable error) {
        
        //
        //  Notify
        //
        if (blockCompletion)
        {
            blockCompletion(completed, error);
        }
    }];
}


@end
