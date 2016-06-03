//
//  MASSessionSharingDelegate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

#import "MASConstants.h"


@protocol MASSessionSharingDelegate <NSObject>


@required

/**
 *  SDK callback to this method for user consent to authorize session sharing.
 *
 *  @param completion MASCompletionErrorBlock returns boolean of consent state and error if there is any
 *  @param deviceName NSString of device name
 */
- (void)handleBLESessionSharingUserConsent:(MASCompletionErrorBlock)completion deviceName:(NSString *)deviceName;



@optional



/**
 *  Notify the host application that the authorization code has been received from other device.
 *  Alternatively, developers can subscribe notification, MASDeviceDidReceiveAuthorizationCodeFromSessionSharingNotification, to receive the authorization code.
 *
 *  @param authorizationCode NSString of authorization code
 */
- (void)didReceiveAuthorizationCode:(NSString *)authorizationCode;



/**
 *  Notify the host application on the state of the BLE session sharing.
 *
 *  @param state enumeration of MASBLEServiceState
 */
//- (void)didReceiveBLESessionSharingStateUpdate:(MASBLEServiceState)state;



/**
 *  Notify the host application on any error occured while session sharing
 *
 *  @param error NSError of BLE session sharing error
 */
- (void)didReceiveSessionSharingError:(NSError *)error;

@end
