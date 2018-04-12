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
#import <netinet/in.h>


/**
 MASNetworkReachability class is responsible to monitor network reachability status of a given host.
 */
@interface MASNetworkReachability : NSObject


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 MASNetworkReachabilityStatus enumeration value that indicates current status of the host.
 */
@property (readonly, nonatomic, assign) MASNetworkReachabilityStatus reachabilityStatus;


/**
 NSString format of reachability status enum value.
 */
@property (readonly, nonatomic, strong, getter=reachabilityStatusAsString, nonnull) NSString *reachabilityStatusAsString;


/**
 BOOL indicator whether the network is reachable to the host or not.
 */
@property (readonly, nonatomic, assign, getter=isReachable) BOOL isReachable;


/**
 NSString value of the specified domain for the reachability.
 */
@property (readonly, nonatomic, strong, nonnull) NSString *domain;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle


/**
 Initializer to perform defualt object initialization with specified domain value as in string.

 @param domain NSString value of the domain to be monitored. Domain value should be either DNS format of hostname, or IP address without URL scheme and port.
 @return MASNetworkReachability object created.
 */
- (instancetype _Nullable)initWithDomain:(NSString * _Nonnull)domain;



/**
 Initializer to perform defualt object initialization with specified domain value as in socket address.

 @param address sockaddr object specifying domain to be monitored.
 @return MASNetworkReachability object created.
 */
- (instancetype _Nullable)initWithAddress:(const struct sockaddr * _Nonnull)address;



/**
 This initializer is not available.  Please use [[MASNetowkrReachability alloc] initWithDomain:(NSString *)] or [[MASNetowkrReachability alloc] initWithAddress:(sockaddr *)].

 @return nil will always be returned with this initialization method.
 */
- (instancetype _Nullable)init NS_UNAVAILABLE;



/**
 This initializer is not available.  Please use [[MASNetowkrReachability alloc] initWithDomain:(NSString *)] or [[MASNetowkrReachability alloc] initWithAddress:(sockaddr *)].
 
 @return nil will always be returned with this initialization method.
 */
+ (instancetype _Nullable)new NS_UNAVAILABLE;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 Starts monitoring network reachability status for given domain.
 */
- (void)startMonitoring;



/**
 Stops monitoring network reachability status for given domain.  If the object is already monitoring the reachability, it will stop monitoring first, then re-start.
 */
- (void)stopMonitoring;



/**
 Sets MASNetworkReachabilityStatusBlock which will notify the reachability status of the domain whenever there is a change in the network reachability status.

 @param block MASNetworkReachabilityStatusBlock that updates the network reachability status.
 */
- (void)setReachabilityMonitoringBlock:(MASNetworkReachabilityStatusBlock _Nullable)block;

@end
