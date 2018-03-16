//
//  MASAuthCredentials+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//
#import "MASAuthCredentials+MASPrivate.h"

#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"

#import "MASConstants.h"

@implementation MASAuthCredentials (MASPrivate)

- (void)registerDeviceWithCredential:(MASCompletionErrorBlock)completion
{
    
    //
    // The application must be registered else stop here
    //
    if (![[MASApplication currentApplication] isRegistered])
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorApplicationNotRegistered]);
        }
        
        return;
    }
    
    //
    // Detect if device is already registered, return success
    //
    if ([MASDevice currentDevice].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(YES, nil);
        }
        
        return;
    }
    
    //
    // Post the will register notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceWillRegisterNotification object:self];
 
    __block MASAuthCredentials *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] postTo:self.registerEndpoint
                                  withParameters:[self getParameters]
                                      andHeaders:[self getHeaders]
                                     requestType:MASRequestResponseTypeTextPlain
                                    responseType:MASRequestResponseTypeTextPlain
                                      completion:^(NSDictionary<NSString *,id> * _Nullable responseInfo, NSError * _Nullable error) {
                                          
                                          //
                                          // Detect if error, if so stop here
                                          //
                                          if(error)
                                          {
                                              //DLog(@"Error detected attempting to request registration of the device: %@",
                                              //    [error localizedDescription]);
                                              
                                              //
                                              // Notify
                                              //
                                              if(blockCompletion)
                                              {
                                                  blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                              }
                                              
                                              //
                                              // Post the notification
                                              //
                                              [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidFailToRegisterNotification object:blockSelf];
                                              
                                              return;
                                          }
                                          
                                          //
                                          // Remove PKCE Code Verifier and state
                                          //
                                          [[MASAccessService sharedService].currentAccessObj deleteCodeVerifier];
                                          [[MASAccessService sharedService].currentAccessObj deletePKCEState];
                                          
                                          //
                                          // Validate id_token when received from server.
                                          //
                                          NSDictionary *headerInfo = responseInfo[MASResponseInfoHeaderInfoKey];
                                          
                                          if ([headerInfo objectForKey:MASIdTokenHeaderRequestResponseKey] &&
                                              [headerInfo objectForKey:MASIdTokenTypeHeaderRequestResponseKey] &&
                                              [[headerInfo objectForKey:MASIdTokenTypeHeaderRequestResponseKey] isEqualToString:MASIdTokenTypeToValidateConstant])
                                          {
                                              NSError *idTokenValidationError = nil;
                                              BOOL isIdTokenValid = [MASAccessService validateIdToken:[headerInfo objectForKey:MASIdTokenHeaderRequestResponseKey]
                                                                                        magIdentifier:[headerInfo objectForKey:MASMagIdentifierRequestResponseKey]
                                                                                                error:&idTokenValidationError];
                                              
                                              if (!isIdTokenValid && idTokenValidationError)
                                              {
                                                  if (blockCompletion)
                                                  {
                                                      blockCompletion(NO, idTokenValidationError);
                                                      
                                                      return;
                                                  }
                                              }
                                          }
                                          
                                          //
                                          // Updated with latest info
                                          //
                                          [[MASDevice currentDevice] saveWithUpdatedInfo:responseInfo];
                                          
                                          //
                                          // re-establish URLSession to trigger URL authentication
                                          //
                                          [[MASNetworkingService sharedService] establishURLSession];
                                          
                                          //
                                          // Post the notification
                                          //
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidRegisterNotification object:blockSelf];
                                          
                                          //
                                          // Notify
                                          //
                                          if (blockCompletion)
                                          {
                                              blockCompletion(YES, nil);
                                          }
                                      }];
}


- (void)loginWithCredential:(MASCompletionErrorBlock)completion
{
    //
    // The application must be registered else stop here
    //
    if (![MASApplication currentApplication].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorApplicationNotRegistered]);
        }
        
        return;
    }
    
    //
    // The device must be registered else stop here
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        //
        // Notify
        //
        if (completion)
        {
            completion(NO, [NSError errorDeviceNotRegistered]);
        }
        
        return;
    }
    
    //
    // Post the will register notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASUserWillAuthenticateNotification object:self];
    
    __block MASAuthCredentials *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    [[MASNetworkingService sharedService] postTo:self.tokenEndpoint
                                  withParameters:[self getParameters]
                                      andHeaders:[self getHeaders]
                                     requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                    responseType:MASRequestResponseTypeJson
                                      completion:^(NSDictionary<NSString *,id> * _Nullable responseInfo, NSError * _Nullable error) {
                                          
                                          //
                                          // Detect if error, if so stop here
                                          //
                                          if(error)
                                          {
                                              //
                                              // Post the notification
                                              //
                                              [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToAuthenticateNotification object:blockSelf];
                                              
                                              //
                                              // Notify
                                              //
                                              if(blockCompletion)
                                              {
                                                  blockCompletion(NO, [NSError errorFromApiResponseInfo:responseInfo andError:error]);
                                              }
                                              
                                              return;
                                          }
                                          
                                          //
                                          // Remove PKCE Code Verifier and state
                                          //
                                          [[MASAccessService sharedService].currentAccessObj deleteCodeVerifier];
                                          [[MASAccessService sharedService].currentAccessObj deletePKCEState];
                                          
                                          //
                                          // Validate id_token when received from server.
                                          //
                                          NSDictionary *bodyInfo = responseInfo[MASResponseInfoBodyInfoKey];
                                          
                                          if ([bodyInfo objectForKey:MASIdTokenBodyRequestResponseKey] &&
                                              [bodyInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] &&
                                              [[bodyInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] isEqualToString:MASIdTokenTypeToValidateConstant])
                                          {
                                              NSError *idTokenValidationError = nil;
                                              BOOL isIdTokenValid = [MASAccessService validateIdToken:[bodyInfo objectForKey:MASIdTokenBodyRequestResponseKey]
                                                                                        magIdentifier:[[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier]
                                                                                                error:&idTokenValidationError];
                                              
                                              if (!isIdTokenValid && idTokenValidationError)
                                              {
                                                  //
                                                  // Post the notification
                                                  //
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidFailToAuthenticateNotification object:blockSelf];
                                                  
                                                  if (blockCompletion)
                                                  {
                                                      blockCompletion(NO, idTokenValidationError);
                                                      
                                                      return;
                                                  }
                                              }
                                          }
                                          
                                          //
                                          // Persist current authCredentials type
                                          //
                                          [[MASAccessService sharedService] setAccessValueString:self.credentialsType storageKey:MASKeychainStorageKeyCurrentAuthCredentialsGrantType];
                                          
                                          //
                                          // Create a new instance of MASUser if not client credentials
                                          //
                                          if ([self.credentialsType isEqualToString:MASGrantTypeClientCredentials])
                                          {
                                              //
                                              // Make sure to clean up current user after client credentials authentication
                                              //
                                              [[MASModelService sharedService] clearCurrentUserForLogout];
                                              
                                              //
                                              // set authenticated timestamp
                                              //
                                              NSNumber *authenticatedTimestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
                                              [[MASAccessService sharedService] setAccessValueNumber:authenticatedTimestamp storageKey:MASKeychainStorageKeyAuthenticatedTimestamp];
                                              
                                              //
                                              //  Store credential information into keychain
                                              //
                                              [[MASAccessService sharedService] saveAccessValuesWithDictionary:bodyInfo forceToOverwrite:NO];
                                          }
                                          else {
                                              if(![MASUser currentUser])
                                              {
                                                  [[MASModelService sharedService] setUserObject:[[MASUser alloc] initWithInfo:responseInfo]];
                                                  
                                              }
                                              
                                              //
                                              // Update the existing user with new information
                                              //
                                              else
                                              {
                                                  [[MASUser currentUser] saveWithUpdatedInfo:responseInfo];
                                              }
                                          }
                                          
                                          [[MASAccessService sharedService].currentAccessObj refresh];
                                          
                                          //
                                          // Retrieve userinfo unless otherwise authCredentialsType is client credentials
                                          //
                                          if (![self.credentialsType isEqualToString:MASGrantTypeClientCredentials])
                                          {
                                              [[MASModelService sharedService] requestUserInfoWithCompletion:^(MASUser *user, NSError *error) {
                                                  
                                                  //
                                                  // Post the notification
                                                  //
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidAuthenticateNotification object:blockSelf];
                                                  
                                                  //
                                                  // Requesting additional userInfo upon successful authentication
                                                  // and do not depend on the result of userInfo call.
                                                  // This a workaround to fix other frameworks' dependency issue on userInfo.
                                                  // James Go @ April 4, 2016
                                                  //
                                                  
                                                  //
                                                  // Notify
                                                  //
                                                  if (blockCompletion)
                                                  {
                                                      blockCompletion(YES, nil);
                                                  }
                                              }];
                                          }
                                          else {
                                              
                                              //
                                              // Post the notification
                                              //
                                              [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidAuthenticateNotification object:blockSelf];
                                              
                                              if (blockCompletion)
                                              {
                                                  blockCompletion(YES, nil);
                                              }
                                          }
                                      }];
}

@end
