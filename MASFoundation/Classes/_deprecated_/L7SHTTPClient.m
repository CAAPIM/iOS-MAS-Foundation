//
//  L7SHTTPClient.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "L7SHTTPClient.h"

#import "MASFoundation.h"
#import "MASModelService.h"
#import "L7SClientManager.h"


@interface L7SHTTPClient ()

/**
 *  Requesting grantType (UserCredentialFlow, ClientCredentialFlow)
 */
@property (assign) L7SGrantType grantType;



/**
 *  Requesting new scope as part of L7SHTTPClient
 */
@property (nonatomic, strong) NSString *requestingScope;

@end


@implementation L7SHTTPClient

- (id)initWithConfiguredBaseURL
{
    return [self initWithGrantType:L7SGrantTypePassword andScope:nil];
}

- (id)initWithConfiguredBaseURLWithGrantFlow:(L7SGrantType)grantType andScope:(NSString*)scope
{
    return [self initWithGrantType:grantType andScope:scope];
}

- (id)initWithGrantType:(L7SGrantType)grantType andScope:(NSString*)scope
{
    
    if(self = [super init])
    {
        
        _grantType = grantType;
        _requestingScope = scope;
    }
    
    return self;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
    
    [self getPath:path parameters:parameters requestType:MASRequestResponseTypeJson responseType:MASRequestResponseTypeJson success:success failure:failure];
}


- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
    [self ensureMASFrameworkStatus:^(BOOL completed, NSError *error) {
        
        if(completed && !error)
        {
            [MAS getFrom:path
          withParameters:parameters
              andHeaders:_requestingScope ? [NSDictionary dictionaryWithObject:_requestingScope forKey:MASScopeRequestResponseKey] : nil
             requestType:requestType
            responseType:responseType
              completion:^(NSDictionary *responseInfo, NSError *error) {
                
                  if(error)
                  {
                      failure(nil, error);
                  }
                  else
                  {
                      success(nil, responseInfo[MASResponseInfoBodyInfoKey]);
                  }
            }];
        }
    }];
}


- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
    [self postPath:path parameters:parameters requestType:MASRequestResponseTypeJson responseType:MASRequestResponseTypeJson success:success failure:failure];
}


- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
     requestType:(MASRequestResponseType)requestType
    responseType:(MASRequestResponseType)responseType
         success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
   
    [self ensureMASFrameworkStatus:^(BOOL completed, NSError *error) {
        
        if(completed && !error)
        {
            [MAS postTo:path
         withParameters:parameters
             andHeaders:_requestingScope ? [NSDictionary dictionaryWithObject:_requestingScope forKey:MASScopeRequestResponseKey] : nil
            requestType:requestType
           responseType:responseType
             completion:^(NSDictionary *responseInfo, NSError *error) {
                
                if(error)
                {
                    failure(nil, error);
                }
                else
                {
                    success(nil, responseInfo[MASResponseInfoBodyInfoKey]);
                }
            }];
        }
    }];
}


- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
    [self putPath:path parameters:parameters requestType:MASRequestResponseTypeJson responseType:MASRequestResponseTypeJson success:success failure:failure];
}


- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
    
    [self ensureMASFrameworkStatus:^(BOOL completed, NSError *error) {
        
        if(completed && !error)
        {
            [MAS putTo:path
        withParameters:parameters
            andHeaders:_requestingScope ? [NSDictionary dictionaryWithObject:_requestingScope forKey:MASScopeRequestResponseKey] : nil
           requestType:requestType
          responseType:responseType
            completion:^(NSDictionary *responseInfo, NSError *error) {
                
                if(error)
                {
                    failure(nil, error);
                }
                else
                {
                    success(nil, responseInfo[MASResponseInfoBodyInfoKey]);
                }
            }];
        }
    }];
}


- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
    [self deletePath:path parameters:parameters requestType:MASRequestResponseTypeJson responseType:MASRequestResponseTypeJson success:success failure:failure];
}


- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
           success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
{
    
    [self ensureMASFrameworkStatus:^(BOOL completed, NSError *error) {
        
        if(completed && !error)
        {
            [MAS deleteFrom:path
             withParameters:parameters
                 andHeaders:_requestingScope ? [NSDictionary dictionaryWithObject:_requestingScope forKey:MASScopeRequestResponseKey] : nil
                requestType:requestType
               responseType:responseType
                 completion:^(NSDictionary *responseInfo, NSError *error) {
                
                if(error)
                {
                    failure(nil, error);
                }
                else
                {
                    success(nil, responseInfo[MASResponseInfoBodyInfoKey]);
                }
            }];
        }
    }];
}


#
# pragma mark - Private
#

- (void)ensureMASFrameworkStatus:(MASCompletionErrorBlock)completion
{
    
    //
    // if any one of application, device registration, or authentication is mission, do the MAS start again
    // before making http request
    //
    if (_grantType == L7SGrantTypePassword)
    {
        //
        // if the grant type is username/password flow, set MAS framework
        // otherwise, it's defaulted to client credentials
        //
        [MAS setDeviceRegistrationType:MASDeviceRegistrationTypeUserCredentials];
    }
    else {
        
        //
        // MAS framework is defaulted to client credentail by default,
        // but just to be clear
        //
        [MAS setDeviceRegistrationType:MASDeviceRegistrationTypeClientCredentials];
    }
    
    //
    //  If the SDK was already initialized, just go through the validation
    //
    if ([L7SClientManager sharedClientManager].state == L7SDidSDKStart)
    {
        [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
            
            if(completion) completion(completed, error);
            
            //
            //  Pass the error to L7SClientManager delegate
            //
            if (error && [[L7SClientManager delegate] respondsToSelector:@selector(DidReceiveError:)])
            {
                [[L7SClientManager delegate] DidReceiveError:error];
            }
        }];
    }
    else {
        
        
        [MASDevice setSessionSharingDelegate:[L7SClientManager sharedClientManager]];
        
        //
        //  If the SDK was not initialized, initialize the SDK which will go through validation process inside
        //
        [MAS start:^(BOOL completed, NSError *error) {
            
            if (completed)
            {
                [L7SClientManager sharedClientManager].state = L7SDidSDKStart;
                
                //
                //  Notify L7SClientManager delegate for DidStart
                //
                if ([[L7SClientManager delegate] respondsToSelector:@selector(DidStart)])
                {
                    [[L7SClientManager delegate] DidStart];
                }
            }
            
            //
            //  Pass the error to L7SClientManager delegate
            //
            if (error && [[L7SClientManager delegate] respondsToSelector:@selector(DidReceiveError:)])
            {
                [[L7SClientManager delegate] DidReceiveError:error];
            }
            
            if(completion) completion(completed, error);
        }];
    }
    
    return;
}

#
# pragma mark - MAS Delegate
#
- (MASDeviceRegistrationType)masRequestsDeviceRegistrationType
{
    if (_grantType == L7SGrantTypePassword)
    {
        return MASDeviceRegistrationTypeUserCredentials;
    }
    else
    {
        return MASDeviceRegistrationTypeClientCredentials;
    }
}

@end
