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



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The location updates monitoring block to notify any interested component that the location has changed.
 */
@property (nonatomic, copy) MASLocationMonitorBlock monitoringBlock;



///--------------------------------------
/// @name Location Monitoring
///--------------------------------------

# pragma mark - Location Monitoring




/**
 *  Retrieves the status of whether the location services have been authorized or declined before. 
 *
 *  @return Returns YES if the location services have not been determinded before. Returns no if location services have been determined before.
 */
+ (BOOL)isLocationMonitoringNotDetermined;


/**
 *  Retrieves the current authorization status of location services for the application and return boolean value of whether it is authorized or not.
 *
 *  @return Returns YES if the application has been authorized to use location services, NO if not.
 */
+ (BOOL)isLocationMonitoringAuthorized;


/**
 *  Retrieves the current authorization status of location services for the application and return boolean value of whether it is denied or not.
 *
 *  @return Retruns YES if the application does not have an access to the location service or the authorization status is not determined (not asked for permission yet).
 */
+ (BOOL)isLocationMonitoringDenied;


/**
 *  Retrieves the current location monitoring accuracy as a human readable string.
 *
 *  The location monitoring accuracy enumerated values to their string equivalents are:
 *
 *      MASLocationMonitoringAccuracyNone = "Location inaccurate (greater than 5000 meters and/or received more than 10 minutes ago"
 *      MASLocationMonitoringAccuracyCity = "5000 meters or better and received within the last 10 minutes (Lowest accuracy)"
 *      MASLocationMonitoringAccuracyNeighborhood = "1000 meters or better and received within the last 5 minutes"
 *      MASLocationMonitoringAccuracyBlock = "100 meters or better and received within the last 1 minute"
 *      MASLocationMonitoringAccuracyHouse = "15 meters or better and received within the last 15 seconds"
 *      MASLocationMonitoringAccuracyRoom = "5 meters or better and received within the last 5 seconds (Highest accuracy)"
 *
 *  @return Returns the location monitoring accuracy as a human readable NSString.
 */
+ (NSString *)locationMonitoringAccuracyToString:(MASLocationMonitoringAccuracy)accuracy;


/**
 *  Retrieves the current location monitoring status.
 *
 *  The monitoring status enumerated values to their string equivalents are:
 *
 *      MASLocationMonitoringStatusSuccess = "Location retrieved successfully"
 *      MASLocationMonitoringStatusTimedOut = "Location retrieved but not with the requested accurracy before timeout occurred"
 *      MASLocationMonitoringStatusServicesNotDetermined = "Location service authorization choice has not been made yet"
 *      MASLocationMonitoringStatusServicesDenied = "Location service authorization has been denied to the application"
 *      MASLocationMonitoringStatusServicesRestricted = "Location service authorization is restricted"
 *      MASLocationMonitoringStatusServicesDisabled = "Location service authorization has been disabled on the device"
 *      MASLocationMonitoringStatusError = "Error on attempt to retrieve a location"
 *
 *  @return Returns the monitoring status as a human readable NSString.
 */
+ (NSString *)locationMonitoringStatusToString:(MASLocationMonitoringStatus)status;



///--------------------------------------
/// @name Location Updates
///--------------------------------------

# pragma mark - Location Updates

/**
 * Request a single location update.
 *
 * @param monitor The MASLocationMonitorBlock that will receive the updated location.
 * @return Returns the unique MASLocationUpdateId of the requested update.  This can be used to
 * cancel the request, if necessary.
 */
- (MASLocationUpdateId)startSingleLocationUpdate:(MASLocationMonitorBlock)monitor;


/** 
 * Immediately cancels the location request (or subscription) with the given updateId (if it exists), without executing
 * the monitor block.  It is silently cancelled.
 *
 * @param id The unique update identifier for a previous udpate request.
 */
- (void)cancelLocationUpdate:(MASLocationUpdateId)updateId;

@end
