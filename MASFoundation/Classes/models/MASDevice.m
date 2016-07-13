//
//  MASDevice.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDevice.h"

#import "MASAccessService.h"
#import "MASBluetoothCentral.h"
#import "MASBluetoothPeripheral.h"
#import "MASBluetoothService.h"
#import "MASConstantsPrivate.h"
#import "MASModelService.h"
#import "MASSecurityService.h"
#import "MASServiceRegistry.h"


@implementation MASDevice


static id<MASProximityLoginDelegate> _proximityLoginDelegate_;


# pragma mark - Property

+ (id<MASProximityLoginDelegate>)proximityLoginDelegate
{
    return _proximityLoginDelegate_;
}


+ (void)setProximityLoginDelegate:(id<MASProximityLoginDelegate>)delegate
{
    _proximityLoginDelegate_ = delegate;
}


# pragma mark - Current Device

+ (MASDevice *)currentDevice
{
    return [MASModelService sharedService].currentDevice;
}


- (void)deregisterWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Post the will deregister notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceWillDeregisterNotification object:self];
    
    //
    // Pass through to the service
    //
    [[MASModelService sharedService] deregisterCurrentDeviceWithCompletion:completion];
}


- (void)logOutDeviceAndClearLocal:(BOOL)clearLocal completion:(MASCompletionErrorBlock)completion
{
    //
    // If the user is not authenticated, return an error
    //
    if (![MASUser currentUser])
    {
        if (completion)
        {
            completion(NO, [NSError errorUserDoesNotExist]);
        }
    }
    else {
        
        [[MASUser currentUser] logoutWithCompletion:completion];
    }
}


- (void)resetLocallyWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Reset locally
    //
    [self resetLocally];
    
    if (completion)
    {
        completion(YES, nil);
    }
}


- (void)resetLocally
{
    //
    // Remove local keychains
    //
    [[MASAccessService sharedService] clearLocal];
}



# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if(self) {
        
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) is registered: %@\n\n        identifier: %@\n        name: %@\n        status: %@",
        [self class], (self.isRegistered ? @"Yes" : @"No"), [self identifier], [self name], [self status]];
}


# pragma mark - Bluetooth Peripheral

- (void)startAsBluetoothPeripheral
{
    [[MASBluetoothService sharedService].peripheral startAdvertising];
}


- (void)stopAsBluetoothPeripheral
{
    [[MASBluetoothService sharedService].peripheral stopAdvertising];
}


# pragma mark - Bluetooth Central

- (void)startAsBluetoothCentral
{
    [[MASBluetoothService sharedService].central startScanning];
}


- (void)startAsBluetoothCentralWithAuthenticationProvider:(MASAuthenticationProvider *)provider
{
    [[MASBluetoothService sharedService].central startScanningWithAuthenticationProvider:provider];
}


- (void)stopAsBluetoothCentral
{
    [[MASBluetoothService sharedService].central stopScanning];
}

@end
