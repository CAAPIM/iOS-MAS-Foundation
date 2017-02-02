//
//  MQTTMessage.h
//  Connecta
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/**
 *  MQTTQualityOfService
 */
typedef NS_ENUM(NSInteger, MQTTQualityOfService)
{
    /**
     *  At most once
     */
    AtMostOnce,
    
    /**
     *  At least once
     */
    AtLeastOnce,
    
    /**
     *  Exactly once
     */
    ExactlyOnce,
};



/**
 *  This class is the base class for the Message object used in MASConnecta
 */
@interface MASMQTTMessage : NSObject
    <NSCoding>

@property (readonly, assign) unsigned short mid;
@property (readonly, copy) NSString *topic;
@property (readonly, copy) NSData *payload;
@property (readonly, assign) MQTTQualityOfService qos;
@property (readonly, assign) BOOL retained;


/**
 *  The Payload message as NSString
 *
 *  @return NSString value of the payload
 */
- (NSString *)payloadString;



/**
 *  The Payload message as UIImage
 *
 *  @return UIImage value of the payload
 */
- (UIImage *)payloadImage;



/**
 *  Initialize the Message Object with parameters
 *
 *  @param topic    Topic of the Message
 *  @param payload  Message Payload Data
 *  @param qos      Quality of Service to use in this Message
 *  @param retained True to retain the message
 *  @param mid      The message ID
 *
 *  @return The Message Object instance
 */
- (id)initWithTopic:(NSString *)topic
            payload:(NSData *)payload
                qos:(MQTTQualityOfService)qos
             retain:(BOOL)retained
                mid:(short)mid;

@end

NS_ASSUME_NONNULL_END
