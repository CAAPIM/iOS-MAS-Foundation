//
//  MASServiceRegistry.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASServiceRegistry.h"

#import <objc/runtime.h>
#import "MASAccessService.h"
#import "MASConfigurationService.h"
#import "MASModelService.h"
#import "MASService.h"


//
// Bundle identifiers for our special internal frameworks
//

static NSString * const MASUISystemFramework = @"com.ca.MASUI";

//
// UUIDs for all expected MAS internal services, even in other MAS Frameworks
// that can be plug and play.
//
static NSArray const *_serviceUUIDs_;


@interface MASServiceRegistry ()


/**
 * The lifecycle state tracker for the services.
 */
@property (nonatomic, assign, readonly) MASServiceLifecycleStatus lifecycleStatus;


/**
 * The completion block used for either the start or the stop.
 */
@property (nonatomic, copy) MASCompletionErrorBlock completion;


/**
 * Override public version for internal read/write
 */
@property (nonatomic, assign, readwrite) MASRegistryState state;


/**
 * Override public version for internal read/write
 */
@property (nonatomic, strong) NSBundle *uiFramework;


/**
 * Service callback to notify of a state update.
 */
- (void)serviceDidUpdateLifecycleState:(MASService *)service;

@end



@implementation MASServiceRegistry


# pragma mark - Properties

- (void)setState:(MASRegistryState)state
{
    [self willChangeValueForKey:@"state"];
    _state = state;
    [self didChangeValueForKey:@"state"];
}


# pragma mark - Shared Service

+ (instancetype)sharedRegistry
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[MASServiceRegistry alloc] initPrivate];
    });
    
    return sharedInstance;
}


+ (void)initialize
{
    //
    // Store UUIDs for later comparison
    //
    _serviceUUIDs_ = @
    [
        MASAccessServiceUUID,
        MASConfigurationServiceUUID,
        MASBluetoothServiceUUID,
        MASLocationServiceUUID,
        MASFileServiceUUID,
        MASModelServiceUUID,
        MASNetworkServiceUUID,
     
        MASUIServiceUUID
    ];
}


- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:@"Cannot call base init, call designated factory method" userInfo:nil];
    
    return nil;
}


- (id)initPrivate
{
    if(self = [super init])
    {
        //
        // Defaults
        //
        _state = MASRegistryStateUnknown;
        _services = [NSMutableArray new];
        _lifecycleStatus = MASServiceLifecycleStatusUnknown;
    }
    
    return self;
}


- (NSString *)debugDescription
{
    //
    // Iterate the services to get each debug state string
    //
    NSMutableString *serviceInfo = [NSMutableString new];
    NSString *formattedString;
    for(MASService *service in self.services)
    {
        [serviceInfo appendString:@"        "];
        
        formattedString = [NSString stringWithFormat:@"(%@) showing lifecycle status: %@\n",
            [service.class debugDescription],
            [service lifecycleStatusAsString]];
        [serviceInfo appendString:formattedString];
    }
    
    return [NSString stringWithFormat:@"(%@) registry state: %@\n\n"
        "    services lifecycle status: %@\n    %ld detected services:\n\n%@",
        [self class], [self registryStateAsString],
        [MASService lifecycleStatusToString:self.lifecycleStatus], (unsigned long)self.services.count ,serviceInfo];
}


# pragma mark - Lifecycle

- (void)startWithCompletion:(MASCompletionErrorBlock)completion
{
    //DLog(@"called");
    
    //
    // If the service has already been started
    //
    if (_state == MASRegistryStateStarted)
    {
        if(completion) completion(YES, nil);
        
        return;
    }
    
    //
    // Must be in a fully stopped or unknown state to start
    //
    if(_state != MASRegistryStateStopped && _state != MASRegistryStateUnknown)
    {
        //
        // Notify
        //
        NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        if(completion) completion(NO, error);
        
        return;
    }
 
    //
    // Copy the completion block
    //
    self.completion = completion;
    
    //
    // Determine the lifecycle state at which to begin
    //
    MASServiceLifecycleStatus serviceLifecycleStatus = (_state == MASRegistryStateUnknown ? MASServiceLifecycleStatusInitialized :
        MASServiceLifecycleStatusWillStart);
    
    //
    // Update state
    //
    self.state = MASRegistryStateWillStart;
    
    //
    // Perform the services auto lifecycle process
    //
    [self startServicesLifecycleStatus:serviceLifecycleStatus];
}


// Private
- (void)startServicesLifecycleStatus:(MASServiceLifecycleStatus)status
{
    //DLog(@"called with service lifecycle status: %@", [MASService lifecycleStatusToString:status]);
    
    //
    // Update to current status
    //
    _lifecycleStatus = status;
    
    //
    // Initialized
    //
    // This is a special case, no services exist yet
    //
    if(status == MASServiceLifecycleStatusInitialized)
    {
        [self startServicesInitialization];
        return;
    }
    
    //
    // Else iterate all MASServices to perform the applicable lifecycle process
    //
    for(MASService *service in self.services)
    {
        //DLog(@"service class is: %@", [[service class] debugDescription]);
        
        //
        //  If the state should stop the registry lifecycle; ignore all the services
        //
        if (self.state == MASRegistryStateShouldStop)
        {
            continue;
        }
        
        //
        // Detect the status and respond appropriately
        //
        switch(status)
        {
            //
            // Loaded
            //
            case MASServiceLifecycleStatusLoaded:
            {
                [service serviceDidLoad];
                break;
            }
            
            //
            // Will Start
            //
            case MASServiceLifecycleStatusWillStart:
            {
                [service serviceWillStart];
                break;
            }
            
            //
            // Did Start
            //
            case MASServiceLifecycleStatusDidStart:
            {
                [service serviceDidStart];
                break;
            }
            
            //
            // Will Stop
            //
            case MASServiceLifecycleStatusWillStop:
            {
                [service serviceWillStop];
                break;
            }
            
            //
            // Did Stop
            //
            case MASServiceLifecycleStatusDidStop:
            {
                [service serviceDidStop];
                break;
            }
            
            //
            // Default
            //
            default:
            {
//                DLog(@"\n\nWarning: detected unsupported lifecycle status: %@\n\n",
//                    [MASService lifecycleStatusToString:self.lifecycleStatus]);
                break;
            }
        }
    }
    
    //
    //  If the state should stop the registry lifecycle; reset the registry properly here.
    //  We should wait until the loop finished before we reset.
    //
    if (self.state == MASRegistryStateShouldStop)
    {
        [self resetWithCompletion:nil];
    }
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

// Private
- (void)startServicesInitialization
{
    //DLog(@"called");
    
    if ([MAS respondsToSelector:@selector(willHandleAuthentication)])
    {
        _uiHandlingIsPresent = YES;
    }
    else {
        _uiHandlingIsPresent = NO;
    }
    
    //
    // Detect, and prevent, from being called out of turn
    //
    if(self.lifecycleStatus != MASServiceLifecycleStatusInitialized)
    {
        //DLog(@"\n\nError attempting to call when lifecycle status is: %@\n\n",
        //    [MASService lifecycleStatusToString:self.lifecycleStatus]);
        
        return;
    }
    
    //
    // Find total number of classes in the bundle
    //
    int numClasses;
    Class *classes = NULL;
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    //
    // If we successfully find the classes, not sure why we wouldn't but check anyway
    //
    if (numClasses > 0)
    {
        //
        // Find all those that are specfically of type Class
        //
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        //
        // Iterate all class to find on those with the super class MASSercie
        //
        MASService *service;
        for (int i = 0; i < numClasses; i++)
        {
            //
            // Detect MASService classes
            //
            if(class_getSuperclass(classes[i]) == [MASService class])
            {
                //
                // Invoke the shared service the first time
                //
                service = [classes[i] performSelector:@selector(sharedService)];
                
                //DLog(@"\n\nfound service: %@\\n\n    has a known service uuid: %@\n\n",
                //    [service debugDescription],
                //    ([_serviceUUIDs_ containsObject:[service.class serviceUUID]] ? @"Yes" : @"No"));
                
                //
                // For now lets check if this is a 'known' MAS service by it's UUID.  We are not
                // allowing thirdparty services at this time.  If one detected, ignore it but
                // continue on with other services.
                //
                if(![service.class serviceUUID])
                {
//                    DLog(@"\n\nWarning detected MASService class: %@ with unknown UUID: %@\n\n",
//                        service.class, [service.class serviceUUID]);
//                    
                    continue;
                }
    
                //
                // Detect the set registry method and invoke it
                //
                [service performSelector:@selector(setRegistry:) withObject:self];
                
                //
                // Guarantee that the configuration service is first in the list so
                // it will always hit every lifecycle step first
                //
                if([service isKindOfClass:[MASConfigurationService class]])
                {
                    [self.services insertObject:service atIndex:0];
                }
                
                //
                // Guarantee that the acces service is the first or second in the list so
                // it will always available to other services using keychain storage
                //
                
                // MASAccessService does not have any dependency with MASConfigurationService,
                // but other services have dependencies on these two, so ensuring these two services get initialized (regardless of the order of these two) before the other services
                
                else if ([service isKindOfClass:[MASAccessService class]])
                {
                    if ([self.services count] > 0)
                    {
                        [self.services insertObject:service atIndex:1];
                    }
                    else {
                        [self.services insertObject:service atIndex:0];
                    }
                }
                
                //
                // Else this is any other framework
                //
                else
                {
                    //
                    // Add newly created services as they are found
                    //
                    [self.services addObject:service];
                    
                    //
                    // If the MASUI framework is present check for it's service
                    //
                    if(_uiHandlingIsPresent)
                    {
                        //
                        // If this is the MASUI's service it will be detected
                        //
                        if ([service class] == [NSClassFromString(@"MASUIService") class])
                        {
                            _uiService = service;
                        }
                    }
                }
            }
        }
        
        //
        // Free the memory
        //
        free(classes);
    }
    
    //DLog(@"called and found %ld MASServices:\n\n%@\n\n",
    //    (unsigned long)self.services.count, self.services);

    //
    // Proceed with the next step in the lifecycle
    //
    [self startServicesLifecycleStatus:MASServiceLifecycleStatusLoaded];
}

#pragma clang diagnostic pop


- (void)stopWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Must be in a fully started state
    //
    if(_state != MASRegistryStateStarted)
    {
        //
        // Notify
        //
        NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        if(completion) completion(NO, error);
        
        return;
    }
    
    //
    // Copy the completion block
    //
    self.completion = completion;
    
    //
    // Update state
    //
    self.state = MASRegistryStateWillStop;
    
    //
    // Perform the services auto lifecycle process
    //
    [self startServicesLifecycleStatus:MASServiceLifecycleStatusWillStop];
    
    //
    // Notify
    //
    if(completion) completion(YES, nil);
}


- (void)resetWithCompletion:(MASCompletionErrorBlock)completion
{
    //DLog(@"called");
    
    //
    // If registry is unknown there is nothing to do
    //
    if(self.state == MASRegistryStateUnknown) return;
    
    //
    // Iterate all MASServices to perform their resets
    //
    for(MASService *service in self.services)
    {
        [service serviceDidReset];
    }
        
    //
    // Reset defaults
    //
    [_services removeAllObjects];
    _state = MASRegistryStateUnknown;
    _lifecycleStatus = MASServiceLifecycleStatusUnknown;
        
    //
    // Notify
    //
    if(completion) completion(YES, nil);
    
    //DLog(@"\n\n*******************\n\n"
    //          "Registry reset detected\n"
    //          "%@", [self debugDescription]);
}


# pragma mark - Notification

- (void)serviceDidUpdateLifecycleState:(MASService *)service
{
    //DLog(@"called \n\n  service is: %@\n  error: %@\n\n", service.class, [error localizedDescription]);
    
    //
    // Iterate the known services and determine if we can proceed to the next lifecycle stage
    //
    for(MASService *service in self.services)
    {
        //
        // If any service has not yet reached the desired state, stop here
        //
        if((service.lifecycleStatus != self.lifecycleStatus))
        {
            return;
        }
    }

    //
    // If we have started
    //
    if(self.lifecycleStatus == MASServiceLifecycleStatusDidStart)
    {
        //
        // Update state
        //
        self.state = MASRegistryStateStarted;
        
        //DLog(@"\n\n*******************\n\n"
        //      "Registry started detected\n"
        //      "%@", [self debugDescription]);
        
        //
        // Notify
        //
        if(self.completion)
        {
            self.completion(YES, nil);
            self.completion = nil;
        }
        
        return;
    }
    
    //
    // Else if we have stopped
    //
    else if(self.lifecycleStatus == MASServiceLifecycleStatusDidStop)
    {
        //
        // Update state
        //
        self.state = MASRegistryStateStopped;
        
        //DLog(@"\n\n*******************\n\n"
        //      "Registry stopped detected\n"
        //      "%@", [self debugDescription]);
        
        //
        // Notify
        //
        if(self.completion)
        {
            self.completion(YES, nil);
            self.completion = nil;
        }
        
        return;
    }
    
    //
    // Else increment to the next state level
    //
    _lifecycleStatus++;
    
    //
    // Perform the next lifecycle state process
    //
    [self startServicesLifecycleStatus:_lifecycleStatus];
}


- (void)serviceDidFailToUpdateLifecycleState:(MASService *)service error:(NSError *)error
{
    //DLog(@"called with service class: %@\n and error: %@\n\n", [service.class debugDescription], [error localizedDescription]);
    
    //
    //  If the error was thrown from MASConfigurationService, all other services should stop as well
    //
    if ([service isKindOfClass:[MASConfigurationService class]])
    {
        _state = MASRegistryStateShouldStop;
    }
    
    //
    // Notify
    //
    if(self.completion)
    {
        self.completion(NO, error);
        self.completion = nil;
    }
}



# pragma mark - RegistryState

- (NSString *)registryStateAsString
{
    return [MASServiceRegistry registryStateToString:self.state];
}


+ (NSString *)registryStateToString:(MASRegistryState)state
{
    //
    // Detect the state and respond appropriately
    //
    switch (state)
    {
        //
        // Will Start
        //
        case MASRegistryStateWillStart: return @"Will Start";
        
        //
        // Started
        //
        case MASRegistryStateStarted: return @"Started";
        
        //
        // Will Stop
        //
        case MASRegistryStateWillStop: return @"Will Stop";
        
        //
        // Stopped
        //
        case MASRegistryStateStopped: return @"Stopped";

        //
        // Default
        //
        default: return @"Unknown";
    }
}


# pragma mark - UI Service

- (BOOL)uiServiceWillHandleBasicAuthentication:(MASBasicCredentialsBlock)basicBlock
    authorizationCodeBlock:(MASAuthorizationCodeCredentialsBlock)authorizationCodeBlock
{

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

    //
    // If an authenticated user is present no need to continue
    //
    if([[MASApplication currentApplication] isAuthenticated] && [MASApplication currentApplication].authenticationStatus == MASAuthenticationStatusLoginWithUser)
    {
        return NO;
    }
    
    //
    // If the UI handling framework is not present no need to continue
    //
    if(!self.uiHandlingIsPresent)
    {
        return NO;
    }
    
    //
    // If the service does not even implement the will handle authentication UI method
    // stop here.
    //
    // Note this method is a static method
    //
    SEL selector = NSSelectorFromString(@"willHandleAuthentication");
    Class uiServiceClass = self.uiService.class;
    if(![uiServiceClass respondsToSelector:selector])
    {
        return NO;
    }
    
    //
    // Retrieve the function pointer for this selector
    //
    IMP imp = [uiServiceClass methodForSelector:selector];
    BOOL (*willHandleAuthentication)(id, SEL) = (void *)imp;
                    
    //
    // Invoke the method and if the service responds that it will NOT handle authentication UI
    // stop here
    //
    // Note this is an instance method
    //
    BOOL willHandle = willHandleAuthentication(self.uiService.class, selector);
    if(!willHandle)
    {
        return NO;
    }
    
    //
    // If the service does not even implement the notification callback to handle the authentication
    // stop here
    //
    selector = NSSelectorFromString(@"__masRequestsCredentialsWithAuthenticationProviders:basicCredentialsBlock:authorizationCodeBlock__:");
    if(![self.uiService respondsToSelector:selector])
    {
        return NO;
    }
    
    //
    // Retrieve the function pointer for this selector
    //
    imp = [self.uiService methodForSelector:selector];
    __block void (*handleAuthentication)(id, SEL, MASAuthenticationProviders*, MASBasicCredentialsBlock, MASAuthorizationCodeCredentialsBlock) = (void *)imp;
    
    //
    // Attempt to retrieve the authentication providers
    //
    handleAuthentication(self.uiService, selector, [MASAuthenticationProviders currentProviders], basicBlock, authorizationCodeBlock);
                
#pragma clang diagnostic pop

    return YES;
}


- (BOOL)uiServiceWillHandleOTPAuthentication:(MASOTPFetchCredentialsBlock)otpBlock error:(NSError *)otpError
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    //
    // If the UI handling framework is not present no need to continue
    //
    if(!self.uiHandlingIsPresent)
    {
        return NO;
    }
    
    //
    // If the service does not even implement the will handle OTP authentication UI method
    // stop here.
    //
    // Note this method is a static method
    //
    SEL selector = NSSelectorFromString(@"willHandleOTPAuthentication");
    Class uiServiceClass = self.uiService.class;
    if(![uiServiceClass respondsToSelector:selector])
    {
        return NO;
    }
    
    //
    // Retrieve the function pointer for this selector
    //
    IMP imp = [uiServiceClass methodForSelector:selector];
    BOOL (*willHandleOTPAuthentication)(id, SEL) = (void *)imp;
    
    //
    // Invoke the method and if the service responds that it will NOT handle OTP authentication UI
    // stop here
    //
    // Note this is an instance method
    //
    BOOL willHandle = willHandleOTPAuthentication(self.uiService.class, selector);
    if(!willHandle)
    {
        return NO;
    }
    
    //
    // If the service does not even implement the notification callback to handle the OTP
    // authentication stop here
    //
    selector = NSSelectorFromString(@"__masRequestsOTPCredentialsWithOTPCredentialsBlock__:error:");
    if(![self.uiService respondsToSelector:selector])
    {
        return NO;
    }
    
    //
    // Retrieve the function pointer for this selector
    //
    imp = [self.uiService methodForSelector:selector];
    __block void (*handleOTPAuthentication)(id, SEL, MASOTPFetchCredentialsBlock, NSError *) = (void *)imp;
    
    //
    // Attempt to retrieve the one time password
    //
    handleOTPAuthentication(self.uiService, selector, otpBlock, otpError);
    
#pragma clang diagnostic pop
    
    return YES;
}


- (BOOL)uiServiceWillHandleOTPChannelSelection:(NSArray *)supportedChannels
                            otpGenerationBlock:(MASOTPGenerationBlock)generationBlock
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    //
    // If the UI handling framework is not present no need to continue
    //
    if(!self.uiHandlingIsPresent)
    {
        return NO;
    }
    
    //
    // If the service does not even implement the will handle OTP authentication UI method
    // stop here.
    //
    // Note this method is a static method
    //
    SEL selector = NSSelectorFromString(@"willHandleOTPAuthentication");
    Class uiServiceClass = self.uiService.class;
    if(![uiServiceClass respondsToSelector:selector])
    {
        return NO;
    }
    
    //
    // Retrieve the function pointer for this selector
    //
    IMP imp = [uiServiceClass methodForSelector:selector];
    BOOL (*willHandleOTPAuthentication)(id, SEL) = (void *)imp;
    
    //
    // Invoke the method and if the service responds that it will NOT handle OTP authentication UI
    // stop here
    //
    // Note this is an instance method
    //
    BOOL willHandle = willHandleOTPAuthentication(self.uiService.class, selector);
    if(!willHandle)
    {
        return NO;
    }
    
    //
    // If the service does not even implement the notification callback to handle the OTP
    // authentication stop here
    //
    selector = NSSelectorFromString(@"__masRequestsOTPChannelsWithOTPGenerationBlock__:supportedChannels:");
    if(![self.uiService respondsToSelector:selector])
    {
        return NO;
    }
    
    //
    // Retrieve the function pointer for this selector
    //
    imp = [self.uiService methodForSelector:selector];
    __block void (*handleOTPChannelSelection)(id, SEL, MASOTPGenerationBlock, NSArray*) = (void *)imp;
    
    //
    // Attempt to retrieve the selected OTP channels
    //
    handleOTPChannelSelection(self.uiService, selector, generationBlock, supportedChannels);
    
#pragma clang diagnostic pop
    
    return YES;
}

@end
