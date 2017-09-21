//
//  MASAuthCredentialsClientCredentials.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentialsClientCredentials : MASAuthCredentials



/**
 Designated factory method to construct MASAuthCredentials object for client credentials credentials
 
 @return MASAuthCredentialsClientCredentials object that can be used as auth credentials to register or login
 */
+ (MASAuthCredentialsClientCredentials * _Nullable)initClientCredentials;

@end
