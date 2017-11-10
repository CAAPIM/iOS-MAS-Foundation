//
//  MASPush.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


/**
 *  MASPush is the front facing class where a valid `deviceToken` is stored and bound to MAG. There it can be used to target push notifications.
 *  The device is automatically bound when the deviceToken is set and credentials become available.
 *
 *  @warning *Important:* The device bidding will not be available if MASFoundation framework is not initialized; the framework should be initialized prior registration.
 */
@interface MASPush : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 *  Is the device registered for push.
 *
 *  @param return BOOL value indicating if device is registered or not
 */
+ (BOOL)isBound;



/**
 *  DeviceToken static property
 *
 *  @return return NSString value representing the deviceToken registered for Push Notifications
 */
+ (NSString *_Nullable)deviceToken;



/**
 *  Clear the deviceToken from keychain storage, used for testing purposes
 */
+ (void)clearDeviceToken;



/**
 *  Sets the device token string property from an `NSData`-encoded token.
 *  Usually received from APN in AppDelegate through 'application: didRegisterForRemoteNotificationsWithDeviceToken:' method.
 *
 *  @param deviceTokenData NSData A token that identifies the device.
 */
+ (void)setDeviceTokenData:(NSData *_Nonnull)deviceTokenData;



/**
 *  Sets the device token string property.
 *  Usually received from APN in AppDelegate through 'application: didRegisterForRemoteNotificationsWithDeviceToken:' method.
 *
 *  @param deviceToken NSString A token that identifies the device.
 */
+ (void)setDeviceToken:(NSString *_Nonnull)deviceToken;



@end
