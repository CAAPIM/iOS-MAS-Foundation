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
#import "MASFile.h"

#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/x509.h>
#import "fmemopen.h"


# pragma mark - Constants

static NSString *const kMASSecurityPrivateKeyBits = @"kMASSecurityPrivateKeyBits";
static NSString *const kMASSecurityPublicKeyBits = @"kMASSecurityPublicKeyBits";

#define kAsymmetricSecKeyPairModulusSize 2048


@interface MASSecurityService ()

# pragma mark - Properties

@property (nonatomic, assign, readonly) BOOL isConfigured;

@property (nonatomic, strong, readonly) NSData *privateKeyData;
@property (nonatomic, strong, readonly) NSData *publicKeyData;

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

+ (NSString *)serviceUUID
{
    return MASSecurityServiceUUID;
}


- (void)serviceWillStart
{
    NSString *privateKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"privateKey"];
    NSString *publicKeyIdentifierStr = [NSString stringWithFormat:@"%@.%@", [MASConfiguration currentConfiguration].gatewayUrl.absoluteString, @"publicKey"];
    
    
    _privateKeyData = [[NSData alloc] initWithBytes:[privateKeyIdentifierStr UTF8String]
                                             length:[privateKeyIdentifierStr length]];
    
    _publicKeyData = [[NSData alloc] initWithBytes:[publicKeyIdentifierStr UTF8String]
                                            length:[publicKeyIdentifierStr length]];
    
    _isConfigured = YES;
    
    [super serviceWillStart];
}


- (void)serviceDidReset
{
    _privateKeyData = nil;
    
    _publicKeyData = nil;
    
    _isConfigured = NO;

    [super serviceDidReset];
}


# pragma mark - Keys

- (NSURLCredential *)createUrlCredential
{
    NSArray *identities = [[MASAccessService sharedService] getAccessValueIdentities];
    NSArray *certificates = [[MASAccessService sharedService] getAccessValueCertificateWithType:MASAccessValueTypeSignedPublicCertificate];

    //DLog(@"\n\ncalled and identities is: %@ and certificates is: %@", identities, certificates);
    
    return [NSURLCredential credentialWithIdentity:(__bridge SecIdentityRef)(identities[0])
        certificates:certificates
        persistence:NSURLCredentialPersistenceNone];
}


- (void)deleteAsymmetricKeys
{
    //DLog(@"called");
    
    NSAssert(_isConfigured, @"The utility is not configured, call the MASSecurity.configure method first");
   
	OSStatus sanityCheck = noErr;
	NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
	
    //
	// Set the public key query dictionary
	//
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[queryPublicKey setObject:_publicKeyData forKey:(__bridge id)kSecAttrApplicationTag];
	[queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	
	//
    // Set the private key query dictionary
	//
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[queryPrivateKey setObject:_privateKeyData forKey:(__bridge id)kSecAttrApplicationTag];
	[queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	
	//
    // Delete the private key
	//
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    if(!(sanityCheck == noErr || sanityCheck == errSecItemNotFound))
    {
//        DLog(@"Error removing private key, OSStatus == %d.", (int)sanityCheck );
    }
	
	//
    // Delete the public key
	//
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    if(!(sanityCheck == noErr || sanityCheck == errSecItemNotFound))
    {
//        DLog(@"Error removing public key, OSStatus == %d.", (int)sanityCheck );
    }
}


- (NSString *)generateCSRWithUsername:(NSString *)userName
{
    //DLog(@"called with userName: %@", userName);
    
    NSAssert(_isConfigured, @"The utility is not configured, call the MASSecurity.configure method first");
    
    NSData *publicKeyBits = [self publicKeyBits];
    NSData *privateKeyBits = [self privateKeyBits];
    
    NSAssert(userName, @"Username cannot be nil");
    NSAssert(publicKeyBits, @"Public key bits not found");
    NSAssert(privateKeyBits, @"Private key bits not found");
   
    X509_REQ *req = NULL;
    X509_NAME *name= NULL;
    EVP_PKEY *key;
    EVP_PKEY *privatekey=EVP_PKEY_new();
    
    const unsigned char * bits = (unsigned char *) [publicKeyBits bytes];
    unsigned long length = [publicKeyBits length];
    
    if ((req=X509_REQ_new()) == NULL)
    {
//        DLog(@"Error generating the certificate signing request");
        return NULL;
    }
    
    RSA * rsa = NULL;
    key=EVP_PKEY_new();
    d2i_RSAPublicKey(&rsa, &bits, length);
    EVP_PKEY_assign_RSA(key,rsa);
    name = X509_REQ_get_subject_name(req);
    X509_REQ_set_pubkey(req, key);
    
    /* This function creates and adds the entry, working out the
     * correct string type and performing checks on its length.
     * Normally we'd check the return value for errors...
     */
    
    NSString *organization = [MASApplication currentApplication].organization;
    NSAssert(organization, @"Organazation in msso_config.json cannot be nil - Assertion while generating CSR");
    
    X509_NAME_add_entry_by_txt(name,"CN",
                               MBSTRING_ASC, (const unsigned char*)[userName UTF8String], -1, -1, 0);
    X509_NAME_add_entry_by_txt(name,"O",
                               MBSTRING_ASC, (const unsigned char*)[organization UTF8String], -1, -1, 0);
    
    //device id
    NSString *deviceId = [MASDevice deviceIdBase64Encoded];
    X509_NAME_add_entry_by_txt(name,"OU",
                               MBSTRING_ASC, (const unsigned char*)[deviceId UTF8String], -1, -1, 0);
    
    //device name
    
    //
    // changing this for now as base64 encoded string is being stored with double quotes in server's database for some reason - James Go @ December 4th, 2015
    //
    NSString *deviceName = [[UIDevice currentDevice] name];//[MASDevice deviceNameBase64Encoded];
    NSString *newDeviceName = [deviceName stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    X509_NAME_add_entry_by_txt(name,"DC",
                               MBSTRING_ASC, (const unsigned char*)[newDeviceName UTF8String], -1, -1, 0);
    
    const unsigned char * privateBits = (unsigned char *) [privateKeyBits bytes];
    unsigned long privateKeyLength = [privateKeyBits length];
    d2i_RSAPrivateKey(&rsa, &privateBits, privateKeyLength);
    EVP_PKEY_assign_RSA(privatekey,rsa);
    
    //
    // Store new value in keychain
    //
    if(privateKeyBits)
    {
        NSString *keyContents = [self evpKeyToString:privatekey];
    
        //DLog(@"\n\nEVP key as string: %@\n\n", [self evpKeyToString:privatekey]);
    
        //
        // Store private key bits into keychain
        //
        [[MASAccessService sharedService] setAccessValueString:keyContents withAccessValueType:MASAccessValueTypePrivateKeyBits];
        
        //
        // Try to get private key as MASFile to ensure we create the file
        //
        [self getPrivateKey];
    }
    
    if (!X509_REQ_sign(req, privatekey, EVP_sha1()))
    {
        //DLog(@"Error cannot sign request");
        return NULL;
    }
    
    BIO * csr = BIO_new(BIO_s_mem());
    // Tell the context to encode base64
    BIO *command = BIO_new(BIO_f_base64());
    csr = BIO_push(command, csr);
    i2d_X509_REQ_bio(csr, req);
    //X509_REQ_print(csr, req);
    __unused int i = BIO_flush(csr);
    
    char *outputBuffer;
    long outputLength = BIO_get_mem_data(csr, &outputBuffer);
    NSString *encodedString = [[NSString alloc] initWithBytes:outputBuffer length:outputLength encoding:NSNEXTSTEPStringEncoding];
    
    BIO_free_all(csr);
    
    //X509_REQ_print_fp(stdout, req);
    
    return encodedString;
}


- (NSString *)evpKeyToString:(EVP_PKEY *)key
{
    char *buf[256];
    FILE *pFile;
    NSString *pkey_string;
    
    pFile = fmemopen(buf, sizeof(buf), "w");
    
    PEM_write_PrivateKey(pFile, key, NULL, NULL, 0, 0, NULL);
    fputc('\0', pFile);
    
    fclose(pFile);
    
    pkey_string = [NSString stringWithUTF8String:(char *)buf];
    
    return pkey_string;
}


- (void)generateKeypair
{
    //DLog(@"called");
    
    NSAssert(_isConfigured, @"The utility is not configured, call the MASSecurity.configure method first");
    
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
	[keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:kAsymmetricSecKeyPairModulusSize]
        forKey:(__bridge id)kSecAttrKeySizeInBits];
	
	//
    // Set the private key dictionary
	//
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
	[privateKeyAttr setObject:_privateKeyData forKey:(__bridge id)kSecAttrApplicationTag];
    
	//
    // Set the public key dictionary
	//
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
	[publicKeyAttr setObject:_publicKeyData forKey:(__bridge id)kSecAttrApplicationTag];
    
	//
    // Set attributes to top level dictionary
	//
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
	[keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
	sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
    if(!( sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL))
    {
        //DLog(@"Error with something really bad went wrong with generating the key pair");
    }
    
    //
    // Storing privateKey and publicKey into keychain
    //
    if(privateKeyRef)
    {
        [[MASAccessService sharedService] setAccessValueCryptoKey:privateKeyRef withAccessValueType:MASAccessValueTypePrivateKey];
    }
    
    if(publicKeyRef)
    {
        [[MASAccessService sharedService] setAccessValueCryptoKey:publicKeyRef withAccessValueType:MASAccessValueTypePublicKey];
    }
    
    privateKeyRef = NULL;
    publicKeyRef = NULL;
}


- (NSData *)privateKeyBits
{
    
	OSStatus sanityCheck = noErr;
	NSData *privateKeyBits = nil;
	
	NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    
	// Set the public key query dictionary
	[queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[queryPrivateKey setObject:_privateKeyData forKey:(__bridge id)kSecAttrApplicationTag];
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
 
    OSStatus sanityCheck = noErr;
	NSData * publicKeyBits = nil;
	
	NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
	// Set the public key query dictionary.
	[queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[queryPublicKey setObject:_publicKeyData forKey:(__bridge id)kSecAttrApplicationTag];
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


///--------------------------------------
/// @name MASFile Security
///--------------------------------------

# pragma mark - MASFile Security

- (MASFile *)getSignedCertificate
{
    NSString *gatewayIdentifier = [[[MASConfiguration currentConfiguration].gatewayUrl.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    MASFile *signedCert = [MASFile findFileWithName:[NSString stringWithFormat:@"%@.%@", gatewayIdentifier, MASSignedCertificate]];
    
    if (!signedCert)
    {
        NSData *signedCertificateData = [[MASAccessService sharedService] getAccessValueDataWithType:MASAccessValueTypeSignedPublicCertificateData];

        if (signedCertificateData)
        {
            signedCert = [MASFile fileWithName:[NSString stringWithFormat:@"%@.%@", gatewayIdentifier, MASSignedCertificate] contents:signedCertificateData];
            [signedCert saveWithPassword:MASDefaultStuff];
        }
    }
    
    return signedCert;
}


- (MASFile *)getClientCertificate
{
    NSString *gatewayIdentifier = [[[MASConfiguration currentConfiguration].gatewayUrl.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    MASFile *clientCert = [MASFile findFileWithName:[NSString stringWithFormat:@"%@.%@", gatewayIdentifier, MASCertificate]];
    
    if (!clientCert)
    {
        //
        // Create the public server certificate file
        //
        NSArray *certs = [[MASConfiguration currentConfiguration] gatewayCertificatesAsPEMData];
        if(certs.count > 0)
        {
            NSData *certificateData = certs[0];
            
            //DLog(@"\n\nServer Certificate class is: %@\n\n  and value: %@\n\n", [[certificateData class] debugDescription], certificateData);
            
            if(certificateData)
            {
                clientCert = [MASFile fileWithName:[NSString stringWithFormat:@"%@.%@", gatewayIdentifier, MASCertificate] contents:certificateData];
                [clientCert saveWithPassword:MASDefaultStuff];
            }
        }
    }
    
    return clientCert;
}


- (MASFile *)getPrivateKey
{
    NSString *gatewayIdentifier = [[[MASConfiguration currentConfiguration].gatewayUrl.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    
      MASFile *privateKey = [MASFile findFileWithName:[NSString stringWithFormat:@"%@.%@", gatewayIdentifier, MASKey]];

    //
    // If the private key file does not exsist, create one.
    //
    if (!privateKey)
    {
        //
        // Retrieve privateKeyBits from keychain.
        //
        NSString *privateKeyBits = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypePrivateKeyBits];
        
        if (privateKeyBits)
        {
            //
            // Create MASFile and save. Note: saveWithPassword method will simply ignore the password at the moment.
            //
            privateKey = [MASFile fileWithName:[NSString stringWithFormat:@"%@.%@", gatewayIdentifier, MASKey] contents:[privateKeyBits dataUsingEncoding:NSUTF8StringEncoding]];
            [privateKey saveWithPassword:MASDefaultStuff];
        }
    }
    
    return privateKey;
}


- (void)removeAllFiles
{
    MASFile *privateKey = [self getPrivateKey];
    MASFile *clientCert = [self getClientCertificate];
    MASFile *signedCert = [self getSignedCertificate];
    
    if ([privateKey filePath])
    {
        [MASFile removeItemAtFilePath:[privateKey filePath]];
    }
    
    if ([clientCert filePath])
    {
        [MASFile removeItemAtFilePath:[clientCert filePath]];
    }
    
    if ([signedCert filePath])
    {
        [MASFile removeItemAtFilePath:[signedCert filePath]];
    }
}

@end
