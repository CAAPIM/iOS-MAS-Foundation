//
//  MASSessionDataTaskOperation.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSessionDataTaskOperation.h"

@interface MASSessionDataTaskOperation ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSError *error;

@property (nonatomic) long long totalBytesExpected;
@property (nonatomic) long long bytesReceived;

@end


@implementation MASSessionDataTaskOperation

- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request
{
    self = [super initWithSession:session request:request];
    if (self)
    {
        self.task = [session dataTaskWithRequest:request];
    }
    
    return self;
}


# pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    __block id responseObj = nil;
    
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
