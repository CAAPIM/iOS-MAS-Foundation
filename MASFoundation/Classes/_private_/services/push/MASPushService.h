//
//  MASPushService.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

#import "MASConstantsPrivate.h"

/**
 * The `MASPushService` class is a service class that provides interfaces for Push Notification and other related services.
 */
@interface MASPushService : MASService



///--------------------------------------
/// @name Shared Service
///--------------------------------------

# pragma mark - Shared Service

/**
 * Retrieve the shared, singleton service.
 *
 * @return Returns the MASPushService singleton.
 */
+ (instancetype _Nonnull)sharedService;



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  DeviceToken static property
 *
 *  @return return NSString value representing the deviceToken registered for Push Notifications
 */
- (NSString *_Nullable)deviceToken;



/**
 *  Sets the device token string property.
 *  Usually received from APN in AppDelegate through 'application: didRegisterForRemoteNotificationsWithDeviceToken:' method.
 *
 *  @param deviceToken NSString A token that identifies the device.
 */
- (void)setDeviceToken:(NSString *_Nonnull)deviceToken;



/**
 *  Clear the deviceToken from keychain storage, used for testing purposes
 */
- (void)clearDeviceToken;



/**
 *  Static boolean property indicating where the device is registered for Push Notifications.
 *
 *  @return return BOOL value indicating is registered for Push Notifications or not
 */
- (BOOL)isRegistered;



/**
 *  Setter of static boolean property indicating auto registration is enabled or not.
 *  By default auto registration is enabled.
 *
 *  @param enable BOOL value indicating auto registration is enabled or not
 */
- (void)enableAutoRegistration:(BOOL)enable;



/**
 *  Gets BOOL indicator of Auto Registration enabled or not.
 *  By default auto registration is enabled.
 *
 *  @return return BOOL value indicating Keychain sincronization is enabled or not
 */
- (BOOL)isKAutoRegistrationEnabled;



/**
 *  Register the current app for Push Notification.
 *
 *  Device is automatically registered when the deviceToken is set and credentials become available.
 *  Call this method explicitly if you require to refresh the register manually. It's usually required if
 *  you disabled a register by calling the the method 'deregisterForPushNotification:'
 *
 *  This method invokes the register endpoint in MAG to enroll the current app + device for Push Notification.
 *
 *  Although an asynchronous block callback parameter is provided for response usage,
 *  optionally you can set that to nil and the caller can observe the lifecycle
 *
 *  The application registration notifications are:
 *
 *      MASPushWillRegisterNotification
 *      MASPushDidFailToRegisterNotification
 *      MASPushDidRegisterNotification
 *
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
- (void)registerDevice:(MASCompletionErrorBlock _Nullable)completion;



/**
 *  Deregister the current app for Push Notification.
 *
 *  This method invokes the deregister endpoint in MAG to remove the device from Push Notification.
 *
 *  Although an asynchronous block callback parameter is provided for response usage,
 *  optionally you can set that to nil and the caller can observe the lifecycle
 *
 *  The application deregister notifications are:
 *
 *      MASPushWillRemoveNotification
 *      MASPushDidFailToRemoveNotification
 *      MASPushDidRemoveNotification
 *
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
- (void)deregisterDevice:(MASCompletionErrorBlock _Nullable)completion;


@end
