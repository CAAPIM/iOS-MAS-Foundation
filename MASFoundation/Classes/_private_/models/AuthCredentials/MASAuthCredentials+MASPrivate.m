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

- (instancetype)initPrivate
{
    return [super init];
}


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
    
    
    NSMutableDictionary *headerInfo = [[self getHeaders] mutableCopy];
    NSMutableDictionary *parameterInfo = [[self getParameters] mutableCopy];
    NSString *registerEndpoint = [self getRegisterEndpoint];
    
    //
    //  Prepare common request headers/parameters
    //
    
    // Client Authorization
    if (![headerInfo.allKeys containsObject:MASClientAuthorizationRequestResponseKey])
    {
        NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
       
        if (clientAuthorization)
        {
            headerInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
        }
    }
    
    // DeviceId
    if (![headerInfo.allKeys containsObject:MASDeviceIdRequestResponseKey])
    {
        NSString *deviceId = [MASDevice deviceIdBase64Encoded];
        
        if (deviceId)
        {
            headerInfo[MASDeviceIdRequestResponseKey] = deviceId;
        }
    }
    
    // DeviceName
    if (![headerInfo.allKeys containsObject:MASDeviceNameRequestResponseKey])
    {
        NSString *deviceName = [MASDevice deviceNameBase64Encoded];
        
        if (deviceName)
        {
            headerInfo[MASDeviceNameRequestResponseKey] = deviceName;
        }
    }
    
    if (![headerInfo.allKeys containsObject:MASCreateSessionRequestResponseKey])
    {
        // Create Session
        headerInfo[MASCreateSessionRequestResponseKey] = [MASConfiguration currentConfiguration].ssoEnabled ? @"true" : @"false";
    }
    
    if (![headerInfo.allKeys containsObject:MASCertFormatRequestResponseKey])
    {
        // Certificate Format
        headerInfo[MASCertFormatRequestResponseKey] = @"pem";
    }
    
    
    __block MASAuthCredentials *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    [[MASNetworkingService sharedService] postTo:registerEndpoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
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
    if(![MASApplication currentApplication].isRegistered)
    {
        //
        // Notify
        //
        if(completion) completion(NO, [NSError errorApplicationNotRegistered]);
        
        return;
    }
    
    //
    // The device must be registered else stop here
    //
    if(![MASDevice currentDevice].isRegistered)
    {
        //
        // Notify
        //
        if(completion) completion(NO, [NSError errorDeviceNotRegistered]);
        
        return;
    }
    
    //
    // Post the will register notification
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASUserWillAuthenticateNotification object:self];
    
    NSMutableDictionary *headerInfo = [[self getHeaders] mutableCopy];
    NSMutableDictionary *parameterInfo = [[self getParameters] mutableCopy];
    NSString *tokenEndpoint = [self getTokenEndpoint];
    
    //
    //  Prepare common request headers/parameters
    //
    
    // Client Authorization with 'Authorization' header key
    if (![headerInfo.allKeys containsObject:MASAuthorizationRequestResponseKey])
    {
        NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
        if (clientAuthorization)
        {
            headerInfo[MASAuthorizationRequestResponseKey] = clientAuthorization;
        }
    }
    
    // Scope
    if (![parameterInfo.allKeys containsObject:MASScopeRequestResponseKey])
    {
        NSString *scope = [[MASApplication currentApplication] scopeAsString];
        
        if ([MASAccess currentAccess].requestingScopeAsString)
        {
            if (scope)
            {
                scope = [scope stringByAppendingString:[NSString stringWithFormat:@" %@",[MASAccess currentAccess].requestingScopeAsString]];
                [MASAccess currentAccess].requestingScopeAsString = nil;
            }
            else {
                scope = [scope stringByAppendingString:[MASAccess currentAccess].requestingScopeAsString];
            }
        }
        
        if (scope)
        {
            parameterInfo[MASScopeRequestResponseKey] = scope;
        }
    }
    
    __block MASAuthCredentials *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    [[MASNetworkingService sharedService] postTo:tokenEndpoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
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
                                          NSDictionary *bodayInfo = responseInfo[MASResponseInfoBodyInfoKey];
                                          
                                          if ([bodayInfo objectForKey:MASIdTokenBodyRequestResponseKey] &&
                                              [bodayInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] &&
                                              [[bodayInfo objectForKey:MASIdTokenTypeBodyRequestResponseKey] isEqualToString:MASIdTokenTypeToValidateConstant])
                                          {
                                              NSError *idTokenValidationError = nil;
                                              BOOL isIdTokenValid = [MASAccessService validateIdToken:[bodayInfo objectForKey:MASIdTokenBodyRequestResponseKey]
                                                                                        magIdentifier:[[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier]
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
                                          [[MASAccessService sharedService] setAccessValueString:self.credentialsType withAccessValueType:MASAccessValueTypeCurrentAuthCredentialsGrantType];
                                          
                                          //
                                          // Create a new instance
                                          //
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
                                          
                                          //
                                          // Post the notification
                                          //
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidAuthenticateNotification object:blockSelf];
                                          
                                          //
                                          // Retrieve userinfo unless otherwise authCredentialsType is client credentials
                                          //
                                          if (![self.credentialsType isEqualToString:MASGrantTypeClientCredentials])
                                          {
                                              [[MASModelService sharedService] requestUserInfoWithCompletion:^(MASUser *user, NSError *error) {
                                                  
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
                                              if (blockCompletion)
                                              {
                                                  blockCompletion(YES, nil);
                                              }
                                          }
                                      }];
}


- (NSDictionary *)getHeaders
{
    return nil;
}


- (NSDictionary *)getParameters
{
    return nil;
}


- (NSString *)getRegisterEndpoint
{
    return @"";
}


- (NSString *)getTokenEndpoint
{
    return @"";
}

@end
