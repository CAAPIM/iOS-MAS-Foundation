//
//  CLLocation+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <CoreLocation/CoreLocation.h>


@interface CLLocation (MASPrivate)


/**
 * Returns a geo-location formatted string using the current location.
 * 
 * The format is "<lat>,<long>"
 *
 * @return Returns NSString geo-location.
 */
- (NSString *)locationAsGeoCoordinates;
               
@end
