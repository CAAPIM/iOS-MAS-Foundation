//
//  L7SClientManager.h
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

@class L7SHTTPClient;


extern NSString * const L7SStatusUpdateKey;
extern NSString * const L7SDidReceiveStatusUpdateNotification;


//
// Client Lifecycle States
//
typedef enum
{
    L7SDidFinishRegistration,
    L7SDidFinishAuthentication,
    L7SDidFinishDeRegistration,
    L7SDidLogout,
    L7SDidLogoff,
    L7SDidSDKStart,
    L7SDidSDKStartInit,
    L7SDidSDKStop,
    L7SLocationServiceAuthorized,
    L7SLocationServiceDenied,
    L7SQRAuthenticationPollingStopped

} L7SClientState;


//
// BLE Session Sharing State
//
typedef NS_ENUM(NSInteger, L7SBLESessionSharingState)
{
    L7SBLEStateUnknown = 0,
    
    // States for central device
    L7SBLECentralScanStarted,
    L7SBLECentralScanStopped,
    L7SBLECentralDeviceDetected,
    L7SBLECentralDeviceConnected,
    L7SBLECentralDeviceDisconnected,
    L7SBLECentralServiceDiscovered,
    L7SBLECentralCharacteristicDiscovered,
    L7SBLECentralCharacteristicWritten,
    L7SBLECentralAuthorizationSucceeded,
    L7SBLECentralAuthorizationFailed,
    
    // States for peripheral device
    L7SBLEPeripheralSubscribed,
    L7SBLEPeripheralUnsubscribed,
    L7SBLEPeripheralStarted,
    L7SBLEPeripheralStopped,
    L7SBLEPeripheralSessionAuthorized,
    L7SBLEPeripheralSessionNotified
    
} NS_ENUM_AVAILABLE(NA, 6_0);



@protocol L7SClientProtocol;
@protocol MASProximityLoginDelegate;
@protocol L7SBLESessionSharingDelegate;

#import "MASProximityLoginDelegate.h"

@interface L7SClientManager : NSObject <MASProximityLoginDelegate>


# pragma mark - Properties


@property (assign) L7SClientState state DEPRECATED_ATTRIBUTE;


@property (nonatomic, copy) void (^consent)(BOOL) DEPRECATED_ATTRIBUTE;

// Pseudo property
+ (id<L7SClientProtocol>)delegate DEPRECATED_ATTRIBUTE;

// Pseudo property
+ (void)setDelegate:(id<L7SClientProtocol>)delegate DEPRECATED_ATTRIBUTE;



# pragma mark - Lifecycle

/**
 * This is an initializer.  It initializes and configures an instance of `L7SClientManager` 
 * with a json configuration file placed in the app's main resource bundle.  The configuration file 
 * name must be "msso_config.json".
 *
 * @returns The instance of the `L7SClientManager` if it has been configured and initialized.
 */
+ (id)initClientManager DEPRECATED_MSG_ATTRIBUTE("Use [MAS start:].");


/**
 * This is an initializer.  This version takes a JSON object and configures an instance of 'L7SClientManager'.  
 *
 * The JSON object.
 */
+ (id)initClientManagerWithJSONObject:(id)json DEPRECATED_MSG_ATTRIBUTE("Use [MAS startWithJSON:completion:].");


/**
 * @returns The instance of the `L7SClientManager` if it has been configured and initialized.
 */
+ (L7SClientManager *)sharedClientManager DEPRECATED_ATTRIBUTE;


# pragma mark - Configuration

/**
 * Retrieve the prefix.
 *
 * @param prefix The prefix configured in the JSON configuration file.
 */
- (NSString *)prefix DEPRECATED_MSG_ATTRIBUTE("Use [MASConfiguration currentConfiguration].gatewayPrefix instead.");


# pragma mark - App

/**
 * Whether the current app has a login session.
 */
- (BOOL)isAppLogon DEPRECATED_MSG_ATTRIBUTE("Use [MASUser currentUser].isAuthenticated instead.");


/**
 * Logoff the app.
 *
 * The method removes access credentials of the current app.
 */
- (void)logoffApp DEPRECATED_MSG_ATTRIBUTE("Use [[MASUser currentUser] logoffWithCompletion:] instead.");


# pragma mark - Device

/**
 * Deregister the device.
 *
 * The method resets the device so that it removes all access credentials and client certificates 
 * within the same group across the device.  This method can be used when the app is in a state that 
 * its current client certificate becomes invalid.  In this case, calling this method will reset the 
 * device, so that the registration process will be triggered to initiate a new PKI provisioning process.
 *
 * The app user needs to kill the app to achieve a clean device reset before any other activities on 
 * the app, because de-registration process does not clean the TLS cache.
 *
 * Please note that SDK will callback with a state "L7SDidFinishDeRegistration" once the de-registration 
 * process is completed, at this point app user may be prompted for an alert message, such as notifying 
 * to kill the app.
 */
- (void)deRegister DEPRECATED_MSG_ATTRIBUTE("Use [[MASDevice currentDevice] deregisterWithCompletion:] instead.");


/**
 * Whether the device is registered. (i.e. client certificate is provisioned)
 */
- (BOOL)isRegistered DEPRECATED_MSG_ATTRIBUTE("Use [MASDevice currentDevice].isRegistered instead.");


/**
 * Whether the device has a login session for the apps within the same access group.
 */
- (BOOL)isDeviceLogin DEPRECATED_ATTRIBUTE;


/**
 * Logout the device.
 *
 * The method removes access credentials of all apps within the same access group on
 * the device.
 */
- (void)logoutDevice DEPRECATED_MSG_ATTRIBUTE("Use [[MASUser currentUser] logoutWithCompletion:] instead.");


# pragma mark - BLE

/**
 This method is used by a device to start BLE session sharing. It only works when the device has a valid session.  SDK will throw an error if there are any issue during the process; otherwise the SDK will notify the app that the BLE session sharing is started.  The delegate is for SDK to callback to the app for handling user consent.
 
 @param delegate the delegate for handling user consent.
 */
- (void) startBLESessionSharingWithDelegate: (id<L7SBLESessionSharingDelegate>) delegate DEPRECATED_MSG_ATTRIBUTE("Use [[MASDevice currentDevice] startAsBluetoothPeripheral] instead.");


/**
 Stop BLE session sharing
 */
- (void) stopBLESessionSharing DEPRECATED_MSG_ATTRIBUTE("Use [[MASDevice currentDevice] stopAsBluetoothPeripheral] instead.");

/**
 Enable authentication with Bluetooth Low Energy.
 @param delegate the delegate for handling callback
 */

- (void) enableBLESessionRequestWithDelegate: (id<L7SBLESessionSharingDelegate>) delegate DEPRECATED_MSG_ATTRIBUTE("Use [[MASDevice currentDevice] startAsBluetoothCentral] instead.");

/**
 Disable authentication with bluetooth Low Energy.
 */
- (void) disableBLESessionRequest DEPRECATED_MSG_ATTRIBUTE("Use [[MASDevice currentDevice] stopAsBluetoothCentral] instead.");

# pragma mark - Authentication

/**
 * Authenticate with username and password.
 */
- (void)authenticateWithUserName:(NSString *)userName password:(NSString *)password DEPRECATED_MSG_ATTRIBUTE("Use [MASUser loginWithUserName:password:completion:] instead.");


/**
 * Cancel the authentication operation.
 */
- (void)cancelAuthentication DEPRECATED_ATTRIBUTE;

/*
 Authorize a user session with a given code
 */
- (void) authorize: (NSString *) code failure: (void (^)(NSError *)) callback DEPRECATED_MSG_ATTRIBUTE("Use [MASSessionSharingQRCode authorizeAuthenticateUrl:completion:] instead.");


#ifdef DEBUG

///--------------------------------------
/// @name Debug Only
///--------------------------------------

# pragma mark - Debug only

/**
 *  Method for debug purposes to view the current runtime contents of the framework on the
 *  debug console.  The debugDescription results of the MASNetworkingService, MASApplication,
 *  MASDevice and MASUser are shown if available.
 *
 *  This will not be compiled into release versions of an application.
 */
+ (void)currentStatusToConsole;


/**
 *  Turn on or off the logging of the network activity.
 *
 *  @param logNetworkActivity BOOL YES to turn on logging, NO to turn it off.
 */
+ (void)setGatewayNetworkActivityLogging:(BOOL)logNetworkActivity;

#endif


@end


//////////////////////////////////////////////////////////////////////////////////////////////


/**
 * The `L7SClientProtocol` protocol defines a method for apps to receive error callbacks.
 *
 * Please refer to `L7SErrors` for the defined error codes.
 */
@protocol L7SClientProtocol <NSObject>

@optional

/**
 * Receives the errors.
 *
 * @param error NSError object.
 */
- (void)DidReceiveError:(NSError *)error DEPRECATED_ATTRIBUTE;

/**
 * Receive notification of a successful start.
 */
- (void)DidStart DEPRECATED_ATTRIBUTE;

@end


DEPRECATED_ATTRIBUTE
@protocol L7SBLESessionSharingDelegate <NSObject>


@required

/**
 * SDK callback to this method for user consent to authorize session sharing
 * @param consentHandler block to handler user consent
 * @param deviceName device that requests the session sharing
 */
- (void)requestUserConsent:(void (^)(BOOL))consentHandler deviceName:(NSString *)deviceName DEPRECATED_MSG_ATTRIBUTE("Use MASSessionSharingDelegate instead.");


@optional

/**
 * Notify the host application of the current BLE session sharing state
 */
- (void)didReceiveBLESessionSharingStatusUpdate:(L7SBLESessionSharingState)state DEPRECATED_MSG_ATTRIBUTE("Use MASSessionSharingDelegate instead.");

@end
