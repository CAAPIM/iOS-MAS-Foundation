//
//  MASNotifications.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;


///--------------------------------------
/// @name MAS Notifications
///--------------------------------------


# pragma mark - MAS Notifications

/**
 * The NSString constant for the MAS notification indicating that MAS has begun
 * starting all it's processes.
 */
extern NSString *const _Nonnull MASWillStartNotification;


/**
 * The NSString constant for the MAS notification indicating that MAS has failed
 * to successfully start it's processes.
 */
extern NSString *const _Nonnull MASDidFailToStartNotification;


/**
 * The NSString constant for the MAS notification indicating that MAS has
 * successfully started it's processes.
 */
extern NSString *const _Nonnull MASDidStartNotification;


/**
 * The NSString constant for the MAS notification indicating that MAS has begun
 * stopping all it's processes.
 */
extern NSString *const _Nonnull MASWillStopNotification;


/**
 * The NSString constant for the MAS notification indicating that MAS has failed
 * to successfully stop it's processes.
 */
extern NSString *const _Nonnull MASDidFailToStopNotification;


/**
 * The NSString constant for the MAS notification indicating that MAS has
 * successfully stopped it's processes.
 */
extern NSString *const _Nonnull MASDidStopNotification;


/**
 *  The NSString constant for the MAS notification indicating that MAS will
 *  switch the server.
 */
extern NSString *const _Nonnull MASWillSwitchGatewayServerNotification;


/**
 *  The NSString constant for the MAS notification indicating that MAS did finish to
 *  switch the server.
 */
extern NSString *const _Nonnull MASDidSwitchGatewayServerNotification;



///--------------------------------------
/// @name Device Notifications
///--------------------------------------

# pragma mark - Device Notifications

/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has begun the process of deregistering the device.
 */
extern NSString *const _Nonnull MASDeviceWillDeregisterNotification;


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has failed to successfully deregister.
 */
extern NSString *const _Nonnull MASDeviceDidFailToDeregisterNotification;


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has successfully deregistered.
 */
extern NSString *const _Nonnull MASDeviceDidDeregisterNotification;


/**
 * The NSString constant for the device notification indicating that the MASDevice
 * has reset locally.
 */
extern NSString *const _Nonnull MASDeviceDidResetLocallyNotification;


///--------------------------------------
/// @name User Notifications
///--------------------------------------

# pragma mark - User Notifications

/**
 * The NSString constant for the user notification indicating that a MASUser
 * will attempt to authenticate.
 */
extern NSString *const _Nonnull MASUserWillAuthenticateNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has failed to authenticate.
 */
extern NSString *const _Nonnull MASUserDidFailToAuthenticateNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has successfully authenticated.
 */
extern NSString *const _Nonnull MASUserDidAuthenticateNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * will attempt to log out.
 */
extern NSString *const _Nonnull MASUserWillLogoutNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has failed to log out.
 */
extern NSString *const _Nonnull MASUserDidFailToLogoutNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has successfully logged out.
 */
extern NSString *const _Nonnull MASUserDidLogoutNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * will attempt to update it's information.
 */
extern NSString *const _Nonnull MASUserWillUpdateInformationNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has failed to update it's user information.
 */
extern NSString *const _Nonnull MASUserDidFailToUpdateInformationNotification;


/**
 * The NSString constant for the user notification indicating that a MASUser
 * has successfully updated it's information.
 */
extern NSString *const _Nonnull MASUserDidUpdateInformationNotification;



///--------------------------------------
/// @name Authorization Response - Social Login
///--------------------------------------

# pragma mark - Authorization Response - Social Login

/**
 *  The NSString constant for the device notification indicating that the MASAuthorizationResponse
 *  has received authorization code from social login
 */
extern NSString *const _Nonnull MASAuthorizationResponseDidReceiveAuthorizationCodeNotification;


/**
 *  The NSString constant for the device notification indicating that the MASAuthorizationResponse
 *  has received an error from social login
 */
extern NSString *const _Nonnull MASAuthorizationResponseDidReceiveErrorNotification;



///--------------------------------------
/// @name Proximity Login Notification
///--------------------------------------

# pragma mark - Proximity Login Notification

/**
 *  The NSString constant for the device notification indicating that the MASDevice
 *  has received authorization code from proximity login (BLE/QR Code)
 */
extern NSString *const _Nonnull MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification;


/**
 *  The NSString constant for the device notification indicating that the MASDevice
 *  has received an error from proximity login (BLE/QR Code)
 */
extern NSString *const _Nonnull MASDeviceDidReceiveErrorFromProximityLoginNotification;


/**
 *  The NSString constant for the proximity login notification indicating that QR Code image did start displaying.
 */
extern NSString *const _Nonnull MASProximityLoginQRCodeDidStartDisplayingQRCodeImage;


/**
 *  The NSString constant for the proximity login notification indicating that QR Code image did stop displaying.
 */
extern NSString *const _Nonnull MASProximityLoginQRCodeDidStopDisplayingQRCodeImage;



///--------------------------------------
/// @name Gateway Monitor Notifications
///--------------------------------------

# pragma mark - Gateway Monitor Notifications

/**
 * The NSString constant for the network reachability monitor notification indicating that the monitor status
 * has updated to a new value.
 */
extern NSString *const _Nonnull MASNetworkReachabilityStatusUpdateNotification;


/**
 * The NSString constant for the gateway monitor notification indicating that the monitor status
 * has updated to a new value.
 */
extern NSString *const _Nonnull MASGatewayMonitorStatusUpdateNotification;
