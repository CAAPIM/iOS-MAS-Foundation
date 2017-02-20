//
//  MASBluetoothCentral.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


@interface MASBluetoothCentral : MASObject



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Create a bluetooth central.
 *
 * @param serviceUUID The peripheral's service UUID.
 * @param characteristicUUI The peripheral's characteristic UUID.
 * @param sessionId The session identifier.
 * @return Returns the newly initialized 'MASBluetoothCentral'.
 */
+ (id)centralWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID;



///--------------------------------------
/// @name Starting & Stopping
///--------------------------------------

# pragma mark - Starting and Stopping

/**
 * Start the central scanning for peripherals.
 */
- (void)startScanning;



/**
 *  Start the central scanning for peripherals with specific authentication provider
 *
 *  @param provider MASAuthneticationProvider to scan
 */
- (void)startScanningWithAuthenticationProvider:(MASAuthenticationProvider *)provider;



/**
 * Stop the central from scanning for peripherals.
 */
- (void)stopScanning;

@end
