//
//  MASBluetoothService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"

#import "MASConstantsPrivate.h"


@class MASBluetoothCentral;
@class MASBluetoothPeripheral;


@interface MASBluetoothService : MASService



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The BLE central.
 */
@property (nonatomic, strong, readonly) MASBluetoothCentral *central;


/**
 * The BLE peripheral.
 */
@property (nonatomic, strong, readonly) MASBluetoothPeripheral *peripheral;

@end
