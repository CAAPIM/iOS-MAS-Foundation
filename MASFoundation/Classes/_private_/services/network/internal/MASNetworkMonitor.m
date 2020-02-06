//
//  MASNetworkMonitor.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASNetworkMonitor.h"

#import "MASConstantsPrivate.h"
#import <objc/runtime.h>

@implementation MASNetworkMonitor

# pragma mark - Lifecycle

+ (instancetype)sharedMonitor
{
    static MASNetworkMonitor *_sharedMonitor = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedMonitor = [[self alloc] init];
    });
    
    return _sharedMonitor;
}


- (void)dealloc
{
    [self stopMonitoring];
}


# pragma mark - Public

- (void)startMonitoring
{
    [self stopMonitoring];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNetworkStart:) name:MASSessionTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNetworkComplete:) name:MASSessionTaskDidCompleteNotification object:nil];
}


- (void)stopMonitoring
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


# pragma mark - Private

static void * MASNetworkRequestStartTimestamp = &MASNetworkRequestStartTimestamp;

- (void)didNetworkStart:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSURLSessionTask class]])
    {
        NSURLSessionTask *task = (NSURLSessionTask *)[notification object];
        NSURLRequest *request = [task originalRequest];
        
        objc_setAssociatedObject(notification.object, MASNetworkRequestStartTimestamp, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSString *httpBody = nil;
        
        if ([request HTTPBody])
        {
            httpBody = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
        }
        
        DLog(@"%@ '%@' : %@ %@", [request HTTPMethod], [[request URL] absoluteString], [request allHTTPHeaderFields], httpBody);
    }
}


- (void)didNetworkComplete:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSURLSessionTask class]])
    {
        NSURLSessionTask *task = (NSURLSessionTask *)[notification object];
        
        NSError *error = [task error];
        NSURLResponse *response = [task response];
        NSURLRequest *request = [task originalRequest];
        
        if (!request && !response)
        {
            return;
        }
        
        NSDictionary *responseHeader = [(NSHTTPURLResponse *)response allHeaderFields];
        NSInteger responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
        NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, MASNetworkRequestStartTimestamp)];
        id responseObject = notification.userInfo[MASSessionTaskDidCompleteSerializedResponseKey];
        
        if (error)
        {
            DLog(@"[Error] %@ '%@' (%ld) [%.04f s]: %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, elapsedTime, error);
        }
        else {
            DLog(@"%ld '%@' [%.04f s]: %@ %@", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime, responseHeader, responseObject);
        }
    }
}

@end
