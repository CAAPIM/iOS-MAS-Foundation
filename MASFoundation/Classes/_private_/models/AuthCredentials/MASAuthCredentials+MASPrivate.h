//
//  MASAuthCredentials+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentials (MASPrivate)

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
