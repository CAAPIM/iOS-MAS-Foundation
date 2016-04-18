//
//  MASINTULocationRequestDefines.h
//
//  Copyright (c) 2014-2015 MASINTUit Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#ifndef MASINTU_LOCATION_REQUEST_DEFINES_H
#define MASINTU_LOCATION_REQUEST_DEFINES_H

@import Foundation;
#import <CoreLocation/CoreLocation.h>

#if __has_feature(nullability)
#   define __MASINTU_ASSUME_NONNULL_BEGIN      NS_ASSUME_NONNULL_BEGIN
#   define __MASINTU_ASSUME_NONNULL_END        NS_ASSUME_NONNULL_END
#   define __MASINTU_NULLABLE                  nullable
#else
#   define __MASINTU_ASSUME_NONNULL_BEGIN
#   define __MASINTU_ASSUME_NONNULL_END
#   define __MASINTU_NULLABLE
#endif

#if __has_feature(objc_generics)
#   define __MASINTU_GENERICS(type, ...)       type<__VA_ARGS__>
#else
#   define __MASINTU_GENERICS(type, ...)       type
#endif

#ifdef NS_DESIGNATED_INITIALIZER
#   define __MASINTU_DESIGNATED_INITIALIZER    NS_DESIGNATED_INITIALIZER
#else
#   define __MASINTU_DESIGNATED_INITIALIZER
#endif

static const CLLocationAccuracy kMASINTUHorizontalAccuracyThresholdCity =         5000.0;  // in meters
static const CLLocationAccuracy kMASINTUHorizontalAccuracyThresholdNeighborhood = 1000.0;  // in meters
static const CLLocationAccuracy kMASINTUHorizontalAccuracyThresholdBlock =         100.0;  // in meters
static const CLLocationAccuracy kMASINTUHorizontalAccuracyThresholdHouse =          15.0;  // in meters
static const CLLocationAccuracy kMASINTUHorizontalAccuracyThresholdRoom =            5.0;  // in meters

static const NSTimeInterval kMASINTUUpdateTimeStaleThresholdCity =             600.0;  // in seconds
static const NSTimeInterval kMASINTUUpdateTimeStaleThresholdNeighborhood =     300.0;  // in seconds
static const NSTimeInterval kMASINTUUpdateTimeStaleThresholdBlock =             60.0;  // in seconds
static const NSTimeInterval kMASINTUUpdateTimeStaleThresholdHouse =             15.0;  // in seconds
static const NSTimeInterval kMASINTUUpdateTimeStaleThresholdRoom =               5.0;  // in seconds

/** The possible states that location services can be in. */
typedef NS_ENUM(NSInteger, MASINTULocationServicesState) {
    /** User has already granted this app permissions to access location services, and they are enabled and ready for use by this app.
        Note: this state will be returned for both the "When In Use" and "Always" permission levels. */
    MASINTULocationServicesStateAvailable,
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    MASINTULocationServicesStateNotDetermined,
    /** User has explicitly denied this app permission to access location services. (The user can enable permissions again for this app from the system Settings app.) */
    MASINTULocationServicesStateDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    MASINTULocationServicesStateRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    MASINTULocationServicesStateDisabled
};

/** A unique ID that corresponds to one location request. */
typedef NSInteger MASINTULocationRequestID;

/** An abstraction of both the horizontal accuracy and recency of location data.
    Room is the highest level of accuracy/recency; City is the lowest level. */
typedef NS_ENUM(NSInteger, MASINTULocationAccuracy) {
    // 'None' is not valid as a desired accuracy.
    /** Inaccurate (>5000 meters, and/or received >10 minutes ago). */
    MASINTULocationAccuracyNone = 0,
    
    // The below options are valid desired accuracies.
    /** 5000 meters or better, and received within the last 10 minutes. Lowest accuracy. */
    MASINTULocationAccuracyCity,
    /** 1000 meters or better, and received within the last 5 minutes. */
    MASINTULocationAccuracyNeighborhood,
    /** 100 meters or better, and received within the last 1 minute. */
    MASINTULocationAccuracyBlock,
    /** 15 meters or better, and received within the last 15 seconds. */
    MASINTULocationAccuracyHouse,
    /** 5 meters or better, and received within the last 5 seconds. Highest accuracy. */
    MASINTULocationAccuracyRoom,
};

/** A status that will be passed in to the completion block of a location request. */
typedef NS_ENUM(NSInteger, MASINTULocationStatus) {
    // These statuses will accompany a valid location.
    /** Got a location and desired accuracy level was achieved successfully. */
    MASINTULocationStatusSuccess = 0,
    /** Got a location, but the desired accuracy level was not reached before timeout. (Not applicable to subscriptions.) */
    MASINTULocationStatusTimedOut,
    
    // These statuses indicate some sort of error, and will accompany a nil location.
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    MASINTULocationStatusServicesNotDetermined,
    /** User has explicitly denied this app permission to access location services. */
    MASINTULocationStatusServicesDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    MASINTULocationStatusServicesRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    MASINTULocationStatusServicesDisabled,
    /** An error occurred while using the system location services. */
    MASINTULocationStatusError
};

/**
 A block type for a location request, which is executed when the request succeeds, fails, or times out.
 
 @param currentLocation The most recent & accurate current location available when the block executes, or nil if no valid location is available.
 @param achievedAccuracy The accuracy level that was actually achieved (may be better than, equal to, or worse than the desired accuracy).
 @param status The status of the location request - whether it succeeded, timed out, or failed due to some sort of error. This can be used to
               understand what the outcome of the request was, decide if/how to use the associated currentLocation, and determine whether other
               actions are required (such as displaying an error message to the user, retrying with another request, quietly proceeding, etc).
 */
typedef void(^MASINTULocationRequestBlock)(CLLocation *currentLocation, MASINTULocationAccuracy achievedAccuracy, MASINTULocationStatus status);

#endif /* MASINTU_LOCATION_REQUEST_DEFINES_H */
