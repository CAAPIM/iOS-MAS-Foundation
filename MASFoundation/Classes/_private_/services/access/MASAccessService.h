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


/**
 * The enumerated MASAccessValueType
 */
typedef NS_ENUM(NSInteger, MASAccessValueType)
{
    MASAccessValueTypeUknonw = -1,
    MASAccessValueTypeAccessToken,
    MASAccessValueTypeAuthenticatedTimestamp,
    MASAccessValueTypeAuthenticatedUserObjectId,
    MASAccessValueTypeConfiguration,
    MASAccessValueTypeClientExpiration,
    MASAccessValueTypeClientId,
    MASAccessValueTypeClientSecret,
    MASAccessValueTypeExpiresIn,
    MASAccessValueTypeIdToken,
    MASAccessValueTypeIdTokenType,
    MASAccessValueTypeIsDeviceLocked,
    MASAccessValueTypeJWT,
    MASAccessValueTypeMAGIdentifier,
    MASAccessValueTypeMSSOEnabled,
    MASAccessValueTypePrivateKey,
    MASAccessValueTypePrivateKeyBits,
    MASAccessValueTypePublicKey,
    MASAccessValueTypeRefreshToken,
    MASAccessValueTypeScope,
    MASAccessValueTypeSecuredIdToken,
    MASAccessValueTypeSignedPublicCertificate,
    MASAccessValueTypeSignedPublicCertificateData,
    MASAccessValueTypeSignedPublicCertificateExpirationDate,
    MASAccessValueTypeTokenExpiration,
    MASAccessValueTypeTokenType,
    MASAccessValueTypeTrustedServerCertificate
};


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



# pragma mark - MASAccess object

/**
 *  Save a dictionary of access information into MASAccess object
 *
 *  @param dictionary       Dictionary information of the access information
 *  @param forceToOverwrite Boolean value to overwrite MASAccess information or not
 */
- (void)saveAccessValuesWithDictionary:(NSDictionary *)dictionary forceToOverwrite:(BOOL)forceToOverwrite;



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
 *  @param type        MASAccessValueType enum specifying the value key
 */
- (void)setAccessValueCertificate:(NSData *)certificate withAccessValueType:(MASAccessValueType)type;



/**
 *  Retrieve the certificate data by the value key
 *
 *  @param type MASAccessValueType enum value for key
 *
 *  @return Certificate value by the specified value key
 */
- (id)getAccessValueCertificateWithType:(MASAccessValueType)type;



/**
 *  Store NSData of access value into keychain
 *
 *  @param data NSData to store into keychain
 *  @param type MASAccessValueType enum value for the value key
 */
- (void)setAccessValueData:(NSData *)data withAccessValueType:(MASAccessValueType)type;



/**
 *  Retrieve NSData of access value from keychain
 *
 *  @param type MASAccessValueType enum value for the value key
 *
 *  @return NSData of the access data by the specified value key
 */
- (NSData *)getAccessValueDataWithType:(MASAccessValueType)type;



/**
 *  Store NSString of access value into keychain
 *
 *  @param string NSString to store into keychain
 *  @param type   MASAccessValueType enum value for the value key
 */
- (void)setAccessValueString:(NSString *)string withAccessValueType:(MASAccessValueType)type;



/**
 *  Retrieve NSString of access value from keychain
 *
 *  @param type MASAccessValueType enum value for the value key
 *
 *  @return NSString of the access data by the specified value key
 */
- (NSString *)getAccessValueStringWithType:(MASAccessValueType)type;



/**
 *  Store NSDictionary of access value into keychain
 *
 *  @param dictionary NSDictionary to store into keychain
 *  @param type       MASAccessValueType enum value for the value key
 */
- (void)setAccessValueDictionary:(NSDictionary *)dictionary withAccessValueType:(MASAccessValueType)type;



/**
 *  Retrieve NSDictionary of access value from keychain
 *
 *  @param type MASAccessValueType enum value for the value key
 *
 *  @return NSDictionary of the access data by the specified value key
 */
- (NSDictionary *)getAccessValueDictionaryWithType:(MASAccessValueType)type;



/**
 *  Store NSNumber of access value into keychain
 *
 *  @param number NSNumber to store into keychain
 *  @param type   MASAccessValueType enum value for the value key
 */
- (void)setAccessValueNumber:(NSNumber *)number withAccessValueType:(MASAccessValueType)type;



/**
 *  Retrieve NSNumber of access value from keychain
 *
 *  @param type MASAccessValueType enum value for the value key
 *
 *  @return NSNumber of the access data by the specified value key
 */
- (NSNumber *)getAccessValueNumberWithType:(MASAccessValueType)type;



/**
 *  Store SecKeyRef of access value into keychain
 *
 *  Note: for now, this method will only accept the access value type for public and private keys.
 *  MASAccessValueTypePublicKey and MASAccessValueTypePrivateKey.
 *  Other access type value will not be stored.
 *
 *  @param cryptoKey SecKeyRef to store into keychain
 *  @param type      MASAccessValueType enum value for the value key
 */
- (void)setAccessValueCryptoKey:(SecKeyRef)cryptoKey withAccessValueType:(MASAccessValueType)type;



/**
 *  Retrieve SecKeyRef of access value from keychain
 *
 *  Note: for now, this method will only accept the access value type for public and private keys.
 *  MASAccessValueTypePublicKey and MASAccessValueTypePrivateKey.
 *  Other access type value will not be retrieved.
 *
 *  @param type MASAccessValueType enum value for the value key
 *
 *  @return SecKeyRef of the access data by the specified value key
 */
- (SecKeyRef)getAccessValueCryptoKeyWithType:(MASAccessValueType)type;


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




- (NSDate *)extractExpirationDateFromCertificate:(SecCertificateRef)certificate;



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



# pragma mark - Debug only

- (void)clearLocal;

- (void)clearShared;

- (NSString *)debugSecuredDescription;

@end
