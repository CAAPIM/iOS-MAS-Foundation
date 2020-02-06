//
//  MASMQTTForegroundReconnection.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


//
//  Implementation details referenced from MQTTClient/ForegroundReconnection.m
//  https://github.com/novastone-media/MQTT-Client-Framework
//
#import "MASMQTTForegroundReconnection.h"

#if TARGET_OS_IPHONE == 1

#import "MASMQTTClient.h"
#import <UIKit/UIKit.h>

@interface MASMQTTForegroundReconnection ()

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation MASMQTTForegroundReconnection

- (instancetype)initWithMQTTClient:(MASMQTTClient *)mqttClient
{
    self = [super init];
    
    if (self)
    {
        self.mqttClient = mqttClient;
        self.backgroundTask = UIBackgroundTaskInvalid;
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self
                          selector:@selector(appWillResignActive)
                              name:UIApplicationWillResignActiveNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(appDidEnterBackground)
                              name:UIApplicationDidEnterBackgroundNotification
                            object:nil];
        
        [defaultCenter addObserver:self
                          selector:@selector(appDidBecomeActive)
                              name:UIApplicationDidBecomeActiveNotification
                            object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)appWillResignActive
{
    [self.mqttClient disconnectWithCompletionHandler:^(NSUInteger code) {
        
    }];
}


- (void)appDidEnterBackground
{
    if (!self.mqttClient.connected)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf endBackgroundTask];
    }];
}


- (void)appDidBecomeActive
{
    [self.mqttClient reconnect];
}


- (void)endBackgroundTask
{
    if (self.backgroundTask)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

@end

#endif
