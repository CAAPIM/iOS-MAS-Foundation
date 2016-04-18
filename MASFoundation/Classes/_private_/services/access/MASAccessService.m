//
//  MASAccessService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAccessService.h"

#import "NSData+MASPrivate.h"
#import "MASIKeyChainStore.h"
#import "MASIKeyChainStore+MASPrivate.h"
#import "MASSecurityService.h"


# pragma mark - Property Constants

static NSString *const kMASAccessSharedStorageServiceName = @"SharedStorageService";
static NSString *const kMASAccessLocalStorageServiceName = @"LocalStorageService";

static NSString *const kMASAccessSharedStorageKey = @"sharedStorage";
static NSString *const kMASAccessLocalStorageKey = @"localStorage";

static NSString *const kMASAccessIsNotFreshInstallFlag = @"isNotFreshInstall";

@interface MASAccessService ()

# pragma mark - Properties

@property (strong, nonatomic, readonly) NSDictionary *storages;
@property (strong, nonatomic, readwrite) NSString *sharedStorageServiceName;
@property (strong, nonatomic, readwrite) NSString *localStorageServiceName;
@property (strong, nonatomic, readwrite) NSString *gatewayHostName;

@property (strong, nonatomic, readwrite) NSString *gatewayIdentifier;

@end


@implementation MASAccessService


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
    // Retrieve gatewayUrl which is combination of hostname, port number, and prefix of the gateway.
    // The gatewayUrl can be unique identifier for each server.
    //
    _gatewayIdentifier = [MASConfiguration currentConfiguration].gatewayUrl.absoluteString;

    
    _localStorageServiceName = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, kMASAccessLocalStorageServiceName];
    
    if ([MASConfiguration currentConfiguration].ssoEnabled)
    {
        _sharedStorageServiceName = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, kMASAccessSharedStorageServiceName];
        
        //
        // Local storage
        //
        MASIKeyChainStore *localStorage = [MASIKeyChainStore keyChainStoreWithService:_localStorageServiceName];
        
        //
        // Shared storage
        //
        MASIKeyChainStore *sharedStorage = [MASIKeyChainStore keyChainStoreWithService:_sharedStorageServiceName accessGroup:self.accessGroup];
        
        //
        // storage dictionary property
        //
        _storages = [NSDictionary dictionaryWithObjectsAndKeys:localStorage, kMASAccessLocalStorageKey, sharedStorage, kMASAccessSharedStorageKey, nil];
    }
    else {
        
        _sharedStorageServiceName = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, kMASAccessSharedStorageServiceName];
        
        //
        // Local storage
        //
        MASIKeyChainStore *localStorage = [MASIKeyChainStore keyChainStoreWithService:_localStorageServiceName];
        
        //
        // storage dictionary property
        //
        _storages = [NSDictionary dictionaryWithObjectsAndKeys:localStorage, kMASAccessLocalStorageKey, localStorage, kMASAccessSharedStorageKey, nil];
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
    if(forceToOverwrite)
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

- (void)setAccessValueCertificate:(NSData *)certificate withAccessValueType:(MASAccessValueType)type
{
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    NSString *accessValueAsString = [self convertAccessTypeToString:type];
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
 
    NSString * certString = [[NSString alloc] initWithData:certificate encoding:NSUTF8StringEncoding];
    NSData * certData = [NSData convertPEMCertificateToDERCertificate:certString];
    
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
        [destinationStorage removeItemForKey:accessValueAsString];
    }
}


- (id)getAccessValueCertificateWithType:(MASAccessValueType)type
{
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    NSString *accessValueAsString = [self convertAccessTypeToString:type];
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
    
    return [destinationStorage certificateForKey:accessValueAsString];
}


- (id)getAccessValueIdentities
{
    //DLog(@"\n\ncalled\n\n");
    
    MASIKeyChainStore *keychainStore = [MASIKeyChainStore keyChainStore];
    NSArray *identities = [keychainStore identitiesWithCertificateLabel:[self convertAccessTypeToString:MASAccessValueTypeSignedPublicCertificate]];
    
    return identities;
}


- (void)setAccessValueData:(NSData *)data withAccessValueType:(MASAccessValueType)type
{
    
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    NSString *accessValueAsString = [self convertAccessTypeToString:type];
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
    
    //
    // Addition
    //
    if (data)
    {
        [destinationStorage setData:data forKey:accessValueAsString];
    }
    //
    // Removal
    //
    else
    {
        [destinationStorage removeItemForKey:accessValueAsString];
    }
}


- (NSData *)getAccessValueDataWithType:(MASAccessValueType)type
{
    
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    NSString *accessValueAsString = [self convertAccessTypeToString:type];
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
    
    return [destinationStorage dataForKey:accessValueAsString];
}


- (void)setAccessValueString:(NSString *)string withAccessValueType:(MASAccessValueType)type
{
    
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    NSString *accessValueAsString = [self convertAccessTypeToString:type];
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
    
    //
    // Addition
    //
    if (string)
    {
        [destinationStorage setString:string forKey:accessValueAsString];
    }
    //
    // Removal
    //
    else
    {
        [destinationStorage removeItemForKey:accessValueAsString];
    }
}


- (NSString *)getAccessValueStringWithType:(MASAccessValueType)type
{
    
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    NSString *accessValueAsString = [self convertAccessTypeToString:type];
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
    
    return [destinationStorage stringForKey:accessValueAsString];
}


- (void)setAccessValueDictionary:(NSDictionary *)dictionary withAccessValueType:(MASAccessValueType)type
{
    
    //
    // convert dictionary to data
    //
    NSData *thisData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    //
    // make sure the data exists
    //
    if(thisData)
    {
        [self setAccessValueData:thisData withAccessValueType:type];
    }
}


- (NSDictionary *)getAccessValueDictionaryWithType:(MASAccessValueType)type
{
    //
    // get data from keychain as NSData first
    //
    NSData *thisData = [self getAccessValueDataWithType:type];
    
    //
    // return nil if NSData is nil
    //
    return thisData ? [NSKeyedUnarchiver unarchiveObjectWithData:thisData] : nil;
}


- (void)setAccessValueNumber:(NSNumber *)number withAccessValueType:(MASAccessValueType)type
{
    // convert dictionary to data
    //
    NSData *thisData = [NSKeyedArchiver archivedDataWithRootObject:number];
    
    //
    // make sure the data exists
    //
    if(thisData)
    {
        [self setAccessValueData:thisData withAccessValueType:type];
    }
}


- (NSNumber *)getAccessValueNumberWithType:(MASAccessValueType)type
{
    //
    // get data from keychain as NSData first
    //
    NSData *thisData = [self getAccessValueDataWithType:type];
    
    //
    // return nil if NSData is nil
    //
    return thisData ? [NSKeyedUnarchiver unarchiveObjectWithData:thisData] : nil;
}


- (void)setAccessValueCryptoKey:(SecKeyRef)cryptoKey withAccessValueType:(MASAccessValueType)type
{
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
    
    NSString *keyIdentifierStr = nil;
    
    if (type == MASAccessValueTypePublicKey)
    {
        keyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    }
    else if (type == MASAccessValueTypePrivateKey)
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


- (SecKeyRef)getAccessValueCryptoKeyWithType:(MASAccessValueType)type
{
    
    NSString *storageKey = [self getStorageKeyWithAccessValueType:type];
    MASIKeyChainStore *destinationStorage = _storages[storageKey];
    
    NSString *keyIdentifierStr = nil;
    
    
    if (type == MASAccessValueTypePublicKey)
    {
        keyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    }
    else if (type == MASAccessValueTypePrivateKey)
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


#pragma mark - Private

- (NSString *)getStorageKeyWithAccessValueType:(MASAccessValueType)type
{
    NSString *storageKey = @"";
    
    switch (type) {
            //Configuration
        case MASAccessValueTypeConfiguration:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //AccessToken
        case MASAccessValueTypeAccessToken:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //RefreshToken
        case MASAccessValueTypeRefreshToken:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //Scope
        case MASAccessValueTypeScope:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //TokenType
        case MASAccessValueTypeTokenType:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //ExpiresIn
        case MASAccessValueTypeExpiresIn:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //TokenExpiration
        case MASAccessValueTypeTokenExpiration:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //IdToken
        case MASAccessValueTypeIdToken:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //IdTokenType
        case MASAccessValueTypeIdTokenType:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //ClientExpiration
        case MASAccessValueTypeClientExpiration:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //ClientId
        case MASAccessValueTypeClientId:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //ClientSecret
        case MASAccessValueTypeClientSecret:
            storageKey = kMASAccessLocalStorageKey;
            break;
            //JWT
        case MASAccessValueTypeJWT:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //MAGIdentifier
        case MASAccessValueTypeMAGIdentifier:
            storageKey = kMASAccessSharedStorageKey;
            break;
        case MASAccessValueTypeMSSOEnabled:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //PrivateKey
        case MASAccessValueTypePrivateKey:
            storageKey = kMASAccessSharedStorageKey;
            break;
        case MASAccessValueTypePrivateKeyBits:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //PublicKey
        case MASAccessValueTypePublicKey:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //TrustedServerCertificate
        case MASAccessValueTypeTrustedServerCertificate:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //PublicCertificate
        case MASAccessValueTypeSignedPublicCertificate:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //PublicCertificate as NSData
        case MASAccessValueTypeSignedPublicCertificateData:
            storageKey = kMASAccessSharedStorageKey;
            break;
            //authentication timestamp
        case MASAccessValueTypeAuthenticatedTimestamp:
            storageKey = kMASAccessLocalStorageKey;
            break;
        default:
            //
            // MASAccessValueTypeUknonw
            //
            break;
    }
    
    return storageKey;
}


- (NSString *)convertAccessTypeToString:(MASAccessValueType)type
{
    
    NSString *accessTypeToString = @"";
    
    switch (type) {
            //Configuration
        case MASAccessValueTypeConfiguration:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainConfiguration"];
            break;
            //AccessToken
        case MASAccessValueTypeAccessToken:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainAccessToken"];
            break;
            //RefreshToken
        case MASAccessValueTypeRefreshToken:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainRefreshToken"];
            break;
            //Scope
        case MASAccessValueTypeScope:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainScope"];
            break;
            //TokenType
        case MASAccessValueTypeTokenType:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainTokenType"];
            break;
            //ExpiresIn
        case MASAccessValueTypeExpiresIn:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainExpiresIn"];
            break;
            //TokenExpiration
        case MASAccessValueTypeTokenExpiration:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainTokenExpiration"];
            break;
            //IdToken
        case MASAccessValueTypeIdToken:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainIdToken"];
            break;
            //IdTokenType
        case MASAccessValueTypeIdTokenType:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainIdTokenType"];
            break;
            //ClientExpiration
        case MASAccessValueTypeClientExpiration:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainClientExpiration"];
            break;
            //ClientId
        case MASAccessValueTypeClientId:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainClientId"];
            break;
            //ClientSecret
        case MASAccessValueTypeClientSecret:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainClientSecret"];
            break;
            //JWT
        case MASAccessValueTypeJWT:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainJwt"];
            break;
            //MAGIdentifier
        case MASAccessValueTypeMAGIdentifier:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainMagIdentifier"];
            break;
        case MASAccessValueTypeMSSOEnabled:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASAccessValueTypeMSSOEnabled"];
            break;
            //PrivateKey
        case MASAccessValueTypePrivateKey:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainPrivateKey"];
            break;
            //PrivateKeyBits
        case MASAccessValueTypePrivateKeyBits:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainPrivateKeyBits"];
            break;
            //PublicKey
        case MASAccessValueTypePublicKey:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainPublicKey"];
            break;
            //TrustedServerCertificate
        case MASAccessValueTypeTrustedServerCertificate:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainTrustedServerCertificate"];
            break;
            //PublicCertificate
        case MASAccessValueTypeSignedPublicCertificate:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainSignedPublicCertificate"];
            break;
            //PublicCertificate as NSData
        case MASAccessValueTypeSignedPublicCertificateData:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASKeyChainSignedPublicCertificateData"];
            break;
        case MASAccessValueTypeAuthenticatedTimestamp:
            accessTypeToString = [NSString stringWithFormat:@"%@.%@", _gatewayIdentifier, @"kMASAccessValueTypeAuthenticatedTimestamp"];
            break;
        default:
            //
            // MASAccessValueTypeUknonw
            //
            break;
    }
    
    return accessTypeToString;
}


#pragma mark - accessGroup

- (NSString *)accessGroup
{
    
    //
    // if accessGroup is not defined
    //
    if(!_accessGroup)
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

+ (BOOL)validateIdToken:(NSString *)idToken magIdentifier:(NSString *)magIdentifier error:(NSError *__autoreleasing *)error
{
    //
    // Credits to Anthony Yu
    //
    
    NSArray *segments = [idToken componentsSeparatedByString:@"."];
    
    //
    // check if idToken is in valid format
    //
    if (segments == nil || [segments count] != 3) {
        
        if (error)
        {
            *error = [NSError errorInvalidIdToken];
        }
        
        return NO;
    }
    
    NSString *headerString = [segments objectAtIndex:0];
    NSString *payload = [segments objectAtIndex:1];
    NSString *signature = [segments objectAtIndex:2];
    
    if (!headerString || !payload || !signature){
        
        if (error)
        {
            *error = [NSError errorInvalidIdToken];
        }
        return NO;
    }
    
    //
    // verifying signature
    // processes to unwrap the header
    //
    NSString *encodedHeaderString = [[NSString alloc] initWithData:[NSData dataWithBase64EncodedString:headerString] encoding:NSUTF8StringEncoding];
    
    NSDictionary *headerDisctionary = [NSJSONSerialization JSONObjectWithData:[encodedHeaderString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:0
                                                                        error:nil];
    
    if ([[headerDisctionary objectForKey:@"alg"] isEqualToString:@"HS256"]){
        
        //check signature
        NSMutableArray *signatureSegments = [NSMutableArray array];
        [signatureSegments addObject:headerString];
        [signatureSegments addObject:payload];
        
        NSString *signingInput = [signatureSegments componentsJoinedByString:@"."];
        NSString *clientSecret = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientSecret];
        NSData *signedInput = [NSData sign:signingInput key:clientSecret];
        NSString *encodedSignedInput = [signedInput base64Encoding];
        
        //case 1: signature doesn't match
        if (![encodedSignedInput isEqualToString:[MASAccessService padding:signature]]){
            
            if (error)
            {
                *error = [NSError errorIdTokenInvalidSignature];
            }
            return NO;
        }
    }
    
    //validating payload
    //padding payload
    payload = [MASAccessService padding:payload];
    
    //process to unwrap the payload
    NSData *decodedData = [NSData dataWithBase64EncodedString:payload];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    NSDictionary *payloadDictionary = [NSJSONSerialization JSONObjectWithData:[decodedString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:0
                                                                        error:nil];
    
    NSString *aud = [payloadDictionary valueForKey:@"aud"];
    NSString *azp = [payloadDictionary valueForKey:@"azp"];
    NSDate *exp = [NSDate dateWithTimeIntervalSince1970:[[payloadDictionary valueForKey:@"exp"] floatValue]];
    
    if (!aud || !azp || !exp){
        
        if (error)
        {
            *error = [NSError errorInvalidIdToken];
        }
        return NO;
    }
    
    //case 2: aud doesn't match with clientId
    if (![aud isEqualToString:[[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientId]]){
        
        if (error)
        {
            *error = [NSError errorIdTokenInvalidAud];
        }
        return NO;
    }
    
    //case 3: azp doesn't match with mag-identifier
    if (![azp isEqualToString:magIdentifier]){
        
        if (error)
        {
            *error = [NSError errorIdTokenInvalidAzp];
        }
        return NO;
    }
    
    //case 4: JWT expired
    if ([exp timeIntervalSinceNow] < 0){
        
        if (error)
        {
            *error = [NSError errorIdTokenExpired];
        }
        return NO;
    }

    
    return YES;
}


+ (NSString *)padding: (NSString *) encodedString{
    
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


# pragma mark - Debug only

- (void)clearLocal
{
    [_storages[kMASAccessLocalStorageKey] removeAllItems];
    
    //DLog(@"called and self is now: %@", [self debugSecuredDescription]);
}


- (void)clearShared;
{
    [_storages[kMASAccessSharedStorageKey] removeAllItems];
    
    //
    // Retrieve the key for certificate
    //
    NSString *certificateKey = [self convertAccessTypeToString:MASAccessValueTypeSignedPublicCertificate];
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
    
    for(NSString *key in [_storages[kMASAccessLocalStorageKey] allKeys])
    {
        [keychainDescription appendString:[NSString stringWithFormat:@"\n      key: %@", key]];
    }
    
    //
    // Shared
    //
    value = [NSString stringWithFormat:@"\n\n  Shared (%@):\n", kMASAccessSharedStorageServiceName];
    [keychainDescription appendString:value];
    
    for(NSString *key in [_storages[kMASAccessSharedStorageKey] allKeys])
    {
        [keychainDescription appendString:[NSString stringWithFormat:@"\n      key: %@", key]];
    }
    
    [keychainDescription appendString:@"\n\n*********************\n\n"];
    
    return keychainDescription;
}

@end
