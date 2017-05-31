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



+ (MASAuthCredentialsPassword * _Nullable)initWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password;

@end
