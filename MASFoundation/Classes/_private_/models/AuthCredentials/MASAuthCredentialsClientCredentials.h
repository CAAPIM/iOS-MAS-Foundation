//
//  MASAuthCredentialsClientCredentials.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentialsClientCredentials : MASAuthCredentials



/**
 Designated factory method to construct MASAuthCredentials object for client credentials credentials
 
 @return MASAuthCredentialsClientCredentials object that can be used as auth credentials to register or login
 */
+ (MASAuthCredentialsClientCredentials * _Nullable)initClientCredentials;

@end
