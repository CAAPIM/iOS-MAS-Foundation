//
//  MASMQTTForegroundReconnection.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE == 1

@class MASMQTTClient;


/**
 MASMQTTForegroundReconnection class is responsible to manage MQTT connection in between foreground/background process within iOS.
 The class is only designed and available for iOS lifecycle.
 */
@interface MASMQTTForegroundReconnection : NSObject


/**
 MASMQTTclient object that MASMQTTForegroundReconnection class is responsible to manage the connection.
 */
@property (weak, nonatomic) MASMQTTClient *mqttClient;



/**
 Designated initializer for MASMQTTForegroundReconnection with MASMQTTClient

 @param mqttClient MASMQTTClient that MASMQTTForegroundReconnection should be responsible
 @return MASMQTTForegroundReconnection instance
 */
- (instancetype)initWithMQTTClient:(MASMQTTClient *)mqttClient;

@end

#endif
