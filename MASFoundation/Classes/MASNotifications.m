//
// MASNotifications.m
// MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASNotifications.h"



# pragma mark - MAS Notifications

NSString *const MASWillStartNotification = @"MASWillStartNotification";


NSString *const MASDidFailToStartNotification = @"MASDidFailToStartNotification";


NSString *const MASDidStartNotification = @"MASDidStartNotification";


NSString *const MASWillStopNotification = @"MASWillStopNotification";


NSString *const MASDidFailToStopNotification = @"MASDidFailToStopNotification";


NSString *const MASDidStopNotification = @"MASDidStopNotification";


NSString *const MASWillSwitchGatewayServerNotification = @"MASWillSwitchGatewayServerNotification";


NSString *const MASDidSwitchGatewayServerNotification = @"MASDidSwitchGatewayServerNotification";



# pragma mark - Device Notifications

NSString *const MASDeviceWillDeregisterNotification = @"MASDeviceWillDeregisterNotification";


NSString *const MASDeviceDidFailToDeregisterNotification = @"MASDeviceDidFailToDeregisterNotification";


NSString *const MASDeviceDidDeregisterNotification = @"MASDeviceDidDeregisterNotification";


NSString *const MASDeviceDidResetLocallyNotification = @"MASDeviceDidResetLocallyNotification";



# pragma mark - User Notifications

NSString *const MASUserWillAuthenticateNotification = @"MASUserWillAuthenticateNotification";


NSString *const MASUserDidFailToAuthenticateNotification = @"MASUserDidFailToAuthenticateNotification";


NSString *const MASUserDidAuthenticateNotification = @"MASUserDidAuthenticateNotification";


NSString *const MASUserWillLogoutNotification = @"MASUserWillLogoutNotification";


NSString *const MASUserDidFailToLogoutNotification = @"MASUserDidFailToLogoutNotification";


NSString *const MASUserDidLogoutNotification = @"MASUserDidLogoutNotification";


NSString *const MASUserWillUpdateInformationNotification = @"MASUserWillUpdateInformationNotification";


NSString *const MASUserDidFailToUpdateInformationNotification = @"MASUserDidFailToUpdateInformationNotification";


NSString *const MASUserDidUpdateInformationNotification = @"MASUserDidUpdateInformationNotification";



# pragma mark - Authorization Response - Social Login

NSString *const MASAuthorizationResponseDidReceiveAuthorizationCodeNotification = @"MASAuthorizationResponseDidReceiveAuthorizationCodeNotification";


NSString *const MASAuthorizationResponseDidReceiveErrorNotification = @"MASAuthorizationResponseDidReceiveErrorNotification";



# pragma mark - Proximity Login Notification

NSString *const MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification = @"MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification";


NSString *const MASDeviceDidReceiveErrorFromProximityLoginNotification = @"MASDeviceDidReceiveErrorFromProximityLoginNotification";


NSString *const MASProximityLoginQRCodeDidStartDisplayingQRCodeImage = @"MASProximityLoginQRCodeDidStartDisplayingQRCodeImage";


NSString *const MASProximityLoginQRCodeDidStopDisplayingQRCodeImage = @"MASProximityLoginQRCodeDidStopDisplayingQRCodeImage";



# pragma mark - Gateway Monitor Notifications

NSString *const MASNetworkReachabilityStatusUpdateNotification = @"com.ca.mas.networking.reachability.status";

NSString *const MASGatewayMonitorStatusUpdateNotification = @"MASGatewayMonitorStatusUpdateNotification";

