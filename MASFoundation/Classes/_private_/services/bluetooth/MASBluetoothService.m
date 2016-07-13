//
//  MASBluetoothService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASBluetoothService.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "MASBluetoothCentral.h"
#import "MASBluetoothPeripheral.h"


@implementation MASBluetoothService


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[MASBluetoothService alloc] initProtected];
    });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (NSString *)serviceUUID
{
    return MASBluetoothServiceUUID;
}


- (void)serviceDidLoad
{
    
    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    //
    // Retrieve the configuation for UUID values
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    
    //
    // Create the central
    //
    _central = [MASBluetoothCentral centralWithServiceUUID:configuration.bluetoothServiceUuid
                                        characteristicUUID:configuration.bluetoothCharacteristicUuid];
    
    //
    // Create the peripheral
    //
    _peripheral = [MASBluetoothPeripheral peripheralWithServiceUUID:configuration.bluetoothServiceUuid
                                                 characteristicUUID:configuration.bluetoothCharacteristicUuid];
    
    [super serviceWillStart];
}


- (void)serviceWillStop
{
    //
    // If the central exists
    //
    if(self.central)
    {
        [self.central stopScanning];
    }
    
    //
    // If the peripheral exists
    //
    if(self.peripheral)
    {
        [self.peripheral stopAdvertising];
    }

    [super serviceWillStop];
}


- (void)serviceDidReset
{
    //
    // If the central exists
    //
    if(self.central)
    {
        [self.central stopScanning];
        _central = nil;
    }
    
    //
    // If the peripheral exists
    //
    if(self.peripheral)
    {
        [self.peripheral stopAdvertising];
        _peripheral = nil;
    }
    
    [super serviceDidReset];
}


# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    central: %@\n\n    peripheral: %@",
        [super debugDescription],
        [self.central debugDescription], [self.peripheral debugDescription]];
}

@end
