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



+ (MASAuthCredentialsAuthorizationCode * _Nullable)initWithAuthorizationCode:(NSString * _Nonnull)authorizationCode;

@end
