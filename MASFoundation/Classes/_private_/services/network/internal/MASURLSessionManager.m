//
//  MASURLSessionManager.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASURLSessionManager.h"

#import "MASSecurityService.h"

@interface MASURLSessionManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, copy) MASURLSessionDidReceiveAuthenticationChallengeBlock sessionAuthChallengeBlock;
@property (readwrite, nonatomic, copy) MASTaskDidReceiveAuthenticationChallengeBlock taskAuthChallengeBlock;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSMutableDictionary *operations;


@end


@implementation MASURLSessionManager


# pragma mark - Initialization

- (instancetype)init
{
    return [self initWithConfiguration:nil];
}


- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    
    if (self)
    {
        if (!configuration)
        {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _operations = [NSMutableDictionary dictionary];
        
        __block MASURLSessionManager *blockSelf = self;
        
        //
        //  NSURLSession authentication challenge
        //
        [self setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential) {
         
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
            {
                BOOL didPassEvaluation = YES;
                
                MASSecurityPolicy *securityPolicy = (MASSecurityPolicy *)blockSelf.securityPolicy;
                
                if (securityPolicy.MASSSLPinningMode == MASSSLPinningModePublicKeyHash)
                {
                    didPassEvaluation = [securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust withPublicKeyHashes:[MASConfiguration currentConfiguration].trustedCertPinnedPublickKeyHashes forDomain:challenge.protectionSpace.host];
                }
                else {
                    didPassEvaluation = [securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host];
                }
                
                if (didPassEvaluation)
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
        
        //
        //  MASURLSessionTask authentication challenge
        //
        [self setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential) {
            
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
            {
                BOOL didPassEvaluation = YES;
                
                if ([MASConfiguration currentConfiguration].enabledTrustedPublicPKI)
                {
                    SecTrustResultType result = 0;
                    SecTrustEvaluate(challenge.protectionSpace.serverTrust, &result);
                    
                    if (result != kSecTrustResultUnspecified && result != kSecTrustResultProceed)
                    {
                        didPassEvaluation = NO;
                    }
                }
                
                if (didPassEvaluation)
                {
                    MASSecurityPolicy *securityPolicy = (MASSecurityPolicy *)blockSelf.securityPolicy;
                    
                    if (securityPolicy.MASSSLPinningMode == MASSSLPinningModePublicKeyHash)
                    {
                        didPassEvaluation = [securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust withPublicKeyHashes:[MASConfiguration currentConfiguration].trustedCertPinnedPublickKeyHashes forDomain:challenge.protectionSpace.host];
                    }
                    else {
                        didPassEvaluation = [securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host];
                    }
                }
                
                if (didPassEvaluation)
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
    }
    
    return self;
}


# pragma mark - CRUD Operations

- (MASSessionDataTaskOperation *)dataOperationWithRequest:(MASURLRequest *)request completionHandler:(MASSessionDataTaskCompletionBlock)completionHandler
{
    MASSessionDataTaskOperation *dataTask = [[MASSessionDataTaskOperation alloc] initWithSession:_session request:request];
    [self.operations setObject:dataTask forKey:@(dataTask.task.taskIdentifier)];
    
    dataTask.didCompleteWithDataErrorBlock = ^(NSURLSession *session, NSURLSessionTask *task, NSData *data, NSError *error) {
      
        if (completionHandler)
        {
            completionHandler(task.response, data, error);
        }
    };
    
    return dataTask;
}


# pragma mark - NSOperationQueue

- (NSOperationQueue *)operationQueue
{
    @synchronized (self) {
        if (!_operationQueue)
        {
            _operationQueue = [[NSOperationQueue alloc] init];
            _operationQueue.name = [NSString stringWithFormat:@"com.ca.mas.network.operationqueue"];
            _operationQueue.maxConcurrentOperationCount = 10;
        }
        
        return _operationQueue;
    }
}


# pragma mark - Public

- (void)addOperation:(MASSessionTaskOperation *)operation
{
    [self.operationQueue addOperation:operation];
}


- (void)setTaskDidReceiveAuthenticationChallengeBlock:(nullable NSURLSessionAuthChallengeDisposition (^)(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential * __nullable __autoreleasing * __nullable credential))block
{
    self.taskAuthChallengeBlock = block;
}


- (void)setSessionDidReceiveAuthenticationChallengeBlock:(nullable NSURLSessionAuthChallengeDisposition (^)(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential * __nullable __autoreleasing * __nullable credential))block
{
    self.sessionAuthChallengeBlock = block;
}


# pragma mark - Private

- (void)removeSessionTaskFromOperations:(NSURLSessionTask *)task
{
    MASSessionTaskOperation *operation = self.operations[@(task.taskIdentifier)];
    
    if (operation)
    {
        [self.operations removeObjectForKey:@(operation.task.taskIdentifier)];
    }
}


# pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credentials = nil;
    
    if (self.sessionAuthChallengeBlock)
    {
        disposition = self.sessionAuthChallengeBlock(session, challenge, &credentials);
    }
    
    if (completionHandler)
    {
        completionHandler(disposition, credentials);
    }
}


# pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    MASSessionTaskOperation *operation = self.operations[@(task.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:task:didCompleteWithError:)])
    {
        [operation URLSession:session task:task didCompleteWithError:error];
    }
    
    [self removeSessionTaskFromOperations:task];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    MASSessionTaskOperation *operation = self.operations[@(task.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)])
    {
        [operation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    MASSessionTaskOperation *operation = self.operations[@(task.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)])
    {
        [operation URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    MASSessionTaskOperation *operation = self.operations[@(task.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:task:needNewBodyStream:)])
    {
        [operation URLSession:session task:task needNewBodyStream:completionHandler];
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    MASSessionTaskOperation *operation = self.operations[@(task.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)])
    {
        [operation URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
    }
}


# pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    MASSessionDataTaskOperation *operation = self.operations[@(dataTask.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)])
    {
        [operation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    MASSessionDataTaskOperation *operation = self.operations[@(dataTask.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)])
    {
        [operation URLSession:session dataTask:dataTask didReceiveData:data];
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    MASSessionDataTaskOperation *operation = self.operations[@(dataTask.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)])
    {
        [operation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    MASSessionDataTaskOperation *operation = self.operations[@(dataTask.taskIdentifier)];
    
    if ([operation respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)])
    {
        [operation URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
    }
}

@end
