//
//  CLLocation+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "CLLocation+MASPrivate.h"


@implementation CLLocation (MASPrivate)


- (NSString *)locationAsGeoCoordinates
{
    return [NSString stringWithFormat:@"%f,%f",
        self.coordinate.latitude,
        self.coordinate.longitude];
}

@end
