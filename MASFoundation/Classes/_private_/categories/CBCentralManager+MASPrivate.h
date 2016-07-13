//
//  CBCentralManager+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <CoreBluetooth/CoreBluetooth.h>


@interface CBCentralManager (MASPrivate)



///--------------------------------------
/// @name CBCentralManagerState
///--------------------------------------

# pragma mark - CBCentralManagerState


/**
 * Simple, convenient method to determine if the peripheral is in the state 'CBCentralManagerStatePoweredOn'.
 *
 * This is equivalent to the code 'self.centralManager.state == CBCentralManagerStatePoweredOn'.
 *
 * @returns YES if powered on, NO if in any other state.
 */
- (BOOL)isPoweredOn;


/**
 * Retrieve a human readable string value for the current CBCentralManagerState enumeration.
 */
- (NSString *)centralManagerStateAsString;


/**
 * Retrieve a human readable string value for a CBCentralManagerState enumeration.
 *
 * @param status The CBCentralManagerState value.
 */
+ (NSString *)centralManagerStateToString:(CBCentralManagerState)state;


/**
 *  Retrieve a MASFoundation NSError object with MASFoundationErrorDomainLocal for its CBCentralManagerState enumeration.
 *
 *  @return NSError object of bluetooth state error; if there no error, the method will return nil.
 */
- (NSError *)centralManagerStateToMASFoundationError;

@end
