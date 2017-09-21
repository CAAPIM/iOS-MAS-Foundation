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



/**
 Prepare all required header values for the registration/authentication request
 
 @return NSDictionary of all required headers
 */
- (NSDictionary * _Nullable)getHeaders;



/**
 Prepare all required parameter values for the registration/authentication request
 
 @return NSDictionary of all required parameters
 */
- (NSDictionary * _Nullable)getParameters;



/**
 Return MAG system endpoint for device registration of current auth credentials type

 @return NSString of MAG system endpoint for device registration
 */
- (NSString * _Nonnull)getRegisterEndpoint;



/**
 Return MAG system endpoint for user authentication of current auth credentials type

 @return NSString of MAG system endpoint for user authentication
 */
- (NSString * _Nonnull)getTokenEndpoint;

@end
