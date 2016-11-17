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


# pragma mark - Property Constants

static NSString *const MASDeviceIsRegisteredPropertyKey = @"isRegistered"; // bool
static NSString *const MASDeviceIdentifierPropertyKey = @"identifier"; // string
static NSString *const MASDeviceNamePropertyKey = @"name"; // string
static NSString *const MASDeviceStatusPropertyKey = @"status"; // string


@implementation MASDevice (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithConfiguration
{
    self = [super init];
    if(self)
    {
        self.identifier = [MASDevice deviceIdBase64Encoded];
        self.name = [MASDevice deviceNameBase64Encoded];
    }
    
    return self;
}


+ (MASDevice *)instanceFromStorage
{
    //DLog(@"\n\ncalled\n\n");
    
    MASDevice *device;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] dataForKey:[MASDevice.class description]];
    if(data)
    {
        device = (MASDevice *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    //DLog(@"\n\ncalled and returning device: %@\n\n", [device debugDescription]);
    
    return device;
}


- (void)saveToStorage
{
    //DLog(@"\n\ncalled\n\n");
    
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
    //DLog(@"\n\ncalled\n\n");
    
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
        self.status = status;
    }
    
    // JWT
    NSString *jwt = headerInfo[MASJwtRequestResponseKey];
    if (jwt)
    {
        [accessService setAccessValueString:jwt withAccessValueType:MASAccessValueTypeJWT];
    }
    
    // Mag Identifier
    NSString *magIdentifier = headerInfo[MASMagIdentifierRequestResponseKey];
    if (magIdentifier)
    {
        [accessService setAccessValueString:magIdentifier withAccessValueType:MASAccessValueTypeMAGIdentifier];
    }
    
    // Id token
    NSString *idToken = headerInfo[MASIdTokenHeaderRequestResponseKey];
    if (idToken)
    {
        [accessService setAccessValueString:idToken withAccessValueType:MASAccessValueTypeIdToken];
    }
    
    // Id token type
    NSString *idTokenType = headerInfo[MASIdTokenTypeHeaderRequestResponseKey];
    if (idTokenType)
    {
        [accessService setAccessValueString:idTokenType withAccessValueType:MASAccessValueTypeIdTokenType];
    }
    
    //
    // Certificate Data (in the body)
    //
    DLog(@"\n\nCert data is: %@\n\n", info[MASResponseInfoBodyInfoKey]);
    
    NSData *certificateData = info[MASResponseInfoBodyInfoKey];
    if (certificateData)
    {
        [accessService setAccessValueCertificate:certificateData withAccessValueType:MASAccessValueTypeSignedPublicCertificate];
        [accessService setAccessValueData:certificateData withAccessValueType:MASAccessValueTypeSignedPublicCertificateData];
        
        //
        // Extracting signed client certificate expiration date
        //
        NSArray * cert = [accessService getAccessValueCertificateWithType:MASAccessValueTypeSignedPublicCertificate];
        SecCertificateRef certificate = (__bridge SecCertificateRef)([cert objectAtIndex:0]);

        //
        // Store client certificate expiration date into shared keychain storage
        //
        NSDate *expirationDate = [accessService extractExpirationDateFromCertificate:certificate];
        [accessService setAccessValueNumber:[NSNumber numberWithDouble:[expirationDate timeIntervalSince1970]] withAccessValueType:MASAccessValueTypeSignedPublicCertificateExpirationDate];
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


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
    [super encodeWithCoder:aCoder];
    
    if(self.identifier) [aCoder encodeObject:self.identifier forKey:MASDeviceIdentifierPropertyKey];
    if(self.name) [aCoder encodeObject:self.name forKey:MASDeviceNamePropertyKey];
    if(self.status) [aCoder encodeObject:self.status forKey:MASDeviceStatusPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //DLog(@"\n\ncalled\n\n");
    
    if(self = [super initWithCoder:aDecoder])
    {
        self.identifier = [aDecoder decodeObjectForKey:MASDeviceIdentifierPropertyKey];
        self.name = [aDecoder decodeObjectForKey:MASDeviceNamePropertyKey];
        self.status = [aDecoder decodeObjectForKey:MASDeviceStatusPropertyKey];
    }
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)isRegistered
{
    //
    // Obtain key chain items to determine registration status
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSString *magIdentifier = [accessService getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier];
    NSData *certificateData = [accessService getAccessValueCertificateWithType:MASAccessValueTypeSignedPublicCertificate];

    return (magIdentifier && certificateData);
}


- (NSString *)identifier
{
    return objc_getAssociatedObject(self, &MASDeviceIdentifierPropertyKey);
}


- (void)setIdentifier:(NSString *)identifier
{
    objc_setAssociatedObject(self, &MASDeviceIdentifierPropertyKey, identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)name
{
    return objc_getAssociatedObject(self, &MASDeviceNamePropertyKey);
}


- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, &MASDeviceNamePropertyKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)status
{
    return objc_getAssociatedObject(self, &MASDeviceStatusPropertyKey);
}


- (void)setStatus:(NSString *)status
{
    objc_setAssociatedObject(self, &MASDeviceStatusPropertyKey, status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma clang diagnostic pop

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
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
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
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSData *deviceNameData = [deviceName dataUsingEncoding:NSUTF8StringEncoding];
    
    return [deviceNameData base64EncodedStringWithOptions:0];
}

@end
