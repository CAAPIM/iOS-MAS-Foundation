//
//  MASService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"

#import "MASServiceRegistry.h"
#import "NSString+MASPrivate.h"


@interface MASService ()

@property (nonatomic, strong) MASServiceRegistry *registry;

@end


@implementation MASService

static NSMutableDictionary *_subClasses_;

#
# pragma mark - Shared Service
#

+ (instancetype)sharedService
{
    return nil;
}


- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:@"Cannot call base init, call designated factory method" userInfo:nil];
    
    return nil;
}


- (instancetype)initProtected
{
    if(self = [super init])
    {
        _lifecycleStatus = MASServiceLifecycleStatusInitialized;
    }
    
    return self;
}


- (void)dealloc
{
    //
    // Deregister from any notifications
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


# pragma mark - Lifecycle


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

// Must be overriden in subclasses
+ (NSUUID *)serviceUUID
{
    return nil;
}


- (void)serviceDidLoad
{
    //DLog(@"called for class: %@", [[self class] debugDescription]);
    
    //
    // Change the state value
    //
    _lifecycleStatus = MASServiceLifecycleStatusLoaded;
    
    //
    // Notify registry
    //
    if(self.registry)
    {
        //
        // Detect the set registry method and invoke it
        //
        [self.registry performSelector:@selector(serviceDidUpdateLifecycleState:)
            withObject:self
            withObject:nil];
    }
}


- (void)serviceWillStart
{
    //DLog(@"called for class: %@", [[self class] debugDescription]);

    //
    // Change the state value
    //
    _lifecycleStatus = MASServiceLifecycleStatusWillStart;

    //
    // Notify registry
    //
    if(self.registry)
    {
        //
        // Detect the set registry method and invoke it
        //
        [self.registry performSelector:@selector(serviceDidUpdateLifecycleState:)
            withObject:self
            withObject:nil];
    }
}


- (void)serviceDidStart
{
    //DLog(@"called for class: %@", [[self class] debugDescription]);
    
    //
    // Change the state value
    //
    _lifecycleStatus = MASServiceLifecycleStatusDidStart;
    
    //
    // Notify registry
    //
    if(self.registry)
    {
        //
        // Detect the set registry method and invoke it
        //
        [self.registry performSelector:@selector(serviceDidUpdateLifecycleState:)
            withObject:self
            withObject:nil];
    }
}


- (void)serviceWillStop
{
    //DLog(@"called for class: %@", [[self class] debugDescription]);
    
    //
    // Change the state value
    //
    _lifecycleStatus = MASServiceLifecycleStatusWillStop;
    
    //
    // Notify registry
    //
    if(self.registry)
    {
        //
        // Detect the set registry method and invoke it
        //
        [self.registry performSelector:@selector(serviceDidUpdateLifecycleState:)
            withObject:self
            withObject:nil];
    }
}


- (void)serviceDidStop
{
    //DLog(@"called for class: %@", [[self class] debugDescription]);
    
    //
    // Change the state value
    //
    _lifecycleStatus = MASServiceLifecycleStatusDidStop;
    
    //
    // Notify registry
    //
    if(self.registry)
    {
        //
        // Detect the set registry method and invoke it
        //
        [self.registry performSelector:@selector(serviceDidUpdateLifecycleState:)
            withObject:self
            withObject:nil];
    }
}


- (void)serviceDidReset
{
    //DLog(@"called for class: %@", [[self class] debugDescription]);
    
    _lifecycleStatus = MASServiceLifecycleStatusUnknown;
}


# pragma mark - Protected

- (void)serviceDidFailWithError:(NSError *)error
{
    //
    // Notify registry
    //
    if(self.registry)
    {
        //
        // Detect the set registry method and invoke it
        //
        [self.registry performSelector:@selector(serviceDidFailToUpdateLifecycleState:error:)
            withObject:self
            withObject:error];
    }
}

#pragma clang diagnostic pop


# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) uuid: %@, lifecycle state: %@", [self class],
        [self.class serviceUUID], [self lifecycleStatusAsString]];
}


# pragma mark - Service Lifecycle Status

- (NSString *)lifecycleStatusAsString
{
    return [MASService lifecycleStatusToString:self.lifecycleStatus];
}


+ (NSString *)lifecycleStatusToString:(MASServiceLifecycleStatus)status
{
    //
    // Detect the status and respond appropriately
    //
    switch (status)
    {
        //
        // Initialized
        //
        case MASServiceLifecycleStatusInitialized: return @"Initialized";
        
        //
        // Loaded
        //
        case MASServiceLifecycleStatusLoaded: return @"Loaded";

        //
        // Will Start
        //
        case MASServiceLifecycleStatusWillStart: return @"Will Start";
        
        //
        // Did Start
        //
        case MASServiceLifecycleStatusDidStart: return @"Did Start";
        
        //
        // Will Stop
        //
        case MASServiceLifecycleStatusWillStop: return @"Will Stop";
        
        //
        // Did Stop
        //
        case MASServiceLifecycleStatusDidStop: return @"Did Stop";

        //
        // Default
        //
        default: return @"Unknown";
    }
}


# pragma mark - Subclass Registry Methods

+ (NSArray *)getSubclasses
{
    return _subClasses_.allValues;
}


+ (void)registerSubclass:(Class)subclass serviceUUID:(NSString *)serviceUUID
{
    if (_subClasses_ == nil)
    {
        _subClasses_ = [NSMutableDictionary dictionary];
    }
    
    if (![serviceUUID isEmpty] && subclass != nil)
    {
        [_subClasses_ setObject:subclass forKey:serviceUUID];
    }
}

@end
