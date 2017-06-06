//
//  MASAuthCredentialsAuthorizationCode.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentialsAuthorizationCode : MASAuthCredentials


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 * Credential, authorization code.
 */
@property (nonatomic, copy, readonly, nullable) NSString *authorizationCode;




/**
 Designated factory method to construct MASAuthCredentials object for authorization code credentials

 @param authorizationCode NSString of authorization code for credentials
 @return MASAuthCredentialsAuthorizationCode object that can be used as auth credentials to register or login
 */
+ (MASAuthCredentialsAuthorizationCode * _Nullable)initWithAuthorizationCode:(NSString * _Nonnull)authorizationCode;

@end
