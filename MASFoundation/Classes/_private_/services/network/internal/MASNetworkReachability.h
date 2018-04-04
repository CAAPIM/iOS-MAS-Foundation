//
//  MASNetworkReachability.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;
#import "MASConstants.h"

@interface MASNetworkReachability : NSObject


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (readonly, nonatomic, assign) MASNetworkReachabilityStatus reachabilityStatus;


@property (readonly, nonatomic, assign, getter=isReachable) BOOL isReachable;


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

- (instancetype _Nullable)initWithDomain:(NSURL * _Nonnull)domain NS_DESIGNATED_INITIALIZER;



- (instancetype _Nullable)init NS_UNAVAILABLE;



+ (instancetype _Nullable)new NS_UNAVAILABLE;


///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

- (void)startMonitoring;



- (void)stopMonitoring;



- (void)setReachabilityMonitoringBlock:(nullable void (^)(MASNetworkReachabilityStatus status))block;

@end
