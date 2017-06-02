//
//  MASAuthCredentialsClientCredentials.m
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentialsClientCredentials.h"

#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"

#import "MASConstants.h"
#import "MASDevice.h"

@implementation MASAuthCredentialsClientCredentials

@synthesize credentialsType = _credentialsType;
@synthesize canRegisterDevice = _canRegisterDevice;
@synthesize isReuseable = _isReuseable;


# pragma mark - LifeCycle

+ (MASAuthCredentialsClientCredentials *)initClientCredentials
{
    MASAuthCredentialsClientCredentials *authCredentials = [[self alloc] initPrivate];
    
    return authCredentials;
}


- (instancetype)initPrivate
{
    self = [super initPrivate];
    
    if(self) {
        _credentialsType = MASAuthCredentialsTypeClientCredential;
        _canRegisterDevice = YES;
        _isReuseable = YES;
    }
    
    return self;
}


# pragma mark - Private

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
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].deviceRegisterClientEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    // Client Authorization
    NSString *clientAuthorization = [[MASApplication currentApplication] clientAuthorizationBasicHeaderValue];
    if(clientAuthorization) headerInfo[MASClientAuthorizationRequestResponseKey] = clientAuthorization;
    
    // DeviceId
    NSString *deviceId = [MASDevice deviceIdBase64Encoded];
    if(deviceId) headerInfo[MASDeviceIdRequestResponseKey] = deviceId;
    
    // DeviceName
    NSString *deviceName = [MASDevice deviceNameBase64Encoded];
    if(deviceName) headerInfo[MASDeviceNameRequestResponseKey] = deviceName;
    
    // Certificate Format
    headerInfo[MASCertFormatRequestResponseKey] = @"pem";
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // Certificate Signing Request
    MASSecurityService *securityService = [MASSecurityService sharedService];
    [securityService deleteAsymmetricKeys];
    [securityService generateKeypair];
    
    NSString *certificateSigningRequest = [securityService generateCSRWithUsername:@"clientName"];
    if(certificateSigningRequest) parameterInfo[MASCertificateSigningRequestResponseKey] = certificateSigningRequest;
    
    //
    // Trigger the request
    //
    __block MASAuthCredentialsClientCredentials *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    [[MASNetworkingService sharedService] postTo:endPoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
                                     requestType:MASRequestResponseTypeTextPlain
                                    responseType:MASRequestResponseTypeTextPlain
                                      completion:^(NSDictionary *responseInfo, NSError *error)
     {
         //
         // Detect if error, if so stop here
         //
         if (error)
         {
             //DLog(@"Error detected attempting to request registration of the device: %@",
             //[error localizedDescription]);
             
             //
             // Notify
             //
             if (blockCompletion)
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
         // Updated with latest info
         //
         [[MASDevice currentDevice] saveWithUpdatedInfo:responseInfo];
         
         //
         // re-establish URLSession to trigger URL authentication
         //
         [[MASNetworkingService sharedService] establishURLSession];
         
         //
         // Post the did register notification
         //
         [[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidRegisterNotification object:blockSelf];
         
         //
         // Error
         //
         if (error)
         {
             //
             // Notify
             //
             if (blockCompletion)
             {
                 blockCompletion(NO, error);
             }
             
             return;
         }
         
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
    // The device must be registered else stop here
    //
    if (![[MASDevice currentDevice] isRegistered])
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
    // The current user must NOT be authenticated else stop here
    //
    if ([MASApplication currentApplication].isAuthenticated)
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
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].tokenEndpointPath;
    
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    // MAG Identifier
    NSString *magIdentifier = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier];
    if(magIdentifier) headerInfo[MASMagIdentifierRequestResponseKey] = magIdentifier;
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // ClientId
    NSString *clientId = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientId];
    if (clientId)
    {
        parameterInfo[MASClientIdentifierRequestResponseKey] = clientId;
    }
    
    // ClientSecret
    NSString *clientSecret = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientSecret];
    if (clientSecret)
    {
        parameterInfo[MASClientSecretRequestResponseKey] = clientSecret;
    }
    
    // Scope
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
    
    // Grant Type
    parameterInfo[MASGrantTypeRequestResponseKey] = MASGrantTypeClientCredentials;
    
    //
    // Trigger the request
    //
    // Note that security credentials are added automatically by this method
    //
    __block MASAuthCredentialsClientCredentials *blockSelf = self;
    __block MASCompletionErrorBlock blockCompletion = completion;
    
    [[MASNetworkingService sharedService] postTo:endPoint
                                  withParameters:parameterInfo
                                      andHeaders:headerInfo
                                     requestType:MASRequestResponseTypeWwwFormUrlEncoded
                                    responseType:MASRequestResponseTypeJson
                                      completion:^(NSDictionary *authResponseInfo, NSError *error)
     {
         //
         // Detect if error, if so stop here
         //
         if(error)
         {
             //
             // Notify
             //
             if(blockCompletion)
             {
                 blockCompletion(NO, [NSError errorFromApiResponseInfo:authResponseInfo andError:error]);
             }
             
             return;
         }
         
         //
         // set authenticated timestamp
         //
         NSNumber *authenticatedTimestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
         [[MASAccessService sharedService] setAccessValueNumber:authenticatedTimestamp withAccessValueType:MASAccessValueTypeAuthenticatedTimestamp];
         
         //
         // Body Info
         //
         NSDictionary *bodyInfo = authResponseInfo[MASResponseInfoBodyInfoKey];
         
         //
         //  Clear refresh_token if it exists as client credential should not have refresh_token
         //
         [[MASAccessService sharedService] setAccessValueString:nil withAccessValueType:MASAccessValueTypeRefreshToken];
         
         //
         //  Store credential information into keychain
         //
         [[MASAccessService sharedService] saveAccessValuesWithDictionary:bodyInfo forceToOverwrite:NO];
         
         //
         // Post the notification
         //
         [[NSNotificationCenter defaultCenter] postNotificationName:MASUserDidAuthenticateNotification object:blockSelf];
         
         //
         // Notify
         //
         if(blockCompletion)
         {
             blockCompletion(YES, nil);
         }
     }];
}

@end
