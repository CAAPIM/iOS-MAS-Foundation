//
//  MASMQTTHelper.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import <MASFoundation/MASFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MASMQTTHelper : NSObject

+ (void)showLogMessage:(NSString *)message debugMode:(BOOL)debugMode;

+ (NSString *)mqttClientId;

+ (NSString *)buildMessageWithString:(NSString *)message andUser:(NSString *)userName;

+ (NSString *)structureTopic:(NSString *)topic forObject:(MASObject *)masObject;

@end

NS_ASSUME_NONNULL_END
