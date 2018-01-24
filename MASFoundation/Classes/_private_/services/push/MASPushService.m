//
//  MASPushService.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASPushService.h"

#import "MASAccessService.h"

@implementation MASPushService

static NSString *_deviceToken_ = nil;
static BOOL _autoBindding_ = YES;


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASPushService alloc] initProtected];
                  });
    
    return sharedInstance;
}


# pragma mark - Service Lifecycle

+ (NSString *)serviceUUID
{
    return MASPushServiceUUID;
}


- (void)serviceDidLoad
{
    
    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    [super serviceWillStart];
    
    //
    // Subscribe for MAS events if auto registration is enabled
    //
    if(_autoBindding_)
    {
        [self registerForEvents];
    }
}


- (void)serviceDidStart
{
    [super serviceDidStart];
}


- (void)serviceWillStop
{
    [super serviceWillStop];
    
    //
    // Unsubscribe for MAS events if auto registration is enabled
    //
    if (_autoBindding_)
    {
        [self unregisterForEvents];
    }
}


- (void)serviceDidStop
{
    [super serviceDidStop];
}


- (void)serviceDidReset
{
    [super serviceDidReset];
    
}


#pragma mark - Notifications

- (void)registerForEvents
{
    NSArray* notificationNames = @[MASDidStartNotification, MASUserDidAuthenticateNotification];
    
    for (NSString* notificationName in notificationNames)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:notificationName object:nil];
    }
}

- (void)unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationReceived:(NSNotification*)notification
{
    //
    // Check if device is not already registered and deviceToken was set
    //
    if (!self.isBound && _deviceToken_)
    {
        //
        // Register for Push if application is already authenticated after MAS starts
        //
        if ([notification.name isEqualToString: MASDidStartNotification])
        {
            
            if ([MASApplication currentApplication].isAuthenticated)
            {
                [self bind:nil];
            }
        }
        
        //
        // Register for Push after user authenticates
        //
        else if ([notification.name isEqualToString: MASUserDidAuthenticateNotification])
        {
            if ([notification.object isKindOfClass:[MASAuthCredentials class]]) //remove refresh token, to be revisited once developers can extend MASAuthCredentials
            {
                [self bind:nil];
            }
        }
    }

}


# pragma mark - Properties

- (void)enableAutoBindding:(BOOL)enable
{
    _autoBindding_ = enable;
}


- (BOOL)isAutoBinddingEnabled
{
    return _autoBindding_;
}


- (BOOL)isBound
{
    //
    // Retrieve deviceToken from Keychain, if it was already registered should be the same
    //
    NSString *deviceTokenFromKeyChain = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyDeviceRegistrationToken];
    
    return ([_deviceToken_ isEqualToString:deviceTokenFromKeyChain] && _deviceToken_);
}


- (void)setDeviceToken:(NSString *_Nonnull)deviceToken
{
    _deviceToken_ = deviceToken;
}


- (void)clearDeviceToken
{
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyDeviceRegistrationToken];
}


- (NSString *)deviceToken
{
    return _deviceToken_;
}


# pragma mark - Push methods

- (void)bind:(MASCompletionErrorBlock _Nullable)completion
{
    //
    //  Check if SDK was initialized
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        //
        // Notify
        //
        if(completion)
        {
            completion(NO, [NSError errorMASIsNotStarted]);
        }
        
        return;
    }
    
    //
    // Check if the device token was set
    //
    if (!_deviceToken_)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorForFoundationCode:(MASFoundationErrorCodePushDeviceTokenInvalid) errorDomain:MASFoundationErrorDomainLocal]);
        }
        
        return;
    }
    
    //
    // Check if device token was already registered
    //
    if (self.isBound)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorForFoundationCode:(MASFoundationErrorCodePushDeviceAlreadyRegistered) errorDomain:MASFoundationErrorDomainLocal]);
        }
        
        return;
    }
    
    //
    // Post notification the Mobile SDK will attempt to register for push
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASPushWillRegisterNotification object:nil];
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].pushNotificationRegisterEndpoint;
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // DeviceToken
    parameterInfo[MASPushNotificationDeviceTokenRequestResponseKey] = _deviceToken_;
    
    // system version
    parameterInfo[MASDeviceSystemVersionRequestResponseKey] = [[UIDevice currentDevice] systemVersion];

    // device model
    parameterInfo[MASDeviceModelRequestResponseKey] = [[UIDevice currentDevice] model];

    // device locale
    if ([[NSLocale currentLocale] localeIdentifier])
    {
        parameterInfo[MASDeviceSystemLocaleRequestResponseKey] = [[NSLocale currentLocale] localeIdentifier];
    }

    // device time zone
    if ([[NSTimeZone localTimeZone] name])
    {
        parameterInfo[MASDeviceSystemLocalTimeZone] = [[NSTimeZone localTimeZone] name];
    }

    //
    // Trigger the request
    //
    [MAS postTo:endPoint withParameters:parameterInfo andHeaders:nil requestType:MASRequestResponseTypeJson responseType:MASRequestResponseTypeJson
     completion:^(NSDictionary *responseInfo, NSError *error)
     {
         //
         // If error stop here
         //
         if (error)
         {
             NSError *apiError = [NSError errorFromApiResponseInfo:responseInfo andError:error];
             
             //
             // Notify completion block
             //
             if(completion) completion(NO, apiError);
             
             //
             // Post did fail to register for push notifications
             //
             [[NSNotificationCenter defaultCenter] postNotificationName:MASPushDidFailToRegisterNotification object:apiError];
             
             return;
         }
         
         //
         // Store the deviceToken in the keychain
         //
         else {
             [[MASAccessService sharedService] setAccessValueString:_deviceToken_ storageKey:MASKeychainStorageKeyDeviceRegistrationToken];
         }
         
         //
         // Post did register for push notification
         //
         [[NSNotificationCenter defaultCenter] postNotificationName:MASPushDidRegisterNotification object:nil];
         
         //
         // Notify
         //
         if (completion)
         {
             completion(YES, nil);
         }

     }
     ];
}


- (void)unbind:(MASCompletionErrorBlock _Nullable)completion
{
    //
    //  Check if SDK was initialized
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorMASIsNotStarted]);
        }
        
        return;
    }
    
    if (!_deviceToken_)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorForFoundationCode:(MASFoundationErrorCodePushDeviceTokenInvalid) errorDomain:MASFoundationErrorDomainLocal]);
        }
        
        return;
    }
    
    //
    // Post notification the Mobile SDK will attempt to remove device from push
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASPushWillRemoveNotification object:nil];
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].pushNotificationRemoveEndpoint;
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // DeviceToken
    parameterInfo[MASPushNotificationDeviceTokenRequestResponseKey] = _deviceToken_;
    
    //
    // Trigger the request
    //
    [MAS postTo:endPoint withParameters:parameterInfo andHeaders:nil requestType:MASRequestResponseTypeJson responseType:MASRequestResponseTypeJson
     completion:^(NSDictionary *responseInfo, NSError *error)
     {
         //
         // If error stop here
         //
         if (error)
         {
             NSError *apiError = [NSError errorFromApiResponseInfo:responseInfo andError:error];
             
             //
             // Notify completion block
             //
             if(completion) completion(NO, apiError);
             
             //
             // Post did fail to remove device from push
             //
             [[NSNotificationCenter defaultCenter] postNotificationName:MASPushDidFailToRemoveNotification object:apiError];
             
             return;
         }
         
         //
         // Remove the deviceToken from keychain
         //
         else {
             [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyDeviceRegistrationToken];
         }
         
         //
         // Post did remove the device from push notification
         //
         [[NSNotificationCenter defaultCenter] postNotificationName:MASPushDidRemoveNotification object:nil];
         
         //
         // Notify
         //
         if (completion)
         {
             completion(YES, nil);
         }
         
     }
     ];
}


@end
