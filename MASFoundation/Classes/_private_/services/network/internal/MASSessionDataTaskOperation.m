//
//  MASSessionDataTaskOperation.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSessionDataTaskOperation.h"

#import "MASAccessService.h"
#import "MASAuthValidationOperation.h"
#import "MASDevice.h"
#import "MASURLRequest.h"
#import "MASConstantsPrivate.h"

@interface MASSessionDataTaskOperation ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSError *error;

@property (nonatomic) long long totalBytesExpected;
@property (nonatomic) long long bytesReceived;

@property (nonatomic, readwrite, getter = isFinished) BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;

@property (nonatomic, readwrite, strong) MASURLRequest *request;
@property (nonatomic, readwrite, strong) NSURLSession *session;

@end


@implementation MASSessionDataTaskOperation

@synthesize executing = _executing;
@synthesize finished = _finished;


- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request
{
    self = [super initWithSession:session request:request];
    if (self)
    {
        self.request = (MASURLRequest *)request;
        [self setResponseType:self.request.responseType];
    }
    
    return self;
}

# pragma mark - Public

- (void)updateSession:(NSURLSession *)session
{
    [super updateSession:session];
}


# pragma mark - NSOperation

- (void)start
{
    if ([self isCancelled])
    {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    if (!self.request.isPublic)
    {
        NSMutableDictionary *mutableHeader = [self.request.headerInfo mutableCopy];
        
        if (![[self.request.headerInfo allKeys] containsObject:MASMagIdentifierRequestResponseKey] && [MASDevice currentDevice].isRegistered && [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier])
        {
            [mutableHeader setObject:[[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier] forKey:MASMagIdentifierRequestResponseKey];
        }
        
        if (![[self.request.headerInfo allKeys] containsObject:MASAuthorizationRequestResponseKey] && [MASAccessService sharedService].currentAccessObj.accessToken)
        {
            [mutableHeader setObject:[MASUser authorizationBearerWithAccessToken] forKey:MASAuthorizationRequestResponseKey];
        }
        
        self.request.headerInfo = mutableHeader;
        self.request = [self.request rebuildRequest];
    }
    
    if ([self.dependencies.lastObject isKindOfClass:[MASAuthValidationOperation class]])
    {
        MASAuthValidationOperation *validationOperation = (MASAuthValidationOperation *)self.dependencies.lastObject;
        
        if (!validationOperation.result || validationOperation.error != nil)
        {
            if (self.didCompleteWithDataErrorBlock)
            {
                dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
                   
                    self.didCompleteWithDataErrorBlock(nil, nil, nil, validationOperation.error);
                });
            }
            
            [self completeOperation];
            
            return;
        }
    }
    self.task = [self.session dataTaskWithRequest:self.request];
    
    //
    //  post notification for network monitoring
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MASSessionTaskDidResumeNotification object:self.task];
    });
    
    [self.task resume];
}


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

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    __block id responseObj = nil;
    __block NSURLSessionTask *blockTask = task;
    
    if (error)
    {
        if (self.didCompleteWithDataErrorBlock)
        {
            dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
                
                self.didCompleteWithDataErrorBlock(session, task, responseObj, error);
            });
        }
    }
    else {
        
        NSError *serializationError = nil;
        responseObj = [self.responseSerializer responseObjectForResponse:task.response data:self.responseData error:&serializationError];
        
        
        if (self.didCompleteWithDataErrorBlock)
        {
            dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
                
                self.didCompleteWithDataErrorBlock(session, task, responseObj, serializationError);
            });
        }
    }
    
    //
    //  post notification for network monitoring
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        if (responseObj)
            [[NSNotificationCenter defaultCenter] postNotificationName:MASSessionTaskDidCompleteNotification object:blockTask userInfo:@{MASSessionTaskDidCompleteSerializedResponseKey:responseObj}];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:MASSessionTaskDidResumeNotification object:blockTask];
    });
    
    [self completeOperation];
}


# pragma mark - NSURLSessionDataTaskDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    
    if (self.didReceiveResponseBlock)
    {
        disposition = self.didReceiveResponseBlock(session, dataTask, response);
    }
    
    if (completionHandler)
    {
        completionHandler(disposition);
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.bytesReceived += [data length];
    
    if (self.didReceiveDataBlock)
    {
        dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
           
            self.didReceiveDataBlock(session, dataTask, data);
        });
    }
    else {
        if (!self.responseData)
        {
            self.responseData = [NSMutableData dataWithData:data];
        }
        else {
            [self.responseData appendData:data];
        }
    }
    
    //
    // TO DO: progress handler
    //
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    if (self.didBecomeDownloadTaskBlock)
    {
        dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
           
            self.didBecomeDownloadTaskBlock(session, dataTask, downloadTask);
        });
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler
{
    __block NSCachedURLResponse *cachedResponse = proposedResponse;
    
    if (self.willCacheResponseBlock)
    {
        dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
           
            cachedResponse = self.willCacheResponseBlock(session, dataTask, proposedResponse);
            
            if (completionHandler)
            {
                completionHandler(cachedResponse);
            }
        });
    }
    else {
        dispatch_group_async(self.completionGroup ? self.completionGroup : [self defaultDispatchGroupForCompletionBlock], self.completionQueue ? self.completionQueue : dispatch_get_main_queue(), ^{
            
            if (completionHandler)
            {
                completionHandler(cachedResponse);
            }
        });
    }
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}

@end
