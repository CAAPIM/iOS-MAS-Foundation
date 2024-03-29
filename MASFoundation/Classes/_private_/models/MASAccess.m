//
//  MASAccess.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAccess.h"

#import "MASAccessService.h"
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"
#import "MASDERCertificate.h"


@interface MASAccess ()
@end


@implementation MASAccess

@synthesize scope = _scope;
@synthesize expiresInDate = _expiresInDate;
@synthesize clientCertificateExpirationDate = _clientCertificateExpirationDate;

# pragma mark - Lifecycle


- (instancetype)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if(self)
    {
        
        [self saveWithUpdatedInfo:info];
    }
    
    return self;
}


- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


+ (MASAccess *)instanceFromStorage
{
    
    //
    // retrieve all values from keychain and initialize with dictionary as those values shouold be read only.
    //
    NSString *accessToken = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyAccessToken];
    NSString *tokenType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyTokenType];
    NSString *refreshToken = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyRefreshToken];
    NSString *idToken = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdToken];
    NSString *idTokenType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdTokenType];
    NSNumber *expiresIn = [[MASAccessService sharedService] getAccessValueNumberWithStorageKey:MASKeychainStorageKeyExpiresIn];
    NSString *scopeAsString = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyScope];
    NSString *authCredentialsType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyCurrentAuthCredentialsGrantType];
    
    NSMutableDictionary *accessDictionary = [NSMutableDictionary dictionary];
    
    if (accessToken)
    {
        [accessDictionary setObject:accessToken forKey:MASAccessTokenRequestResponseKey];
    }
    
    if (tokenType)
    {
        [accessDictionary setObject:tokenType forKey:MASTokenTypeRequestResponseKey];
    }
    
    if (refreshToken)
    {
        [accessDictionary setObject:refreshToken forKey:MASRefreshTokenRequestResponseKey];
    }
    
    if (idToken)
    {
        [accessDictionary setObject:idToken forKey:MASIdTokenHeaderRequestResponseKey];
    }
    
    if (idTokenType)
    {
        [accessDictionary setObject:idTokenType forKey:MASIdTokenTypeHeaderRequestResponseKey];
    }
    
    if (expiresIn)
    {
        [accessDictionary setObject:expiresIn forKey:MASExpiresInRequestResponseKey];
    }
    
    if (scopeAsString)
    {
        [accessDictionary setObject:scopeAsString forKey:MASScopeRequestResponseKey];
    }
    
    if (authCredentialsType)
    {
        [accessDictionary setObject:authCredentialsType forKey:MASGrantTypeRequestResponseKey];
    }
    
    MASAccess *access = [[MASAccess alloc] initWithInfo:accessDictionary];
    
    return access;
}


# pragma mark - Private


- (void)updateWithInfo:(NSDictionary *)info
{
    [self saveWithUpdatedInfo:info];
}


- (NSString *)description
{
    return [self debugDescription];
}


- (NSString *)debugDescription
{
    
    return [NSString stringWithFormat:@"\n\n(%@) \n accessToken : %@ \n tokenType : %@ \n refreshToken : %@ \n idToken : %@ \n idTokenType : %@ \n expiredIn : %@ \n scopes : %@ \n scopeAsInString : %@\n authCredentialsType : %@\n"
            "\n\n*********************\n\n",
            [self class], self.accessToken, self.tokenType, self.refreshToken, self.idToken, self.idTokenType, self.expiresIn, self.scope, self.scopeAsString,
            self.authCredentialsType];
}


- (void)saveToStorage
{
    //DLog(@"\n\ncalled\n\n");
    
    //
    // Save to the keychain
    //
    [[MASAccessService sharedService] setAccessValueString:self.accessToken storageKey:MASKeychainStorageKeyAccessToken];
    [[MASAccessService sharedService] setAccessValueString:self.tokenType storageKey:MASKeychainStorageKeyTokenType];
    [[MASAccessService sharedService] setAccessValueString:self.refreshToken storageKey:MASKeychainStorageKeyRefreshToken];
    [[MASAccessService sharedService] setAccessValueString:self.idToken storageKey:MASKeychainStorageKeyIdToken];
    [[MASAccessService sharedService] setAccessValueString:self.idTokenType storageKey:MASKeychainStorageKeyIdTokenType];
    [[MASAccessService sharedService] setAccessValueNumber:self.expiresIn storageKey:MASKeychainStorageKeyExpiresIn];
    [[MASAccessService sharedService] setAccessValueString:self.scopeAsString storageKey:MASKeychainStorageKeyScope];
    [[MASAccessService sharedService] setAccessValueString:self.authCredentialsType storageKey:MASKeychainStorageKeyCurrentAuthCredentialsGrantType];
}


- (void)saveWithUpdatedInfo:(NSDictionary *)info
{
    
    NSParameterAssert(info);
    //DLog(@"\n\ncalled with info from %@: %@\n\n", info, NSStringFromClass(self.class));
    
    //
    // access_token
    //
    NSString *accessToken = info[MASAccessTokenRequestResponseKey];
    if (accessToken)
    {
        _accessToken = accessToken;
    }
    
    //
    // token_type
    //
    NSString *tokenType = info[MASTokenTypeRequestResponseKey];
    if (tokenType)
    {
        _tokenType = tokenType;
    }
    
    //
    // refresh_token
    //
    NSString *refreshToken = info[MASRefreshTokenRequestResponseKey];
    if (refreshToken)
    {
        _refreshToken = refreshToken;
    }
    //
    // if the access_token exsists, but not refresh_token, nullify refresh_token
    //
    else if (!refreshToken && accessToken) {
        _refreshToken = nil;
    }
    
    //
    // id_token - header
    //
    NSString *idToken = info[MASIdTokenHeaderRequestResponseKey];
    if (idToken)
    {
        _idToken = idToken;
    }
    //
    // id_token - if id_token exists in body
    //
    else if (info[MASIdTokenBodyRequestResponseKey])
    {
        NSString *idTokenBody = info[MASIdTokenBodyRequestResponseKey];
        
        if (idTokenBody)
        {
            _idToken = idTokenBody;
        }
    }
    
    //
    // id_token_type - header
    //
    NSString *idTokenType = info[MASIdTokenTypeHeaderRequestResponseKey];
    if (idTokenType)
    {
        _idTokenType = idTokenType;
    }
    //
    // id_token_type - if id_token_type exists in body
    //
    else if (info[MASIdTokenTypeBodyRequestResponseKey])
    {
        NSString *idTokenTypeBody = info[MASIdTokenTypeBodyRequestResponseKey];
        
        if (idTokenTypeBody)
        {
            _idTokenType = idTokenTypeBody;
        }
    }
    
    //
    // expires_in
    //
    NSNumber *expiresIn = info[MASExpiresInRequestResponseKey];
    if (expiresIn)
    {
        _expiresIn = expiresIn;
    }
    
    //
    // scope
    //
    NSString *scopeAsString = info[MASScopeRequestResponseKey];
    if (scopeAsString)
    {
        _scopeAsString = scopeAsString;
    }
    
    //
    // authCredentialsType
    //
    NSString *authCredentialsType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyCurrentAuthCredentialsGrantType];
    if (authCredentialsType)
    {
        _authCredentialsType = authCredentialsType;
    }
    
    //
    // save access information to keychain
    //
    [self saveToStorage];
}


- (void)refresh
{
    _accessToken = nil;
    _accessToken = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyAccessToken];
    
    _tokenType = nil;
    _tokenType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyTokenType];
    
    _refreshToken = nil;
    _refreshToken = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyRefreshToken];
    
    _idToken = nil;
    _idToken = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdToken];
    
    _idTokenType = nil;
    _idTokenType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdTokenType];
    
    _expiresIn = nil;
    _expiresIn = [[MASAccessService sharedService] getAccessValueNumberWithStorageKey:MASKeychainStorageKeyExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    _scopeAsString = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyScope];
    
    _authCredentialsType = nil;
    _authCredentialsType = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyCurrentAuthCredentialsGrantType];
}



- (void)reset
{
    
    //
    // remove all data from the keychain
    //
    _accessToken = nil;
    
    _tokenType = nil;
    
    _refreshToken = nil;
    
    _idToken = nil;
    
    _idTokenType = nil;
    
    _expiresIn = nil;
    
    _scope = nil;
    _scopeAsString = nil;
}


- (void)deleteAll
{
    
    //
    // remove all data from the keychain
    //
    _accessToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyAccessToken];
    
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyAuthenticatedUserObjectId];
    
    [[MASAccessService sharedService] setAccessValueNumber:nil storageKey:MASKeychainStorageKeyAuthenticatedTimestamp];
    
    _tokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyTokenType];
    
    _refreshToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyRefreshToken];
    
    _idToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdToken];
    
    _idTokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyIdTokenType];
    
    _expiresIn = nil;
    [[MASAccessService sharedService] setAccessValueNumber:nil storageKey:MASKeychainStorageKeyExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyScope];
    
    //
    // Clena up the tokens from Local Authentication protected keychain storage
    //
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeySecuredIdToken];
    [[MASAccessService sharedService] setAccessValueNumber:nil storageKey:MASKeychainStorageKeyIsDeviceLocked];
}


- (void)deleteForLogOff
{
    
    //
    // remove all data from the keychain
    //
    _accessToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyAccessToken];
    
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyAuthenticatedUserObjectId];
    
    [[MASAccessService sharedService] setAccessValueNumber:nil storageKey:MASKeychainStorageKeyAuthenticatedTimestamp];
    
    _tokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyTokenType];
    
    _refreshToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyRefreshToken];
    
    _expiresIn = nil;
    [[MASAccessService sharedService] setAccessValueNumber:nil storageKey:MASKeychainStorageKeyExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyScope];
}


- (void)deleteForTokenExpiration
{
    //
    // remove all data from the keychain
    //
    _accessToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyAccessToken];
    
    [[MASAccessService sharedService] setAccessValueNumber:nil storageKey:MASKeychainStorageKeyAuthenticatedTimestamp];
    
    _tokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyTokenType];

    _expiresIn = nil;
    [[MASAccessService sharedService] setAccessValueNumber:nil storageKey:MASKeychainStorageKeyExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyScope];
}


///--------------------------------------
/// @name Code Verifier - PKCE support
///--------------------------------------

# pragma mark - Code Verifier - PKCE support

- (void)generateCodeVerifier
{
    if ([MASAccessService isPKCEEnabled])
    {
        [[MASAccessService sharedService] setAccessValueString:
            [NSString randomStringWithLength:43] storageKey:MASKeychainStorageKeyCodeVerifier];
    }
}


- (void)deleteCodeVerifier
{
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyCodeVerifier];
}


- (NSString *)retrieveCodeVerifier
{
    return [MASAccessService isPKCEEnabled] ?
        [[MASAccessService sharedService]getAccessValueStringWithStorageKey:MASKeychainStorageKeyCodeVerifier] : nil;
}


///--------------------------------------
/// @name PKCE State - PKCE support
///--------------------------------------

# pragma mark - PKCE State - PKCE support

- (void)generatePKCEState
{
    if ([MASAccessService isPKCEEnabled])
    {
        [[MASAccessService sharedService] setAccessValueString:
            [NSString randomStringWithLength:43] storageKey:MASKeychainStorageKeyPKCEState];
    }
}


- (void)deletePKCEState
{
    [[MASAccessService sharedService] setAccessValueString:nil storageKey:MASKeychainStorageKeyPKCEState];
}


- (NSString *)retrievePKCEState
{
    return [MASAccessService isPKCEEnabled] ?
        [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyPKCEState] : nil;
}


# pragma mark - Current Access

+ (MASAccess *)currentAccess
{
    return [MASAccessService sharedService].currentAccessObj;
}


# pragma mark - isSessionLocked

- (BOOL)isSessionLocked
{
    return [[MASAccessService sharedService] isSessionLocked];
}


# pragma mark - isAccessTokenValid

- (BOOL)isAccessTokenValid
{
    
    BOOL isValid = YES;
    
    NSString *accessToken = self.accessToken;
    NSNumber *expiresIn = self.expiresIn;
    NSDate *expiresInDate = self.expiresInDate;
    
    if (!accessToken || !expiresIn || !expiresInDate)
    {
        isValid = NO;
    }
    
    if (expiresIn && ([expiresInDate timeIntervalSinceNow] <= 0))
    {
        isValid = NO;
        [self deleteForTokenExpiration];
    }
    
    return isValid;
}

#pragma mark - scope

- (NSSet *)scope
{
    
    //
    // explode scope into array
    //
    if(self.scopeAsString && _scope == nil)
    {
        //
        // explode scope into array
        //
        NSArray *scopeInArray = [self.scopeAsString componentsSeparatedByString:@" "];
        NSMutableArray *validScopes = [NSMutableArray array];
        
        for (NSString *eachScope in scopeInArray)
        {
            //
            // check if the scope string is empty
            //
            if (![eachScope isEmpty])
            {
                [validScopes addObject:eachScope];
            }
        }
        
        //
        // making sure the scopes are not empty
        //
        if([validScopes count] > 0)
        {
            _scope = [[NSSet alloc] initWithArray:validScopes];
        }
    }
    
    return _scope;
}


#pragma mark - expiresInDate

- (NSDate *)expiresInDate
{
    
    //
    // check if expiresIn value exists
    //
    if(!_expiresIn)
    {
        return nil;
    }
    
    // Authentication timestamp
    NSNumber *authenticatedTimestamp = [[MASAccessService sharedService] getAccessValueNumberWithStorageKey:MASKeychainStorageKeyAuthenticatedTimestamp];
    double expiresInDateNumber = [authenticatedTimestamp doubleValue] + [_expiresIn doubleValue];
    
    NSDate *expiresInDate = [NSDate dateWithTimeIntervalSince1970:expiresInDateNumber];
    
    return expiresInDate;
}


- (NSDate *)clientCertificateExpirationDate
{
    if (!_clientCertificateExpirationDate)
    {
        NSNumber *clientCertExpTimestamp = [[MASAccessService sharedService] getAccessValueNumberWithStorageKey:MASKeychainStorageKeyPublicCertificateExpirationDate];
        
        if (clientCertExpTimestamp)
        {
            _clientCertificateExpirationDate = [NSDate dateWithTimeIntervalSince1970:[clientCertExpTimestamp doubleValue]];
        }
        else if ([MASDevice currentDevice].isRegistered)
        {
            
            NSData *certificateAsPEM = [[MASAccessService sharedService] getAccessValueDataWithStorageKey:MASKeychainStorageKeyPublicCertificateData];
            NSString *certificateAsString = [[NSString alloc] initWithData:certificateAsPEM encoding:NSUTF8StringEncoding];
            
            certificateAsString = [certificateAsString stringByReplacingOccurrencesOfString:MASDefaultNewline withString:@""];
            certificateAsString = [certificateAsString stringByReplacingOccurrencesOfString:MASCertificateBeginPrefix withString:@""];
            certificateAsString = [certificateAsString stringByReplacingOccurrencesOfString:MASCertificateEndSuffix withString:@""];
            
            //
            //  Convert string certificate to NSData
            //
            NSData *certDataAsDER = [[NSData alloc] initWithBase64EncodedString:certificateAsString options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            //
            //  Parse certificate Data with ASN.1 parser
            //
            MASDERCertificate *certificateObject = [[MASDERCertificate alloc] initWithDERCertificateData:certDataAsDER];
            [certificateObject parseCertificateData];
            
            if (certificateObject.notAfter != nil)
            {
                _clientCertificateExpirationDate = certificateObject.notAfter;
                
            }
        }
    }
    
    return _clientCertificateExpirationDate;
}

@end
