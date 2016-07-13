//
//  CLLocationManager+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "CLLocationManager+MASPrivate.h"


@implementation CLLocationManager (MASPrivate)


# pragma mark - Authorization Status

+ (NSString *)authorizationStatusToString:(CLAuthorizationStatus)status
{
    //
    // Detect status and respond appropriately
    //
    switch(status)
    {
        //
        // Authorized Always
        //
        case kCLAuthorizationStatusAuthorizedAlways: return @"Authorized Always";
        
        //
        // Denied
        //
        case kCLAuthorizationStatusDenied: return @"Denied";
        
        //
        // Restricted
        //
        case kCLAuthorizationStatusRestricted: return @"Restricted";
        
        //
        // Default
        //
        default: return @"Not determined";
    }
}

@end
