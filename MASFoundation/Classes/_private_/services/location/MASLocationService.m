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

static NSTimeInterval const kMASLocationServiceTimerInterval = 300;

@interface MASLocationService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *lastKnownLocationTime;
@property (nonatomic, strong) NSTimer *locationTimer;
@property (assign) BOOL didFailToAuthorize;

@end


@implementation MASLocationService

@synthesize locationAccuracy = _locationAccuracy;
@synthesize locationUpdateInterval = _locationUpdateInterval;
@synthesize lastKnownLocation = _lastKnownLocation;


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

+ (void)load
{
    [MASService registerSubclass:[self class] serviceUUID:MASLocationServiceUUID];
}


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
    // If the configuration specifies that we need location services force the request for
    // authorization.  It will skip it if already granted.
    //
    if ([MASConfiguration currentConfiguration].locationIsRequired)
    {
        if (_locationManager != nil)
        {
            [_locationManager stopUpdatingLocation];
            _locationManager = nil;
        }
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        
        NSString *locationAccuracy = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"kMASLocationServiceAccuracy"];
        NSInteger locationUpdateTimerInterval = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"kMASLocationServiceUpdateTimerInterval"] integerValue];
        
        //
        //  Default to nearest 3000 meters and update time interval of 5 minutes (300 seconds)
        //
        _locationAccuracy = [self locationAccuracyFromString:locationAccuracy];
        _locationUpdateInterval = kMASLocationServiceTimerInterval;
        
        if (locationUpdateTimerInterval > 1)
        {
            _locationUpdateInterval = locationUpdateTimerInterval;
        }
        
        [_locationManager setDesiredAccuracy:_locationAccuracy];
        [_locationManager setDistanceFilter:_locationAccuracy];
        
        [self requestAuthorizationToUseLocation];
    }
    
    //
    // Regardless of the location status, SDK should successfully initialize SDK.
    // In case of unavailable location from the device, it would simply not send location information in the request,
    // and return a proper error from the endpoint (if needed).
    //
    [super serviceWillStart];
}


- (void)serviceWillStop
{
    [super serviceWillStop];
    
    //
    //  Stop monitoring the location service
    //
    if (_locationManager != nil)
    {
        [_locationManager stopUpdatingLocation];
        _locationManager = nil;
    }
    
    //
    //  Stop timer location update
    //
    [self stopSchedulingLocationUpdate];
    
    _lastKnownLocation = nil;
    _lastKnownLocationTime = nil;
}


- (void)serviceDidReset
{
    //
    // Reset the value
    //
    _monitoringBlock = nil;
    
    [super serviceDidReset];
}


# pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    _lastKnownLocation = [locations firstObject];
    self.lastKnownLocationTime = [NSDate date];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //
    //  If the error was returned specifying location unknown, unllify the last known location information
    //
    if (error.domain == kCLErrorDomain && error.code == kCLErrorLocationUnknown)
    {
        _lastKnownLocation = nil;
        self.lastKnownLocationTime = nil;
    }
    
    if (error.domain == kCLErrorDomain && error.code == kCLErrorDenied)
    {
        //
        //  If the permission denied during runtime, stop the scheduler
        //
        [self stopSchedulingLocationUpdate];
    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self initializeSchedulingLocationupdate];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusNotDetermined:
        default:
            break;
    }
}


# pragma mark - Private

- (void)initializeSchedulingLocationupdate
{
    if (_locationTimer != nil)
    {
        [_locationTimer invalidate];
        _locationTimer = nil;
    }
    
    _locationTimer = [NSTimer timerWithTimeInterval:_locationUpdateInterval target:self selector:@selector(requestLocationSingleUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_locationTimer forMode:NSRunLoopCommonModes];
    [_locationTimer fire];
}


- (void)stopSchedulingLocationUpdate
{
    if (_locationTimer != nil)
    {
        [_locationTimer invalidate];
        _locationTimer = nil;
    }
}


- (void)requestLocationSingleUpdate
{
    if ([MASConfiguration currentConfiguration].locationIsRequired && _locationManager != nil && !self.didFailToAuthorize)
    {
        [_locationManager requestLocation];
    }
}


- (void)requestAuthorizationToUseLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    //
    //  Only when the location authorization is not determined, ask for authorization
    //
    if (status == kCLAuthorizationStatusNotDetermined && [CLLocationManager locationServicesEnabled])
    {
        //
        //  Make sure that the application has proper privacy description for using location
        //
        BOOL alwaysInUseKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
        BOOL whenInUseKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        if (alwaysInUseKey)
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        else if (whenInUseKey)
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
        else {
            self.didFailToAuthorize = YES;
        }
    }
}


- (NSString *)locationServiceStatusAsString
{
    NSString *statusAsString = @"";
    
    switch ([[MASLocationService sharedService] locationServiceStatus]) {
        case MASLocationServiceStatusAvailable:
            statusAsString = @"Location service is available and collecting the information.";
            break;
        case MASLocationServiceStatusRestricted:
            statusAsString = @"Location service authorization is restricted.";
            break;
        case MASLocationServiceStatusDenied:
            statusAsString = @"Location service authorization has been denied to the application.";
            break;
        case MASLocationServiceStatusNotDetermined:
            statusAsString = @"Location service authorization choice has not been made yet.";
            break;
        case MASLocationServiceStatusDisabled:
            statusAsString = @"Location service authorization has been disabled on the device.";
            break;
        case MASLocationServiceStatusFailToAuthorize:
            statusAsString = @"Location service failed to request authorization due to missing Privacy information in .plist file of the application.";
            break;
        default:
            statusAsString = @"Unknown location service status.";
            break;
    }

    return statusAsString;
}


- (CLLocationAccuracy)locationAccuracyFromString:(NSString *)locationAccuracyString
{
    CLLocationAccuracy locationAccuracy;
    
    if ([locationAccuracyString isEqualToString:@"kCLLocationAccuracyBestForNavigation"])
    {
        locationAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    else if ([locationAccuracyString isEqualToString:@"kCLLocationAccuracyBest"])
    {
        locationAccuracy = kCLLocationAccuracyBest;
    }
    else if ([locationAccuracyString isEqualToString:@"kCLLocationAccuracyNearestTenMeters"])
    {
        locationAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    else if ([locationAccuracyString isEqualToString:@"kCLLocationAccuracyHundredMeters"])
    {
        locationAccuracy = kCLLocationAccuracyHundredMeters;
    }
    else if ([locationAccuracyString isEqualToString:@"kCLLocationAccuracyKilometer"])
    {
        locationAccuracy = kCLLocationAccuracyKilometer;
    }
    else {
        locationAccuracy = kCLLocationAccuracyThreeKilometers;
    }
    
    return locationAccuracy;
}


# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    location services authorization status: %@",
        [super debugDescription],
        [[MASLocationService sharedService] locationServiceStatusAsString]];
}


- (CLLocation *)getLastKnownLocation
{
    CLLocation *mostRecentLocation = nil;
    
    //
    //  Only return the last know location information when the location service is allowed
    //
    if ([[MASLocationService sharedService] locationServiceStatus] == MASLocationServiceStatusAvailable && [MASConfiguration currentConfiguration].locationIsRequired)
    {
        mostRecentLocation = _lastKnownLocation;
    }
    
    return mostRecentLocation;
}


- (void)setLocationAccuracy:(CLLocationAccuracy)locationAccuracy
{
    _locationAccuracy = locationAccuracy;
    
    if (self.locationManager != nil && self.locationManager.desiredAccuracy != _locationAccuracy)
    {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager setDistanceFilter:_locationAccuracy];
        [self.locationManager setDesiredAccuracy:_locationAccuracy];
        [self initializeSchedulingLocationupdate];
    }
}


- (CLLocationAccuracy)getLocationAccuracy
{
    return _locationAccuracy;
}


- (void)setLocationUpdateInterval:(NSTimeInterval)locationUpdateInterval
{
    _locationUpdateInterval = locationUpdateInterval;
    [self initializeSchedulingLocationupdate];
}


- (NSTimeInterval)getLocationUpdateInterval
{
    return _locationUpdateInterval;
}


- (MASLocationServiceStatus)locationServiceStatus
{
    MASLocationServiceStatus status = MASLocationServiceStatusAvailable;
    
    if (![CLLocationManager locationServicesEnabled])
    {
        status = MASLocationServiceStatusDisabled;
    }
    else if (self.didFailToAuthorize)
    {
        status = MASLocationServiceStatusFailToAuthorize;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        status = MASLocationServiceStatusNotDetermined;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        status = MASLocationServiceStatusDenied;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        status = MASLocationServiceStatusRestricted;
    }
    
    return status;
}

@end
