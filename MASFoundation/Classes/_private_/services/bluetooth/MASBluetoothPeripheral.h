//
//  MASBluetoothPeripheral.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>
 

@interface MASBluetoothPeripheral : MASObject



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Create a bluetooth peripheral.
 *
 * @param serviceUUID The peripheral's service UUID.
 @ @param characteristicUUI The peripheral's characteristic UUID.
 * @return Returns the newly initialized 'MASBluetoothPeripheral'.
 */
+ (id)peripheralWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID;



///--------------------------------------
/// @name Starting & Stopping
///--------------------------------------

# pragma mark - Starting and Stopping

/**
 * Start the peripheral advertising it's presence.
 */
- (void)startAdvertising;


/**
 * Stop the peripheral advertising it's presence.
 */
- (void)stopAdvertising;

@end
