//
//  L7SBrowserURLProtocol.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "L7SBrowserURLProtocol.h"
#import <MASApplication+MASPrivate.h>
#import <MASUser+MASPrivate.h>
#import "MASKeyChainService.h"
#import "MASSecurityService.h"

@implementation L7SBrowserURLProtocol


@synthesize allowsInvalidSSLCertificate = _allowsInvalidSSLCertificate;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"AuthorizationSet" inRequest:request] == nil) {
        
        return YES;
    }

    return NO;
}


+ (BOOL)isProtectedResource:(NSURL *)resourceURL
{
    NSString *resourceURLHost = [resourceURL host];
    NSString *endpointHost = [MASConfiguration currentConfiguration].gatewayHostName;
    
    //
    // If the url has a prefix
    //
    if([resourceURLHost hasPrefix:endpointHost])
    {
        if( resourceURLHost.length == endpointHost.length ||
           [resourceURLHost isEqualToString:[endpointHost stringByAppendingString:@"."]])
        {
            return YES;
        }
    }
    
    return NO;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}


+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}


- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    if ([MASApplication currentApplication].isAuthenticated) {
        
        if ([self.class isProtectedResource:self.request.URL])
        {
            NSString *authorization = [MASUser authorizationBearerWithAccessToken];
            [newRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
            [NSURLProtocol setProperty:@YES forKey:@"AuthorizationSet" inRequest:newRequest];
        }
        else {
            [NSURLProtocol setProperty:@NO forKey:@"AuthorizationSet" inRequest:newRequest];
        }
        
        self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    }
    else
    {
        [self stopLoading];
        
        [MAS setGrantFlow:MASGrantFlowClientCredentials];
        
        [MAS start:^(BOOL completed, NSError *error) {
            
            if(error)
            {
                return;
            }
            else if (completed){
                
                if ([self.class isProtectedResource:self.request.URL])
                {
                    NSString *authorization = [MASUser authorizationBearerWithAccessToken];
                    [newRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                    [NSURLProtocol setProperty:@YES forKey:@"AuthorizationSet" inRequest:newRequest];
                }
                else {
                    [NSURLProtocol setProperty:@NO forKey:@"AuthorizationSet" inRequest:newRequest];
                }
                
                self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            }
        }];
    }
}


- (void)stopLoading
{
    [self.connection cancel];
}


#pragma mark - NSURLConnectionDelegate. Following code are modified copy from AFNetworking AFURLConnectionOperation.m

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        
        SecPolicyRef policy = SecPolicyCreateBasicX509();
        CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
        NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:certificateCount];
        
        for (CFIndex i = 0; i < certificateCount; i++) {
            SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
            
            [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
        }
        
        CFRelease(policy);
        
        {
            for (id serverCertificateData in trustChain) {
                if ([[self.class pinnedCertificates] containsObject:serverCertificateData]) {
                    NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                    return;
                }
            }
            
            SecTrustResultType result = 0;
            SecTrustEvaluate(serverTrust, &result);
            
            if (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed) {
                NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            } else {
                [[challenge sender] cancelAuthenticationChallenge:challenge];
            }
        }
    } else {
        if ([challenge previousFailureCount] == 0) {
            //client side authentication
            NSURLCredential * credential = [[MASSecurityService sharedService] createUrlCredential];
            if (credential) {
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        } else {
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}


+ (NSArray *)pinnedCertificates {
    static NSMutableArray *_pinnedCertificates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
        
        NSMutableArray *certificates = [NSMutableArray arrayWithCapacity:[paths count]];
        for (NSString *path in paths) {
            NSData *certificateData = [NSData dataWithContentsOfFile:path];
            [certificates addObject:certificateData];
        }
        
        _pinnedCertificates = [[NSMutableArray alloc] initWithArray:certificates];
        //adding the certificates from Json configuration
        [_pinnedCertificates addObjectsFromArray:[[MASConfiguration currentConfiguration] gatewayCertificatesAsDERData]];
        
    });
    return _pinnedCertificates;
}


+ (NSArray *)pinnedPublicKeys {
    static NSArray *_pinnedPublicKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *pinnedCertificates = [self pinnedCertificates];
        NSMutableArray *publicKeys = [NSMutableArray arrayWithCapacity:[pinnedCertificates count]];
        
        for (NSData *data in pinnedCertificates) {
            SecCertificateRef allowedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
            NSParameterAssert(allowedCertificate);
            
            SecCertificateRef allowedCertificates[] = {allowedCertificate};
            CFArrayRef certificates = CFArrayCreate(NULL, (const void **)allowedCertificates, 1, NULL);
            
            SecPolicyRef policy = SecPolicyCreateBasicX509();
            SecTrustRef allowedTrust = NULL;
            OSStatus status = SecTrustCreateWithCertificates(certificates, policy, &allowedTrust);
            NSAssert(status == errSecSuccess, @"SecTrustCreateWithCertificates error: %ld", (long int)status);
            
            SecTrustResultType result = 0;
            status = SecTrustEvaluate(allowedTrust, &result);
            NSAssert(status == errSecSuccess, @"SecTrustEvaluate error: %ld", (long int)status);
            
            SecKeyRef allowedPublicKey = SecTrustCopyPublicKey(allowedTrust);
            NSParameterAssert(allowedPublicKey);
            [publicKeys addObject:(__bridge_transfer id)allowedPublicKey];
            
            CFRelease(allowedTrust);
            CFRelease(policy);
            CFRelease(certificates);
            CFRelease(allowedCertificate);
        }
        
        _pinnedPublicKeys = [[NSArray alloc] initWithArray:publicKeys];
    });
    
    return _pinnedPublicKeys;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
