//
//  MASLocationService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"
#import "MASConstantsPrivate.h"

@interface MASLocationService : MASService

/**
 MASLocationServiceStatus enumeration value. This enumeration value represents current status of location service in MASFoundation.

 - MASLocationServiceStatusFailToAuthorize: Location service has failed to request authorization to the user due to missing privacy information in .plist file of the application.
 - MASLocationServiceStatusAvailable: Location service has been enabled, and granted permission; the location information will be available.
 - MASLocationServiceStatusNotDetermined: Location service has not been determined by the user yet.
 - MASLocationServiceStatusDenied: Location service has been denied by the user to the application.
 - MASLocationServiceStatusRestricted: Location service has been restricted due to the device limitation, or policy.
 - MASLocationServiceStatusDisabled: Location service has been disabled for the application.
 */
typedef NS_ENUM(NSInteger, MASLocationServiceStatus)
{
    MASLocationServiceStatusFailToAuthorize,
    MASLocationServiceStatusAvailable,
    MASLocationServiceStatusNotDetermined,
    MASLocationServiceStatusDenied,
    MASLocationServiceStatusRestricted,
    MASLocationServiceStatusDisabled
};



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The location updates monitoring block to notify any interested component that the location has changed.
 */
@property (nonatomic, copy) MASLocationMonitorBlock monitoringBlock;


/**
 CLLocation object that represents the most recent location information that was collected by SDK.
 */
@property (nonatomic, strong, readonly, getter=getLastKnownLocation) CLLocation *lastKnownLocation;


/**
 CLLocationAccuracy that represents the accuracy of the location information that was requested to the iOS.
 */
@property (assign, setter=setLocationAccuracy:, getter=getLocationAccuracy) CLLocationAccuracy locationAccuracy;


/**
 NSTimeInterval that represents the time interval of the location information that is constantly being collected.
 Default time interval set by SDK is 5 minutes (300 seconds).
 */
@property (assign, setter=setLocationUpdateInterval:, getter=getLocationUpdateInterval) NSTimeInterval locationUpdateInterval;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 Current location service status of the application.

 @return MASLocationServiceStatus enumeration value representing current status.
 */
- (MASLocationServiceStatus)locationServiceStatus;

@end
