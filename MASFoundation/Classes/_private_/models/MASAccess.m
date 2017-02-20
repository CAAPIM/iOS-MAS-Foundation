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


@interface MASAccess ()

@property (nonatomic, strong) NSString *codeVerifier;
@property (nonatomic, strong) NSString *pkceState;

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
    NSString *accessToken = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeAccessToken];
    NSString *tokenType = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeTokenType];
    NSString *refreshToken = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeRefreshToken];
    NSString *idToken = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeIdToken];
    NSString *idTokenType = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeIdTokenType];
    NSNumber *expiresIn = [[MASAccessService sharedService] getAccessValueNumberWithType:MASAccessValueTypeExpiresIn];
    NSString *scopeAsString = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeScope];
    
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
    
    return [NSString stringWithFormat:@"\n\n(%@) \n accessToken : %@ \n tokenType : %@ \n refreshToken : %@ \n idToken : %@ \n idTokenType : %@ \n expiredIn : %@ \n scopes : %@ \n scopeAsInString : %@\n"
            "\n\n*********************\n\n",
            [self class], self.accessToken, self.tokenType, self.refreshToken, self.idToken, self.idTokenType, self.expiresIn, self.scope, self.scopeAsString];
}


- (void)saveToStorage
{
    //DLog(@"\n\ncalled\n\n");
    
    //
    // Save to the keychain
    //
    [[MASAccessService sharedService] setAccessValueString:self.accessToken withAccessValueType:MASAccessValueTypeAccessToken];
    [[MASAccessService sharedService] setAccessValueString:self.tokenType withAccessValueType:MASAccessValueTypeTokenType];
    [[MASAccessService sharedService] setAccessValueString:self.refreshToken withAccessValueType:MASAccessValueTypeRefreshToken];
    [[MASAccessService sharedService] setAccessValueString:self.idToken withAccessValueType:MASAccessValueTypeIdToken];
    [[MASAccessService sharedService] setAccessValueString:self.idTokenType withAccessValueType:MASAccessValueTypeIdTokenType];
    [[MASAccessService sharedService] setAccessValueNumber:self.expiresIn withAccessValueType:MASAccessValueTypeExpiresIn];
    [[MASAccessService sharedService] setAccessValueString:self.scopeAsString withAccessValueType:MASAccessValueTypeScope];
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
    // save access information to keychain
    //
    [self saveToStorage];
}


- (void)refresh
{
    
    _accessToken = nil;
    _accessToken = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeAccessToken];
    
    _tokenType = nil;
    _tokenType = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeTokenType];
    
    _refreshToken = nil;
    _refreshToken = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeRefreshToken];
    
    _idToken = nil;
    _idToken = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeIdToken];
    
    _idTokenType = nil;
    _idTokenType = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeIdTokenType];
    
    _expiresIn = nil;
    _expiresIn = [[MASAccessService sharedService] getAccessValueNumberWithType:MASAccessValueTypeExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    _scopeAsString = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeScope];
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
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeAccessToken];
    
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeAuthenticatedUserObjectId];
    
    [[MASAccessService sharedService] setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeAuthenticatedTimestamp];
    
    _tokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeTokenType];
    
    _refreshToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeRefreshToken];
    
    _idToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeIdToken];
    
    _idTokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeIdTokenType];
    
    _expiresIn = nil;
    [[MASAccessService sharedService] setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeScope];
    
    //
    // Clena up the tokens from Local Authentication protected keychain storage
    //
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeSecuredIdToken];
    [[MASAccessService sharedService] setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeIsDeviceLocked];
}



- (void)deleteForLogOff
{
    
    //
    // remove all data from the keychain
    //
    _accessToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeAccessToken];
    
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeAuthenticatedUserObjectId];
    
    [[MASAccessService sharedService] setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeAuthenticatedTimestamp];
    
    _tokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeTokenType];
    
    _refreshToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeRefreshToken];
    
    _expiresIn = nil;
    [[MASAccessService sharedService] setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeScope];
}


- (void)deleteForTokenExpiration
{
    //
    // remove all data from the keychain
    //
    _accessToken = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeAccessToken];
    
    [[MASAccessService sharedService] setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeAuthenticatedTimestamp];
    
    _tokenType = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeTokenType];

    _expiresIn = nil;
    [[MASAccessService sharedService] setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeExpiresIn];
    
    _scope = nil;
    _scopeAsString = nil;
    [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeScope];
}


///--------------------------------------
/// @name Code Verifier - PKCE support
///--------------------------------------

# pragma mark - Code Verifier - PKCE support

- (void)generateCodeVerifier
{
    _codeVerifier = [NSString randomStringWithLength:43];
}


- (void)deleteCodeVerifier
{
    _codeVerifier = nil;
}


- (NSString *)retrieveCodeVerifier
{
    return _codeVerifier;
}


///--------------------------------------
/// @name PKCE State - PKCE support
///--------------------------------------

# pragma mark - PKCE State - PKCE support

- (void)generatePKCEState
{
    _pkceState = [NSString randomStringWithLength:32];
}


- (void)deletePKCEState
{
    _pkceState = nil;
}


- (NSString *)retrievePKCEState
{
    return _pkceState;
}


# pragma mark - Current Access

+ (MASAccess *)currentAccess
{
    return [MASAccessService sharedService].currentAccessObj;
}


# pragma mark - isSessionLocked

- (BOOL)isSessionLocked
{
    //
    // Obtain key chain items to determine device lock status
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSNumber *isLocked = [accessService getAccessValueNumberWithType:MASAccessValueTypeIsDeviceLocked];
    
    return [isLocked boolValue];
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
    NSNumber *authenticatedTimestamp = [[MASAccessService sharedService] getAccessValueNumberWithType:MASAccessValueTypeAuthenticatedTimestamp];
    double expiresInDateNumber = [authenticatedTimestamp doubleValue] + [_expiresIn doubleValue];
    
    NSDate *expiresInDate = [NSDate dateWithTimeIntervalSince1970:expiresInDateNumber];
    
    return expiresInDate;
}


- (NSDate *)clientCertificateExpirationDate
{
    if (!_clientCertificateExpirationDate)
    {
        NSNumber *clientCertExpTimestamp = [[MASAccessService sharedService] getAccessValueNumberWithType:MASAccessValueTypeSignedPublicCertificateExpirationDate];
        
        if (clientCertExpTimestamp)
        {
            _clientCertificateExpirationDate = [NSDate dateWithTimeIntervalSince1970:[clientCertExpTimestamp doubleValue]];
        }
        else if ([MASDevice currentDevice].isRegistered)
        {
            //
            // Extracting signed client certificate expiration date
            //
            NSArray * cert = [[MASAccessService sharedService] getAccessValueCertificateWithType:MASAccessValueTypeSignedPublicCertificate];
            SecCertificateRef certificate = (__bridge SecCertificateRef)([cert objectAtIndex:0]);
            
            //
            // Store client certificate expiration date into shared keychain storage
            //
            _clientCertificateExpirationDate = [[MASAccessService sharedService] extractExpirationDateFromCertificate:certificate];
            [[MASAccessService sharedService] setAccessValueNumber:[NSNumber numberWithDouble:[_clientCertificateExpirationDate timeIntervalSince1970]]
                                               withAccessValueType:MASAccessValueTypeSignedPublicCertificateExpirationDate];
        }
    }
    
    return _clientCertificateExpirationDate;
}

@end
