//
//  MASBluetoothPeripheral.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASBluetoothPeripheral.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "MASConstantsPrivate.h"


@interface MASBluetoothPeripheral ()
    <CBPeripheralManagerDelegate>

# pragma mark - Properties

@property (nonatomic, strong, readonly) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong, readwrite) CBMutableCharacteristic *transferCharacteristic;

@property (nonatomic, copy, readonly) NSString *serviceUUID;
@property (nonatomic, copy, readonly) NSString *characteristicUUID;
@property (nonatomic, copy, readonly) NSMutableData *sessionURLData;

@property (nonatomic, strong) MASVoidCodeBlock initializeCodeBlock;

@property (assign) BOOL isSubscribed;

@end


@implementation MASBluetoothPeripheral


# pragma mark - Current Peripheral

+ (id)peripheralWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID;
{
    //
    // These are required
    //
    NSParameterAssert(serviceUUID);
    NSParameterAssert(characteristicUUID);
    
    // todo: validate the UUIDs???
    
    MASBluetoothPeripheral *peripheral = [[MASBluetoothPeripheral alloc] initWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    
    return peripheral;
}


# pragma mark - Private

- (void)updateBLEState:(MASBLEServiceState)state
{
    //
    // If MASDevice's BLE delegate is set, and method is implemented, notify the delegate
    //
    if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(didReceiveBLEProximityLoginStateUpdate:)])
    {
        [[MASDevice proximityLoginDelegate] didReceiveBLEProximityLoginStateUpdate:state];
    }
}


- (void)notifyErrorForBLEState:(NSError *)error
{
    //
    // If MASDevice's BLE delegate is set, and method is implemented, notify the delegate
    //
    if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(didReceiveProximityLoginError:)])
    {
        [[MASDevice proximityLoginDelegate] didReceiveProximityLoginError:error];
    }
}


- (void)requestUserPermissionOnBLEForDeviceName:(NSString *)deviceName completion:(MASCompletionErrorBlock)completion
{
    //
    // If MASDevice's BLE delegate is set, and method is implemented, notify the delegate
    //
    if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(handleBLEProximityLoginUserConsent:deviceName:)])
    {
        [[MASDevice proximityLoginDelegate] handleBLEProximityLoginUserConsent:completion deviceName:deviceName];
    }
    //
    // Otherwise, return an error for delegate undefine
    //
    else {
        completion(NO, [NSError errorForFoundationCode:MASFoundationErrorCodeBLEDelegateNotDefined errorDomain:MASFoundationErrorDomainLocal]);
    }
}


# pragma mark - Creating a new peripheral

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID
{
    self = [super init];
    if(self)
    {
        
        _serviceUUID = serviceUUID;
        _characteristicUUID = characteristicUUID;
        _sessionURLData = [[NSMutableData alloc] init];
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) peripheral manager state is: %@ and is advertising: %@\n\n"
        "        background authorization status: %@\n        serviceUUID: %@\n        characteristicUUID: %@",
        [self class], [self.peripheralManager peripheralManagerStateAsString], ([self.peripheralManager isAdvertising] ? @"Yes" : @"No"),
        [CBPeripheralManager peripheralManagerAuthorizationStatusAsString],
        self.serviceUUID, self.characteristicUUID];
}


# pragma mark - Starting and Stopping

- (void)startAdvertising
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    __block MASBluetoothPeripheral *blockSelf = self;
    
    MASVoidCodeBlock initializeCodeBlock = ^{
        
        //
        // If the peripheral manager exists, and is not advertising
        //
        if (blockSelf.peripheralManager && ![blockSelf.peripheralManager isAdvertising])
        {
            //
            // Check BLE state, and return proper error if the state is invalid.
            //
            if (![blockSelf.peripheralManager isPoweredOn])
            {
                NSError *bleError = [blockSelf.peripheralManager peripheralManagerStateToMASFoundationError];
                
                //
                // Notify delegate
                //
                [blockSelf notifyErrorForBLEState:bleError];
            }
            else {
                
                //
                // Notify delegatepo
                //
                [blockSelf updateBLEState:MASBLEServiceStatePeripheralStarted];
                
                //
                // If characteristic service is not created
                //
                if (!blockSelf.transferCharacteristic)
                {
                    @try {
                        
                        //
                        // Create characteristic
                        //
                        blockSelf.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:_characteristicUUID]
                                                                                              properties:CBCharacteristicPropertyWriteWithoutResponse + CBCharacteristicPropertyNotify
                                                                                                   value:nil
                                                                                             permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
                        
                        //
                        // Create service
                        //
                        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:_serviceUUID]
                                                                                           primary:YES];
                        transferService.characteristics = @[blockSelf.transferCharacteristic];
                        
                        //
                        // Add service
                        //
                        [blockSelf.peripheralManager addService:transferService];
                        
                        //
                        // Start peripheral advertising
                        //
                        [blockSelf.peripheralManager startAdvertising:@
                         {
                             CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:_serviceUUID]]
                         }];
                    }
                    @catch (NSException *exception) {
                        
                        //
                        //  Nullify the transferCharacteristic, otherwise on the second attempt to startPeripheral it will throw an uncaught exception.
                        //
                        blockSelf.transferCharacteristic = nil;
                        
                        NSDictionary *exceptionInfo = @{@"reason" : exception.reason , @"name" : exception.name};
                        
                        //
                        // Conver the exception with proper framework error domain and error code.
                        //
                        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheral info:exceptionInfo errorDomain:MASFoundationErrorDomainLocal];
                        
                        //
                        // Notify delegate
                        //
                        [blockSelf notifyErrorForBLEState:masError];
                    }
                }
                else {
                    
                    //
                    // Start peripheral advertising
                    //
                    [blockSelf.peripheralManager startAdvertising:@
                     {
                         CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:_serviceUUID]]
                     }];
                }
            }
        }
        
        blockSelf.initializeCodeBlock = nil;
    };
    
    //
    // If there is no peripheral manager instantiated stop here
    //
    if (!_peripheralManager)
    {
        //DLog(@"\n\nError: no peripheral manager detected!!\n\n");
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _peripheralManager.delegate = self;
        _initializeCodeBlock = initializeCodeBlock;
    }
    else {
        
        initializeCodeBlock();
    }
}


- (void)stopAdvertising
{
    //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    //
    // If there is no peripheral manager instantiated stop here
    //
    if(!self.peripheralManager)
    {
        //DLog(@"\n\nError: no peripheral manager detected!!\n\n");
        
        return;
    }
    
    //
    // If it is already NOT advertising stop here
    //
    if(![self.peripheralManager isAdvertising])
    {
        //DLog(@"\n\nThe peripheral is already NOT advertising:\n%@\n\n", [self debugDescription]);
        
        return;
    }
    
    //
    // Stop peripheral advertising
    //
    [self.peripheralManager stopAdvertising];
    
    //
    // Notify delegate
    //
    [self updateBLEState:MASBLEServiceStatePeripheralStopped];
}


# pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    //DLog(@"\n\ncalled with characteristic: %@\n\n", [characteristic debugDescription]);
    
    _isSubscribed = YES;
    
    //
    // Notify delegate
    //
    [self updateBLEState:MASBLEServiceStatePeripheralSubscribed];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    //DLog(@"\ncalled with characteristic: %@\n\n", [characteristic debugDescription]);
    
    _isSubscribed = NO;
    
    //
    // Notify delegate
    //
    [self updateBLEState:MASBLEServiceStatePeripheralUnsubscribed];
}


- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    //DLog(@"\n%@\n\n", [self debugDescription]);
}

/*
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
   //DLog(@"\n\ncalled with request: %@\n\n", [request debugDescription]);
}
*/

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    //DLog(@"\n\ncalled with requests: %@\n\n", [requests debugDescription]);

    if([requests count] > 0)
    {
        CBATTRequest *request = requests[0];
        NSString *sessionURLFragment = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
        
       //DLog(@"\n\nsessionURLFragment: %@\n\n", sessionURLFragment);
        
        //
        // We rely on EOM to signal the end of the message
        //
        if([sessionURLFragment isEqualToString:@"EOM"])
        {
           //DLog(@"\n\nreceived EOM indicating the end of the authorization request\n\n");

            NSError *error = nil;
            NSDictionary *authorizationRequest = [NSJSONSerialization JSONObjectWithData:self.sessionURLData
                                                                                 options:kNilOptions
                                                                                   error:&error];
            if(error != nil)
            {
               //DLog(@"\n\nFailed to load authorization request with error: %@\n\n", error);
                
                NSError *authorizationError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEAuthorizationFailed
                                                                         info:error.userInfo
                                                                  errorDomain:MASFoundationErrorDomainLocal];
                [self notifyErrorForBLEState:authorizationError];
                
                return;
            }
            
            //DLog(@"\n\nsessionURL: %@\n\n", authorizationRequest);
            
            //
            // Reset the sessionData
            //
            _sessionURLData = [[NSMutableData alloc] init];
            
            [self requestUserPermissionOnBLEForDeviceName:[authorizationRequest objectForKey:@"device_name"] completion:^(BOOL completed, NSError *error) {
                
                //
                // If error was returned, notify delegate and stop processing
                //
                if (error)
                {
                    [self notifyErrorForBLEState:error];
                    
                    return;
                }
                else {
                    
                    //
                    // If user accepts the consent
                    //
                    if (completed)
                    {
                        NSString *providerURL = [authorizationRequest objectForKey:@"provider_url"];
                        
                        if ([providerURL isEmpty])
                        {
                            NSError *invalidURLError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEAuthorizationFailed errorDomain:MASFoundationErrorDomainLocal];
                            [self notifyErrorForBLEState:invalidURLError];
                            
                            return;
                        }
                        
                        //
                        //  Retrieve the absolute URL of the authorizing device's gateway URL
                        //  Due to TLS Caching issue, if the authenticating device is on iOS 8, the auth url may come with trailing dot.
                        //  Make sure to handle both of them.
                        //
                        NSString *absoluteURL = [NSString stringWithFormat:@"https://%@:%@",[MASConfiguration currentConfiguration].gatewayHostName, [MASConfiguration currentConfiguration].gatewayPort];
                        NSString *absoluteURLWithTrailingDot = [NSString stringWithFormat:@"https://%@.:%@",[MASConfiguration currentConfiguration].gatewayHostName, [MASConfiguration currentConfiguration].gatewayPort];
                        
                        if ([MASConfiguration currentConfiguration].gatewayPrefix)
                        {
                            absoluteURL = [NSString stringWithFormat:@"%@/%@", absoluteURL, [MASConfiguration currentConfiguration].gatewayPrefix];
                            absoluteURLWithTrailingDot = [NSString stringWithFormat:@"%@/%@", absoluteURLWithTrailingDot, [MASConfiguration currentConfiguration].gatewayPrefix];
                        }
                        
                        NSString *authPath = @"";
                        
                        if ([providerURL rangeOfString:absoluteURL].location != NSNotFound || [providerURL rangeOfString:absoluteURLWithTrailingDot].location != NSNotFound)
                        {
                            //
                            // Extract the path of the authorization URL
                            //
                            authPath = [providerURL stringByReplacingOccurrencesOfString:absoluteURL withString:@""];
                            authPath = [authPath stringByReplacingOccurrencesOfString:absoluteURLWithTrailingDot withString:@""];
                        }
                        else {
                            
                            [self notifyErrorForBLEState:[NSError errorProximityLoginInvalidAuthroizeURL]];
                            return;
                        }
                        
                        @try {
                            
                            [MAS postTo:authPath
                         withParameters:nil
                             andHeaders:nil
                            requestType:MASRequestResponseTypeWwwFormUrlEncoded
                           responseType:MASRequestResponseTypeTextPlain
                             completion:^(NSDictionary *responseInfo, NSError *error) {
                                
                                 if (error)
                                 {
                                     
                                     NSError * invalidURLError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEAuthorizationFailed info:responseInfo errorDomain:MASFoundationErrorDomain];
                                     [self notifyErrorForBLEState:invalidURLError];
                                     
                                     NSString *statusCode = @"1";
                                     [self.peripheralManager updateValue:[statusCode dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
                                     
                                     return;
                                 }
                                 else {
                                     
                                     [self updateBLEState:MASBLEServiceStatePeripheralSessionAuthorized];
                                     
                                     if (!_isSubscribed)
                                     {
                                         NSError *noSubscribedDeviceError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLECentralDeviceNotFound errorDomain:MASFoundationErrorDomainLocal];
                                         [self notifyErrorForBLEState:noSubscribedDeviceError];
                                         
                                         return;
                                     }
                                     
                                     
                                     NSString *statusCode = @"0";
                                     [self.peripheralManager updateValue:[statusCode dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
                                     
                                     [self updateBLEState:MASBLEServiceStatePeripheralSessionNotified];
                                 }
                            }];
                        }
                        @catch(NSException* exception)
                        {
                            NSError *invalidURLError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEAuthorizationFailed errorDomain:MASFoundationErrorDomainLocal];
                            [self notifyErrorForBLEState:invalidURLError];
                            
                            return;
                        }
                    }
                    //
                    // If user does not authroize
                    //
                    else {
                        
                        NSString *statusCode = @"2";
                        [self.peripheralManager updateValue:[statusCode dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
                    }
                }
            }];
        }
        
        //
        // Append the data to what we already have
        //
        else
        {
            [self.sessionURLData appendData:request.value];
        }
    }
}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    //DLog(@"\n%@\n  error: %@\n\n", [self debugDescription], [error localizedDescription]);
    
    if (error)
    {
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheral info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
    }
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    //DLog(@"\n%@\n\n", [self debugDescription]);
    if (_initializeCodeBlock)
    {
        _initializeCodeBlock();
    }
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)stateInfo
{
    //DLog(@"\n\ncalled with restored state: %@\n\n", stateInfo);
}

@end
