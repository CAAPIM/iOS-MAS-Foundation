//
//  CBCentralManager+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "CBCentralManager+MASPrivate.h"

#import "NSError+MASPrivate.h"
#import "MASConstants.h"

@implementation CBCentralManager (MASPrivate)


# pragma mark - CBCentralManagerState


/**
 * Simple, convenient method to determine if the peripheral is in the state 'CBCentralManagerStatePoweredOn'.
 *
 * This is equivalent to the code 'self.centralManager.state == CBCentralManagerStatePoweredOn'.
 *
 * @returns YES if powered on, NO if in any other state.
 */
- (BOOL)isPoweredOn
{
    return (self.state == CBCentralManagerStatePoweredOn);
}


/**
 * Retrieve a human readable string value for the current CBCentralManagerState enumeration.
 */
- (NSString *)centralManagerStateAsString
{
    return [CBCentralManager centralManagerStateToString:self.state];
}


/**
 * Retrieve a human readable string value for a CBCentralManagerState enumeration.
 *
 * @param status The CBCentralManagerState value.
 */
+ (NSString *)centralManagerStateToString:(CBCentralManagerState)state
{
    //
    // Detect state and respond appropriately
    //
    switch(state)
    {
        //
        // Resetting
        //
        case CBCentralManagerStateResetting: return @"Resetting";
        
        //
        // Unsupported
        //
        case CBCentralManagerStateUnsupported: return @"Unsupported";
        
        //
        // Unauthorized
        //
        case CBCentralManagerStateUnauthorized: return @"Unauthorized";
        
        //
        // Powered Off
        //
        case CBCentralManagerStatePoweredOff: return @"Powered Off";
        
        //
        // Powered On
        //
        case CBCentralManagerStatePoweredOn: return @"Powered On";
        
        //
        // Default
        //
        default: return @"Unknown";
    }
}


- (NSError *)centralManagerStateToMASFoundationError
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
