//
//  MASNetworkReachability.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASNetworkReachability.h"
#import "MASNotifications.h"
#import "NSString+MASPrivate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <arpa/inet.h>


# pragma mark - Network Monitoring Constants

NSString *const MASNetworkReachabilityStatusUnknownValue = @"Unknown";
NSString *const MASNetworkReachabilityStatusNotReachableValue = @"Not Reachable";
NSString *const MASNetworkReachabilityStatusReachableViaWWANValue = @"Reachable Via WWAN";
NSString *const MASNetworkReachabilityStatusReachableViaWiFiValue = @"Reachable Via WiFi";
NSString *const MASNetworkReachabilityStatusInitializingValue = @"Initializing network manager";


#
# pragma mark - MASNetworkReachability
#

@interface MASNetworkReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, assign) MASNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, copy) MASNetworkReachabilityStatusBlock reachabilityStatusBlock;

@end


@implementation MASNetworkReachability

# pragma mark - Lifecycle

- (instancetype)initWithDomain:(NSString *)domain
{
    self = [super init];
    
    if (self)
    {
        if ([domain isIPAddress])
        {
            //
            //  If the domain is IP address format
            //
            struct sockaddr_in address;
            bzero(&address, sizeof(address));
            address.sin_len = sizeof(address);
            address.sin_family = AF_INET;
            address.sin_addr.s_addr = inet_addr([domain UTF8String]);
            self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&address);
        }
        else {
            //
            //  If the domain is DNS format
            //
            self.reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
        }
        
        self.domain = domain;
        self.reachabilityStatus = MASNetworkReachabilityStatusInitializing;
    }
    
    return self;
}


- (instancetype)initWithAddress:(const struct sockaddr *)address
{
    self = [super init];
    
    if (self)
    {
        self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, address);
        self.domain = @"default";
        self.reachabilityStatus = MASNetworkReachabilityStatusInitializing;
    }
    
    return self;
}


- (instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`-init` is not available. Use `-initWithDomain:` instead"
                                 userInfo:nil];
    return nil;
}


+ (instancetype)new
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`+new` is not available. Use `-initWithDomain:` instead"
                                 userInfo:nil];
    return nil;
}


- (void)dealloc
{
    [self stopMonitoring];
    
    if (self.reachabilityRef != NULL)
    {
        //  release reachability reference
        CFRelease(self.reachabilityRef);
    }
}


# pragma mark - Public getter methods

- (NSString *)reachabilityStatusAsString
{
    NSString *reachabilityStatusAsString = @"";
    
    switch (self.reachabilityStatus) {
        case MASNetworkReachabilityStatusNotReachable:
            reachabilityStatusAsString = MASNetworkReachabilityStatusNotReachableValue;
            break;
        case MASNetworkReachabilityStatusReachableViaWiFi:
            reachabilityStatusAsString = MASNetworkReachabilityStatusReachableViaWiFiValue;
            break;
        case MASNetworkReachabilityStatusReachableViaWWAN:
            reachabilityStatusAsString = MASNetworkReachabilityStatusReachableViaWWANValue;
            break;
        case MASNetworkReachabilityStatusInitializing:
            reachabilityStatusAsString = MASNetworkReachabilityStatusInitializingValue;
            break;
        case MASNetworkReachabilityStatusUnknown:
        default:
            reachabilityStatusAsString = MASNetworkReachabilityStatusUnknownValue;
            break;
    }
    
    return reachabilityStatusAsString;
}


- (BOOL)isReachable
{
    return (self.reachabilityStatus == MASNetworkReachabilityStatusReachableViaWiFi || self.reachabilityStatus == MASNetworkReachabilityStatusReachableViaWWAN);
}


# pragma mark - Public

- (void)startMonitoring
{
    [self stopMonitoring];
    
    if (self.reachabilityRef != NULL)
    {
        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        SCNetworkReachabilitySetCallback(self.reachabilityRef, MASNetworkReachabilityCallback, &context);
        SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        
        //
        //  Asynchronous reachability check with IP address does not invoke the callback for initial status.
        //  synchronous reachability has to be invoked for the first time to trigger the asynchronous callback
        //
        if ([self.domain isEqualToString:@"default"] || [self.domain isIPAddress])
        {
            __block __typeof(self) blockSelf = self;
            dispatch_async(dispatch_queue_create("com.ca.mas.networking.reachability.synchronous.flags", NULL), ^{
                SCNetworkReachabilityFlags flags;
                if (SCNetworkReachabilityGetFlags(blockSelf.reachabilityRef, &flags))
                {
                    [blockSelf reachabilityStatusUpdate:flags];
                }
            });
        }
    }
}


- (void)stopMonitoring
{
    self.reachabilityStatus = MASNetworkReachabilityStatusUnknown;
    if (self.reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    }
}


- (void)setReachabilityMonitoringBlock:(MASNetworkReachabilityStatusBlock)block
{
    self.reachabilityStatusBlock = block;
}


# pragma mark - Private helper methods

- (MASNetworkReachabilityStatus)reachabilityStatusFromFlags:(SCNetworkReachabilityFlags)flags
{
    //
    //  Parsing reference: https://developer.apple.com/documentation/systemconfiguration/scnetworkreachabilityflags?language=objc
    //
    BOOL reachableFlag = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL connectionRequired = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL connectionOnDemandFlag = ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0);
    BOOL connectionOnTrafficFlag = ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0);
    BOOL interventionRequiredFlag = ((flags & kSCNetworkReachabilityFlagsInterventionRequired) != 0);
    BOOL wwanFlag = ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
    
    MASNetworkReachabilityStatus status = MASNetworkReachabilityStatusNotReachable;
    
    //  Not reachable
    if (!reachableFlag)
    {
        return status;
    }
    
    //  If connection is not required, and reachable through WiFi
    if (!connectionRequired)
    {
        status = MASNetworkReachabilityStatusReachableViaWiFi;
    }
    
    //  If either of OnDemand or OnTraffic is set to true, and user intervention is not required, reachable through WiFi.
    if (connectionOnDemandFlag || connectionOnTrafficFlag)
    {
        if (!interventionRequiredFlag)
        {
            status = MASNetworkReachabilityStatusReachableViaWiFi;
        }
    }
    
    //  WWAN
    if (wwanFlag)
    {
        status = MASNetworkReachabilityStatusReachableViaWWAN;
    }
    
    return status;
}


- (void)reachabilityStatusUpdate:(SCNetworkReachabilityFlags)flags
{
    MASNetworkReachabilityStatus status = [self reachabilityStatusFromFlags:flags];
    
    __block __typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //
        //  Update, and notify status
        //
        blockSelf.reachabilityStatus = status;
        if (blockSelf.reachabilityStatusBlock)
        {
            blockSelf.reachabilityStatusBlock(status);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MASNetworkReachabilityStatusUpdateNotification object:@{blockSelf.domain : [NSNumber numberWithInt:blockSelf.reachabilityStatus]}];
    });
}


#
# pragma mark - SCNetworkReachability callbacks
#

static void MASNetworkReachabilityCallback(SCNetworkReachabilityRef reachabilityRef, SCNetworkReachabilityFlags flags, void* info)
{
    if ([(__bridge id)info isKindOfClass:[MASNetworkReachability class]])
    {
        MASNetworkReachability *reachability = (__bridge MASNetworkReachability *)info;
        [reachability reachabilityStatusUpdate:flags];
    }
}

@end
