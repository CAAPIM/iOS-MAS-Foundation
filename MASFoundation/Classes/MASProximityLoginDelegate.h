//
//  MASProximityLoginDelegate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

#import "MASConstants.h"

/**
 *  The enumerated MASBLEServiceState that can indicate what is current status of Device BLE
 */
typedef NS_ENUM(NSInteger, MASBLEServiceState) {
    /**
     *  Unknown
     */
    MASBLEServiceStateUnknown = -1,
    /**
     *  BLE Central started
     */
    MASBLEServiceStateCentralStarted,
    /**
     *  BLE Central stopped
     */
    MASBLEServiceStateCentralStopped,
    /**
     *  BLE Central a device detected
     */
    MASBLEServiceStateCentralDeviceDetected,
    /**
     *  BLE Central a device connected
     */
    MASBLEServiceStateCentralDeviceConnected,
    /**
     *  BLE Central a device disconnected
     */
    MASBLEServiceStateCentralDeviceDisconnected,
    /**
     *  BLE Central service discovered
     */
    MASBLEServiceStateCentralServiceDiscovered,
    /**
     *  BLE Central characteristic discovered
     */
    MASBLEServiceStateCentralCharacteristicDiscovered,
    /**
     *  BLE Central characteristic written
     */
    MASBLEServiceStateCentralCharacteristicWritten,
    /**
     *  BLE Central authorization succeeded
     */
    MASBLEServiceStateCentralAuthorizationSucceeded,
    /**
     *  BLE Central authorization failed
     */
    MASBLEServiceStateCentralAuthorizationFailed,
    /**
     *  BLE Peripheral subscribed
     */
    MASBLEServiceStatePeripheralSubscribed,
    /**
     *  BLE Peripheral unsubscribed
     */
    MASBLEServiceStatePeripheralUnsubscribed,
    /**
     *  BLE Peripheral started
     */
    MASBLEServiceStatePeripheralStarted,
    /**
     *  BLE Peripheral stopped
     */
    MASBLEServiceStatePeripheralStopped,
    /**
     *  BLE Peripheral session authorized
     */
    MASBLEServiceStatePeripheralSessionAuthorized,
    /**
     *  BLE Peripheral session notified
     */
    MASBLEServiceStatePeripheralSessionNotified
};


@protocol MASProximityLoginDelegate <NSObject>


@required

/**
 *  SDK callback to this method for user consent to authorize proximity login.
 *
 *  @param completion MASCompletionErrorBlock returns boolean of consent state and error if there is any
 *  @param deviceName NSString of device name
 */
- (void)handleBLEProximityLoginUserConsent:(MASCompletionErrorBlock _Nullable)completion deviceName:(NSString *_Nonnull)deviceName;



@optional



/**
 *  Notify the host application that the authorization code has been received from other device.
 *  Alternatively, developers can subscribe notification, MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification, to receive the authorization code.
 *
 *  @param authorizationCode NSString of authorization code
 */
- (void)didReceiveAuthorizationCode:(NSString *_Nonnull)authorizationCode;



/**
 *  Notify the host application on the state of the BLE proximity login.
 *
 *  @param state enumeration of MASBLEServiceState
 */
- (void)didReceiveBLEProximityLoginStateUpdate:(MASBLEServiceState)state;



/**
 *  Notify the host application on any error occured while proximity login
 *
 *  @param error NSError of BLE proximity login error
 */
- (void)didReceiveProximityLoginError:(NSError *_Nonnull)error;

@end
