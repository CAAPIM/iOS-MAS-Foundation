//
//  MASLocationService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASLocationService.h"

#import "MASConstantsPrivate.h"
#import "MASConfigurationService.h"
#import "MASINTULocationManager.h"


@interface MASLocationService ()
    <MASINTULocationManagerDelegate>

@property (nonatomic, copy) MASCompletionErrorBlock locationAuthorizationBlock;

@end


@implementation MASLocationService


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[MASLocationService alloc] initProtected];
    });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (NSString *)serviceUUID
{
    return MASLocationServiceUUID;
}


- (void)serviceDidLoad
{

    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    
    //
    // Retrieve the configuration
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    
    //
    // If the configuration specifies that we need location services force the request for
    // authorization.  It will skip it if already granted.
    //
    if(configuration.locationIsRequired)
    {
        [MASINTULocationManager sharedInstance].delegate = self;
        [self serviceDidLoadCompletion:^(BOOL completed, NSError *error)
         {
             //
             // Regardless of the location status, SDK should successfully initialize SDK.
             // In case of unavailable location from the device, it would simply not send location information in the request,
             // and return a proper error from the endpoint (if needed).
             //
             [super serviceWillStart];
         }];
    }
    else {
        [super serviceWillStart];
    }
}


- (void)serviceDidReset
{
    //
    // Reset the value
    //
    _monitoringBlock = nil;
    
    [super serviceDidReset];
}


# pragma mark - Private

- (void)serviceDidLoadCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Set the callback block
    //
    self.locationAuthorizationBlock = completion;
    
    
    //
    // If the location service is already available
    //
    if ([MASLocationService isLocationMonitoringAuthorized])
    {
        completion(YES, nil);
    }
    //
    // If the location service is determined, but not available (Unauthorized)
    //
    else if (![MASLocationService isLocationMonitoringNotDetermined])
    {
        completion(NO, [NSError errorGeolocationServicesAreUnauthorized]);
    }
    //
    // Otherwise, request authorization from the user
    //
    else {
        
        [[MASINTULocationManager sharedInstance] requestAuthorizationIfNeeded];
    }
}


# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    location services authorization status: %@",
        [super debugDescription],
        [MASLocationService locationMonitoringAuthorizationStatusToString:(int)MASINTULocationManager.locationServicesState]];
}


# pragma mark - Location Monitoring

+ (BOOL)isLocationMonitoringNotDetermined
{
    return ([MASINTULocationManager locationServicesState] == MASINTULocationServicesStateNotDetermined);
}

+ (BOOL)isLocationMonitoringAuthorized
{
    return ([MASINTULocationManager locationServicesState] == MASINTULocationServicesStateAvailable);
}


+ (BOOL)isLocationMonitoringDenied
{
    return ([MASINTULocationManager locationServicesState] != MASINTULocationServicesStateAvailable && [MASINTULocationManager locationServicesState] != MASINTULocationServicesStateNotDetermined);
}


+ (NSString *)locationMonitoringAccuracyToString:(MASLocationMonitoringAccuracy)accuracy
{
    //
    // Detect accuracy and respond appropriately
    //
    switch(accuracy)
    {
        //
        // No Accuracy
        //
        case MASLocationMonitoringAccuracyNone: return @"Location inaccurate (greater than 5000 meters and/or received more than 10 minutes ago";
        
        //
        // City
        //
        case MASLocationMonitoringAccuracyCity: return @"5000 meters or better and received within the last 10 minutes (Lowest accuracy)";
        
        //
        // Neighborhood
        //
        case MASLocationMonitoringAccuracyNeighborhood: return @"1000 meters or better and received within the last 5 minutes";
        
        //
        // Block
        //
        case MASLocationMonitoringAccuracyBlock: return @"100 meters or better and received within the last 1 minute";
        
        //
        // House
        //
        case MASLocationMonitoringAccuracyHouse: return @"15 meters or better and received within the last 15 seconds";
        
        //
        // Room
        //
        case MASLocationMonitoringAccuracyRoom: return @"5 meters or better and received within the last 5 seconds (Highest accuracy)";
 
        //
        // Default
        //
        default: return @"Unknown";
    }
}


+ (NSString *)locationMonitoringStatusToString:(MASLocationMonitoringStatus)status
{
    //
    // Detect status and respond appropriately
    //
    switch(status)
    {
        //
        // Success
        //
        case MASLocationMonitoringStatusSuccess: return @"Location retrieved successfully";
        
        //
        // Timed Out
        //
        case MASLocationMonitoringStatusTimedOut: return @"Location retrieved but not with the requested accurracy before timeout occurred";
        
        //
        // Not Determined
        //
        case MASLocationMonitoringStatusServicesNotDetermined: return @"Location service authorization choice has not been made yet";
        
        //
        // Denied
        //
        case MASLocationMonitoringStatusServicesDenied: return @"Location service authorization has been denied to the application";
        
        //
        // Restricted
        //
        case MASLocationMonitoringStatusServicesRestricted: return @"Location service authorization is restricted";
        
        //
        // Disabled
        //
        case MASLocationMonitoringStatusServicesDisabled: return @"Location service authorization has been disabled on the device";
        
        //
        // Error
        //
        case MASLocationMonitoringStatusError: return @"Error on attempt to retrieve a location";
 
        //
        // Default
        //
        default: return @"Unknown";
    }
}


+ (NSString *)locationMonitoringAuthorizationStatusToString:(MASLocationMonitoringStatus)status
{
    //
    // Detect status and respond appropriately
    //
    switch(status)
    {
        //
        // Success
        //
        case MASLocationMonitoringStatusSuccess:
        case MASLocationMonitoringStatusTimedOut: return @"Location service authorized";
        
        //
        // Default
        //
        default: return [self locationMonitoringStatusToString:status];
    }
}


# pragma mark - Location Updates

- (MASLocationUpdateId)startSingleLocationUpdate:(MASLocationMonitorBlock)monitor;
{
    //DLog(@"\n\ncalled\n\n");
    
    MASINTULocationManager *locMgr = [MASINTULocationManager sharedInstance];
    
    return [locMgr requestLocationWithDesiredAccuracy:MASINTULocationAccuracyNeighborhood
        timeout:5
        delayUntilAuthorized:YES
        block:^(CLLocation *currentLocation, MASINTULocationAccuracy achievedAccuracy, MASINTULocationStatus status)
        {
            //DLog(@"\n\n (internal) called with new location: %@\n  at accuracy: %@\n  with status: %@\n\n",
            //    [currentLocation debugDescription], [MASLocationService locationMonitoringAccuracyToString:(int)achievedAccuracy],
            //    [MASLocationService locationMonitoringStatusToString:(int)status]);
            
            //
            // Notify
            //
            if(monitor) monitor(currentLocation, (int)achievedAccuracy, (int)status);
        }];
}


- (void)cancelLocationUpdate:(MASLocationUpdateId)updateId
{
    [[MASINTULocationManager sharedInstance] cancelLocationRequest:updateId];
}


# pragma mark - MASINTULocationManagerDelegate

- (void)didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //DLog(@"called with new status: %@ and block is: %@",
    //   [CLLocationManager authorizationStatusToString:status],
    //   self.locationAuthorizationBlock);
    
    //
    // Ignore an not determined state
    //
    if(status == kCLAuthorizationStatusNotDetermined) return;
    
    //
    // Else a choice has been made and there is a block waiting for the response
    //
    if(self.locationAuthorizationBlock)
    {
        //
        // Authorized
        //
        if(status == kCLAuthorizationStatusAuthorizedAlways ||
           status == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            self.locationAuthorizationBlock(YES, nil);
        }
        
        //
        // Else no
        //
        else
        {
            self.locationAuthorizationBlock(NO, [NSError errorGeolocationServicesAreUnauthorized]);
        }
    }
}

@end
