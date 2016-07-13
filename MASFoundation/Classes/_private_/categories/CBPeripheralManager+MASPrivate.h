//
//  CBPeripheralManager+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <CoreBluetooth/CoreBluetooth.h>


@interface CBPeripheralManager (MASPrivate)



///--------------------------------------
/// @name CBPeripheralAuthorizationStatus
///--------------------------------------

# pragma mark - CBPeripheralAuthorizationStatus

/**
 * Simple, convenient method to determine if the peripheral's application background authorization status is
 * 'CBPeripheralManagerAuthorizationStatusAuthorized'.
 *
 * This is equivalent to the code '[CBPeripheralManager authorizationStatus] == CBPeripheralManagerAuthorizationStatusAuthorized'.
 *
 * @returns YES if authorized, NO if in any other status.
 */
+ (BOOL)isAuthorizedForBackground;


/**
 * Retrieve a human readable string value for the current CBPeripheralManagerAuthorizationStatus enumeration.
 */
+ (NSString *)peripheralManagerAuthorizationStatusAsString;



///--------------------------------------
/// @name CBPeripheralManagerState
///--------------------------------------

# pragma mark - CBPeripheralManagerState


/**
 * Simple, convenient method to determine if the peripheral is in the state 'CBPeripheralManagerStatePoweredOn'.
 *
 * This is equivalent to the code 'self.peripheralManager.state == CBPeripheralManagerStatePoweredOn'.
 *
 * @returns YES if powered on, NO if in any other state.
 */
- (BOOL)isPoweredOn;


/**
 * Retrieve a human readable string value for the current CBPeripheralManagerState enumeration.
 */
- (NSString *)peripheralManagerStateAsString;


/**
 * Retrieve a human readable string value for a CBPeripheralManagerState enumeration.
 *
 * @param status The CBPeripheralManagerState value.
 */
+ (NSString *)peripheralManagerStateToString:(CBPeripheralManagerState)state;


/**
 *  Retrieve a MASFoundation NSError object with MASFoundationErrorDomainLocal for its CBPeripheralManagerState enumeration.
 *
 *  @return NSError object of bluetooth state error; if there no error, the method will return nil.
 */
- (NSError *)peripheralManagerStateToMASFoundationError;

@end
