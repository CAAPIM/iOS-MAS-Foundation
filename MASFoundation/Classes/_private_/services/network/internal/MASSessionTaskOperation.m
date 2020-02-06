//
//  MASSessionTaskOperation.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSessionTaskOperation.h"
#import "MASURLRequest.h"

@interface MASSessionTaskOperation ()

@property (nonatomic, readwrite, getter = isFinished) BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;
@property (nonatomic, readwrite, copy) MASTaskDidReceiveAuthenticationChallengeBlock taskAuthenticationChallengeBlock;
@property (nonatomic, readwrite, strong) MASURLRequest *request;
@property (nonatomic, readwrite, strong) NSURLSession *session;

@end

@implementation MASSessionTaskOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

# pragma mark - Initialization

- (instancetype)init
{
    self = [self initWithSession:nil request:nil];
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@'s init is not a valid initializer, please use a designated initializer", NSStringFromClass([self class])]
                                 userInfo:nil];
    
    
    return nil;
}


- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.request = (MASURLRequest *)request;
    }
    
    return self;
}




# pragma mark - Public

- (void)updateSession:(NSURLSession *)session
{
    if (self.session)
    {
        self.session = nil;
    }
    
    self.session = session;
}


- (void)setResponseType:(MASRequestResponseType)responseType
{
    _responseSerializer = [MASURLRequest responseSerializerForType:responseType];
}


- (void)completeOperation
{
    self.executing = NO;
    self.finished = YES;
}


- (dispatch_group_t)defaultDispatchGroupForCompletionBlock
{
    static dispatch_group_t masDefaultDispatchGroup;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        masDefaultDispatchGroup = dispatch_group_create();
    });
    
    return masDefaultDispatchGroup;
}


- (void)setTaskDidReceiveAuthenticationChallengeBlock:(nullable NSURLSessionAuthChallengeDisposition (^)(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential * __nullable __autoreleasing * __nullable credential))block
{
    self.taskAuthenticationChallengeBlock = block;
}


# pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, executing: %@, cancelled: %@, finished: %@ taskIdentifier: %lu>", NSStringFromClass([self class]), self, self.executing ? @"YES":@"NO", [self isCancelled] ? @"YES":@"NO", self.isFinished ? @"YES":@"NO", (unsigned long)self.task.taskIdentifier];
}


# pragma mark - Private

- (void)didFinishOperation
{
    self.executing = NO;
    self.finished = YES;
}


# pragma mark - NSOperation methods

- (void)start
{
    if ([self isCancelled])
    {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    [self.task resume];
}


- (void)cancel
{
    [self.task cancel];
    [super cancel];
}


# pragma mark - NSOperation properties

- (void)setExecuting:(BOOL)executing
{
    if (executing != _executing)
    {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
}


- (void)setFinished:(BOOL)finished
{
    if (finished != _finished)
    {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
}


# pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    NSURLRequest *redirectRequest = request;
    
    if (self.willPerformHTTPRedirectBlock)
    {
        redirectRequest = self.willPerformHTTPRedirectBlock(session, task, response, request);
    }
    
    if (completionHandler)
    {
        completionHandler(redirectRequest);
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credentials = nil;
    
    if (self.taskAuthenticationChallengeBlock)
    {
        disposition = self.taskAuthenticationChallengeBlock(session, task, challenge, &credentials);
    }
    
    if (completionHandler)
    {
        completionHandler(disposition, credentials);
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler
{
    if (self.needNewBodyStreamBlock)
    {
        dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
           
            self.needNewBodyStreamBlock(session, task);
        });
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if (self.didSendBodyDataBlock)
    {
        dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
           
            self.didSendBodyDataBlock(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend);
        });
    }
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (self.didCompleteWithDataErrorBlock)
    {
        dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
           
            self.didCompleteWithDataErrorBlock(session, task, nil, error);
        });
    }
}


@end
