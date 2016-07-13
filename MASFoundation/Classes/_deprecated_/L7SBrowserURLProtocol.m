//
//  L7SBrowserURLProtocol.m
//  SampleWebView
//
//  The code partially comes from AFNetworking
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
    if ( [NSURLProtocol propertyForKey:@"AuthorizationSet" inRequest:request] == nil &&
        [[self class] isProtectedResource:request.URL]){
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
        //
        //
        //
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
        NSString *authorization = [MASUser authorizationBearerWithAccessToken];
        [newRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
        
        [NSURLProtocol setProperty:@YES forKey:@"AuthorizationSet" inRequest:newRequest];
        
        self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    }
    else
    {
        [self stopLoading];
        
        [MAS setGrantFlow:MASGrantFlowPassword];
        
        [MAS start:^(BOOL completed, NSError *error) {
            if(error)
            {
                if([L7SClientManager delegate] && [[L7SClientManager delegate] respondsToSelector:@selector(DidReceiveError:)]){
                    [[L7SClientManager delegate] DidReceiveError:error];
                }
                
                return;
            }
            else if (completed){
                [L7SClientManager sharedClientManager].state = L7SDidSDKStart;
                
                NSString *authorization = [MASUser authorizationBearerWithAccessToken];
                [newRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
                
                [NSURLProtocol setProperty:@YES forKey:@"AuthorizationSet" inRequest:newRequest];
                
                self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            }
            
            
            if([L7SClientManager delegate] && [[L7SClientManager delegate] respondsToSelector:@selector(DidStart)])
            {
                [[L7SClientManager delegate] DidStart];
            }
        }];
    }
}


- (void)stopLoading
{
    [self.connection cancel];
}


#pragma mark - NSURLConnectionDelegate. Following code are modified copy from AFNetworking AFURLConnectionOperation.m


- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        
        SecPolicyRef policy = SecPolicyCreateBasicX509();
        CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
        NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:certificateCount];
        for (CFIndex i = 0; i < certificateCount; i++) {
            SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
            
            //Todo : checking only for certificate pinning mode
            // Currently it is assumed as certificate pinning mode
            
//            if ([L7SPolicyManager sharedPolicyManager].configuration.pinningMode == L7SAFSSLPinningModeCertificate) {
            
                [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
            
//            } else if ([L7SPolicyManager sharedPolicyManager].configuration.pinningMode  == L7SAFSSLPinningModePublicKey) {
//                SecCertificateRef someCertificates[] = {certificate};
//                CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);
//                
//                SecTrustRef trust = NULL;
//                
//                OSStatus status = SecTrustCreateWithCertificates(certificates, policy, &trust);
//                NSAssert(status == errSecSuccess, @"SecTrustCreateWithCertificates error: %ld", (long int)status);
//                
//                SecTrustResultType result;
//                status = SecTrustEvaluate(trust, &result);
//                NSAssert(status == errSecSuccess, @"SecTrustEvaluate error: %ld", (long int)status);
//                
//                [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];
//                
//                CFRelease(trust);
//                CFRelease(certificates);
//            }
        }
        
        CFRelease(policy);
        
        //Todo: checking only for case certificatePinning mode
        {
            for (id serverCertificateData in trustChain) {
                if ([[self.class pinnedCertificates] containsObject:serverCertificateData]) {
                    NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                    return;
                }
            }
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
//            break;
        }
        /*
        switch ([L7SPolicyManager sharedPolicyManager].configuration.pinningMode ) {
            case L7SAFSSLPinningModePublicKey: {
                NSArray *pinnedPublicKeys = [self.class pinnedPublicKeys];
                
                for (id publicKey in trustChain) {
                    for (id pinnedPublicKey in pinnedPublicKeys) {
                        if (AFSecKeyIsEqualToKey((__bridge SecKeyRef)publicKey, (__bridge SecKeyRef)pinnedPublicKey)) {
                            NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                            return;
                        }
                    }
                }
                
                [[challenge sender] cancelAuthenticationChallenge:challenge];
                break;
            }
            case L7SAFSSLPinningModeCertificate: {
                for (id serverCertificateData in trustChain) {
                    if ([[self.class pinnedCertificates] containsObject:serverCertificateData]) {
                        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                        return;
                    }
                }
                
                [[challenge sender] cancelAuthenticationChallenge:challenge];
                break;
            }
            case L7SAFSSLPinningModeNone: {
                if (self.allowsInvalidSSLCertificate){
                    NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                } else {
                    SecTrustResultType result = 0;
                    OSStatus status = SecTrustEvaluate(serverTrust, &result);
                    NSAssert(status == errSecSuccess, @"SecTrustEvaluate error: %ld", (long int)status);
                    
                    if (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed) {
                        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                    } else {
                        [[challenge sender] cancelAuthenticationChallenge:challenge];
                    }
                }
                break;
            }
        }*/
    } else {
        if ([challenge previousFailureCount] == 0) {
            //client side authentication
            NSURLCredential * credential = [[MASSecurityService sharedService]createUrlCredential];
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
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
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



/*
-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSLog(@"challenge..%@",challenge.protectionSpace.authenticationMethod);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        
    }
    else
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
    NSLog(@"data ...%@  ",data); //handle data here
//    [self.mutableData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(!error)
    {
        [self.client URLProtocolDidFinishLoading:self];
    }
    else{
        NSLog(@"error ...%@  ",error);
        [self.client URLProtocol:self didFailWithError:error];
    }
    
}*/


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


/*

#if !defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
static NSData *AFSecKeyGetData(SecKeyRef key) {
    CFDataRef data = NULL;
    
    OSStatus status = SecItemExport(key, kSecFormatUnknown, kSecItemPemArmour, NULL, &data);
    NSCAssert(status == errSecSuccess, @"SecItemExport error: %ld", (long int)status);
    NSCParameterAssert(data);
    
    return (__bridge_transfer NSData *)data;
}
#endif

static BOOL AFSecKeyIsEqualToKey(SecKeyRef key1, SecKeyRef key2) {
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    return [(__bridge id)key1 isEqual:(__bridge id)key2];
#else
    return [AFSecKeyGetData(key1) isEqual:AFSecKeyGetData(key2)];
#endif
}
*/

@end
