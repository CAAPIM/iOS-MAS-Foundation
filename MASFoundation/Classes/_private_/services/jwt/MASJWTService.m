//
//  MASJWTService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASJWTService.h"

#import "JWT.h"
#import "JWTAlgorithmNone.h"
#import "JWTCryptoKey.h"

#import "MASAccessService.h"
#import "MASConfigurationService.h"

#import "NSURLSession+MASPrivate.h"


@implementation MASJWTService

static BOOL _enableJWKSetLoading_ = NO;

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

+ (void)enableJWKSetLoading:(BOOL)enable
{
    _enableJWKSetLoading_ = enable;
}


+ (BOOL)isJWKSetLoadingEnabled
{
    return _enableJWKSetLoading_;
}


///--------------------------------------
/// @name Shared Service
///-------------------------------------

# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASJWTService alloc] initProtected];
                  });
    
    return sharedInstance;
}


///--------------------------------------
/// @name Lifecycle
///-------------------------------------

# pragma mark - Lifecycle

+ (void)load
{
    [MASService registerSubclass:[self class] serviceUUID:MASJWTServiceUUID];
}


+ (NSString *)serviceUUID
{
    return MASJWTServiceUUID;
}


- (void)serviceDidLoad
{
    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    //
    // Attempt to retrieve the current JWKS from local storage
    //
    _currentJWKSet = [MASJWKSet instanceFromStorage];
    
    //
    // If found but it is an unloaded version that was somehow stored remove
    // it to start fresh below ... just a safety precaution as it can get into
    // a weird state if this happens
    //
    if(!self.currentJWKSet.isLoaded)
    {
        [self.currentJWKSet reset];
        _currentJWKSet = nil;
    }
    
    //
    // Retrieve the current configuration from keychain storage.
    //
    MASConfiguration *currentConfiguration = [MASConfigurationService sharedService].currentConfiguration;
    
    if (!self.currentJWKSet) {

        //
        // Start loading JWKS asynchronously if idTokenSignedResponseAlgo is "RS256'.
        //
        if (_enableJWKSetLoading_ ||
            [[currentConfiguration idTokenSignedResponseAlgo] isEqualToString:@"RS256"]) {

            [self loadJWKSAsynchronously:YES completion:nil];
        }
    }
    
    [super serviceWillStart];
}


- (void)serviceDidReset
{
    [super serviceDidReset];
}


///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@",
            [super debugDescription]];
}


///--------------------------------------
/// @name Private
///--------------------------------------

# pragma mark - Private

- (void)loadJWKSAsynchronously:(BOOL)async completion:(MASCompletionErrorBlock)completion {
 
    //
    // Endpoint
    //
    __block NSString *endPoint = MASJWTOpenIdConfigEndpointKey;
    
    //
    // Load Asynchronously.
    //
    if (async) {
        
        [[MASNetworkingService sharedService] getFrom:endPoint
                                       withParameters:nil
                                           andHeaders:nil
                                          requestType:MASRequestResponseTypeJson
                                         responseType:MASRequestResponseTypeJson
                                             isPublic:YES
                                           completion:
         ^(NSDictionary<NSString *,id> * _Nullable responseInfo, NSError * _Nullable error) {
             
             if (!responseInfo && error) {
                 
                 if (completion) {
                     
                     completion(NO, error);
                 }
                 
                 return;
             }
             
             //
             // JWKS Endpoint
             //
             endPoint = responseInfo[MASResponseInfoBodyInfoKey][MASJWTJWKSURIKey];
             
             [[MASNetworkingService sharedService] getFrom:endPoint
                                            withParameters:nil
                                                andHeaders:nil
                                               requestType:MASRequestResponseTypeJson
                                              responseType:MASRequestResponseTypeJson
                                                  isPublic:YES
                                                completion:
              ^(NSDictionary<NSString *,id> * _Nullable responseInfo, NSError * _Nullable error) {
                  
                  if (!responseInfo && error) {
                      
                      if (completion) {
                          
                          completion(NO, error);
                      }
                      
                      return;
                  }
                  
                  _currentJWKSet = [[MASJWKSet alloc] initWithJWKSetInfo:responseInfo[MASResponseInfoBodyInfoKey]];
                  
                  //
                  // If created then store it to local storage
                  //
                  if(_currentJWKSet)
                  {
                      [_currentJWKSet saveToStorage];
                  }
                  
                  if (completion) {
                      
                      completion(YES, nil);
                  }
                  
                  return;
              }];
         }];
    }
    //
    // Load Synchronously.
    //
    else {
        
        //
        // Adding prefix to the endpoint path
        //
        if ([MASConfiguration currentConfiguration].gatewayPrefix &&
            ![endPoint hasPrefix:@"http://"] &&
            ![endPoint hasPrefix:@"https://"])
        {
            endPoint = [NSString stringWithFormat:@"%@%@",[MASConfiguration currentConfiguration].gatewayPrefix, endPoint];
        }

        //
        // Full URL path
        //
        NSURL *url = [NSURL URLWithString:endPoint relativeToURL:[MASConfiguration currentConfiguration].gatewayUrl];
        
        NSAssert(url, @"URL cannot be nil");
        
        NSDictionary *responseInfo = [NSURLSession requestSynchronousJSONWithURLString:[url absoluteString]];
        
        if (!responseInfo) {
            
            if (completion) {
                
                completion(NO, nil);
            }
            
            return;
        }
        
        //
        // Endpoint
        //
        endPoint = responseInfo[MASJWTJWKSURIKey];
        
        responseInfo = [NSURLSession requestSynchronousJSONWithURLString:endPoint];
        
        if (!responseInfo) {
            
            if (completion) {
                
                completion(NO, nil);
            }
            
            return;
        }
        
        _currentJWKSet = [[MASJWKSet alloc] initWithJWKSetInfo:responseInfo];
        
        //
        // If created then store it to local storage
        //
        if(_currentJWKSet)
        {
            [_currentJWKSet saveToStorage];
        }
        
        if (completion) {
            
            completion(YES, nil);
        }
        
        return;
    }
}


///--------------------------------------
/// @name Token Validation
///--------------------------------------

#pragma mark - Token Validation

- (NSDictionary *)decodeToken:(NSString *)token
                        keyId:(NSString *)keyId
    skipSignatureVerification:(BOOL)skipVerification
                        error:(NSError *__autoreleasing *)error {
    
    //
    // If no locally stored JWKS is found.
    // Start loading JWKS synchronously.
    //
    if (!self.currentJWKSet) {
        
        [self loadJWKSAsynchronously:NO completion:nil];
    }
    
    //
    // Extract the x509 cert chain for Json Web Key of keyId.
    //
    NSArray *x5c = nil;
    NSArray *JWKeys = [self.currentJWKSet jsonWebKeys];
    for (NSDictionary *JWKey in JWKeys) {
        
        if ([keyId isEqualToString:JWKey[@"kid"]]) {
            
            x5c = JWKey[@"x5c"];
            break;
        }
    }
    
    //
    // If no x509 cert chain return nil.
    //
    if (!x5c) return nil;
    
    
    //
    // JWT Algorithm = RS256.
    //
    NSString *algorithmName = @"RS256";
    
    NSError *theError = nil;
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:algorithmName];
    if (!algorithm) {
        return nil;
    }
    
    //
    // Extract JWT Public Key.
    //
    id<JWTAlgorithmDataHolderProtocol> holder = nil;
    if ([algorithm isKindOfClass:[JWTAlgorithmRSBase class]] || [algorithm.name hasPrefix:@"RS"]) {
        
        //
        //  Use x5c[0] of chain.
        //
        NSData *certData =
            [[NSData alloc] initWithBase64EncodedString:x5c[0] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
        NSError *keyError = nil;
        id<JWTCryptoKeyProtocol>key = [[JWTCryptoKeyPublic alloc] initWithCertificateData:certData parameters:nil error:&keyError];
        
        theError = keyError;
        if (!theError) {
            holder = [JWTAlgorithmRSFamilyDataHolder new].verifyKey(key).algorithmName(algorithmName).secretData([NSData new]);
        }
    }
    else if ([algorithm isKindOfClass:[JWTAlgorithmNone class]]) {
        holder = [JWTAlgorithmNoneDataHolder new];
    }
    
    //
    // JWT error out.
    //
    if (theError) {
        //DSLog(@"JWT internalError: %@", theError);
        
        if (error) {
            *error = theError;
        }
        
        return nil;
    }
    
    //
    // Decode id_token.
    //
    JWTCodingBuilder *builder = [JWTDecodingBuilder decodeMessage:token].addHolder(holder).options(@(skipVerification));
    JWTCodingResultType *result = builder.result;
    return result.successResult.headerAndPayloadDictionary;
}

@end
