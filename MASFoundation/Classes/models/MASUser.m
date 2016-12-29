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
    
    [[MASModelService sharedService] validateCurrentUserAuthenticationWithUsername:userName password:password completion:completion];
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
    
    [[MASModelService sharedService] validateCurrentUserAuthenticationWithAuthorizationCode:authorizationCode completion:completion];
}


- (void)requestUserInfoWithCompletion:(MASUserResponseErrorBlock)completion
{
    [[MASModelService sharedService] requestUserInfoWithCompletion:completion];
}


- (void)logoutWithCompletion:(MASCompletionErrorBlock)completion
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
        if([accessService getAccessValueStringWithType:MASAccessValueTypeIdToken])
        {
            [[MASModelService sharedService] logOutDeviceAndClearLocalAccessToken:YES completion:completion];
        }
        //
        // If the sso is disabled or id_token does not exist, revoke the access_token only
        //
        else {
            [[MASModelService sharedService] logoutWithCompletion:completion];
        }
    }
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
    [super encodeWithCoder:aCoder];
    
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
    //DLog(@"\n\ncalled\n\n");
    
    if(self = [super initWithCoder:aDecoder])
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


@end
