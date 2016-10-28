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


@implementation MASUser


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
        [accessService removeSessionLock];
        [[MASModelService sharedService] clearCurrentUserForLogout];
        
        //
        // Set id_token and id_token_type to nil
        //
        [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeIdToken];
        [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeIdTokenType];
        
        [[MASAccessService sharedService].currentAccessObj refresh];
        
        if (completion)
        {
            completion(YES, nil);
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
        // Detect if there is id_token, and sso is enabled
        //
        if([accessService getAccessValueStringWithType:MASAccessValueTypeIdToken] && [MASConfiguration currentConfiguration].ssoEnabled)
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

@end
