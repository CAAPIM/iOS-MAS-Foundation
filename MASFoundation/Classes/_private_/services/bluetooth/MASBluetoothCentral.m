//
//  MASBluetoothCentral.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASBluetoothCentral.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "MASAccessService.h"
#import "MASBluetoothService.h"
#import "MASConstantsPrivate.h"
#import "MASNetworkingService.h"

@interface MASBluetoothCentral ()
    <CBCentralManagerDelegate, CBPeripheralDelegate>

# pragma mark - Properties

@property (nonatomic, strong, readonly) CBCentralManager *centralManager;
@property (nonatomic, strong, readonly) NSMutableArray *peripherals;

@property (nonatomic, copy, readonly) NSString *serviceUUID;
@property (nonatomic, copy, readonly) NSString *characteristicUUID;
@property (nonatomic, copy, readonly) MASAuthenticationProvider *provider;

@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, strong) MASVoidCodeBlock initializeCodeBlock;

@end


@implementation MASBluetoothCentral


# pragma mark - Central

+ (id)centralWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID
{
    // todo: validate the UUIDs???
    
    MASBluetoothCentral *central = [[MASBluetoothCentral alloc] initWithServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    
    return central;
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


- (void)sendAuthURLWithAuthenticationProvider:(MASAuthenticationProvider *)authProvider characteristic:(CBCharacteristic *)characteristic
{
    //
    // Notify that the device is being authorized to avoid duplicate calls
    //
    [[MASDevice currentDevice] setIsBeingAuthorized:YES];
    
    //
    // Prepare auth data request to transfer with given auth provider url and discovered characteristic
    //
    NSDictionary *authDictionary = @{@"provider_url" : authProvider.authenticationUrl.absoluteString , @"device_name" : [[UIDevice currentDevice] name]};
    NSData *authData = [NSJSONSerialization dataWithJSONObject:authDictionary options:NSJSONWritingPrettyPrinted error:nil];
    
    NSData *authRequest = [[[NSString alloc] initWithBytes:[authData bytes] length:[authData length] encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];

    NSInteger sendDataIndex = 0;
    
    BOOL isSending = YES;
    
    while (isSending)
    {
        CBPeripheral *discoveredPeripheral = [self.peripherals objectAtIndex:0];
        
        NSInteger sendDataAmount = authRequest.length - sendDataIndex;
        
        //
        // BLE transfer data limit to 20 byes
        //
        if (sendDataAmount > 20)
        {
            sendDataAmount = 20;
        }
        
        //
        // Data for for specific amount
        //
        NSData *chunk = [NSData dataWithBytes:authRequest.bytes+sendDataIndex length:sendDataAmount];
        
        //
        // Send value to disvered peripheral's characteristic
        //
        [discoveredPeripheral writeValue:chunk forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        
        sendDataIndex += sendDataAmount;
        
        //
        // If all data was sent, notify EOM
        //
        if (sendDataIndex >= authRequest.length)
        {
            [discoveredPeripheral writeValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
            //
            // Notify delegate
            //
            [self updateBLEState:MASBLEServiceStateCentralCharacteristicWritten];
            
            isSending = NO;            
        }
    }
}


- (void)pollAuthorizationCode
{

    
    NSString *pollURL = _provider.pollUrl.absoluteString;
    
    if ([pollURL isEmpty])
    {
        NSError *invalidURLError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEAuthorizationFailed errorDomain:MASFoundationErrorDomainLocal];
        [self notifyErrorForBLEState:invalidURLError];
        
        return;
    }
    
    NSString *pollPath = [pollURL stringByReplacingOccurrencesOfString:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString
                                                                withString:@""];
    
    //
    // Instead of making a request through [MAS getFrom:..] public interface, call directly the networking service to bypass validation process
    //
    [[MASNetworkingService sharedService] getFrom:pollPath
                                   withParameters:nil
                                       andHeaders:nil
                                      requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                     responseType:MASRequestResponseTypeJson
                                       completion:^(NSDictionary *responseInfo, NSError *error) {
        //
        // Notify that the device is done with authorization
        //
        [[MASDevice currentDevice] setIsBeingAuthorized:NO];
        
        if (error)
        {
            NSError * pollError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEAuthorizationPollingFailed info:responseInfo errorDomain:MASFoundationErrorDomain];
            [self notifyErrorForBLEState:pollError];
            
            //
            // Send the notification with authorization code
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidReceiveErrorFromProximityLoginNotification object:pollError];
        }
        else {
            
            //
            // Validate PKCE state value
            // If either one of request or response states is present, validate it; otherwise, ignore
            //
            if ([responseInfo objectForKey:MASPKCEStateRequestResponseKey] || [[MASAccessService sharedService].currentAccessObj retrievePKCEState])
            {
                NSString *responseState = [responseInfo objectForKey:MASPKCEStateRequestResponseKey];
                NSString *requestState = [[MASAccessService sharedService].currentAccessObj retrievePKCEState];
                
                NSError *pkceError = nil;
                
                //
                // If response or request state is nil, invalid request and/or response
                //
                if (responseState == nil || requestState == nil)
                {
                    pkceError = [NSError errorInvalidAuthorization];
                }
                //
                // verify that the state in the response is the same as the state sent in the request
                //
                else if (![[responseInfo objectForKey:MASPKCEStateRequestResponseKey] isEqualToString:[[MASAccessService sharedService].currentAccessObj retrievePKCEState]])
                {
                    pkceError = [NSError errorInvalidAuthorization];
                }
                
                //
                // If the validation fail, notify
                //
                if (pkceError)
                {
                    
                    //
                    // If MASDevice's BLE delegate is set, and method is implemented, notify the delegate
                    //
                    if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(didReceiveProximityLoginError:)])
                    {
                        [[MASDevice proximityLoginDelegate] didReceiveProximityLoginError:pkceError];
                    }
                    
                    //
                    // Send the notification with authorization code
                    //
                    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidReceiveErrorFromProximityLoginNotification object:pkceError];
                    
                    return;
                }
            }
            
            //
            // Retrieve authorization code
            //
            NSString *code = [responseInfo[MASResponseInfoBodyInfoKey] valueForKey:@"code"];
            
            //
            // If the delegate is set, send the authorization code to delegation method
            //
            if ([MASDevice proximityLoginDelegate] && [[MASDevice proximityLoginDelegate] respondsToSelector:@selector(didReceiveAuthorizationCode:)])
            {
                [[MASDevice proximityLoginDelegate] didReceiveAuthorizationCode:code];
            }
            
            //
            // Send the notification with authoriation code
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidReceiveAuthorizationCodeFromProximityLoginNotification object:@{@"code" : code}];
            
        }
    }];
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
        
        _peripherals = [NSMutableArray new];
        
        _lock = [[NSRecursiveLock alloc] init];
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) central manager state is: %@\n\n        known peripheral count: %ld",
        [self class], [self.centralManager centralManagerStateAsString], (unsigned long)self.peripherals.count];
}


# pragma mark - Starting and Stopping

/**
 * Start the central scanning for peripherals.
 */
- (void)startScanning
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    __block MASBluetoothCentral *blockSelf = self;
    
    MASVoidCodeBlock initializeCodeBlock = ^{
      
        //
        // If the central manager exists, and is not scanning
        //
        if (blockSelf.centralManager && ![blockSelf.centralManager isScanning])
        {
            //
            //  If the central manager is not powered on and/or is in a state it can't search
            //
            if (![blockSelf.centralManager isPoweredOn])
            {
                NSError *bleError = [blockSelf.centralManager centralManagerStateToMASFoundationError];
                
                //
                // Notify delegate
                //
                [blockSelf notifyErrorForBLEState:bleError];
            }
            else {
                @try {
                    //
                    // Start central scanning for peripherals
                    //
                    [blockSelf.centralManager scanForPeripheralsWithServices:@[
                                                                          [
                                                                           CBUUID UUIDWithString:_serviceUUID]
                                                                          ]
                                                                options:@
                     {
                         CBCentralManagerScanOptionAllowDuplicatesKey : @NO
                     }];
                    
                    [blockSelf updateBLEState:MASBLEServiceStateCentralStarted];
                }
                @catch (NSException *exception) {
                    
                    //
                    // Catech an exception
                    //
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
        }
        
        blockSelf.initializeCodeBlock = nil;
    };
    
    //
    // If there is no central manager instantiated, so initialize the central manager
    //
    if (!_centralManager)
    {
       //DLog(@"\n\nError: no central manager detected!!\n\n");
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _centralManager.delegate = self;
        _initializeCodeBlock = initializeCodeBlock;
    }
    else {
        
        initializeCodeBlock();
    }
}


- (void)startScanningWithAuthenticationProvider:(MASAuthenticationProvider *)provider
{
    
    //
    // If no auth provider is set, notify delegate
    // Authentication provider should have both auth url and poll url
    //
    if (!provider && !provider.authenticationUrl && !provider.pollUrl)
    {
        NSError *invalidAuthError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEInvalidAuthenticationProvider errorDomain:MASFoundationErrorDomainLocal];
        [self notifyErrorForBLEState:invalidAuthError];
        
        return;
    }
    
    _provider = provider;
    
    [self startScanning];
}


/**
 * Stop the central from scanning for peripherals.
 */
- (void)stopScanning
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    //
    // If there is no central manager instantiated stop here
    //
    if(!self.centralManager)
    {
       //DLog(@"\n\nError: no central manager detected!!\n\n");
        
        return;
    }
    
    //
    // For connected peripherals, search for characteristics that are currently subscribing
    //
    for (CBPeripheral *peripheral in self.peripherals)
    {
        //
        // Loop through services
        //
        for (CBService *service in peripheral.services)
        {
            //
            // Loop through characteristics
            //
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                //
                // If characteristics UUID matches with our UUID and it is currently notifying, stop
                //
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:_characteristicUUID]] && characteristic.isNotifying)
                {
                    //
                    // Unsubscribe characteristics
                    //
                    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
        
        //
        // Cancel peripheral connection
        //
        [self.centralManager cancelPeripheralConnection:peripheral];
    }

    //
    // Stop central scanning for peripherals
    //
    [self.centralManager stopScan];
    
    //
    // Notify delegate
    //
    [self updateBLEState:MASBLEServiceStateCentralDeviceDisconnected];
}


# pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
   //DLog(@"\n\ndiscovered peripheral: %@ for central:\n\n%@\n\n", peripheral.name, [self debugDescription]);
    
    //
    // If RSSI is not in reasonable range defined in msso_config.json, reject it
    //
    if (RSSI.integerValue < [[MASConfiguration currentConfiguration] bluetoothRssi])
    {
        NSError *error = [NSError errorForFoundationCode:MASFoundationErrorCodeBLERSSINotInRange errorDomain:MASFoundationErrorDomainLocal];
        [self notifyErrorForBLEState:error];
        
        return;
    }
    
    //
    // Detect a duplicate and ignore if found
    //
    if([self.peripherals containsObject:peripheral])
    {
       //DLog(@"\n\nDetected duplicate peripheral: %@\n\n", peripheral.name);
        
        //
        // Search only for services that match our UUID
        //
        [peripheral discoverServices:@[[CBUUID UUIDWithString: _serviceUUID]]];
        
        return;
    }
    
    //
    // Stop scanning once peripheral discovered
    //
    [self.centralManager stopScan];
    
    //
    // Device detected
    //
    [self updateBLEState:MASBLEServiceStateCentralDeviceDetected];
    
    //
    // Stop scanning
    //
    [self updateBLEState:MASBLEServiceStateCentralStopped];
    
    //
    // Add the discovered peripheral
    //
    [peripheral setDelegate:self];
    [self.peripherals addObject:peripheral];
    
    //
    // Connect the peripheral
    //
    [central connectPeripheral:peripheral options:nil];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
   //DLog(@"\n\nconnected to peripheral: %@ for central:\n\n%@\n\n", peripheral.name, [self debugDescription]);
    
    [self updateBLEState:MASBLEServiceStateCentralDeviceConnected];
    
    //
    // Search only for services that match our UUID
    //
    [peripheral discoverServices:@[[CBUUID UUIDWithString: _serviceUUID]]];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
   //DLog(@"\n\nfailed to connect to peripheral: %@ for central:\n\n%@ with error:\n\n%@\n\n", peripheral.name, [self debugDescription], [error localizedDescription]);
   
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
    
    //
    // Remove the peripheral
    //
    [self.peripherals removeObject:peripheral];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
   //DLog(@"\n\ndisconnected from peripheral: %@ for central:\n\n%@\n\n with error:\n\n%@\n\n", peripheral.name, [self debugDescription], [error localizedDescription]);
    
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
    
    //
    // Remove the peripheral
    //
    [self.peripherals removeObject:peripheral];
    
    //
    // Notify delegate
    //
    [self updateBLEState:MASBLEServiceStateCentralDeviceDisconnected];
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
//   DLog(@"\n%@\n\n", [self debugDescription]);
    if (_initializeCodeBlock)
    {
        _initializeCodeBlock();
    }
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)stateInfo
{
   //DLog(@"\n\ncalled with restored state: %@\n\n", stateInfo);
}


# pragma mark - CBPeripheralDelegate
/*
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
}
*/

# pragma mark - CBPeripheralDelegate (Services)

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
   //DLog(@"\n\ncalled with peripheral: %@, services: %@ with error:\n\n%@\n\n", peripheral.name, peripheral.services, [error localizedDescription]);
    
    //
    // Error
    //
    if(error)
    {
       //DLog(@"\n\nError discovering services:\n\n%@\n\n", [error localizedDescription]);
        
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLECentral info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
        
        return;
    }
    
    //
    // Iterate the newly filled peripheral.services array, just in case there's more than one.
    //
    for (CBService *service in peripheral.services)
    {
       //DLog(@"\n\n    found service: %@\n\n", [service debugDescription]);
        
        [self updateBLEState:MASBLEServiceStateCentralServiceDiscovered];
        
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:_characteristicUUID]] forService:service];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    if (error)
    {
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheralServices info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
    }
}

/*
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
}
*/

# pragma mark - CBPeripheralDelegate (Characteristics)

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
   //DLog(@"called with peripheral: %@\n\n%@\n\n with error:\n\n%@\n\n", peripheral.name, [self debugDescription], [error localizedDescription]);
    
    //
    // Error
    //
    if(error)
    {
       //DLog(@"\n\nError when discovering service from peripheral: %@ characteristics:\n\n%@\n\n", service.peripheral.name, [error localizedDescription]);
        
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheralCharacteristics info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
        
        return;
    }
    
    //
    // Lock the thread for one request at a given time
    //
    [_lock lock];
    
    //
    // Again, we loop through the array, just in case.
    //
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //
        // Detect the one we are looking for
        //
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:_characteristicUUID]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            //
            // Notify
            //
            [self updateBLEState:MASBLEServiceStateCentralCharacteristicDiscovered];
            
            //
            // Call method to send data to peripheral with given auth provider and characteristic if authentication provider is provided
            //
            if (_provider)
            {
                [self sendAuthURLWithAuthenticationProvider:_provider characteristic:characteristic];
            }
        }
    }
    
    //
    // Unlock the thread after it's done
    //
    [_lock unlock];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    if (error)
    {
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheralCharacteristics info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    if (error)
    {
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheralCharacteristics info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    if (error)
    {
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheralCharacteristics info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    //
    // Error
    //
    if(error)
    {
        NSError *errorDetail = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheralCharacteristics info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:errorDetail];
        
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if ([stringFromData isEqualToString:@"0"])
    {
        [self updateBLEState:MASBLEServiceStateCentralAuthorizationSucceeded];
        
        //
        // Pull URL, if authentication provider is provided
        //
        if (_provider)
        {
            [self pollAuthorizationCode];
        }
    }
    else {
        [self updateBLEState:MASBLEServiceStateCentralAuthorizationFailed];
    }
    
    //
    // Stop
    //
    [self stopScanning];
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   //DLog(@"\n\n%@\n\n", [self debugDescription]);
    
    if (error)
    {
        //
        // Re-create an error with proper framework error domain and error code.
        //
        NSError *masError = [NSError errorForFoundationCode:MASFoundationErrorCodeBLEPeripheralCharacteristics info:error.userInfo errorDomain:MASFoundationErrorDomainLocal];
        
        //
        // Notify delegate
        //
        [self notifyErrorForBLEState:masError];
    }
}


@end
