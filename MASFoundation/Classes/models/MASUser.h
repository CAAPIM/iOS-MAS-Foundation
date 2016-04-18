//
//  MASUser.h
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
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
 *
 */
@property (nonatomic, assign, readonly) BOOL isCurrentUser;

/**
 *
 */
@property (nonatomic, assign, readonly) BOOL isAuthenticated;

/**
 *
 */
@property (nonatomic, assign, readonly) BOOL wasLoggedOff;

/**
 *
 */
@property (nonatomic, copy, readonly) NSString *userName;

/**
 *
 */
@property (nonatomic, copy, readonly) NSString *familyName;

/**
 *
 */
@property (nonatomic, copy, readonly) NSString *givenName;

/**
 *
 */
@property (nonatomic, copy, readonly) NSString *formattedName;

/**
 *
 */
@property (nonatomic, copy, readonly) NSDictionary *emailAddresses;

/**
 *
 */
@property (nonatomic, copy, readonly) NSDictionary *phoneNumbers;

/**
 *
 */
@property (nonatomic, copy, readonly) NSDictionary *addresses;

/**
 *
 */
@property (nonatomic, copy, readonly) NSDictionary *photos;

/**
 *
 */
@property (nonatomic, copy, readonly) NSArray *groups;

/**
 *
 */
@property (nonatomic, assign, readonly) BOOL active;

/**
 *
 */
@property (nonatomic, copy, readonly) NSString *accessToken;



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
+ (MASUser *)currentUser;



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
+ (void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(MASCompletionErrorBlock)completion;


/**
 *  Requesting userInfo for the MASUser object.
 *  This method will retrieve additional information on the MASUser object.
 *
 *  @param completion The MASUserResponseErrorBlock block that returns MASUSer object with updated value which is also available through
 *  the current MASUser object that is making this request, and NSError object in case any error is encountered during the process.
 *
 */
- (void)requestUserInfoWithCompletion:(MASUserResponseErrorBlock)completion;


/**
 *  Logoff an already authenticated user via asynchronous request.
 *
 *  This will return YES upon a successful result.
 *
 *  @param completion The MASCompletionErrorBlock block that receives the results.  On a successful completion, the user 
 *  available via [MASUser currentUser] has been updated with the new information.
 */
- (void)logoffWithCompletion:(MASCompletionErrorBlock)completion;


@end
