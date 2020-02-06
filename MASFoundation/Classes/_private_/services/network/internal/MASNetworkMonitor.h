//
//  MASNetworkMonitor.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

@interface MASNetworkMonitor : NSObject

///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 Singleton shared instance for network monitor

 @return MASNetworkMonitor singleton object
 */
+ (instancetype)sharedMonitor;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 Starts monitoring all network requests and responses.  
 
 @warning   The request and response will be displayed in Xcode's debug console; however, even if you start monitoring, if the app is built as release build, network monitor will not display anything.
 */
- (void)startMonitoring;



/**
 Stops monitoring all network requests and responses.
 */
- (void)stopMonitoring;

@end
