//
//  MASUser.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASUser.h"

#import "MASAccessService.h"
#import "MASConstantsPrivate.h"
#import "MASModelService.h"

# pragma mark - Property Constants

static NSString *const MASUserObjectIdPropertyKey = @"objectId"; // string
static NSString *const MASUserUserNamePropertyKey = @"userName"; // string
static NSString *const MASUserFamilyNamePropertyKey = @"familyName"; // string
static NSString *const MASUserGivenNamePropertyKey = @"givenName"; // string
static NSString *const MASUserFormattedNamePropertyKey = @"formattedName"; // string
static NSString *const MASUserEmailAddressesPropertyKey = @"emailAddresses"; // string
static NSString *const MASUserPhoneNumbersPropertyKey = @"phoneNumbers"; // string
static NSString *const MASUserAddressesPropertyKey = @"addresses"; // string
static NSString *const MASUserPhotosPropertyKey = @"photos"; // string
static NSString *const MASUserGroupsPropertyKey = @"groups"; // string
static NSString *const MASUserActivePropertyKey = @"active"; // bool
static NSString *const MASUserAttributesPropertyKey = @"attributes";

@implementation MASUser
@synthesize accessToken = _accessToken;

# pragma mark - Current User

+ (MASUser *)currentUser
{
    return [MASModelService sharedService].currentUser;
}


# pragma mark - Current User - Lock/Unlock Session

- (void)lockSessionWithCompletion:(MASCompletionErrorBlock)completion
{
    NSError *error = nil;
    BOOL success = [[MASAccessService sharedService] lockSession:&error];
    
    completion(success, error);
}


- (void)unlockSessionWithCompletion:(MASCompletionErrorBlock)completion
{
    NSError *error = nil;
    
    BOOL success = [[MASAccessService sharedService] unlockSessionWithUserOperationPromptMessage:nil error:&error];
    
    completion(success, error);
}


- (void)unlockSessionWithUserOperationPromptMessage:(NSString *)userOperationPrompt completion:(MASCompletionErrorBlock)completion
{
    NSError *error = nil;
    BOOL success = [[MASAccessService sharedService] unlockSessionWithUserOperationPromptMessage:userOperationPrompt error:&error];
    
    completion(success, error);
}


- (void)removeSessionLock
{
    //
    //  Clearing currentUser like logging off as id_token and other credentials will be removed
    //
    [[MASModelService sharedService] clearCurrentUserForLogout];
    [[MASAccessService sharedService] removeSessionLock];
}


# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) is current user: %@, is authenticated: %@\n\n, is session locked: %@\n\n"
        "        and objectId: %@\n        user name: %@\n        family name: %@\n"
        "        given name: %@\n        formatted name: %@\n        active: %@\n        email addresses: %@\n"
        "        phone numbers: %@\n        addresses: %@\n        photos: %@\n        groups: %@",
        [self class], ([self isCurrentUser] ? @"Yes" : @"No"), ([self isAuthenticated] ? @"Yes" : @"No"), ([self isSessionLocked] ? @"Yes" : @"No"),
        [self objectId], [self userName], [self familyName],
        [self givenName], [self formattedName], ([self active] ? @"Yes" : @"No"), [self emailAddresses],
        [self phoneNumbers], [self addresses], [self photos], [self groups]];
}


# pragma mark - Properties

- (NSString *)accessToken
{
    _accessToken = [MASAccessService sharedService].currentAccessObj.accessToken;
    
    if (_accessToken) {
        
        return _accessToken;
    }
    else {
        
        return nil;
    }
}


- (BOOL)isCurrentUser
{
    //
    // Get currently authenticated user's object id to make sure that isCurrentUser flag can be determined properly for other users
    //
    NSString *currentlyAuthenticatedUserObjectId = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyAuthenticatedUserObjectId];
    
    return [self.objectId isEqualToString:currentlyAuthenticatedUserObjectId];
}


// Special case which is determined by other fields
- (BOOL)isAuthenticated
{
    //
    // Get currently authenticated user's object id to make sure that isAuthenticated flag can be determined properly for other users
    //
    NSString *currentlyAuthenticatedUserObjectId = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyAuthenticatedUserObjectId];
    
    //
    // if the user status is not MASUserStatusNotLoggedIn,
    // the user is authenticated either anonymously or with username and password
    //
    return ([MASApplication currentApplication].authenticationStatus == MASAuthenticationStatusLoginWithUser && [self.objectId isEqualToString:currentlyAuthenticatedUserObjectId]);
}


- (BOOL)isSessionLocked
{
    //
    // Get currently authenticated user's object id to make sure that isAuthenticated flag can be determined properly for other users
    //
    NSString *currentlyAuthenticatedUserObjectId = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyAuthenticatedUserObjectId];
    
    if ([self.objectId isEqualToString:currentlyAuthenticatedUserObjectId])
    {
        return [MASAccess currentAccess].isSessionLocked;
    }
    else {
        return NO;
    }
}


# pragma mark - Login & Logoff

+ (void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(MASCompletionErrorBlock)completion
{
    //
    //  If the user session has already been authenticated, throw an error.
    //
    if ([MASUser currentUser] && [MASUser currentUser].isAuthenticated)
    {
        if(completion) completion(NO, [NSError errorUserAlreadyAuthenticated]);
        
        return;
    }
    
    MASAuthCredentialsPassword *authCredentials = [MASAuthCredentialsPassword initWithUsername:userName password:password];
    [[MASModelService sharedService] validateCurrentUserSessionWithAuthCredentials:authCredentials completion:completion];
}


+ (void)loginWithAuthorizationCode:(NSString *)authorizationCode completion:(MASCompletionErrorBlock)completion
{
    //
    //  If the user session has already been authenticated, throw an error.
    //
    if ([MASUser currentUser] && [MASUser currentUser].isAuthenticated)
    {
        if(completion) completion(NO, [NSError errorUserAlreadyAuthenticated]);
        
        return;
    }
    
    MASAuthCredentialsAuthorizationCode *authCredentials = [MASAuthCredentialsAuthorizationCode initWithAuthorizationCode:authorizationCode];
    [[MASModelService sharedService] validateCurrentUserSessionWithAuthCredentials:authCredentials completion:completion];
}


+ (void)loginWithIdToken:(NSString *_Nonnull)idToken tokenType:(NSString *_Nonnull)tokenType completion:(MASCompletionErrorBlock _Nullable)completion
{
    //
    //  If the user session has already been authenticated, throw an error.
    //
    if ([MASUser currentUser] && [MASUser currentUser].isAuthenticated)
    {
        if(completion) completion(NO, [NSError errorUserAlreadyAuthenticated]);
        
        return;
    }
    
    MASAuthCredentialsJWT *authCredentials = [MASAuthCredentialsJWT initWithJWT:idToken tokenType:tokenType];
    [[MASModelService sharedService] validateCurrentUserSessionWithAuthCredentials:authCredentials completion:completion];
}


+ (void)loginWithAuthCredentials:(MASAuthCredentials *_Nonnull)authCredentials completion:(MASCompletionErrorBlock _Nullable)completion
{
    //
    //  If the user session has already been authenticated, throw an error.
    //
    if ([MASUser currentUser] && [MASUser currentUser].isAuthenticated)
    {
        if(completion) completion(NO, [NSError errorUserAlreadyAuthenticated]);
        
        return;
    }
    
    [[MASModelService sharedService] validateCurrentUserSessionWithAuthCredentials:authCredentials completion:completion];
}


+(void)initializeBrowserBasedAuthenticationWithCompletion:(MASCompletionErrorBlock _Nullable)completion
{
    if(![MASModelService browserBasedAuthentication])
    {
        if(completion) completion(NO, [NSError errorBrowserBasedAuthenticaionNotEnabled]);
        return;
    }
    
    if ([MASUser currentUser] && [MASUser currentUser].isAuthenticated)
    {
        if(completion) completion(NO, [NSError errorUserAlreadyAuthenticated]);
        
        return;
    }
    
    [[MASModelService sharedService] validateCurrentUserSession:completion];
}

- (void)requestUserInfoWithCompletion:(MASUserResponseErrorBlock)completion
{
    [[MASModelService sharedService] requestUserInfoWithCompletion:completion];
}


- (void)logout:(BOOL)force completion:(MASCompletionErrorBlock)completion
{
    
    MASAccessService *accessService = [MASAccessService sharedService];
    
    if (self.isSessionLocked)
    {
        //
        // If the current session is locked, return an error
        //
        if (completion)
        {
            completion(NO, [NSError errorUserSessionIsCurrentlyLocked]);
        }
        
        return;
    }
    else if (!self.isAuthenticated)
    {
        if (completion)
        {
            completion(NO, [NSError errorUserNotAuthenticated]);
        }
        
        return;
    }
    else {
     
        //
        // Detect if there is id_token
        //
        if ([accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyIdToken])
        {
            [[MASModelService sharedService] logoutDevice:force completion:completion];
        }
        //
        // If the sso is disabled or id_token does not exist, revoke the access_token only
        //
        else {
            [[MASModelService sharedService] logout:force completion:completion];
        }
    }
}

# pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASUser *user = [[MASUser alloc] init];
    
    [user setValue:self.objectId forKey:@"objectId"];
    [user setValue:self.userName forKey:@"userName"];
    [user setValue:self.familyName forKey:@"familyName"];
    [user setValue:self.givenName forKey:@"givenName"];
    [user setValue:self.formattedName forKey:@"formattedName"];
    [user setValue:self.emailAddresses forKey:@"emailAddresses"];
    [user setValue:self.phoneNumbers forKey:@"phoneNumbers"];
    [user setValue:self.addresses forKey:@"addresses"];
    [user setValue:self.groups forKey:@"groups"];
    [user setValue:[NSNumber numberWithBool:self.active] forKey:@"active"];
    [user setValue:self.photos forKey:@"photos"];
    
    return user;
}

# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder]; //ObjectID is encoded in the super class MASObject
    
    if(self.userName) [aCoder encodeObject:self.userName forKey:MASUserUserNamePropertyKey];
    if(self.familyName) [aCoder encodeObject:self.familyName forKey:MASUserFamilyNamePropertyKey];
    if(self.givenName) [aCoder encodeObject:self.givenName forKey:MASUserGivenNamePropertyKey];
    if(self.formattedName) [aCoder encodeObject:self.formattedName forKey:MASUserFormattedNamePropertyKey];
    if(self.emailAddresses) [aCoder encodeObject:self.emailAddresses forKey:MASUserEmailAddressesPropertyKey];
    if(self.phoneNumbers) [aCoder encodeObject:self.phoneNumbers forKey:MASUserPhoneNumbersPropertyKey];
    if(self.addresses) [aCoder encodeObject:self.addresses forKey:MASUserAddressesPropertyKey];
    if(self.photos) [aCoder encodeObject:self.photos forKey:MASUserPhotosPropertyKey];
    if(self.groups) [aCoder encodeObject:self.groups forKey:MASUserGroupsPropertyKey];
    if(self.active) [aCoder encodeBool:self.active forKey:MASUserActivePropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) //ObjectID is decoded in the super class MASObject
        
    {
        [self setValue:[aDecoder decodeObjectForKey:MASUserUserNamePropertyKey] forKey:@"userName"];
        [self setValue:[aDecoder decodeObjectForKey:MASUserFamilyNamePropertyKey] forKey:@"familyName"];
        [self setValue:[aDecoder decodeObjectForKey:MASUserGivenNamePropertyKey] forKey:@"givenName"];
        [self setValue:[aDecoder decodeObjectForKey:MASUserFormattedNamePropertyKey] forKey:@"formattedName"];
        
        [self setValue:[aDecoder decodeObjectForKey:MASUserPhotosPropertyKey] forKey:@"photos"];
        [self setValue:[aDecoder decodeObjectForKey:MASUserEmailAddressesPropertyKey] forKey:@"emailAddresses"];
        [self setValue:[aDecoder decodeObjectForKey:MASUserPhoneNumbersPropertyKey] forKey:@"phoneNumbers"];
        [self setValue:[aDecoder decodeObjectForKey:MASUserAddressesPropertyKey] forKey:@"addresses"];
        
        [self setValue:[aDecoder decodeObjectForKey:MASUserGroupsPropertyKey] forKey:@"groups"];
        [self setValue:[NSNumber numberWithBool:[aDecoder decodeBoolForKey:MASUserActivePropertyKey]] forKey:@"active"];
    }
    
    return self;
}


# pragma mark - Deprecated

- (void)logoutWithCompletion:(MASCompletionErrorBlock)completion
{
    [self logout:NO completion:completion];
}


@end
