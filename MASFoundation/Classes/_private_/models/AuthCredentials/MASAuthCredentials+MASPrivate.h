//
//  MASAuthCredentials+MASPrivate.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentials (MASPrivate)




/**
 Private initialize method for MASAuthCredentials

 @return MASAuthCredentials object for designated auth credentials types
 */
- (instancetype _Nullable)initPrivate;




/**
 Perform device registration with given auth credentials in each individual MASAuthCredentials class

 @param completion MASCompletionErrorBlock to notify the original caller on the result of the device registration
 */
- (void)registerDeviceWithCredential:(MASCompletionErrorBlock _Nullable)completion;




/**
 Perform user authentication with given auth credentials in each individual MASAuthCredentials class

 @param completion MASCompletionErrorBlock to notify the original caller on the result of the user authentication
 */
- (void)loginWithCredential:(MASCompletionErrorBlock _Nullable)completion;

@end
