//
//  MASHTTPSessionManager.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASHTTPSessionManager.h"

#import "MASSecurityService.h"
#import "MASURLRequest.h"


@interface MASHTTPSessionManager () <NSURLSessionTaskDelegate>

@end

@implementation MASHTTPSessionManager


# pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSURL *)url
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.URLCredentialStorage = nil;
    configuration.URLCache = nil;
    
    return [self initWithBaseURL:url sessionConfiguration:configuration];
}


- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (!self)
    {
        return nil;
    }
    
    self.requestSerializer = [MASIHTTPRequestSerializer serializer];
    self.responseSerializer = [MASICompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[MASURLRequest responseSerializerForType:MASRequestResponseTypeJson], [MASURLRequest responseSerializerForType:MASRequestResponseTypeTextPlain], [MASURLRequest responseSerializerForType:MASRequestResponseTypeXml]]];
    
    __block MASHTTPSessionManager *blockSelf = self;
    
    [self setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
        
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        {
            if ([blockSelf.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host])
            {
                *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }
        else {
            
            if ([challenge previousFailureCount] == 0)
            {
             
                NSURLCredential *signedCredential = [[MASSecurityService sharedService] createUrlCredential];
                
                if (signedCredential)
                {
                    *credential = signedCredential;
                    disposition = NSURLSessionAuthChallengeUseCredential;
                }
            }
        }
        
        return disposition;
    }];
    
    [self setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
       
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        {
            if ([blockSelf.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host])
            {
                *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }
        else {
            
            if ([challenge previousFailureCount] == 0)
            {
                
                NSURLCredential *signedCredential = [[MASSecurityService sharedService] createUrlCredential];
                
                if (signedCredential)
                {
                    *credential = signedCredential;
                    disposition = NSURLSessionAuthChallengeUseCredential;
                }
            }
        }
        
        return disposition;
    }];
    
    return self;
}

@end
