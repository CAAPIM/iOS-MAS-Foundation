//
//  MASDevice+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDevice+MASPrivate.h"

#import <objc/runtime.h>
#import "MASAccessService.h"
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"

@implementation MASDevice (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithConfiguration
{
    self = [super init];
    if(self)
    {
        [self setValue:[MASDevice deviceIdBase64Encoded] forKey:@"identifier"];
        NSMutableString *defaultDeviceName = [[[UIDevice currentDevice] model] mutableCopy];
        [self setValue:defaultDeviceName forKey:@"name"];
    }
    
    return self;
}


+ (MASDevice *)instanceFromStorage
{
    MASDevice *device;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] dataForKey:[MASDevice.class description]];
    if(data)
    {
        device = (MASDevice *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return device;
}


- (void)saveToStorage
{
    //
    // Save to the keychain
    //
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if(data)
    {
        NSError *error;
        [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] setData:data
                                                                                                                         forKey:[MASDevice.class description]
                                                                                                                          error:&error];
    
        if(error)
        {
            DLog(@"Error attempting to save data: %@", [error localizedDescription]);
        }
    }
}


- (void)saveWithUpdatedInfo:(NSDictionary *)info
{
    NSAssert(info, @"info cannot be nil");
    
    //
    // Access Service to retrieve information from keychain
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    //
    // Header
    //
    NSDictionary *headerInfo = info[MASResponseInfoHeaderInfoKey];
    
    // Status
    NSString *status = headerInfo[MASDeviceStatusRequestResponseKey];
    if (status)
    {
        [self setValue:status forKey:@"status"];
    }
    
    // JWT
    NSString *jwt = headerInfo[MASJwtRequestResponseKey];
    if (jwt)
    {
        [accessService setAccessValueString:jwt storageKey:MASKeychainStorageKeyJWT];
    }
    
    // Mag Identifier
    NSString *magIdentifier = headerInfo[MASMagIdentifierRequestResponseKey];
    if (magIdentifier)
    {
        [accessService setAccessValueString:magIdentifier storageKey:MASKeychainStorageKeyMAGIdentifier];
    }
    
    // Id token
    NSString *idToken = headerInfo[MASIdTokenHeaderRequestResponseKey];
    if (idToken)
    {
        [accessService setAccessValueString:idToken storageKey:MASKeychainStorageKeyIdToken];
    }
    
    // Id token type
    NSString *idTokenType = headerInfo[MASIdTokenTypeHeaderRequestResponseKey];
    if (idTokenType)
    {
        [accessService setAccessValueString:idTokenType storageKey:MASKeychainStorageKeyIdTokenType];
    }
    
    //
    // Certificate Data (in the body)
    //
    
    NSString *certificateString = info[MASResponseInfoBodyInfoKey];
    NSData *certificateData = [certificateString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (certificateData)
    {
        [accessService setAccessValueCertificate:certificateData storageKey:MASKeychainStorageKeySignedPublicCertificate];
        [accessService setAccessValueData:certificateData storageKey:MASKeychainStorageKeyPublicCertificateData];
        
        //
        // Extracting signed client certificate expiration date
        //
        NSArray * cert = [accessService getAccessValueCertificateWithStorageKey:MASKeychainStorageKeySignedPublicCertificate];
        SecCertificateRef certificate = (__bridge SecCertificateRef)([cert objectAtIndex:0]);

        //
        // Store client certificate expiration date into shared keychain storage
        //
        NSDate *expirationDate = [accessService extractExpirationDateFromCertificate:certificate];
        [accessService setAccessValueNumber:[NSNumber numberWithDouble:[expirationDate timeIntervalSince1970]] storageKey:MASKeychainStorageKeyPublicCertificateExpirationDate];
    }
    
    //
    // Device Vendor Id
    //
    NSString *deviceVendorId = [MASDevice deviceVendorId];    
    if (deviceVendorId)
    {
        [accessService setAccessValueString:deviceVendorId storageKey:MASKeychainStorageKeyDeviceVendorId];
    }
    
    //
    // Reload MASAccess object after storing id-token and type
    //
    [[MASAccessService sharedService].currentAccessObj refresh];
    
    //
    // Save to the keychain
    //
    [self saveToStorage];
}


- (void)reset
{
    [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] removeItemForKey:[MASDevice.class description]];
}


# pragma mark - Public

- (BOOL)isClientCertificateExpired
{
    BOOL isClientCertExpired = YES;
    
    if (self.isRegistered)
    {
        NSDate *expirationDate = [[MASAccessService sharedService].currentAccessObj clientCertificateExpirationDate];
        NSDate *advancedDate = [[NSDate date] dateByAddingTimeInterval:(MASClientCertificateAdvancedRenewTimeframe * 60 * 60 * 24)];
        
        isClientCertExpired = ([advancedDate compare:expirationDate] == NSOrderedDescending);
    }
    
    return isClientCertExpired;
}


+ (NSString *)deviceIdBase64Encoded
{
    NSString *deviceId = [MASDevice deviceVendorId];
    
    //
    //  If the sso is disabled, generate unique device id to differentiate the application's registration record from others.
    //  This is NOT the original design of MSSO; however, we are putting this in to support old MAG SDK's functionality and will revert after the release.
    //
    if (![MASConfiguration currentConfiguration].ssoEnabled)
    {
        //  Append bundle identifier onto device id.
        deviceId = [deviceId stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        
        //  If the device id is longer than 45, csr will not be generated properly, so truncate the string from the END.
        if ([deviceId length] > 45)
        {
            deviceId = [deviceId substringWithRange:NSMakeRange(([deviceId length] - 45), 45)];
        }
    }
    
    NSData *deviceIdData = [deviceId dataUsingEncoding:NSUTF8StringEncoding];
    
    return [deviceIdData base64EncodedStringWithOptions:0];
}


+ (NSString *)deviceNameBase64Encoded;
{
    //
    //  For the time being, as DC attribute in DN needs to be clarified with MAG, sending DC as device model to align with Android SDK.
    //  JG @ January 2, 2017 - DE331046
    //
    NSString *deviceName = [[UIDevice currentDevice] model];
    NSData *deviceNameData = [deviceName dataUsingEncoding:NSUTF8StringEncoding];
    
    return [deviceNameData base64EncodedStringWithOptions:0];
}


+ (NSString *)deviceVendorId
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}


@end
