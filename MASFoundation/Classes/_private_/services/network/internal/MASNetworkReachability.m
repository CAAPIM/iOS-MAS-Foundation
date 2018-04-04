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
#import "NSString+MASPrivate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <arpa/inet.h>


@interface MASNetworkReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, assign) MASNetworkReachabilityStatus status;

@end


@implementation MASNetworkReachability


# pragma mark - Lifecycle

- (instancetype)initWithDomain:(NSURL *)domain
{
    self = [super init];
    
    if (self)
    {
        if ([domain.host isIPAddress])
        {
            //
            //  If the domain is IP address format
            //
            static struct sockaddr_in hostAddress;
            bzero(&hostAddress, sizeof(hostAddress));
            hostAddress.sin_len = sizeof(hostAddress);
            hostAddress.sin_family = AF_INET;
            
            if (domain.port)
            {
                hostAddress.sin_port = htons([domain.port intValue]);
            }
            
            hostAddress.sin_addr.s_addr = inet_addr([domain.host UTF8String]);
            
            self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr*)&hostAddress);
            self.status = MASNetworkReachabilityStatusInitializing;
        }
        else {
            //
            //  If the domain is DNS format
            //
            self.reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain.absoluteString UTF8String]);
            self.status = MASNetworkReachabilityStatusInitializing;
        }
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
    if (_reachabilityRef != NULL)
    {
        //  release reachability reference
        CFRelease(_reachabilityRef);
    }
}


# pragma mark - Public

- (void)startMonitoring
{
    if (self.reachabilityRef)
    {
        
    }
}


- (void)stopMonitoring
{
    if (self.reachabilityRef)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    }
}


- (void)setReachabilityMonitoringBlock:(nullable void (^)(MASNetworkReachabilityStatus status))block
{
    
}


# pragma mark - Private

- (BOOL)isReachable
{
    return (self.status == MASNetworkReachabilityStatusReachableViaWiFi || self.status == MASNetworkReachabilityStatusReachableViaWWAN);
}

@end
