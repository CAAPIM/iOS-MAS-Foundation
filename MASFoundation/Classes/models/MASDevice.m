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

# pragma mark - Property Constants

static NSString *const MASDeviceIsRegisteredPropertyKey = @"isRegistered"; // bool
static NSString *const MASDeviceIdentifierPropertyKey = @"identifier"; // string
static NSString *const MASDeviceNamePropertyKey = @"name"; // string
static NSString *const MASDeviceStatusPropertyKey = @"status"; // string

@implementation MASDevice
@synthesize isRegistered = _isRegistered;

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


# pragma mark - Properties

- (BOOL)isRegistered
{
    _isRegistered = NO;
    
    //
    // Obtain key chain items to determine registration status
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSString *vendorIdFromKeychain = [accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyDeviceVendorId];
    NSString *vendorIdCurrent = [MASDevice deviceVendorId];

    //
    // Check if the vendorId in Keychain macth with current vendorId
    //
    if ([vendorIdCurrent isEqualToString:vendorIdFromKeychain])
    {
        NSString *magIdentifier = [accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier];
        NSData *certificateData = [accessService getAccessValueCertificateWithStorageKey:MASKeychainStorageKeySignedPublicCertificate];
        
        _isRegistered = (magIdentifier && certificateData);
    }
    
    return _isRegistered;
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


- (void)resetLocally
{
    //
    // Remove current user object
    //
    [[MASModelService sharedService] clearCurrentUserForLogout];
    
    //
    // Remove PKCE Code Verifier and state
    //
    [[MASAccessService sharedService].currentAccessObj deleteCodeVerifier];
    [[MASAccessService sharedService].currentAccessObj deletePKCEState];
    
    //
    // Remove local & shared keychains
    //
    [[MASAccessService sharedService] clearLocal];
    [[MASAccessService sharedService] clearShared];
    
    //
    // Clear all currently registered device's information upon de-registration
    //
    [[MASDevice currentDevice] clearCurrentDeviceForDeregistration];
    
    //
    // Refresh current access object to reflect correct status
    //
    [[MASAccessService sharedService].currentAccessObj refresh];
    
    //
    // re-establish URL session
    //
    [[MASNetworkingService sharedService] establishURLSession];
    
    //
    // Post the did reset locally notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidResetLocallyNotification object:self];
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


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    if(self.identifier) [aCoder encodeObject:self.identifier forKey:MASDeviceIdentifierPropertyKey];
    if(self.name) [aCoder encodeObject:self.name forKey:MASDeviceNamePropertyKey];
    if(self.status) [aCoder encodeObject:self.status forKey:MASDeviceStatusPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setValue:[aDecoder decodeObjectForKey:MASDeviceIdentifierPropertyKey] forKey:@"identifier"];
        [self setValue:[aDecoder decodeObjectForKey:MASDeviceNamePropertyKey] forKey:@"name"];
        [self setValue:[aDecoder decodeObjectForKey:MASDeviceStatusPropertyKey] forKey:@"status"];
    }
    
    return self;
}


@end
