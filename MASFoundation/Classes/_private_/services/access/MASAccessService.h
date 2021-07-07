//
//  MASAccessService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"

#import "MASAccess.h"
#import "MASConstantsPrivate.h"


@class MASIKeyChainStore;

//
//  List of constant NSString values for reserved storage keys
//
extern NSString * const MASKeychainStorageKeyConfiguration;
extern NSString * const MASKeychainStorageKeyAccessToken;
extern NSString * const MASKeychainStorageKeyAuthenticatedUserObjectId;
extern NSString * const MASKeychainStorageKeyRefreshToken;
extern NSString * const MASKeychainStorageKeyScope;
extern NSString * const MASKeychainStorageKeyTokenType;
extern NSString * const MASKeychainStorageKeyExpiresIn;
extern NSString * const MASKeychainStorageKeyTokenExpiration;
extern NSString * const MASKeychainStorageKeySecuredIdToken;
extern NSString * const MASKeychainStorageKeyIdToken;
extern NSString * const MASKeychainStorageKeyIdTokenType;
extern NSString * const MASKeychainStorageKeyClientExpiration;
extern NSString * const MASKeychainStorageKeyClientId;
extern NSString * const MASKeychainStorageKeyClientSecret;
extern NSString * const MASKeychainStorageKeyJWT;
extern NSString * const MASKeychainStorageKeyMAGIdentifier;
extern NSString * const MASKeychainStorageKeyMSSOEnabled;
extern NSString * const MASKeychainStorageKeyPrivateKey;
extern NSString * const MASKeychainStorageKeyPrivateKeyBits;
extern NSString * const MASKeychainStorageKeyPublicKey;
extern NSString * const MASKeychainStorageKeyTrustedServerCertificate;
extern NSString * const MASKeychainStorageKeySignedPublicCertificate;
extern NSString * const MASKeychainStorageKeyPublicCertificateData;
extern NSString * const MASKeychainStorageKeyPublicCertificateExpirationDate;
extern NSString * const MASKeychainStorageKeyAuthenticatedTimestamp;
extern NSString * const MASKeychainStorageKeyIsDeviceLocked;
extern NSString * const MASKeychainStorageKeyCurrentAuthCredentialsGrantType;
extern NSString * const MASKeychainStorageKeyMASUserObjectData;
extern NSString * const MASKeychainStorageKeyDeviceVendorId;


/**
 * The `MASAccessService` class is a service class that provides interfaces of keychain stored data and other related services.
 */
@interface MASAccessService : MASService



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 * The current access object singleton.
 */
@property (nonatomic, strong, readonly) MASAccess *currentAccessObj;


/**
 *  AccessGrop
 */
@property (strong, nonatomic) NSString *accessGroup;



/**
 Sets Keychain Sharing Group identifier that has been specified through [MAS setKeychainSharingGroup:] method.
 If not specified, or null value passed, the group identifier will be defaulted to application's bundle identifier replaced last portion with 'singleSignOn'

 @param keychainSharingGroup NSString value of Keychain Sharing Group identifier
 */
+ (void)setKeychainSharingGroup:(NSString *)keychainSharingGroup;



/**
 *  Static boolean property indicating PKCE is enabled or not.
 *
 *  @return return BOOL value indicating PKCE is enabled or not
 */
+ (BOOL)isPKCEEnabled;



/**
 *  Setter of static boolean property indicating PKCE is enabled or not.
 *
 *  @param enable BOOL value indicating PKCE is enabled or not
 */
+ (void)enablePKCE:(BOOL)enable;



/**
 *  Static boolean property indicating SSL Pinning is enabled or not.
 *
 *  @return return BOOL value indicating SSL Pinning is enabled or not
 */
+ (BOOL)isSSLPinningEnabled;



/**
 *  Setter of static boolean property indicating SSL Pinning is enabled or not.
 *
 *  @param enable BOOL value indicating SSL Pinning is enabled or not
 */
+ (void)setSSLPinningEnabled:(BOOL)enable;



/**
 *  Static boolean property indicating Keychain sincronization is enabled or not.
 *
 *  @return return BOOL value indicating Keychain sincronization is enabled or not
 */
+ (BOOL)isKeychainSynchronizable;



/**
 *  Setter of static boolean property indicating Keychain sincronization is enabled or not.
 *
 *  @param enable BOOL value indicating Keychain sincronization is enabled or not
 */
+ (void)setKeychainSynchronizable:(BOOL)enable;



///--------------------------------------
/// @name Shared Service
///--------------------------------------

# pragma mark - Shared Service

/**
 * Retrieve the shared, singleton service.
 *
 * @return Returns the MASAccessService singleton.
 */
+ (instancetype)sharedService;



///--------------------------------------
/// @name MASAccess object
///--------------------------------------

# pragma mark - MASAccess object

/**
 *  Save a dictionary of access information into MASAccess object
 *
 *  @param dictionary       Dictionary information of the access information
 *  @param forceToOverwrite Boolean value to overwrite MASAccess information or not
 */
- (void)saveAccessValuesWithDictionary:(NSDictionary *)dictionary forceToOverwrite:(BOOL)forceToOverwrite;



///--------------------------------------
/// @name Storage methods
///--------------------------------------

# pragma mark - Storage methods

/**
 *  Retrieve list of identities in keychain
 *
 *  @return Array of identities
 */
- (id)getAccessValueIdentities;



/**
 *  Store the certificate as data format into keychain
 *
 *  @param certificate NSData form of certificate
 *  @param storageKey NSString value for the data key
 */
- (void)setAccessValueCertificate:(NSData *)certificate storageKey:(NSString *)storageKey;



/**
 *  Retrieve the certificate data by the value key
 *
 *  @param storageKey NSString value for the data key
 *
 *  @return Certificate value by the specified value key
 */
- (id)getAccessValueCertificateWithStorageKey:(NSString *)storageKey;



/**
 Store NSData of access value into keychain

 @param data NSData to be stored into keychain
 @param storageKey NSString value for the data key
 @return BOOL result of operation
 */
- (BOOL)setAccessValueData:(NSData *)data storageKey:(NSString *)storageKey;



/**
 Store NSData of access value into keychain

 @param data NSData to be stored into keychain
 @param storageKey NSString value for the data key
 @param error NSError reference object to notify if there is any error while keychain operation
 @return BOOL result of operation
 */
- (BOOL)setAccessValueData:(NSData *)data storageKey:(NSString *)storageKey error:(NSError **)error;



/**
 *  Retrieve NSData of access value from keychain
 *
 *  @param storageKey NSString value for the data key
 *
 *  @return NSData of the access data by the specified value key
 */
- (NSData *)getAccessValueDataWithStorageKey:(NSString *)storageKey;



/**
 Retrieve NSData of access value from keychain

 @param storageKey NSString value for the data key
 @param error NSError reference object to notify if there is any error while keychain operation
 @return NSData of the access data by the specified value key
 */
- (NSData *)getAccessValueDataWithStorageKey:(NSString *)storageKey error:(NSError **)error;



/**
 *  Store NSString of access value into keychain
 *
 *  @param string NSString to store into keychain
 *  @param storageKey NSString value for the data key
 *  @return BOOL result of operation
 */
- (BOOL)setAccessValueString:(NSString *)string storageKey:(NSString *)storageKey;



/**
 Store NSString of access value into keychain

 @param string NSString to store into keychain
 @param storageKey NSString value for the data key
 @param error NSError reference object to notify if there is any error while keychain operation
 @return BOOL result of operation
 */
- (BOOL)setAccessValueString:(NSString *)string storageKey:(NSString *)storageKey error:(NSError **)error;



/**
 *  Retrieve NSString of access value from keychain
 *
 *  @param storageKey NSString value for the data key
 *
 *  @return NSString of the access data by the specified value key
 */
- (NSString *)getAccessValueStringWithStorageKey:(NSString *)storageKey;



/**
 Retrieve NSString of access value from keychain

 @param storageKey NSString value for the data key
 @param error NSError reference object to notify if there is any error while keychain operation
 @return NSString of the access data by the specified value key
 */
- (NSString *)getAccessValueStringWithStorageKey:(NSString *)storageKey error:(NSError **)error;



/**
 *  Store NSDictionary of access value into keychain
 *
 *  @param dictionary NSDictionary to store into keychain
 *  @param storageKey NSString value for the data key
 */
- (BOOL)setAccessValueDictionary:(NSDictionary *)dictionary storageKey:(NSString *)storageKey;



/**
 *  Retrieve NSDictionary of access value from keychain
 *
 *  @param storageKey NSString value for the data key
 *
 *  @return NSDictionary of the access data by the specified value key
 */
- (NSDictionary *)getAccessValueDictionaryWithStorageKey:(NSString *)storageKey;



/**
 *  Store NSNumber of access value into keychain
 *
 *  @param number NSNumber to store into keychain
 *  @param storageKey NSString value for the data key
 */
- (BOOL)setAccessValueNumber:(NSNumber *)number storageKey:(NSString *)storageKey;



/**
 *  Retrieve NSNumber of access value from keychain
 *
 *  @param storageKey NSString value for the data key
 *
 *  @return NSNumber of the access data by the specified value key
 */
- (NSNumber *)getAccessValueNumberWithStorageKey:(NSString *)storageKey;



/**
 *  Store SecKeyRef of access value into keychain
 *
 *  Note: for now, this method will only accept the access value type for public and private keys.
 *  MASAccessValueTypePublicKey and MASAccessValueTypePrivateKey.
 *  Other access type value will not be stored.
 *
 *  @param cryptoKey SecKeyRef to store into keychain
 *  @param storageKey NSString value for the data key
 */
- (void)setAccessValueCryptoKey:(SecKeyRef)cryptoKey storageKey:(NSString *)storageKey;



/**
 *  Retrieve SecKeyRef of access value from keychain
 *
 *  Note: for now, this method will only accept the access value type for public and private keys.
 *  MASAccessValueTypePublicKey and MASAccessValueTypePrivateKey.
 *  Other access type value will not be retrieved.
 *
 *  @param storageKey NSString value for the data key
 *
 *  @return SecKeyRef of the access data by the specified value key
 */
- (SecKeyRef)getAccessValueCryptoKeyWithStorageKey:(NSString *)storageKey;



/**
 Deletes keychain storage item based on storage key

 @param storageKey NSString of storage key.
 @param error NSError object reference.
 */
- (void)deleteForStorageKey:(NSString *)storageKey error:(NSError **)error;



///--------------------------------------
/// @name accessGroup
///--------------------------------------

# pragma mark - accessGroup

/**
 Boolean value that indicates whether shared keychain storage is accessible or not.

 @return Boolean indicator whether shared keychain storage is accessible or not
 */
- (BOOL)isAccessGroupAccessible;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 *  Validate id_token
 *
 *  @param idToken NSString of id_token value
 *  @param magIdentifier NSString of mag-identifier value
 *
 *  @return BOOL if the id_token is still valid or not
 */
+ (BOOL)validateIdToken:(NSString *)idToken magIdentifier:(NSString *)magIdentifier error:(NSError *__autoreleasing *)error;



/**
 *  Validate the expiration date in id_token
 *
 *  @param idToken NSString of id_token value
 *
 *  @return BOOL if the id_token has expired and invalid format
 */
+ (BOOL)isIdTokenExpired:(NSString *)idToken error:(NSError *__autoreleasing *)error;



/**
 *  Return the current session's lock status
 *
 *  @return BOOL if the session is locked or not
 */
- (BOOL)isSessionLocked;



/**
 Lock id_token, access_token, and refresh_token into secure keychain storage protected by device's local authentication (passcode and/or fingerprint)

 @param error NSError object that may occur during the process

 @return BOOL of the result
 */
- (BOOL)lockSession:(NSError * __autoreleasing *)error;



/**
 Unlock id_token, access_token, and refresh_token from secure keychain storage protected by device's local authentication (passcode and/or fingerprint)

 @param userOperationPrompt NSString message that will display on system's local authentication screen
 @param error NSError object that may occur during the process

 @return BOOL of the result
 */
- (BOOL)unlockSessionWithUserOperationPromptMessage:(NSString *)userOperationPrompt error:(NSError * __autoreleasing *)error;



/**
 Remove all items in protected keychain storage with local authentications and set session lock status to default.
 */
- (void)removeSessionLock;



/**
 Internal method to determine whether the key is reserved for internal system data or not

 @param storageKey NSString of key to be stored
 @return BOOL result of whether the key is reserved or not by internal system data
 */
- (BOOL)isInternalDataForStorageKey:(NSString *)storageKey;



/**
 *  Revoke tokens via asynchronous request.
 *
 *  @param completion The completion block that receives the results.
 */
- (void)revokeTokensWithCompletion:(MASResponseInfoErrorBlock)completion;



# pragma mark - Debug only

- (void)clearLocal;

- (void)clearShared;

- (NSString *)debugSecuredDescription;

@end
