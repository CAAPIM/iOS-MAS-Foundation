//
//  MASAccess.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

/**
 * The `MASAccess` class is a representation of set of MSSO authentication information.
 */

@interface MASAccess : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

//PR: Please address format in all the code. Line Spaces, Properties, etc. --lsanches
//PR: Please move all unecessary properties to the implementation class inside a class extension to make it more clean and secure --lsanches
//PR: Please use instanceType instead of id in those methods that return the instance of the class --lsanches


# pragma mark - Properties


/**
 * The MASAccess accessToken.
 */
@property (nonatomic, copy, readonly) NSString *accessToken;


/**
 * The MASAccess token type.
 */
@property (nonatomic, copy, readonly) NSString *tokenType;


/**
 * The MASAccess refresh token.
 */
@property (nonatomic, copy, readonly) NSString *refreshToken;


/**
 * The MASAccess id_token.
 */
@property (nonatomic, copy, readonly) NSString *idToken;


/**
 * The MASAccess id token type.
 */
@property (nonatomic, copy, readonly) NSString *idTokenType;


/**
 * The MASAccess expires time in integer.
 */
@property (nonatomic, copy, readonly) NSNumber *expiresIn;


/**
 * The MASAccess expires time in NSDate
 */
@property (nonatomic, copy, readonly) NSDate *expiresInDate;


/**
 * The MASAccess scope as set.
 */
@property (nonatomic, copy, readonly) NSSet *scope;


/**
 * The MASAccess scope as a space seperated string.
 */
@property (nonatomic, copy, readonly) NSString *scopeAsString;


/**
 *  The MASAccess injected requesting scope for new access token.
 */
@property (nonatomic, copy, readwrite) NSString *requestingScopeAsString;


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle



/**
 * Initializer to perform a default initialization.
 *
 * @param info An NSDictionary containing newly provided information.
 *
 * @return Returns the newly initialized MASAccess.
 */
- (id)initWithInfo:(NSDictionary *)info;



/**
 * Retrieves the instance of MASAccess from local storage, if it exists.
 *
 * @return Returns the newly initialized MASAccess or nil if none was stored.
 */
+ (MASAccess *)instanceFromStorage;



# pragma mark - Private



/**
 * Reset all traces of the current access token info.
 */
- (void)reset;



/**
 * Remove all traces of the current access token info.
 */
- (void)deleteAll;



/**
 *  Remove only user associated access information (access token, refresh token, expiration date) for user log out
 */
- (void)deleteForLogOff;


/**
 *  Remove only user associated access information (access token, and expiration date) for token expiration
 */
- (void)deleteForTokenExpiration;



/**
 * Refresh all values from the keychain 
 */
- (void)refresh;



/**
 *  Update MASAccess object information with NSDictionary
 *
 *  @param info NSDictionary of access information
 */
- (void)updateWithInfo:(NSDictionary *)info;



///--------------------------------------
/// @name Current Access
///--------------------------------------

# pragma mark - Current Access



/**
 *  The access token object for the application, if any. Nil returned if none.
 *  This is a singleton object.
 *
 *  @return Returns a singleton 'MASAccess' object.
 */
+ (MASAccess *)currentAccess;


@end
