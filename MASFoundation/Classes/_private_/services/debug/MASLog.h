//
//  MASLog.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

#define MASLogError(msg, ...) [MASLog logWithDebugLevel:MASDebugLevelError file:__FILE__ funtion:__FUNCTION__ line:__LINE__ message: (msg), ## __VA_ARGS__]
#define MASLogWarning(msg, ...) [MASLog logWithDebugLevel:MASDebugLevelWarning file:__FILE__ funtion:__FUNCTION__ line:__LINE__ message: (msg), ## __VA_ARGS__]
#define MASLogDebug(msg, ...) [MASLog logWithDebugLevel:MASDebugLevelDebug file:__FILE__ funtion:__FUNCTION__ line:__LINE__ message: (msg), ## __VA_ARGS__]
#define MASLogInfo(msg, ...) [MASLog logWithDebugLevel:MASDebugLevelInfo file:__FILE__ funtion:__FUNCTION__ line:__LINE__ message: (msg), ## __VA_ARGS__]

@interface MASLog : MASObject

+ (void)setLogLevel:(MASDebugLevel)logLevel;


+ (void)logError:(NSString *)message;


+ (void)logWarning:(NSString *)message;


+ (void)logDebug:(NSString *)message;


+ (void)logInfo:(NSString *)message;


+ (void)logWithDebugLevel:(MASDebugLevel)debugLevel file:(const char *)file funtion:(const char *)function line:(NSUInteger)line message:(NSString *)message, ... NS_FORMAT_FUNCTION(5,6);

@end
