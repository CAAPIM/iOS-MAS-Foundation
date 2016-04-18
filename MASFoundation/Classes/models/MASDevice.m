//
//  MASDevice.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDevice.h"

#import "MASAccessService.h"
#import "MASBluetoothCentral.h"
#import "MASBluetoothPeripheral.h"
#import "MASBluetoothService.h"
#import "MASConstantsPrivate.h"
#import "MASModelService.h"
#import "MASSecurityService.h"
#import "MASServiceRegistry.h"


@implementation MASDevice


static id<MASSessionSharingDelegate> _SessionSharingDelegate_;


# pragma mark - Property

+ (id<MASSessionSharingDelegate>)SessionSharingDelegate;
{
    return _SessionSharingDelegate_;
}


+ (void)setSessionSharingDelegate:(id<MASSessionSharingDelegate>)delegate;
{
    _SessionSharingDelegate_ = delegate;
}


# pragma mark - Current Device

+ (MASDevice *)currentDevice
{
    return [MASModelService sharedService].currentDevice;
}


- (void)deregisterWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // Post the will deregister notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceWillDeregisterNotification object:self];
    
    //
    // Pass through to the service
    //
    [[MASModelService sharedService] deregisterCurrentDeviceWithCompletion:^(BOOL completed, NSError *error)
    {
        
        __block NSError *serverError = error;
   
        //
        // Reset all on device settings, credentials, etc ... whether the deregister call succeeds or fails
        //
        [self resetLocallyWithCompletion:^(BOOL localCompleted, NSError *error)
        {
            //
            // Detect if error, if so stop here
            //
            if(error)
            {
                //
                // Notify
                //
                if(completion) completion(NO, error);
            
                return;
            }
            
            //
            // Detect if error, if so stop here
            //
            if(serverError)
            {
                //
                // Post the did fail to deregister in cloud notification
                //
                [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidFailToDeregisterInCloudNotification object:self];
                
                //
                // Notify
                //
                if(completion) completion(NO, serverError);
                
                return;
            }
            
            if (completed)
            {
                //
                // Post the did deregister in cloud notification
                //
                [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidDeregisterInCloudNotification object:self];
            }
            
            //
            // Post the did deregister overall notification
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidDeregisterNotification object:self];
            
            //
            // Notify
            //
            if(completion) completion(YES, nil);
        }];
    }];
}


- (void)logOutDeviceAndClearLocal:(BOOL)clearLocal completion:(MASCompletionErrorBlock)completion
{
    [[MASModelService sharedService] logOutDeviceAndClearLocalAccessToken:clearLocal completion:completion];
}


- (void)resetLocallyWithCompletion:(MASCompletionErrorBlock)completion
{
    //
    // KeyChain
    //
    [[MASAccessService sharedService] clearLocal];
    [[MASAccessService sharedService] clearShared];
    
    //
    // MASFiles
    //
    [[MASSecurityService sharedService] removeAllFiles];
    
    //
    // Registry Services
    //
    [[MASServiceRegistry sharedRegistry] resetWithCompletion:^(BOOL completed, NSError *error) {
       
        if(error)
        {
            //
            // Post the did fail to deregister on device notification
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidFailToDeregisterOnDeviceNotification object:self];
            
            //
            // Notify
            //
            if(completion) completion(NO, error);
            
            return;
        }
        
        //
        // Post the did deregister on device notification
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidDeregisterOnDeviceNotification object:self];
        
        //
        // Notify
        //
        if(completion) completion(YES, nil);
    }];
}



# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if(self) {
        
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) is registered: %@\n\n        identifier: %@\n        name: %@\n        status: %@",
        [self class], (self.isRegistered ? @"Yes" : @"No"), [self identifier], [self name], [self status]];
}


# pragma mark - Bluetooth Peripheral

- (void)startAsBluetoothPeripheral
{
    [[MASBluetoothService sharedService].peripheral startAdvertising];
}


- (void)stopAsBluetoothPeripheral
{
    [[MASBluetoothService sharedService].peripheral stopAdvertising];
}


# pragma mark - Bluetooth Central

- (void)startAsBluetoothCentral
{
    [[MASBluetoothService sharedService].central startScanning];
}


- (void)startAsBluetoothCentralWithAuthenticationProvider:(MASAuthenticationProvider *)provider
{
    [[MASBluetoothService sharedService].central startScanningWithAuthenticationProvider:provider];
}


- (void)stopAsBluetoothCentral
{
    [[MASBluetoothService sharedService].central stopScanning];
}

@end
