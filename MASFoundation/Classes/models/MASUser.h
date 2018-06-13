//
//  MASUser.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASObject.h"

#import <UIKit/UIKit.h>



/**
 * The `MASUser` class is a local representation of user data.
 */
@interface MASUser : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Boolean indicator of whether the MASUser object is currently authenticated user or not.
 */
@property (nonatomic, assign, readonly) BOOL isCurrentUser;


/**
 *  Boolean indicator of whether the MASUser object is authenticated or not
 */
@property (nonatomic, assign, readonly) BOOL isAuthenticated;


/**
 *  Boolean indicator of whether the currently authenticated MASUser object is locked or not
 */
@property (nonatomic, assign, readonly) BOOL isSessionLocked;


/**
 *  NSString property of username
 */
@property (nonatomic, copy, readonly, nonnull) NSString *userName;


/**
 *  NSString property of the user's family name
 */
@property (nonatomic, copy, readonly, nullable) NSString *familyName;


/**
 *  NSString property of the user's given name
 */
@property (nonatomic, copy, readonly, nullable) NSString *givenName;


/**
 *  NSString property of the user's full name
 */
@property (nonatomic, copy, readonly, nullable) NSString *formattedName;


/**
 *  NSString property of the user's email address
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, NSString *> *emailAddresses;


/**
 *  NSString property of the user's phone number
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, NSString *> *phoneNumbers;


/**
 *  NSString property of the user's address
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, NSString *> *addresses;


/**
 *
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *photos;

/**
 *
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *groups;

/**
 *
 */
@property (nonatomic, assign, readonly) BOOL active;

/**
 *
 */
@property (nonatomic, copy, readonly, nullable) NSString *accessToken;



///--------------------------------------
/// @name Current User
///--------------------------------------

# pragma mark - Current User

/**
 *  The authenticated user for the application, if any. Nil returned if none.
 *  This is a singleton object.
 *
 *  @return Returns a singleton 'MASUser' object.
 */
+ (MASUser *_Nullable)currentUser;



///--------------------------------------
/// @name Current User - Lock/Unlock Session
///--------------------------------------

# pragma mark - Current User - Lock/Unlock Session

/**
 *  Lock currently authenticated user session with device's local authentication (Device's Passcode or Biometric Authentication).
 *
 *  This will lock current user session and block most of operations except for [[MASUser currentUser] logoutWithCompletion:] 
 *  and [[MASDevice currentDevice] deregisterWithCompletion:].
 *  Alternatively, locked user session can be removed by [[MASUser currentUser] removeSessionLock] 
 *  which will remove credentials from protected stroage of the device with local authentication.
 *
 *  After locking user session, [MASUser currentUser] will still exists; 
 *  however, [MASUser currentUser].isAuthenticated property will reflect the lock status and will return false until it's unlocked.
 *  Session lock status can also be checked through [MASUser currentUser].isSessionLocked property.
 *
 *  @param completion The MASCompletionErrorBlock block that receives the results.  
 */
- (void)lockSessionWithCompletion:(MASCompletionErrorBlock _Nullable)completion;



/**
 Unlcok currently locked user session with device's local authentication (Device's Passcode or Biometric Authentication).
 
 This will unlock current user session and unblock all of the operations through SDK.
 
 After unlocking user session, [MASUser currentUser] will reflect correct authentication and lock status.

 @param completion MASCompletionErrorBlock block that receives the results.
 */
- (void)unlockSessionWithCompletion:(MASCompletionErrorBlock _Nullable)completion;



/**
 Unlock currently locked user session with device's local authentication (Device's Passcode or Biometric Authentication) and 
 specified message on system local authentication dialog.
 
 This will unlock current user session and unblock all of the operations through SDK.
 
 After unlocking user session, [MASUser currentUser] will reflect correct authentication and lock status.

 @param userOperationPrompt NSString message that will be displayed on system local authentication dialog.
 @param completion          MASCompletionErrorBlock block that receives the results.
 */
- (void)unlockSessionWithUserOperationPromptMessage:(NSString *_Nonnull)userOperationPrompt completion:(MASCompletionErrorBlock _Nullable)completion;



/**
 Remove user session that had been protected device's local authentication.
 
 This interface can be used when end-user chooses to not provide local authentication and clean up the session.
 */
- (void)removeSessionLock;



//--------------------------------------
/// @name Authentication
///--------------------------------------

# pragma mark - Authentication

/**
 *  Authenticate a user via asynchronous request with basic credentials.
 *
 *  This will create an [MAUser currentUser] upon a successful result.  
 *
 *  @param userName The userName of the user.
 *  @param password The password of the user.
 *  @param completion The MASCompletionErrorBlock block that receives the results.  On a successful completion, the user 
 *  available via [MASUser currentUser] has been updated with the new information.
 */
+ (void)loginWithUserName:(NSString *_Nonnull)userName password:(NSString *_Nonnull)password completion:(MASCompletionErrorBlock _Nullable)completion;



/**
 Authenticate a user via asynchronous request with authorization code.
 
 This will create an [MASUser currentUser] upon a successful result.

 @param authorizationCode The authorization code for the user.
 @param completion        The MASCompletionErrorBlock block that receives the results.  On a successful completion, the user
 *  available via [MASUser currentUser] has been updated with the new information.
 */
+ (void)loginWithAuthorizationCode:(NSString *_Nonnull)authorizationCode completion:(MASCompletionErrorBlock _Nullable)completion;



/**
 Authenticate a user via asynchronous request with id_token
 
 This will create an [MASUser currentUser] upon a successful result.
 
 @param idToken    The id_token for the user.
 @param tokenType   Token type of id_token.
 @param completion The MASCompletionErrorBlock block that receives the results.  On a successful completion, the user
 available via [MASUser currentUser] has been updated with the new information.
 */
+ (void)loginWithIdToken:(NSString *_Nonnull)idToken tokenType:(NSString *_Nonnull)tokenType completion:(MASCompletionErrorBlock _Nullable)completion;




/**
 Authenticate a user via asynchronous request with MASAuthCredentials object.
 This will accept any objects that inherites from MASAuthCredentials and all MASAuthCredentials objects that adheres device registration/user authentication logics
 on backend services.
 
 This will create an [MASUser currentUser] upon a successful result.
 
 @param authCredentials MASAuthCredentials object that contains credentials
 @param completion The MASCompletionErrorBlock block that receives the results.  On a successful completion, the user
 available via [MASUser currentUser] has been updated with the new information.
 */
+ (void)loginWithAuthCredentials:(MASAuthCredentials *_Nonnull)authCredentials completion:(MASCompletionErrorBlock _Nullable)completion;



/**
 Authenticate a user by launching a Browser which in turn loads a URL (templatized).

 @param completion The MASCompletionErrorBlock block that receives the results.  On a successful completion, the user
 available via [MASUser currentUser] has been updated with the new information.
 */
+(void)initializeBrowserBasedAuthenticationWithCompletion:(MASCompletionErrorBlock _Nullable)completion;



/**
 *  Requesting userInfo for the MASUser object.
 *  This method will retrieve additional information on the MASUser object.
 *
 *  @param completion The MASUserResponseErrorBlock block that returns MASUSer object with updated value which is also available through
 *  the current MASUser object that is making this request, and NSError object in case any error is encountered during the process.
 *
 */
- (void)requestUserInfoWithCompletion:(MASUserResponseErrorBlock _Nullable)completion;



/**
 *  Logout an already authenticated user via asynchronous request.
 *
 *  This will return YES upon a successful result.
 *
 *  @param completion The MASCompletionErrorBlock block that receives the results.  On a successful completion, the user 
 *  available via [MASUser currentUser] has been updated with the new information.
 */
- (void)logoutWithCompletion:(MASCompletionErrorBlock _Nullable)completion;


@end
