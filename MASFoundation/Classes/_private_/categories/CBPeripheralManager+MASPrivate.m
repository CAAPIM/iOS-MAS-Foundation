//
//  CBPeripheralManager+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "CBPeripheralManager+MASPrivate.h"

#import "NSError+MASPrivate.h"

@implementation CBPeripheralManager (MASPrivate)


# pragma mark - CBPeripheralAuthorizationStatus

+ (BOOL)isAuthorizedForBackground
{
    return ([CBPeripheralManager authorizationStatus] == CBPeripheralManagerAuthorizationStatusAuthorized);
}


+ (NSString *)peripheralManagerAuthorizationStatusAsString
{
    //
    // Detect status and respond appropriately
    //
    switch([CBPeripheralManager authorizationStatus])
    {
        //
        // Authorized
        //
        case CBPeripheralManagerAuthorizationStatusAuthorized: return @"Authorized";
        
        //
        // Denied
        //
        case CBPeripheralManagerAuthorizationStatusDenied: return @"Denied";
        
        //
        // Restricted
        //
        case CBPeripheralManagerAuthorizationStatusRestricted: return @"Restricted";
        
        //
        // Default (not determined)
        //
        default: return @"Not Determined";
    }
}


# pragma mark - CBPeripheralManagerState

- (BOOL)isPoweredOn
{
    return (self.state == CBPeripheralManagerStatePoweredOn);
}


- (NSString *)peripheralManagerStateAsString
{
    return [CBPeripheralManager peripheralManagerStateToString:self.state];
}


+ (NSString *)peripheralManagerStateToString:(CBPeripheralManagerState)state
{   
    //
    // Detect state and respond appropriately
    //
    switch(state)
    {
        //
        // Resetting
        //
        case CBPeripheralManagerStateResetting: return @"Resetting";
        
        //
        // Unsupported
        //
        case CBPeripheralManagerStateUnsupported: return @"Unsupported";
        
        //
        // Unauthorized
        //
        case CBPeripheralManagerStateUnauthorized: return @"Unauthorized";
        
        //
        // Powered Off
        //
        case CBPeripheralManagerStatePoweredOff: return @"Powered Off";
        
        //
        // Powered On
        //
        case CBPeripheralManagerStatePoweredOn: return @"Powered On";
        
        //
        // Default
        //
        default: return @"Unknown";
    }
}


- (NSError *)peripheralManagerStateToMASFoundationError
{
    //
    // Detect state and respond appropriately
    //
    switch (self.state) {
            
            //
            // Resetting
            //
        case CBCentralManagerStateResetting:
            return [NSError errorForFoundationCode:MASFoundationErrorCodeBLERestting errorDomain:MASFoundationErrorDomainLocal];
            break;
            
            //
            // Unsupported
            //
        case CBCentralManagerStateUnsupported:
            return [NSError errorForFoundationCode:MASFoundationErrorCodeBLEUnSupported errorDomain:MASFoundationErrorDomainLocal];
            break;
            
            //
            // Unauthorized
            //
        case CBCentralManagerStateUnauthorized:
            return [NSError errorForFoundationCode:MASFoundationErrorCodeBLEUnauthorized errorDomain:MASFoundationErrorDomainLocal];
            break;
            
            //
            // Powered Off
            //
        case CBCentralManagerStatePoweredOff:
            return [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPoweredOff errorDomain:MASFoundationErrorDomainLocal];
            break;
            
            //
            // Powered On
            // If the BLE power is on which means no error, return nil.
            //
        case CBCentralManagerStatePoweredOn:
            break;
            
            //
            // Default
            //
        default:
            break;
    }
    
    return nil;
}

@end
