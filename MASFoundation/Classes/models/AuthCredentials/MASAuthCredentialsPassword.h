//
//  MASAuthCredentialsPassword.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentialsPassword : MASAuthCredentials


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 * Credential, password.
 */
@property (nonatomic, copy, readonly, nullable) NSString *username;


/**
 * Credential, password.
 */
@property (nonatomic, copy, readonly, nullable) NSString *password;



/**
 Designated factory method to construct MASAuthCredentials object for password credentials

 @param username NSString of username for credentials
 @param password NSString of password for credentials
 @return MASAuthCredentialsPassword object that can be used as auth credentials to register or login
 */
+ (MASAuthCredentialsPassword * _Nullable)initWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password;

@end
