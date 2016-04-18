// MASINetworkReachabilityManager.m
// Copyright (c) 2011–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MASINetworkReachabilityManager.h"

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const MASINetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString * const MASINetworkingReachabilityNotificationStatusItem = @"MASINetworkingReachabilityNotificationStatusItem";

typedef void (^MASINetworkReachabilityStatusBlock)(MASINetworkReachabilityStatus status);

typedef NS_ENUM(NSUInteger, MASINetworkReachabilityAssociation) {
    MASINetworkReachabilityForAddress = 1,
    MASINetworkReachabilityForAddressPair = 2,
    MASINetworkReachabilityForName = 3,
};

NSString * MASIStringFromNetworkReachabilityStatus(MASINetworkReachabilityStatus status) {
    switch (status) {
        case MASINetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"MASINetworking", nil);
        case MASINetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"MASINetworking", nil);
        case MASINetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"MASINetworking", nil);
        case MASINetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"MASINetworking", nil);
    }
}

static MASINetworkReachabilityStatus MASINetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    MASINetworkReachabilityStatus status = MASINetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = MASINetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = MASINetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = MASINetworkReachabilityStatusReachableViaWiFi;
    }

    return status;
}

static void MASINetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    MASINetworkReachabilityStatus status = MASINetworkReachabilityStatusForFlags(flags);
    MASINetworkReachabilityStatusBlock block = (__bridge MASINetworkReachabilityStatusBlock)info;
    if (block) {
        block(status);
    }


    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ MASINetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:MASINetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });

}

static const void * MASINetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void MASINetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface MASINetworkReachabilityManager ()
@property (readwrite, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) MASINetworkReachabilityAssociation networkReachabilityAssociation;
@property (readwrite, nonatomic, assign) MASINetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) MASINetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation MASINetworkReachabilityManager

+ (instancetype)sharedManager {
    static MASINetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;

        _sharedManager = [self managerForAddress:&address];
    });

    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);

    MASINetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = MASINetworkReachabilityForName;
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);

    MASINetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = MASINetworkReachabilityForAddress;
    return manager;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.networkReachability = reachability;
    self.networkReachabilityStatus = MASINetworkReachabilityStatusUnknown;

    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];

    if (_networkReachability) {
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == MASINetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == MASINetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];

    if (!self.networkReachability) {
        return;
    }

    __weak __typeof(self)weakSelf = self;
    MASINetworkReachabilityStatusBlock callback = ^(MASINetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }

    };

    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, MASINetworkReachabilityRetainCallback, MASINetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, MASINetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

    switch (self.networkReachabilityAssociation) {
        case MASINetworkReachabilityForName:
            break;
        case MASINetworkReachabilityForAddress:
        case MASINetworkReachabilityForAddressPair:
        default: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                SCNetworkReachabilityFlags flags;
                SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
                MASINetworkReachabilityStatus status = MASINetworkReachabilityStatusForFlags(flags);
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(status);

                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:MASINetworkingReachabilityDidChangeNotification object:nil userInfo:@{ MASINetworkingReachabilityNotificationStatusItem: @(status) }];


                });
            });
        }
            break;
    }
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }

    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return MASIStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(MASINetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
