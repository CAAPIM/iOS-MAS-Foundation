//
//  MASAuthCredentialsPassword.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
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
