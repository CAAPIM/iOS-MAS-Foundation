//
//  MASIKeyChainStore+Addition.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASIKeyChainStore+MASPrivate.h"

#import <openssl/x509.h>

#import "MASAccessService.h"

@interface MASIKeyChainStore ()

+ (NSError *)argumentError:(NSString *)message;
+ (NSError *)conversionError:(NSString *)message;
+ (NSError *)securityError:(OSStatus)status;
+ (NSError *)unexpectedError:(NSString *)message;
- (NSMutableDictionary *)query;
- (NSMutableDictionary *)attributesWithKey:(NSString *)key value:(NSData *)value error:(NSError *__autoreleasing *)error;
- (CFTypeRef)accessibilityObject;

@end

@implementation MASIKeyChainStore (MASPrivate)


#
# pragma mark - Private
#

- (NSMutableDictionary *)queryForCertificateAndIdentitiesWithCert:(SecCertificateRef)cert
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    if (self.accessGroup) {
        query[(__bridge __strong id)kSecAttrAccessGroup] = self.accessGroup;
    }
    
#if TARGET_OS_IOS
    if (floor(NSFoundationVersionNumber) > floor(1144.17)) { // iOS 9+
        query[(__bridge __strong id)kSecUseAuthenticationUI] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
    } else if (floor(NSFoundationVersionNumber) > floor(1047.25)) { // iOS 8+
        query[(__bridge __strong id)kSecUseNoAuthenticationUI] = (__bridge id)kCFBooleanTrue;
    }
#elif TARGET_OS_WATCH || TARGET_OS_TV
    query[(__bridge __strong id)kSecUseAuthenticationUI] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
#endif
    
    if (cert)
    {
        query[(__bridge __strong id)kSecValueRef] =(__bridge id)cert;
    }
    
    return query;
}


- (NSMutableDictionary *)attributesForCertificateWithKey:(NSString *)key value:(SecCertificateRef)cert error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *attributes;
    
    if (key) {
        
        attributes = [self queryForCertificateAndIdentitiesWithCert:cert];
        attributes[(__bridge __strong id)kSecAttrAccount] = key;
    }
    else {
        
        attributes = [[NSMutableDictionary alloc] init];
        
        if (cert) {
            
            attributes[(__bridge __strong id)kSecValueRef] =(__bridge id)cert;
        }
    }
    
#if TARGET_OS_IOS
    double iOS_7_1_or_10_9_2 = 1047.25; // NSFoundationVersionNumber_iOS_7_1
#else
    double iOS_7_1_or_10_9_2 = 1056.13; // NSFoundationVersionNumber10_9_2
#endif
    
    CFTypeRef accessibilityObject = [self accessibilityObject];
    
    if (self.authenticationPolicy && accessibilityObject) {
        
        if (floor(NSFoundationVersionNumber) > floor(iOS_7_1_or_10_9_2)) { // iOS 8+ or OS X 10.10+
            
            CFErrorRef securityError = NULL;
            SecAccessControlRef accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, accessibilityObject, (SecAccessControlCreateFlags)self.authenticationPolicy, &securityError);
            
            if (securityError) {
                
                NSError *e = (__bridge NSError *)securityError;
                NSLog(@"error: [%@] %@", @(e.code), e.localizedDescription);
                
                if (error) {
                    
                    *error = e;
                    CFRelease(accessControl);
                    return nil;
                }
            }
            if (!accessControl) {
                
                NSString *message = NSLocalizedString(@"Unexpected error has occurred.", nil);
                NSError *e = [self.class unexpectedError:message];
                
                if (error) {
                    
                    *error = e;
                }
                return nil;
            }
            attributes[(__bridge __strong id)kSecAttrAccessControl] = (__bridge_transfer id)accessControl;
        }
        else {
            
#if TARGET_OS_IOS
            NSLog(@"%@", @"Unavailable 'Touch ID integration' on iOS versions prior to 8.0.");
#else
            NSLog(@"%@", @"Unavailable 'Touch ID integration' on OS X versions prior to 10.10.");
#endif
        }
    }
    else {
        
        if (floor(NSFoundationVersionNumber) <= floor(iOS_7_1_or_10_9_2) && self.accessibility == MASIKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly) {
            
#if TARGET_OS_IOS
            NSLog(@"%@", @"Unavailable 'MASIKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly' attribute on iOS versions prior to 8.0.");
#else
            NSLog(@"%@", @"Unavailable 'MASIKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly' attribute on OS X versions prior to 10.10.");
#endif
        }
        else {
            
            if (accessibilityObject) {
                
                attributes[(__bridge __strong id)kSecAttrAccessible] = (__bridge id)accessibilityObject;
            }
        }
    }
    
    if (floor(NSFoundationVersionNumber) > floor(993.00)) { // iOS 7+
        
        attributes[(__bridge __strong id)kSecAttrSynchronizable] = @(self.synchronizable);
    }
    
    return attributes;
}


#
# pragma mark - Certificate
#

- (BOOL)setCertificate:(NSData *)certificate forKey:(NSString *)key
{
    return [self setCertificate:certificate forKey:nil genericAttribute:nil label:key comment:nil error:nil];
}


- (BOOL)setCertificate:(NSData *)certificate forKey:(NSString *)key label:(NSString *)label comment:(NSString *)comment error:(NSError *__autoreleasing *)error
{
    return [self setCertificate:certificate forKey:key genericAttribute:nil label:label comment:comment error:error];
}


- (BOOL)setCertificate:(NSData *)certificate forKey:(NSString *)key genericAttribute:(id)genericAttribute label:(NSString *)label comment:(NSString *)comment error:(NSError *__autoreleasing *)error
{
    
    if (!label) {
        
        NSError *e = [self.class argumentError:NSLocalizedString(@"the label must not to be nil", nil)];
        
        if (error) {
            *error = e;
        }
        
        return NO;
    }
    
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificate);
    
    NSMutableDictionary *query = [self queryForCertificateAndIdentitiesWithCert:cert];
    
    if (key) {
        
        query[(__bridge __strong id)kSecAttrAccount] = key;
    }
    
    if (label) {
        
        query[(__bridge __strong id)kSecAttrLabel] = label;
    }
    
    query[(__bridge __strong id)kSecClass] =(__bridge id)kSecClassCertificate;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    
    if (status == errSecSuccess || status == errSecInteractionNotAllowed) {
        
        query = [self queryForCertificateAndIdentitiesWithCert:cert];
        query[(__bridge __strong id)kSecAttrAccount] = key;
        
        NSError *unexpectedError = nil;
        NSMutableDictionary *attributes = [self attributesForCertificateWithKey:nil value:cert error:&unexpectedError];
        
        //
        // remove AttrAccount value if exists as it shouldn't be used for the certificate / identities
        //
        if ([[attributes allKeys] containsObject:(__bridge __strong id)kSecAttrAccount]) {
            [attributes removeObjectForKey:(__bridge __strong id)kSecAttrAccount];
        }
        
        //
        // remove AttrService value if exists as it shouldn't be used for the certificate / identities
        //
        if ([[attributes allKeys] containsObject:(__bridge __strong id)kSecAttrService]) {
            [attributes removeObjectForKey:(__bridge __strong id)kSecAttrService];
        }
        
        if (genericAttribute) {
            attributes[(__bridge __strong id)kSecAttrGeneric] = genericAttribute;
        }
        
        if (label) {
            attributes[(__bridge __strong id)kSecAttrLabel] = label;
        }
        if (comment) {
            attributes[(__bridge __strong id)kSecAttrComment] = comment;
        }
        
        if (unexpectedError) {
            NSLog(@"error: [%@] %@", @(unexpectedError.code), NSLocalizedString(@"Unexpected error has occurred.", nil));
            if (error) {
                *error = unexpectedError;
            }
            return NO;
        } else {
            
            if (status == errSecInteractionNotAllowed && floor(NSFoundationVersionNumber) <= floor(1140.11)) { // iOS 8.0.x
                
                if ([self removeItemForKey:key error:error]) {
                    return [self setCertificate:certificate forKey:key label:label comment:comment error:error];
                }
                
            }
            else {
                
                status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
            }
            
            if (status != errSecSuccess) {
                
                NSError *e = [self.class securityError:status];
                if (error) {
                    *error = e;
                }
                return NO;
            }
        }
    }
    else if (status == errSecItemNotFound) {
        
        NSError *unexpectedError = nil;
        NSMutableDictionary *attributes = [self attributesForCertificateWithKey:nil value:cert error:&unexpectedError];
        
        //
        // remove AttrAccount value if exists as it shouldn't be used for the certificate
        //
        if ([[attributes allKeys] containsObject:(__bridge __strong id)kSecAttrAccount]) {
            [attributes removeObjectForKey:(__bridge __strong id)kSecAttrAccount];
        }
        
        //
        // remove AttrService value if exists as it shouldn't be used for the certificate / identities
        //
        if ([[attributes allKeys] containsObject:(__bridge __strong id)kSecAttrService]) {
            [attributes removeObjectForKey:(__bridge __strong id)kSecAttrService];
        }
        
        if (self.accessGroup) {
            attributes[(__bridge __strong id)kSecAttrAccessGroup] = self.accessGroup;
        }
        
        if (genericAttribute) {
            attributes[(__bridge __strong id)kSecAttrGeneric] = genericAttribute;
        }
        
        if (label) {
            attributes[(__bridge __strong id)kSecAttrLabel] = label;
        }
        
        if (comment) {
            attributes[(__bridge __strong id)kSecAttrComment] = comment;
        }
        
        if (unexpectedError) {
            NSLog(@"error: [%@] %@", @(unexpectedError.code), NSLocalizedString(@"Unexpected error has occurred.", nil));
            if (error) {
                *error = unexpectedError;
            }
            return NO;
        }
        else {
            status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
            if (status != errSecSuccess) {
                NSError *e = [self.class securityError:status];
                if (error) {
                    *error = e;
                }
                return NO;
            }
        }
    }
    else {
        
        NSError *e = [self.class securityError:status];
        
        CFRelease(cert);
        
        if (error) {
            *error = e;
        }
        return NO;
    }
    
    return YES;
}


- (NSArray *)certificateForKey:(NSString *)key
{
    return [self certificateForKey:key error:nil];
}


- (NSArray *)certificateForKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    query[(__bridge __strong id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge __strong id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
    query[(__bridge __strong id)kSecClass] = (__bridge id)kSecClassCertificate;
    
    if (key)
        query[(__bridge __strong id)kSecAttrLabel] = key;
    
    CFArrayRef certificates = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query,(CFTypeRef *) &certificates);
    
    if (status == errSecSuccess)
    {
        
        if (certificates) {
            NSArray *certificateArray = [NSArray arrayWithArray:(__bridge id) certificates];
            CFRelease(certificates);
            return certificateArray;
        }
        else {
            NSError *e = [self.class unexpectedError:NSLocalizedString(@"Unexpected error has occurred.", nil)];
            if (error) {
                *error = e;
            }
            return nil;
        }
    }
    else if (status == errSecItemNotFound) {
        return nil;
    }
    
    NSError *e = [self.class securityError:status];
    
    if (error)
    {
        *error = e;
    }
    return nil;
}


- (void)clearCertificatesAndIdentitiesWithCertificateLabelKey:(NSString *)labelKey
{

    /**
     *  Note that we are only deleting certificates for given label key.
     *  Reason for that is iOS Security framework will generate the identities based on certificates and private in keychain.
     *  We never explicitly create or store identities in keychain within our framework.
     *  By removing the private key and the certificate, the identities will not be generated.
     */
    
    //
    // Create a query for delete operation
    //
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    //
    // Define class type to certificate
    //
    query[(__bridge __strong id)kSecClass] = (__bridge id)kSecClassCertificate;
    
    //
    // Label for the certificate
    //
    query[(__bridge __strong id)kSecAttrLabel] = labelKey;

    //
    // Delete operation for query
    //
    SecItemDelete((__bridge CFDictionaryRef)query);
}


- (NSArray *)identitiesWithCertificateLabel:(NSString *)certificateLabel
{
    return [self identitiesWithCertificateLabel:certificateLabel error:nil];
}


- (NSArray *)identitiesWithCertificateLabel:(NSString *)certificateLabel error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    query[(__bridge __strong id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge __strong id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
    query[(__bridge __strong id)kSecClass] = (__bridge id)kSecClassIdentity;
    query[(__bridge __strong id)kSecAttrKeyClass] = (__bridge id)kSecAttrKeyClassPrivate;
    
    if (certificateLabel)
        query[(__bridge __strong id)kSecAttrLabel] = certificateLabel;
    
    CFArrayRef identities = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query,(CFTypeRef *) &identities);
    
    if (status == errSecSuccess) {
        
        NSArray *identitiesArray = [NSArray arrayWithArray:(__bridge id) identities];
        
        if (identities) {
            CFRelease(identities);
            return identitiesArray;
        }
        else {
            
            NSError *e = [self.class unexpectedError:NSLocalizedString(@"Unexpected error has occurred.", nil)];
            
            if (error) {
                *error = e;
            }
            return nil;
        }
    }
    else if (status == errSecItemNotFound) {
        return nil;
    }
    
    NSError *e = [self.class securityError:status];
    if (error) {
        *error = e;
    }
    
    return nil;
}


- (BOOL)setCryptoKey:(SecKeyRef)keyData forApplicationTag:(NSData *)applicationTag
{
    OSStatus sanityCheck = noErr;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:applicationTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    if ([MASAccessService sharedService].accessGroup)
    {
        [queryPublicKey setObject:[MASAccessService sharedService].accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    [queryPublicKey setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    [queryPublicKey setObject:(__bridge_transfer NSData *)keyData forKey:(__bridge id)kSecValueRef];
    
    sanityCheck = SecItemAdd((__bridge CFDictionaryRef)queryPublicKey, NULL);
    
    if(sanityCheck != noErr){
        return NO;
    }
    else {
        return YES;
    }
}


- (SecKeyRef)cryptoKeyForApplicationTag:(NSData *)applicationTag
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    query[(__bridge __strong id)kSecClass] = (__bridge id)kSecClassKey;
    query[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeRSA;
    query[(__bridge id)kSecAttrAccessGroup] = self.accessGroup;
    query[(__bridge id)kSecAttrApplicationTag] = applicationTag;
    
    query[(__bridge __strong id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
    
    SecKeyRef keyData = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)query,(CFTypeRef *) &keyData);
    
    return keyData;
}


- (NSData *)dataForKey:(NSString *)key userOperationPrompt:(NSString *)userOperationPrompt error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *query = [self query];
    query[(__bridge __strong id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge __strong id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    
    query[(__bridge __strong id)kSecAttrAccount] = key;
    
    if (userOperationPrompt)
    {
        query[(__bridge __strong id)kSecUseOperationPrompt] = userOperationPrompt;
    }
    
    CFTypeRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    
    if (status == errSecSuccess) {
        NSData *ret = [NSData dataWithData:(__bridge NSData *)data];
        if (data) {
            CFRelease(data);
            return ret;
        } else {
            NSError *e = [self.class unexpectedError:NSLocalizedString(@"Unexpected error has occurred.", nil)];
            if (error) {
                *error = e;
            }
            return nil;
        }
    } else if (status == errSecItemNotFound) {
        return nil;
    }
    
    NSError *e = [self.class securityError:status];
    if (error) {
        *error = e;
    }
    return nil;
}


- (NSString *)stringForKey:(id)key userOperationPrompt:(NSString *)userOperationPrompt error:(NSError *__autoreleasing *)error
{
    NSData *data = [self dataForKey:key userOperationPrompt:userOperationPrompt error:error];
    if (data) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string) {
            return string;
        }
        NSError *e = [self.class conversionError:NSLocalizedString(@"failed to convert data to string", nil)];
        if (error) {
            *error = e;
        }
        return nil;
    }
    
    return nil;
}

@end
