//
//  MASKeyChainService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASKeyChainService.h"

#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"
#import "NSData+MASPrivate.h"

@interface MASKeyChainService ()

# pragma mark - Properties

@property (strong, nonatomic, readonly) MASIKeyChainStore *localStorage;
@property (copy, nonatomic, readonly) NSString *localStorageServiceName;

@property (strong, nonatomic, readonly) MASIKeyChainStore *sharedStorage;
@property (copy, nonatomic, readonly) NSString *sharedStorageServiceName;

@end


@implementation MASKeyChainService

# pragma mark - Lifecycle

+ (MASKeyChainService *)keyChainService
{
    static MASKeyChainService *sharedKeyChainService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedKeyChainService = [[self alloc] initPrivate];
    });
    
    return sharedKeyChainService;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}

- (id)initPrivate
{
    if(self = [super init])
    {
        NSString *bundleId = [[[[NSBundle mainBundle] bundleIdentifier] mutableCopy]
            stringByReplacingOccurrencesOfString:MASDefaultDot
            withString:MASDefaultEmptyString];
        
        _localStorageServiceName = [NSString stringWithFormat:@"%@%@", bundleId, @"LocalStorageService"];
        
        //
        // Local Storage
        //
        _localStorage = [MASIKeyChainStore keyChainStoreWithService:self.localStorageServiceName];
        
        // Temporary backwards compatibility for development
        if(!self.localStorage)
        {
            //DLog(@"\n\nTEMP LOCAL\n\n");
            
            _localStorage = [MASIKeyChainStore keyChainStoreWithService:@"LocalStorageService"];
        }
        
        //
        // Shared Storage (if access group create a shared storage based on that, if not just share the local)
        //
        NSString *accessGroup = [self accessGroup];
        
        _sharedStorageServiceName = [NSString stringWithFormat:@"%@%@", bundleId, @"SharedStorageService"];
        
        _sharedStorage = (accessGroup ?
            [MASIKeyChainStore keyChainStoreWithService:self.sharedStorageServiceName accessGroup:accessGroup] :
            _localStorage);
            
        // Temporary backwards compatibility for development
        if(!self.sharedStorage)
        {
            //DLog(@"\n\nTEMP SHARED\n\n");
            
            _sharedStorage = [MASIKeyChainStore keyChainStoreWithService:@"SharedStorageService"];
        }
        
        _isConfigured = YES;
        _isSharedStorageActive = (accessGroup != nil);
    }
    
    return self;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\n\n(%@) is configured: %@, is shared storage active: %@, \n\n",
        [self class], ([self isConfigured] ? @"Yes" : @"No"), ([self isSharedStorageActive] ? @"Yes" : @"No")];
}

# pragma mark - Configuration

- (NSDictionary *)configuration
{
    NSData *configurationData = [_localStorage dataForKey:kMASKeyChainConfiguration];
    
    return (configurationData ? [NSKeyedUnarchiver unarchiveObjectWithData:configurationData] : nil);
}
- (void)setConfiguration:(NSDictionary *)configuration
{
    NSData *configurationData = [NSKeyedArchiver archivedDataWithRootObject:configuration];
    
    if(configuration) [self setLocalData:configurationData forKey:kMASKeyChainConfiguration];
}


# pragma mark - Local

- (NSString *)accessToken
{
    return [_localStorage stringForKey:kMASKeyChainAccessToken];
}

- (void)setAccessToken:(NSString *)accessToken
{
    [self setLocalString:accessToken forKey:kMASKeyChainAccessToken];
}

- (NSString *)refreshToken
{
    return [_localStorage stringForKey:kMASKeyChainRefreshToken];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    [self setLocalString:refreshToken forKey:kMASKeyChainRefreshToken];
}

- (NSString *)scope
{
    return [_localStorage stringForKey:kMASKeyChainScope];
}

- (void)setScope:(NSString *)scope
{
    [self setLocalString:scope forKey:kMASKeyChainScope];
}

- (NSString *)tokenType
{
    return [_localStorage stringForKey:kMASKeyChainTokenType];
}

- (void)setTokenType:(NSString *)tokenType
{
    [self setLocalString:tokenType forKey:kMASKeyChainTokenType];
}

- (NSNumber *)expiresIn
{
    NSData *numberAsData = [_localStorage dataForKey:kMASKeyChainExpiresIn];
    if(!numberAsData)
    {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:numberAsData];
}

- (void)setExpiresIn:(NSNumber *)expiresIn
{
    NSData *numberAsData = (expiresIn ? [NSKeyedArchiver archivedDataWithRootObject:expiresIn] :nil);
    
    [self setLocalData:numberAsData forKey:kMASKeyChainExpiresIn];
}

- (NSDate *)expiresInDate
{
    NSData *dateAsData = [_localStorage dataForKey:kMASKeyChainTokenExpiration];
    if(!dateAsData)
    {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:dateAsData];
}

- (void)setExpiresInDate:(NSDate *)expiresInDate
{
    NSData *dateAsData = (expiresInDate ? [NSKeyedArchiver archivedDataWithRootObject:expiresInDate] : nil);
    
    [self setLocalData:dateAsData forKey:kMASKeyChainTokenExpiration];
}

- (NSString *)idToken
{
    return [_localStorage stringForKey:kMASKeyChainIdToken];
}

- (void)setIdToken:(NSString *)idToken
{
    [self setLocalString:idToken forKey:kMASKeyChainIdToken];
}

- (NSString *)idTokenType
{
    return [_localStorage stringForKey:kMASKeyChainIdTokenType];
}

- (void)setIdTokenType:(NSString *)idTokenType
{
    [self setLocalString:idTokenType forKey:kMASKeyChainIdTokenType];
}

- (NSNumber *)clientExpiration
{
    NSData *numberAsData = [_localStorage dataForKey:kMASKeyChainClientExpiration];
    if(!numberAsData)
    {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:numberAsData];
}

- (void)setClientExpiration:(NSNumber *)clientExpiration
{
    NSData *numberAsData = (clientExpiration ? [NSKeyedArchiver archivedDataWithRootObject:clientExpiration] : nil);
    
    [self setLocalData:numberAsData forKey:kMASKeyChainClientExpiration];
}

- (NSString *)clientId
{
    return [_localStorage stringForKey:kMASKeyChainClientId];
}

- (void)setClientId:(NSString *)clientId
{
    [self setLocalString:clientId forKey:kMASKeyChainClientId];
}

- (NSString *)clientSecret
{
    return [_localStorage stringForKey:kMASKeyChainClientSecret];
}

- (void)setClientSecret:(NSString *)clientSecret
{
    [self setLocalString:clientSecret forKey:kMASKeyChainClientSecret];
}


# pragma mark - Shared

- (NSString *)jwt
{
    return [_sharedStorage stringForKey:kMASKeyChainJwt];
}

- (void)setJwt:(NSString *)jwt
{
    [self setSharedString:jwt forKey:kMASKeyChainJwt];
}

- (NSString *)magIdentifier
{
    return [_sharedStorage stringForKey:kMASKeyChainMagIdentifier];
}

- (void)setMagIdentifier:(NSString *)magIdentifier;
{
    [self setSharedString:magIdentifier forKey:kMASKeyChainMagIdentifier];
}

- (NSData *)privateKey
{
    return [_sharedStorage dataForKey:kMASKeyChainPrivateKey];
}

- (void)setPrivateKey:(NSData *)privateKey
{
    [self setSharedData:privateKey forKey:kMASKeyChainPrivateKey];
}

- (NSData *)publicKey
{
    return [_sharedStorage dataForKey:kMASKeyChainPublicKey];
}

- (void)setPublicKey:(NSData *)publicKey
{
    [self setSharedData:publicKey forKey:kMASKeyChainPublicKey];
}

- (NSData *)signedPublicCertificate
{
    return [_sharedStorage dataForKey:kMASKeyChainSignedPublicCertificate];
}

- (NSData *)setSignedPublicCertificate:(NSData *)certificate
{
    DLog(@"\n\nset with certificate: %ld\n\n", (unsigned long)certificate.length);
    
    //
    // Recreate the data with Base64 encoding
    //
    NSData *base64Certificate = [NSData dataWithBase64EncodedString:[certificate base64EncodedStringWithOptions:0]];
    
    //
    // Store this by Anthony's call for now also
    //
    [self setCertificate:base64Certificate];
    
    //
    // Se the certificate in the shared data
    //
    [self setSharedData:base64Certificate forKey:kMASKeyChainSignedPublicCertificate];
    
    return base64Certificate;
}

- (NSData *)trustedServerCertificate
{
    return [_sharedStorage dataForKey:kMASKeyChainTrustedServerCertificate];
}

- (void)setTrustedServerCertificate:(NSData *)certificate
{
    [self setSharedData:certificate forKey:kMASKeyChainTrustedServerCertificate];
}


# pragma mark - Private

- (NSString *)accessGroup
{
    // Yaaay for Anthony
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

    return accessGroup;
}

// Attempts to import the data as a certificate
- (void)setCertificate:(NSData *)certificate
{
    DLog(@"\n\ncalled with certificate data: %@\n\n", certificate);
    
    NSString * certStr = [[NSString alloc] initWithData:certificate encoding:NSUTF8StringEncoding];
    NSData * certData = [NSData convertPEMCertificateToDERCertificate:certStr];
    
    OSStatus err;
    SecCertificateRef cert;
    
    //
    // Default keychain data protection class is kSecAttrAccessibleWhenUnlocked,
    // but added in the dictionary for clarity
    //
    cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    if(!cert)
    {
        DLog(@"\n\nError attempting to convert certificate data to certificate reference\n\n");
        return;
    }
    
    DLog(@"\n\ndoes SecCertificateRef exist: %@\n\n", (cert ? @"Yes" : @"No"));
    
    if (cert != NULL)
    {

#if TARGET_IPHONE_SIMULATOR
        
        err = SecItemAdd(
            (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
                (__bridge id) kSecClassCertificate, kSecClass,
                kSecAttrAccessibleWhenUnlocked, kSecAttrAccessible,
                (__bridge id) cert, kSecValueRef,
                nil],
            NULL);
        
#else
    
        err = SecItemAdd(
            (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
                (__bridge id) kSecClassCertificate, kSecClass,
                kSecAttrAccessibleWhenUnlocked, kSecAttrAccessible,
                (__bridge id) cert, kSecValueRef,
                [self accessGroup], kSecAttrAccessGroup,
                nil],
            NULL);
        
#endif

    }
    CFRelease(cert);
    DLog(@"\n\ndone and status is: %d and certificate reference: %@\n\n", (int)err, cert);
}


- (void)clearCertificatesAndIdentities
{
    //
    // Delete identity in shared keychain
    //
    SecItemDelete((__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
        (__bridge id)kSecClassIdentity, kSecClass,
        [self accessGroup], kSecAttrAccessGroup,
        nil]);

    //
    // Delete identity in local keychain
    //
    SecItemDelete((__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
        (__bridge id)kSecClassIdentity, kSecClass,
        nil]);
  
    //
    // Delete certificates in shared keychain
    //
    SecItemDelete((__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
        (__bridge id)kSecClassCertificate, kSecClass,
        [self accessGroup], kSecAttrAccessGroup,
        nil]);
    
    //
    // Delete certificates in local keychain
    //
    SecItemDelete((__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
        (__bridge id)kSecClassCertificate, kSecClass,
        nil]);
}


- (id)certificates
{
    //DLog(@"\n\ncalled\n\n");
    
    CFArrayRef certificates;
    OSStatus err;
    
#if TARGET_IPHONE_SIMULATOR
    
    err = SecItemCopyMatching(
        (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id) kSecClassCertificate, kSecClass,
            kSecMatchLimitAll, kSecMatchLimit,
            kCFBooleanTrue, kSecReturnRef,
            nil],
        (CFTypeRef *) &certificates);

#else

    err = SecItemCopyMatching(
        (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id) kSecClassCertificate, kSecClass,
            kSecMatchLimitAll, kSecMatchLimit,
            kCFBooleanTrue, kSecReturnRef,
            [self accessGroup], kSecAttrAccessGroup,
            nil],
        (CFTypeRef *) &certificates);
    
#endif

    //DLog(@"\n\ndone and status is: %d\n\n", (int)err);
    
    if(err==noErr)
    {
        NSArray *certificateArray = [NSArray arrayWithArray:(__bridge id) certificates];
        if(err == noErr  && [certificateArray count] > 0)
        {
            CFRelease(certificates);
            return certificateArray;
        }
    }

    return nil;
}


- (id)identities
{
    //DLog(@"\n\ncalled\n\n");
    
    CFArrayRef identities;
    OSStatus err;

#if TARGET_IPHONE_SIMULATOR
   
    err = SecItemCopyMatching(
        (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id) kSecClassIdentity, kSecClass,
            kSecMatchLimitAll, kSecMatchLimit,
            kCFBooleanTrue, kSecReturnRef,
            nil],
        (CFTypeRef *) &identities);
    
#else

    err = SecItemCopyMatching(
        (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id) kSecClassIdentity, kSecClass,
            kSecMatchLimitAll, kSecMatchLimit,
            kCFBooleanTrue, kSecReturnRef,
            [self accessGroup], kSecAttrAccessGroup,
            nil],
        (CFTypeRef *) &identities);
    
#endif

    //DLog(@"\n\ndone and status is: %d\n\n", (int)err);
    
    if(err==noErr)
    {
        NSArray *identitiesArray = [NSArray arrayWithArray:(__bridge id) identities];
        if(err == noErr && [identitiesArray count] > 0)
        {
            CFRelease(identities);
            return identitiesArray;
        }
    }

    return nil;
}

# pragma mark - Private

- (void)setLocalData:(NSData *)value forKey:(NSString *)key
{
    //DLog(@"called with local storage: %@", _localStorage);
    
    //
    // Addition
    //
    if(value)
    {
        [_localStorage setData:value forKey:key];
    }
    
    //
    // Removal
    //
    else
    {
        [_localStorage removeItemForKey:key];
    }
}


- (void)setLocalString:(NSString *)value forKey:(NSString *)key
{
    //DLog(@"called with local storage: %@", _localStorage);
    
    //
    // Addition
    //
    if(value)
    {
        [_localStorage setString:value forKey:key];
    }
    
    //
    // Removal
    //
    else
    {
        [_localStorage removeItemForKey:key];
    }
}


- (void)setSharedData:(NSData *)value forKey:(NSString *)key
{
    //DLog(@"called with shared storage: %@", _sharedStorage);
    
    //
    // Addition
    //
    if(value)
    {
        [_sharedStorage setData:value forKey:key];
    }
    
    //
    // Removal
    //
    else
    {
        [_sharedStorage removeItemForKey:key];
    }
}


- (void)setSharedString:(NSString *)value forKey:(NSString *)key
{
    //DLog(@"called with shared storage: %@", _sharedStorage);
    
    //
    // Addition
    //
    if(value)
    {
        [_sharedStorage setString:value forKey:key];
    }
    
    //
    // Removal
    //
    else
    {
        [_sharedStorage removeItemForKey:key];
    }
}


#ifdef DEBUG

# pragma mark - Debug only

- (void)clearLocal
{
    [_localStorage removeAllItems];
    
    [self clearCertificatesAndIdentities];

    //DLog(@"called and self is now: %@", [self debugSecuredDescription]);
}

- (void)clearShared;
{
    [_sharedStorage removeAllItems];

    //DLog(@"called and self is now: %@", [self debugSecuredDescription]);
}

- (NSString *)debugSecuredDescription
{
    //
    // Local
    //
    NSString *value = [NSString stringWithFormat:@"\n\n(MASKeyChainService)\n\n  Local (%@):\n", self.localStorageServiceName];
    NSMutableString *keychainDescription = [[NSMutableString alloc] initWithString:value];
    
    for(NSString *key in [_localStorage allKeys])
    {
        [keychainDescription appendString:[NSString stringWithFormat:@"\n      key: %@", key]];
    }
    
    //
    // Shared
    //
    value = [NSString stringWithFormat:@"\n\n  Shared (%@):\n", self.sharedStorageServiceName];
    [keychainDescription appendString:value];
    
    for(NSString *key in [_sharedStorage allKeys])
    {
        [keychainDescription appendString:[NSString stringWithFormat:@"\n      key: %@", key]];
    }
    
    [keychainDescription appendString:@"\n\n*********************\n\n"];
    
    return keychainDescription;
}

#endif

@end
