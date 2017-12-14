//
//  MASAccessService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAccessService.h"

#import "NSData+MASPrivate.h"
#import "MASIKeyChainStore.h"
#import "MASIKeyChainStore+MASPrivate.h"
#import "MASSecurityService.h"

#import <openssl/x509.h>
#import <LocalAuthentication/LocalAuthentication.h>

# pragma mark - Property Constants

static NSString *const kMASAccessSharedStorageServiceName = @"SharedStorageService";
static NSString *const kMASAccessLocalStorageServiceName = @"LocalStorageService";

static NSString *const kMASAccessSharedStorageKey = @"sharedStorage";
static NSString *const kMASAccessLocalStorageKey = @"localStorage";
static NSString *const kMASAccessCustomSharedStorageKey = @"customSharedStorage";

static NSString *const kMASAccessIsNotFreshInstallFlag = @"isNotFreshInstall";

# pragma mark - Keychain Storage Key

NSString * const MASKeychainStorageKeyConfiguration = @"kMASKeyChainConfiguration";
NSString * const MASKeychainStorageKeyAccessToken = @"kMASKeyChainAccessToken";
NSString * const MASKeychainStorageKeyAuthenticatedUserObjectId = @"MASAccessValueTypeAuthenticatedUserObjectId";
NSString * const MASKeychainStorageKeyRefreshToken = @"kMASKeyChainRefreshToken";
NSString * const MASKeychainStorageKeyScope = @"kMASKeyChainScope";
NSString * const MASKeychainStorageKeyTokenType = @"kMASKeyChainTokenType";
NSString * const MASKeychainStorageKeyExpiresIn = @"kMASKeyChainExpiresIn";
NSString * const MASKeychainStorageKeyTokenExpiration = @"kMASKeyChainTokenExpiration";
NSString * const MASKeychainStorageKeySecuredIdToken = @"kMASKeyChainSecuredIdToken";
NSString * const MASKeychainStorageKeyIdToken = @"kMASKeyChainIdToken";
NSString * const MASKeychainStorageKeyIdTokenType = @"kMASKeyChainIdTokenType";
NSString * const MASKeychainStorageKeyClientExpiration = @"kMASKeyChainClientExpiration";
NSString * const MASKeychainStorageKeyClientId = @"kMASKeyChainClientId";
NSString * const MASKeychainStorageKeyClientSecret = @"kMASKeyChainClientSecret";
NSString * const MASKeychainStorageKeyJWT = @"kMASKeyChainJwt";
NSString * const MASKeychainStorageKeyMAGIdentifier = @"kMASKeyChainMagIdentifier";
NSString * const MASKeychainStorageKeyMSSOEnabled = @"kMASAccessValueTypeMSSOEnabled";
NSString * const MASKeychainStorageKeyPrivateKey = @"kMASKeyChainPrivateKey";
NSString * const MASKeychainStorageKeyPrivateKeyBits = @"kMASKeyChainPrivateKeyBits";
NSString * const MASKeychainStorageKeyPublicKey = @"kMASKeyChainPublicKey";
NSString * const MASKeychainStorageKeyTrustedServerCertificate = @"kMASKeyChainTrustedServerCertificate";
NSString * const MASKeychainStorageKeySignedPublicCertificate = @"kMASKeyChainSignedPublicCertificate";
NSString * const MASKeychainStorageKeyPublicCertificateData = @"kMASKeyChainSignedPublicCertificateData";
NSString * const MASKeychainStorageKeyPublicCertificateExpirationDate = @"kMASAccessValueTypeSignedPublicCertificateExpirationDate";
NSString * const MASKeychainStorageKeyAuthenticatedTimestamp = @"kMASAccessValueTypeAuthenticatedTimestamp";
NSString * const MASKeychainStorageKeyIsDeviceLocked = @"kMASAccessValueTypeIsDeviceLocked";
NSString * const MASKeychainStorageKeyCurrentAuthCredentialsGrantType = @"kMASAccessValueTypeCurrentAuthCredentialsGrantType";
NSString * const MASKeychainStorageKeyMASUserObjectData = @"kMASAccessValueTypeMASUserObjectData";
NSString * const MASKeychainStorageKeyDeviceVendorId = @"kMASKeyChainDeviceVendorId";


@interface MASAccessService ()

# pragma mark - Properties

@property (strong, nonatomic, readonly) NSDictionary *storages;

@property (strong, nonatomic, readwrite) NSString *sharedStorageServiceName;
@property (strong, nonatomic, readwrite) NSString *localStorageServiceName;
@property (strong, nonatomic, readwrite) NSString *customSharedStorageServiceName;

@property (strong, nonatomic, readwrite) NSString *gatewayHostName;
@property (strong, nonatomic, readwrite) NSString *gatewayIdentifier;

@property (assign) BOOL isSharedKeychainEnabled;

@property (strong, nonatomic, readwrite) NSArray *sharedStorageKeys;
@property (strong, nonatomic, readwrite) NSArray *localStorageKeys;
@property (strong, nonatomic, readwrite) NSArray *secureStorageKeys;

@end


@implementation MASAccessService

static BOOL _isPKCEEnabled_ = YES;

static BOOL _isKeychainSynchronizable_ = NO;

# pragma mark - Properties

+ (BOOL)isPKCEEnabled
{
    return _isPKCEEnabled_;
}


+ (void)enablePKCE:(BOOL)enable
{
    _isPKCEEnabled_ = enable;
}


+ (BOOL)isKeychainSynchronizable
{
    return _isKeychainSynchronizable_;
}


+ (void)setKeychainSynchronizable:(BOOL)enable
{
    _isKeychainSynchronizable_ = enable;
}


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASAccessService alloc] initProtected];
                  });
    
    return sharedInstance;
}


# pragma mark - Service Lifecycle

+ (NSString *)serviceUUID
{
    return MASAccessServiceUUID;
}


- (void)serviceDidLoad
{
    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    //
    //  Define a list of keys for secured storage
    //
    _secureStorageKeys = @[MASKeychainStorageKeySecuredIdToken];
    
    //
    //  Define a list of keys to be stored in local keychain storage
    //
    _localStorageKeys = @[MASKeychainStorageKeyConfiguration,
                          MASKeychainStorageKeyAccessToken,
                          MASKeychainStorageKeyRefreshToken,
                          MASKeychainStorageKeyScope,
                          MASKeychainStorageKeyTokenType,
                          MASKeychainStorageKeyExpiresIn,
                          MASKeychainStorageKeyTokenExpiration,
                          MASKeychainStorageKeyClientExpiration,
                          MASKeychainStorageKeyClientId,
                          MASKeychainStorageKeyClientSecret,
                          MASKeychainStorageKeyAuthenticatedTimestamp];
    
    //
    //  Define a list of keys to be stored in shared keychain storage
    //
    _sharedStorageKeys = @[MASKeychainStorageKeyAuthenticatedUserObjectId,
                           MASKeychainStorageKeySecuredIdToken,
                           MASKeychainStorageKeyIdToken,
                           MASKeychainStorageKeyIdTokenType,
                           MASKeychainStorageKeyJWT,
                           MASKeychainStorageKeyMAGIdentifier,
                           MASKeychainStorageKeyMSSOEnabled,
                           MASKeychainStorageKeyPrivateKey,
                           MASKeychainStorageKeyPrivateKeyBits,
                           MASKeychainStorageKeyPublicKey,
                           MASKeychainStorageKeyTrustedServerCertificate,
                           MASKeychainStorageKeySignedPublicCertificate,
                           MASKeychainStorageKeyPublicCertificateData,
                           MASKeychainStorageKeyPublicCertificateExpirationDate,
                           MASKeychainStorageKeyCurrentAuthCredentialsGrantType,
                           MASKeychainStorageKeyIsDeviceLocked,
                           MASKeychainStorageKeyMASUserObjectData,
                           MASKeychainStorageKeyDeviceVendorId];
    
    //
    // Retrieve gatewayUrl which is combination of hostname, port number, and prefix of the gateway.
    // The gatewayUrl can be unique identifier for each server.
    //
    _gatewayIdentifier = [MASConfiguration currentConfiguration].gatewayUrl.absoluteString;

    _localStorageServiceName = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, kMASAccessLocalStorageServiceName];
    _sharedStorageServiceName = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, kMASAccessSharedStorageServiceName];
    _customSharedStorageServiceName = [NSString stringWithFormat:@"MAS.%@", kMASAccessCustomSharedStorageKey];
    
    //
    // Custom shared storage
    //
    MASIKeyChainStore *customSharedStorage = [MASIKeyChainStore keyChainStoreWithService:_customSharedStorageServiceName accessGroup:self.accessGroup];
    customSharedStorage.synchronizable = _isKeychainSynchronizable_;
    
    //
    // Local storage
    //
    MASIKeyChainStore *localStorage = [MASIKeyChainStore keyChainStoreWithService:_localStorageServiceName];
    localStorage.synchronizable = _isKeychainSynchronizable_;

    if ([MASConfiguration currentConfiguration].ssoEnabled && [self isAccessGroupAccessible])
    {
        //
        // Shared storage
        //
        MASIKeyChainStore *sharedStorage = [MASIKeyChainStore keyChainStoreWithService:_sharedStorageServiceName accessGroup:self.accessGroup];
        sharedStorage.synchronizable = _isKeychainSynchronizable_;

        //
        // storage dictionary property
        //
        _storages = [NSDictionary dictionaryWithObjectsAndKeys:localStorage, kMASAccessLocalStorageKey, sharedStorage, kMASAccessSharedStorageKey, customSharedStorage, kMASAccessCustomSharedStorageKey, nil];
    }
    else {
        //
        // storage dictionary property
        //
        _storages = [NSDictionary dictionaryWithObjectsAndKeys:localStorage, kMASAccessLocalStorageKey, localStorage, kMASAccessSharedStorageKey, customSharedStorage, kMASAccessCustomSharedStorageKey, nil];
    }
    
    
    //
    // For fresh install, make sure that local keychain storage information from previous installation is wiped out.
    // As Apple's keychain storage process keeps the local keychain information after uninstallation, our framework wants to make sure that local keychain storage is clean
    // upon fresh install.
    //
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kMASAccessIsNotFreshInstallFlag])
    {
        //
        // Mark the flag
        //
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMASAccessIsNotFreshInstallFlag];
        
        //
        // Clear ONLY the local keychain storage if it is fresh install.
        // For shared keychain, do not remove it as other apps via MSSO may access to those information.
        //
        [_storages[kMASAccessLocalStorageKey] removeAllItems];
    }
    
    //
    // retrieve the MASAccess object from the storage
    //
    _currentAccessObj = [MASAccess instanceFromStorage];
    
    [super serviceWillStart];
}


- (void)serviceDidStart
{
    [super serviceDidStart];
}


- (void)serviceWillStop
{
    [super serviceWillStop];
    
    if (_gatewayIdentifier)
    {
        _gatewayIdentifier = nil;
    }
}


- (void)serviceDidStop
{
    [super serviceDidStop];
}


- (void)serviceDidReset
{
    [super serviceDidReset];

    if (_currentAccessObj)
    {
        _currentAccessObj = nil;
    }
}


# pragma mark - MASAccess object

- (void)saveAccessValuesWithDictionary:(NSDictionary *)dictionary forceToOverwrite:(BOOL)forceToOverwrite
{
    //
    // if the user chooses to overwite whatever SDK contains with the provided dictionary, reset the object
    //
    if (forceToOverwrite)
    {
        [_currentAccessObj reset];
        _currentAccessObj = nil;
    }

    //
    // if the object still exists, update it
    //
    if (_currentAccessObj)
    {
        [_currentAccessObj updateWithInfo:dictionary];
    }
    //
    // otherwise, create new object
    //
    else
    {
        _currentAccessObj = [[MASAccess alloc] initWithInfo:dictionary];
    }
}


# pragma mark - Storage methods

- (id)getAccessValueIdentities
{
    //DLog(@"\n\ncalled\n\n");
    
    MASIKeyChainStore *keychainStore = [MASIKeyChainStore keyChainStore];
    NSArray *identities = [keychainStore identitiesWithCertificateLabel:[self convertKeyString:MASKeychainStorageKeySignedPublicCertificate]];
    
    return identities;
}


- (void)setAccessValueCertificate:(NSData *)certificate storageKey:(NSString *)storageKey
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
 
    NSData * certData = nil;
    
    if (certificate)
    {
        NSString * certString = [[NSString alloc] initWithData:certificate encoding:NSUTF8StringEncoding];
        certData = [NSData convertPEMCertificateToDERCertificate:certString];
    }
    
    //
    // Addition
    //
    if (certificate) {
        [destinationStorage setCertificate:certData forKey:accessValueAsString];
    }
    //
    // Removal
    //
    else {
        [destinationStorage clearCertificatesAndIdentitiesWithCertificateLabelKey:accessValueAsString];
    }
}


- (id)getAccessValueCertificateWithStorageKey:(NSString *)storageKey
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    
    return [destinationStorage certificateForKey:accessValueAsString];
}


- (BOOL)setAccessValueData:(NSData *)data storageKey:(NSString *)storageKey
{
    return [self setAccessValueData:data storageKey:storageKey error:nil];
}


- (BOOL)setAccessValueData:(NSData *)data storageKey:(NSString *)storageKey error:(NSError **)error
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    NSError *operationError = nil;
    
    BOOL isSecuredData = [self isSecureData:storageKey];
    BOOL result = NO;
    
    if (isSecuredData)
    {
        [destinationStorage setAccessibility:MASIKeyChainStoreAccessibilityWhenUnlockedThisDeviceOnly authenticationPolicy:MASIKeyChainStoreAuthenticationPolicyUserPresence];
    }
    
    //
    // Addition
    //
    if (data)
    {
        result = [destinationStorage setData:data forKey:accessValueAsString error:&operationError];
    }
    //
    // Removal
    //
    else
    {
        result = [destinationStorage removeItemForKey:accessValueAsString error:&operationError];
    }
    
    if (isSecuredData)
    {
        [destinationStorage setAccessibility:MASIKeyChainStoreAccessibilityAfterFirstUnlock authenticationPolicy:0];
    }
    
    if (error)
    {
        *error = operationError;
    }
    
    return result;
}


- (NSData *)getAccessValueDataWithStorageKey:(NSString *)storageKey
{
    return [self getAccessValueDataWithStorageKey:storageKey error:nil];
}


- (NSData *)getAccessValueDataWithStorageKey:(NSString *)storageKey error:(NSError **)error
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    NSError *operationError = nil;
    
    NSData *keychainData = [destinationStorage dataForKey:accessValueAsString error:&operationError];
    
    if (error)
    {
        *error = operationError;
    }
    
    return keychainData;
}


- (BOOL)setAccessValueString:(NSString *)string storageKey:(NSString *)storageKey
{
    return [self setAccessValueString:string storageKey:storageKey error:nil];
}


- (BOOL)setAccessValueString:(NSString *)string storageKey:(NSString *)storageKey error:(NSError **)error
{
    
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    NSError *operationError = nil;
    
    BOOL result = NO;
    BOOL isSecuredData = [self isSecureData:storageKey];
    
    if (isSecuredData)
    {
        [destinationStorage setAccessibility:MASIKeyChainStoreAccessibilityWhenUnlockedThisDeviceOnly authenticationPolicy:MASIKeyChainStoreAuthenticationPolicyUserPresence];
    }
    
    //
    // Addition
    //
    if (string)
    {
        result = [destinationStorage setString:string forKey:accessValueAsString error:&operationError];
    }
    //
    // Removal
    //
    else
    {
        result = [destinationStorage removeItemForKey:accessValueAsString error:&operationError];
    }
    
    if (isSecuredData)
    {
        [destinationStorage setAccessibility:MASIKeyChainStoreAccessibilityAfterFirstUnlock authenticationPolicy:0];
    }
    
    if (error)
    {
        *error = operationError;
    }
    
    return result;
}


- (NSString *)getAccessValueStringWithStorageKey:(NSString *)storageKey
{
    return [self getAccessValueStringWithStorageKey:storageKey error:nil];
}


- (NSString *)getAccessValueStringWithStorageKey:(NSString *)storageKey userOperationPrompt:(NSString *)userOperationPrompt error:(NSError **)error
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    NSError *operationError = nil;
    
    NSString *securedString = [destinationStorage stringForKey:accessValueAsString userOperationPrompt:userOperationPrompt error:&operationError];
    
    if (error)
    {
        *error = operationError;
    }
    
    return securedString;
}


- (NSString *)getAccessValueStringWithStorageKey:(NSString *)storageKey error:(NSError **)error
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    NSError *operationError = nil;
    
    NSString *securedString = [destinationStorage stringForKey:accessValueAsString error:&operationError];
    
    if (error)
    {
        *error = operationError;
    }
    
    return securedString;
}


- (BOOL)setAccessValueDictionary:(NSDictionary *)dictionary storageKey:(NSString *)storageKey
{
    
    //
    // convert dictionary to data
    //
    NSData *thisData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    BOOL result = NO;
    
    //
    // make sure the data exists
    //
    if (thisData)
    {
        result = [self setAccessValueData:thisData storageKey:storageKey];
    }
    
    return result;
}


- (NSDictionary *)getAccessValueDictionaryWithStorageKey:(NSString *)storageKey
{
    //
    // get data from keychain as NSData first
    //
    NSData *thisData = [self getAccessValueDataWithStorageKey:storageKey];
    
    //
    // return nil if NSData is nil
    //
    return thisData ? [NSKeyedUnarchiver unarchiveObjectWithData:thisData] : nil;
}


- (BOOL)setAccessValueNumber:(NSNumber *)number storageKey:(NSString *)storageKey
{
    // convert dictionary to data
    //
    NSData *thisData = [NSKeyedArchiver archivedDataWithRootObject:number];
    BOOL result = NO;
    
    //
    // make sure the data exists
    //
    if (thisData)
    {
        result = [self setAccessValueData:thisData storageKey:storageKey];
    }
    
    return result;
}


- (NSNumber *)getAccessValueNumberWithStorageKey:(NSString *)storageKey
{
    //
    // get data from keychain as NSData first
    //
    NSData *thisData = [self getAccessValueDataWithStorageKey:storageKey];
    
    //
    // return nil if NSData is nil
    //
    return thisData ? [NSKeyedUnarchiver unarchiveObjectWithData:thisData] : nil;
}


- (void)setAccessValueCryptoKey:(SecKeyRef)cryptoKey storageKey:(NSString *)storageKey
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    
    NSString *keyIdentifierStr = nil;
    
    
    if ([storageKey isEqualToString:MASKeychainStorageKeyPublicKey])
    {
        keyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    }
    else if ([storageKey isEqualToString:MASKeychainStorageKeyPrivateKey])
    {
        keyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"privateKey"];
    }
    
    if (keyIdentifierStr)
    {
        NSData *keyData = [[NSData alloc] initWithBytes:[keyIdentifierStr UTF8String]
                                                 length:[keyIdentifierStr length]];
        
        [destinationStorage setCryptoKey:cryptoKey forApplicationTag:keyData];
    }
}


- (SecKeyRef)getAccessValueCryptoKeyWithStorageKey:(NSString *)storageKey
{
    
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    
    NSString *keyIdentifierStr = nil;
    
    
    if ([storageKey isEqualToString:MASKeychainStorageKeyPublicKey])
    {
        keyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    }
    else if ([storageKey isEqualToString:MASKeychainStorageKeyPrivateKey])
    {
        keyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"privateKey"];
    }
    
    
    if (keyIdentifierStr)
    {
        NSData *keyData = [[NSData alloc] initWithBytes:[keyIdentifierStr UTF8String]
                                                 length:[keyIdentifierStr length]];
        
        return [destinationStorage cryptoKeyForApplicationTag:keyData];
    }
    else {
        return nil;
    }
}


- (void)deleteForStorageKey:(NSString *)storageKey error:(NSError **)error
{
    NSString *storageType = [self getStorageTypeWithKey:storageKey];
    NSString *accessValueAsString = [self convertKeyString:storageKey];
    MASIKeyChainStore *destinationStorage = _storages[storageType];
    
    NSError *operationError = nil;
    
    [destinationStorage removeItemForKey:accessValueAsString error:&operationError];
    
    if (operationError && error)
    {
        *error = operationError;
    }
}


#pragma mark - Private

+ (NSString *)padding:(NSString *)encodedString{
    
    unsigned long lengthtRequired = (int)(4 * ceil((float)[encodedString length] / 4.0));
    long numPaddings = lengthtRequired - [encodedString length];
    
    if (numPaddings > 0) {
        NSString *padding =
        [[NSString string] stringByPaddingToLength:numPaddings
                                        withString:@"=" startingAtIndex:0];
        encodedString = [encodedString stringByAppendingString:padding];
    }
    
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    
    return encodedString;
}


+ (NSDictionary *)getIdTokenSegments:(NSString *)idToken error:(NSError *__autoreleasing *)error
{
    NSDictionary *segmentsDict = nil;
    
    NSArray *segments = [idToken componentsSeparatedByString:@"."];
    
    //
    // check if idToken is in valid format
    //
    if (segments == nil || [segments count] != 3) {
        
        if (error)
        {
            *error = [NSError errorInvalidIdToken];
        }
    }
    
    NSString *headerString = [segments objectAtIndex:0];
    NSString *payload = [segments objectAtIndex:1];
    NSString *signature = [segments objectAtIndex:2];
    
    if (!headerString || !payload || !signature){
        
        if (error)
        {
            *error = [NSError errorInvalidIdToken];
        }
        
    }
    else {
        segmentsDict = [[NSDictionary alloc] initWithObjectsAndKeys:headerString, @"headerString", payload, @"payload", signature, @"signature", nil];
    }
    
    return segmentsDict;
}


+ (NSDictionary *)unwrap:(NSString *)data
{
    NSDictionary *dictionary = nil;
    
    //
    // process to unwrap
    //
    NSData *decodedData = [NSData dataWithBase64EncodedString:data];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    dictionary = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:0
                                                   error:nil];
    
    return dictionary;
}


- (NSString *)convertKeyString:(NSString *)key
{
    NSString *accessTypeToString = nil;
    
    //
    //  Internal system data
    //
    if ([_sharedStorageKeys containsObject:key] || [_localStorageKeys containsObject:key])
    {
        accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, key];
        
        //
        //  When access gruop is not accessiable, differentiate the key to make sure there is no conflict of device registration record in the future
        //
        if (![self isAccessGroupAccessible])
        {
            accessTypeToString = [NSString stringWithFormat:@"_%@", accessTypeToString];
        }
    }
    //
    //  External custom data in shared keychain storage
    //
    else {
        accessTypeToString = key;
    }
    
    return accessTypeToString;
}


- (BOOL)isSecureData:(NSString *)key
{
    return [_secureStorageKeys containsObject:key];
}


- (NSString *)getStorageTypeWithKey:(NSString *)key
{
    if ([_sharedStorageKeys containsObject:key])
    {
        return kMASAccessSharedStorageKey;
    }
    else if ([_localStorageKeys containsObject:key])
    {
        return kMASAccessLocalStorageKey;
    }
    //
    //  If the key is not defined in either of shared nor local storage, the key must be custom data which will always be stored in shared
    //
    else {
        return kMASAccessCustomSharedStorageKey;
    }
}


#pragma mark - accessGroup

- (BOOL)isAccessGroupAccessible
{
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        NSString *sharedService = [NSString stringWithFormat:@"kMASFoundationSharedKeyChainAccess.%@", kMASAccessSharedStorageServiceName];
        NSString *tmpDataKey = self.accessGroup;
        
        NSError *sharedKeychainError;
        
        BOOL isAccessGroupAvailable = [MASIKeyChainStore setString:self.accessGroup forKey:tmpDataKey service:sharedService accessGroup:self.accessGroup error:&sharedKeychainError];
        
        if (!isAccessGroupAvailable || sharedKeychainError != nil)
        {
            _isSharedKeychainEnabled = NO;
        }
        else {
            [MASIKeyChainStore removeItemForKey:tmpDataKey service:sharedService accessGroup:self.accessGroup];
            _isSharedKeychainEnabled = YES;
        }
    });
    
    return _isSharedKeychainEnabled;
}


- (NSString *)accessGroup
{
    
    //
    // if accessGroup is not defined
    //
    if (!_accessGroup)
    {

        NSString *groupSuffix = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MSSOSDKKeychainGroup"];
        _accessGroup = [self buildAccessGroup:groupSuffix];
    }
    
    return _accessGroup;
}


- (NSString *)buildAccessGroup: (NSString*) groupSuffix {
    
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    
    NSMutableArray *components = (NSMutableArray *)[accessGroup componentsSeparatedByString:@"."];
    NSString *group;
    
    if(components.count==1){
        group = nil;
    }else if(groupSuffix == nil || groupSuffix.length==0){
        [components replaceObjectAtIndex:components.count-1 withObject:@"singleSignOn"];
        group = [components componentsJoinedByString:@"."];
    }else{
        group = [NSString stringWithFormat:@"%@.%@", [components objectAtIndex:0], groupSuffix];
    }
    
    DLog(@"access group generated: %@", group);
    CFRelease(result);
    
    return group;
}


# pragma mark - Public

- (BOOL)lockSession:(NSError * __nullable __autoreleasing * __nullable)error
{
    NSError *localError = nil;
    BOOL success = NO;
    
    //
    // Check if the local authentication is available
    //
    if ([LAContext class])
    {
        BOOL isLAAvailable = [[LAContext new] canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil];
        
        if (!isLAAvailable)
        {
            //
            // If local authentication is not available, make sure to clean up all keychain data protected by local authentication
            // those keychain data protected by LA will not be accessible if LA is not present
            //
            localError = [NSError errorDeviceDoesNotSupportLocalAuthentication];
            
            [self removeSessionLock];
        }
    }
    
    //
    // Check the device lock status
    //
    if ([MASUser currentUser].isSessionLocked && !localError)
    {
        //
        // If the session is alreay locked, return true
        //
        return YES;
    }
    
    //
    // If LA is available and device lock status is correct, retrieve id_token and secure it with LA
    //
    if (!localError)
    {
        NSString *idToken = [MASAccessService sharedService].currentAccessObj.idToken;
        
        //
        // id_token should exist to lock the device with LA
        //
        if (!idToken)
        {
            localError = [NSError errorIdTokenNotExistForLockingUserSession];
        }
        
        //
        // Secure id_token
        //
        if (!localError)
        {
            [self setAccessValueString:idToken storageKey:MASKeychainStorageKeySecuredIdToken error:&localError];
        }
    }
    
    //
    // If an error occured from any of above, revert everything and return the error
    //
    if (localError)
    {
        //
        // If the device is not locked, and there was an error, clean up the protected keychain storage
        //
        if (![MASUser currentUser].isSessionLocked)
        {
            [self setAccessValueString:nil storageKey:MASKeychainStorageKeySecuredIdToken];
        }
        
        if (error != NULL)
        {
            *error = localError;
        }
    }
    //
    // If it was successful to secure tokens with local authentication, nullify the tokens in unprotected keychain storage
    //
    else {
        
        [self setAccessValueString:nil storageKey:MASKeychainStorageKeyAccessToken];
        [self setAccessValueString:nil storageKey:MASKeychainStorageKeyRefreshToken];
        [self setAccessValueString:nil storageKey:MASKeychainStorageKeyIdToken];
        [self setAccessValueNumber:[NSNumber numberWithBool:YES] storageKey:MASKeychainStorageKeyIsDeviceLocked];
        
        //
        // Refresh the currentAccessObj to reflect the current status
        //
        [[MASAccessService sharedService].currentAccessObj refresh];
        
        success = YES;
    }
    
    return success;
}


- (BOOL)unlockSessionWithUserOperationPromptMessage:(NSString *)userOperationPrompt error:(NSError * __nullable __autoreleasing * __nullable)error
{
    NSError *localError = nil;
    NSString *idToken = nil;
    
    BOOL success = NO;
    
    //
    // Check if the local authentication is available
    //
    if ([LAContext class])
    {
        BOOL isLAAvailable = [[LAContext new] canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil];
        
        if (!isLAAvailable)
        {
            //
            // If local authentication is not available, make sure to clean up all keychain data protected by local authentication
            // those keychain data protected by LA will not be accessible if LA is not present
            //
            localError = [NSError errorDeviceDoesNotSupportLocalAuthentication];
            
            [self removeSessionLock];
        }
    }
    
    //
    // Check the device lock status
    //
    if (![MASUser currentUser].isSessionLocked && !localError)
    {
        //
        // If the session is already unlocked, return true
        //
        return YES;
    }
    
    //
    // Retrieve id_token from secured keychain storage if the device is locked
    //
    if (!localError)
    {
        idToken = [self getAccessValueStringWithStorageKey:MASKeychainStorageKeySecuredIdToken userOperationPrompt:userOperationPrompt error:&localError];
    }
    
    if (idToken)
    {
        //
        // Validate id_token whether it is valid or not
        //
        BOOL isIdTokenValid = [MASAccessService validateIdToken:idToken
                                                  magIdentifier:[[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier]
                                                          error:&localError];
        
        if (localError && localError.code != MASFoundationErrorCodeTokenIdTokenExpired)
        {
            localError = nil;
            isIdTokenValid = YES;
        }
        //
        // If the id_token is no longer valid; remove the session lock regardless
        //
        if (!isIdTokenValid)
        {
            [self removeSessionLock];
        }
    }
    
    //
    // If all tokens were successfully retrieved from secured keychain storage, clean up the secured storage and restore them into regular keychain storage
    //
    if (!localError)
    {
        [self setAccessValueString:idToken storageKey:MASKeychainStorageKeyIdToken];
        [self setAccessValueString:nil storageKey:MASKeychainStorageKeySecuredIdToken];
        [self setAccessValueNumber:[NSNumber numberWithBool:NO] storageKey:MASKeychainStorageKeyIsDeviceLocked];
        
        //
        // Refresh the currentAccessObj to reflect the current status
        //
        [[MASAccessService sharedService].currentAccessObj refresh];
        
        success = YES;
    }
    else {
        if (error != NULL)
        {
            *error = localError;
        }
    }
    
    return success;
}


- (void)removeSessionLock
{
    [self setAccessValueString:nil storageKey:MASKeychainStorageKeySecuredIdToken];
    [self setAccessValueNumber:[NSNumber numberWithBool:NO] storageKey:MASKeychainStorageKeyIsDeviceLocked];
    
    //
    // Refresh the currentAccessObj to reflect the current status
    //
    [[MASAccessService sharedService].currentAccessObj refresh];
}

+ (BOOL)validateIdToken:(NSString *)idToken magIdentifier:(NSString *)magIdentifier error:(NSError *__autoreleasing *)error
{
    //
    // Credits to Anthony Yu
    //

    //
    // extract idToken segments
    //
    NSDictionary *idTokenSegments = [MASAccessService getIdTokenSegments:idToken error:error];
    
    //
    // if could not extract segments, there is an issue with the idToken
    //
    if (!idTokenSegments)
    {
        return NO;
    }
    
    NSString *headerString = [idTokenSegments valueForKey:@"headerString"];
    NSString *payload = [idTokenSegments valueForKey:@"payload"];
    NSString *signature = [idTokenSegments valueForKey:@"signature"];;
    
    //
    // verifying signature
    // processes to unwrap the header
    //
    NSDictionary *headerDisctionary = [MASAccessService unwrap:headerString];
    
    if ([[headerDisctionary objectForKey:@"alg"] isEqualToString:@"HS256"])
    {
        
        //
        // check signature
        //
        NSMutableArray *signatureSegments = [NSMutableArray array];
        [signatureSegments addObject:headerString];
        [signatureSegments addObject:payload];
        
        NSString *signingInput = [signatureSegments componentsJoinedByString:@"."];
        NSString *clientSecret = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientSecret];
        NSData *signedInput = [NSData sign:signingInput key:clientSecret];
        NSString *encodedSignedInput = [signedInput base64Encoding];
        
        //
        // case 1: signature doesn't match
        //
        if (![encodedSignedInput isEqualToString:[MASAccessService padding:signature]]){
            
            if (error)
            {
                *error = [NSError errorIdTokenInvalidSignature];
            }
            return NO;
        }
    }
    
    //
    // validating payload
    //
    NSDictionary *payloadDictionary = [MASAccessService unwrap:payload];
    
    NSString *aud = [payloadDictionary valueForKey:@"aud"];
    NSString *azp = [payloadDictionary valueForKey:@"azp"];
    NSDate *exp = [NSDate dateWithTimeIntervalSince1970:[[payloadDictionary valueForKey:@"exp"] floatValue]];
    
    if (!aud || !azp || !exp)
    {
        
        if (error)
        {
            *error = [NSError errorInvalidIdToken];
        }
        return NO;
    }
    
    //
    // case 2: aud doesn't match with clientId
    //
    if (![aud isEqualToString:[[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientId]])
    {
        
        if (error)
        {
            *error = [NSError errorIdTokenInvalidAud];
        }
        return NO;
    }
    
    //
    // case 3: azp doesn't match with mag-identifier
    //
    if (![azp isEqualToString:magIdentifier])
    {
        
        if (error)
        {
            *error = [NSError errorIdTokenInvalidAzp];
        }
        return NO;
    }
    
    //
    // case 4: JWT expired
    //
    if ([exp timeIntervalSinceNow] < 0)
    {
        
        if (error)
        {
            *error = [NSError errorIdTokenExpired];
        }
        return NO;
    }

    
    return YES;
}

+ (BOOL)isIdTokenExpired:(NSString *)idToken error:(NSError *__autoreleasing *)error
{
    //
    // extract idToken segments
    //
    NSDictionary *idTokenSegments = [MASAccessService getIdTokenSegments:idToken error:error];
    
    //
    // if could not extract segments, there is an issue with the idToken so return as expired
    //
    if (!idTokenSegments)
    {
        return YES;
    }
    
    //
    // validate expire date
    //
    NSString *payload = [idTokenSegments valueForKey:@"payload"];
    
    //
    // unwrap payload
    //
    NSDictionary *payloadDictionary = [MASAccessService unwrap:payload];

    NSDate *exp = [NSDate dateWithTimeIntervalSince1970:[[payloadDictionary valueForKey:@"exp"] floatValue]];

    //
    // check if JWT expired
    //
    if ([exp timeIntervalSinceNow] < 0)
    {
        
        if (error)
        {
            *error = [NSError errorIdTokenExpired];
        }
        return YES;
    }
    
    return NO;
}


//
// Reference & Credits To: http://stackoverflow.com/a/8903088/6242350
//
- (NSDate *)extractExpirationDateFromCertificate:(SecCertificateRef)certificate
{
    NSDate *expirationDate = nil;
    
    NSData *certificateData = (NSData *) CFBridgingRelease(SecCertificateCopyData(certificate));
    
    const unsigned char *certificateDataBytes = (const unsigned char *)[certificateData bytes];
    X509 *certificateX509 = d2i_X509(NULL, &certificateDataBytes, [certificateData length]);
    
    
    if (certificateX509 != NULL)
    {
        ASN1_TIME *certificateExpiryASN1 = X509_get_notAfter(certificateX509);
        if (certificateExpiryASN1 != NULL)
        {
            ASN1_GENERALIZEDTIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
            if (certificateExpiryASN1Generalized != NULL)
            {
                unsigned char *certificateExpiryData = ASN1_STRING_data(certificateExpiryASN1Generalized);
                
                // ASN1 generalized times look like this: "20131114230046Z"
                //                                format:  YYYYMMDDHHMMSS
                //                               indices:  01234567890123
                //                                                   1111
                // There are other formats (e.g. specifying partial seconds or
                // time zones) but this is good enough for our purposes since
                // we only use the date and not the time.
                //
                // (Source: http://www.obj-sys.com/asn1tutorial/node14.html)
                
                NSString *expiryTimeStr = [NSString stringWithUTF8String:(char *)certificateExpiryData];
                NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];
                
                expiryDateComponents.year   = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)] intValue];
                expiryDateComponents.month  = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)] intValue];
                expiryDateComponents.day    = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)] intValue];
                expiryDateComponents.hour   = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)] intValue];
                expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)] intValue];
                expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)] intValue];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                expirationDate = [calendar dateFromComponents:expiryDateComponents];
            }
        }
    }
    
    return expirationDate;
}


- (BOOL)isInternalDataForStorageKey:(NSString *)storageKey
{
    BOOL isInternalData = NO;
    
    if ([_localStorageKeys containsObject:storageKey] || [_sharedStorageKeys containsObject:storageKey])
    {
        isInternalData = YES;
    }
    
    return isInternalData;
}


# pragma mark - Debug only

- (void)clearLocal
{
    [_storages[kMASAccessLocalStorageKey] removeAllItems];
    
    //DLog(@"called and self is now: %@", [self debugSecuredDescription]);
}


- (void)clearShared;
{
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyMAGIdentifier];
    [_storages[kMASAccessSharedStorageKey] removeAllItems];
    
    //
    // Retrieve the key for certificate
    //
    NSString *certificateKey = [self convertKeyString:MASKeychainStorageKeySignedPublicCertificate];
    [[MASIKeyChainStore keyChainStore] clearCertificatesAndIdentitiesWithCertificateLabelKey:certificateKey];
    
    //
    // Remove private key and public key
    //
    [[MASSecurityService sharedService] deleteAsymmetricKeys];

    //DLog(@"called and self is now: %@", [self debugSecuredDescription]);
}


- (NSString *)debugSecuredDescription
{
    //
    // Local
    //
    NSString *value = [NSString stringWithFormat:@"\n\n(MASAccessService)\n\n  Local (%@):\n", kMASAccessLocalStorageServiceName];
    NSMutableString *keychainDescription = [[NSMutableString alloc] initWithString:value];
    
    for (NSString *key in [_storages[kMASAccessLocalStorageKey] allKeys])
    {
        [keychainDescription appendString:[NSString stringWithFormat:@"\n      key: %@", key]];
    }
    
    //
    // Shared
    //
    value = [NSString stringWithFormat:@"\n\n  Shared (%@):\n", kMASAccessSharedStorageServiceName];
    [keychainDescription appendString:value];
    
    for (NSString *key in [_storages[kMASAccessSharedStorageKey] allKeys])
    {
        [keychainDescription appendString:[NSString stringWithFormat:@"\n      key: %@", key]];
    }
    
    //
    //  Custom
    //
    value = [NSString stringWithFormat:@"\n\n  Custom (%@):\n", kMASAccessCustomSharedStorageKey];
    [keychainDescription appendString:value];
    
    for (NSString *key in [_storages[kMASAccessCustomSharedStorageKey] allKeys])
    {
        [keychainDescription appendString:[NSString stringWithFormat:@"\n      key: %@", key]];
    }
    
    [keychainDescription appendString:@"\n\n*********************\n\n"];
    
    return keychainDescription;
}

@end
