//
//  CLLocationManager+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <CoreLocation/CoreLocation.h>


@interface CLLocationManager (MASPrivate)



///--------------------------------------
/// @name Authorization Status
///--------------------------------------

# pragma mark - Authorization Status

/**
 * Retrieve a human readable string value for a CLAuthorizationStatus enumeration.
 *
 * @param status The CLAuthorizationStatus value.
 */
+ (NSString *)authorizationStatusToString:(CLAuthorizationStatus)status;

@end
