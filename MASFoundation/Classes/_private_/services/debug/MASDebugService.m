//
//  MASDebugService.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDebugService.h"

#import "MASConstantsPrivate.h"

@implementation MASDebugService

static MASDebugLevel _logLevel_ = MASDebugLevelNone;

# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASDebugService alloc] initProtected];
                  });
    
    return sharedInstance;
}


# pragma mark - Public

+ (void)setLogLevel:(MASDebugLevel)level
{
    _logLevel_ = level;
}


+ (MASDebugLevel)logLevel
{
    return _logLevel_;
}


- (void)logMessage:(NSString *)message logLevel:(MASDebugLevel)logLevel
{
    NSLog(@"%@", message);
}



# pragma mark - Lifecycle

+ (void)load
{
    [MASService registerSubclass:[self class] serviceUUID:MASDebugServiceUUID];
}


+ (NSString *)serviceUUID
{
    return MASDebugServiceUUID;
}

@end
