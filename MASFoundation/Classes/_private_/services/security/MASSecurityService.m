//
//  MASSecurityService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSecurityService.h"

#import "MASAccessService.h"
#import "MASConstantsPrivate.h"
#import "NSMutableData+MASASN1Helper.h"

#include <CommonCrypto/CommonDigest.h>

#define kAsymmetricSecKeyPairModulusSize 2048

@interface MASSecurityService ()

@end


@implementation MASSecurityService

static MASSecurityService *_sharedService_ = nil;

# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASSecurityService alloc] initProtected];
                  });
    
    return sharedInstance;
}


# pragma mark - Service Lifecycle

+ (void)load
{
    [MASService registerSubclass:[self class] serviceUUID:MASSecurityServiceUUID];
}


+ (NSString *)serviceUUID
{
    return MASSecurityServiceUUID;
}


- (void)serviceWillStart
{
    //
    //  Generate keypair during the initialization process of SDK to avoid delay on keypair generation.
    //  Keypair are not being used along with any authentication data, so that it can be generated in advance, and it will be stored in secured keychain storage.
    //
    __block MASSecurityService *blockSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (![MASDevice currentDevice].isRegistered)
        {
            [blockSelf deleteAsymmetricKeys];
            [blockSelf generateKeypair];
        }
    });
    
    [super serviceWillStart];
}


- (void)serviceDidReset
{
    [super serviceDidReset];
}


# pragma mark - CSR Generation


- (NSString *)generateCSRWithUsername:(NSString *)userName
{
    //
    //  Check if the keypair was generated and was made available
    //
    [self checkKeypair];
    
    //
    //  Retrieve public/private keys
    //
    NSData *publicKeyBits = [self publicKeyBits];
    SecKeyRef privateKeyRef = [[MASAccessService sharedService] getAccessValueCryptoKeyWithStorageKey:MASKeychainStorageKeyPrivateKey];
    NSString *generatedCSR = [self generateCSRWithUsername:userName publicKeyBits:publicKeyBits privateKey:privateKeyRef];
    
    return generatedCSR;
}


- (NSString *)generateCSRWithUsername:(NSString *)userName publicKeyBits:(NSData *)publicKeyBits privateKey:(SecKeyRef)privateKey
{
    NSMutableData *csrInfo = [[NSMutableData alloc] initWithCapacity:512];
    
    //
    // Version
    //
    uint8_t version[3] = {0x02, 0x01, 0x00};
    [csrInfo appendBytes:version length:sizeof(version)];
    
    //
    // DN attributes
    //
    NSMutableData *attributes = [[NSMutableData alloc] initWithCapacity:256];
    
    NSString *organization = [MASApplication currentApplication].organization;
    NSString *deviceId = [MASDevice deviceIdBase64Encoded];
    NSString *escape = @"|!*'();:@&=+$,/?%#[] \"";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:escape] invertedSet];
    deviceId = [deviceId stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    NSString *deviceName = [UIDevice currentDevice].model;
    
    //
    //  For more details on ASN.1's object identifier hex code, check out https://lapo.it/asn1js
    //
    uint8_t oiCommonName[5] = {0x06, 0x03, 0x55, 0x04, 0x03};
    uint8_t oiOrganizationName[5] = {0x06, 0x03, 0x55, 0x04, 0x0A};
    uint8_t oiOrganizationUnitName[5] = {0x06, 0x03, 0x55, 0x04, 0x0B};
    uint8_t oiDomainComponent[12] = {0x06, 0x0A, 0x09, 0x92, 0x26, 0x89, 0x93, 0xF2, 0x2C, 0x64, 0x01, 0x19};
    
    [attributes appendSubjectItem:oiCommonName size:sizeof(oiCommonName) value:userName];
    [attributes appendSubjectItem:oiOrganizationName size:sizeof(oiOrganizationName) value:organization];
    [attributes appendSubjectItem:oiOrganizationUnitName size:sizeof(oiOrganizationUnitName) value:deviceId];
    [attributes appendSubjectItem:oiDomainComponent size:sizeof(oiDomainComponent) value:deviceName];
    [attributes encloseWith:0x30];
    
    [csrInfo appendData:attributes];
    
    //
    //  Add public key info
    //
    NSData *publicKeyInfoData = [NSMutableData buildPublicKeyForASN1:publicKeyBits];
    [csrInfo appendData:publicKeyInfoData];
    
    //
    //  Add attributes
    //
    uint8_t attrs[2] = {0xA0, 0x00};
    [csrInfo appendBytes:attrs length:sizeof(attrs)];
    
    //
    //  enclose with sequence tag
    //
    [csrInfo encloseWith:0x30];
    
    //
    //  Sign and hash
    //
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(csrInfo.bytes, (CC_LONG)csrInfo.length, digest);
    uint8_t signature[256];
    size_t signature_len = sizeof(signature);
    OSStatus result = SecKeyRawSign(privateKey, kSecPaddingPKCS1SHA1, digest, sizeof(digest), signature, &signature_len);
    assert(result == noErr);
    
    NSMutableData *certificateSigningRequest = [[NSMutableData alloc] initWithCapacity:1024];
    [certificateSigningRequest appendData:csrInfo];
    //
    // See: https://tools.ietf.org/html/rfc7427#appendix-A.1.1
    //
    uint8_t sha1WithRSAEncryption[] = {0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 1, 1, 5, 5, 0x00};

    [certificateSigningRequest appendBytes:sha1WithRSAEncryption length:sizeof(sha1WithRSAEncryption)];
    
    NSMutableData * signdata = [NSMutableData dataWithCapacity:257];
    uint8_t zero = 0;
    [signdata appendBytes:&zero length:1];
    [signdata appendBytes:signature length:signature_len];
    [certificateSigningRequest appendBITString:signdata];
    
    [certificateSigningRequest encloseWith:0x30];
    
    return [certificateSigningRequest base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


# pragma mark - Keys

- (NSURLCredential *)createUrlCredential
{
    NSArray *identities = [[MASAccessService sharedService] getAccessValueIdentities];
    NSArray *certificates = [[MASAccessService sharedService] getAccessValueCertificateWithStorageKey:MASKeychainStorageKeySignedPublicCertificate];

    //DLog(@"\n\ncalled and identities is: %@ and certificates is: %@", identities, certificates);
    
    return [NSURLCredential credentialWithIdentity:(__bridge SecIdentityRef)(identities[0]) certificates:certificates persistence:NSURLCredentialPersistenceNone];
}


- (void)deleteAsymmetricKeys
{
    NSString *privateKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"privateKey"];
    NSString *publicKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    
    NSData *privateKeyData = [[NSData alloc] initWithBytes:[privateKeyIdentifierStr UTF8String] length:[privateKeyIdentifierStr length]];
    NSData *publicKeyData = [[NSData alloc] initWithBytes:[publicKeyIdentifierStr UTF8String] length:[publicKeyIdentifierStr length]];
    
	OSStatus sanityCheck = noErr;
	NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
	
    //
	// Set the public key query dictionary
	//
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[queryPublicKey setObject:publicKeyData forKey:(__bridge id)kSecAttrApplicationTag];
	[queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	
	//
    // Set the private key query dictionary
	//
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[queryPrivateKey setObject:privateKeyData forKey:(__bridge id)kSecAttrApplicationTag];
	[queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	
	//
    // Delete the private key
	//
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    if (!(sanityCheck == noErr || sanityCheck == errSecItemNotFound))
    {
        DLog(@"Error removing private key, OSStatus == %d.", (int)sanityCheck);
    }
	
	//
    // Delete the public key
	//
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    if (!(sanityCheck == noErr || sanityCheck == errSecItemNotFound))
    {
        DLog(@"Error removing public key, OSStatus == %d.", (int)sanityCheck);
    }
}


- (void)generateKeypair
{
    NSData *privatKeyBits = [self privateKeyBits];
    NSData *publicKeyBits = [self publicKeyBits];
    
    NSString *privateKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"privateKey"];
    NSString *publicKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    
    NSData *privateKeyData = [[NSData alloc] initWithBytes:[privateKeyIdentifierStr UTF8String] length:[privateKeyIdentifierStr length]];
    NSData *publicKeyData = [[NSData alloc] initWithBytes:[publicKeyIdentifierStr UTF8String] length:[publicKeyIdentifierStr length]];
    
    if (privatKeyBits != nil && publicKeyBits != nil)
    {
        return;
    }
    
    //
    // Generate asymetric keys and save the private key into the keychain and return the public key
    //
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyRef = NULL;
    SecKeyRef privateKeyRef = NULL;
    
    // Container dictionaries
	NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
	
	//
    // Set top level dictionary for the keypair
	//
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	[keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:kAsymmetricSecKeyPairModulusSize] forKey:(__bridge id)kSecAttrKeySizeInBits];
	
	//
    // Set the private key dictionary
	//
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
	[privateKeyAttr setObject:privateKeyData forKey:(__bridge id)kSecAttrApplicationTag];
    
	//
    // Set the public key dictionary
	//
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
	[publicKeyAttr setObject:publicKeyData forKey:(__bridge id)kSecAttrApplicationTag];
    
	//
    // Set attributes to top level dictionary
	//
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
	[keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
	sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
    
    if (!( sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL))
    {
        DLog(@"Error with something really bad went wrong with generating the key pair");
    }
    
    //
    // Storing privateKey and publicKey into keychain
    //
    if (privateKeyRef)
    {
        [[MASAccessService sharedService] setAccessValueCryptoKey:privateKeyRef storageKey:MASKeychainStorageKeyPrivateKey];
    }
    
    if (publicKeyRef)
    {
        [[MASAccessService sharedService] setAccessValueCryptoKey:publicKeyRef storageKey:MASKeychainStorageKeyPublicKey];
    }
    
    privateKeyRef = NULL;
    publicKeyRef = NULL;
}


- (NSData *)privateKeyBits
{
    NSString *privateKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"privateKey"];
    NSData *privateKeyData = [[NSData alloc] initWithBytes:[privateKeyIdentifierStr UTF8String] length:[privateKeyIdentifierStr length]];
    
    OSStatus sanityCheck = noErr;
    NSData *privateKeyBits = nil;
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    // Set the public key query dictionary
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateKeyData forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    CFTypeRef cfresult = NULL;
    
    // Get the key bits
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&cfresult);
    
    privateKeyBits = (__bridge_transfer NSData *)cfresult;
    
    if (sanityCheck != noErr)
    {
        privateKeyBits = nil;
    }
    
	return privateKeyBits;
}


- (NSData *)publicKeyBits
{
    NSString *publicKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    NSData *publicKeyData = [[NSData alloc] initWithBytes:[publicKeyIdentifierStr UTF8String] length:[publicKeyIdentifierStr length]];
 
    OSStatus sanityCheck = noErr;
    NSData * publicKeyBits = nil;
    
    NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicKeyData forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef cfresult = NULL;
    
    // Get the key bits
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&cfresult);
    
    publicKeyBits = (__bridge_transfer NSData *)cfresult;
    
    if (sanityCheck != noErr)
    {
        publicKeyBits = nil;
    }
    
	return publicKeyBits;
}


- (void)checkKeypair
{
    SecKeyRef privateKeyRef = [[MASAccessService sharedService] getAccessValueCryptoKeyWithStorageKey:MASKeychainStorageKeyPrivateKey];
    if (privateKeyRef == NULL)
    {
        [self deleteAsymmetricKeys];
        [self generateKeypair];
    }
}

@end
