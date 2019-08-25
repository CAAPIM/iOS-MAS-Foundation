//
//  MASSessionDownloadTaskOperation.m
//  MASFoundation
//
//  Created by nimma01 on 11/06/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import "MASSessionDownloadTaskOperation.h"
#import "MASURLRequest.h"
#import "MASAccessService.h"
#import "MASAuthValidationOperation.h"
#import "MASDevice.h"
#import "MASConstantsPrivate.h"

@interface MASSessionDownloadTaskOperation ()

@property(nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, readwrite, strong) MASURLRequest *request;
@property (nonatomic,strong)NSString* destinationPath;
@property (nonatomic)MASFileRequestProgressBlock progress;
@property (nonatomic)NSProgress* downloadProgress;
@property (nonatomic, readwrite, strong) NSURLSession *session;

@property (nonatomic, readwrite, getter = isFinished) BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;



@end


@implementation MASSessionDownloadTaskOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request destination:(NSString*)destinationPath progress:(MASFileRequestProgressBlock)progress
{
    self = [super initWithSession:session request:request];
    if (self)
    {
        self.request = (MASURLRequest *)request;
        [self setResponseType:self.request.responseType];
        self.destinationPath = destinationPath;
        self.progress = progress;
        self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    
    return self;
}



- (void)start{
    if ([self isCancelled])
    {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    if(!self.request.isPublic)
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
    
    //self.task = [self.session downloadTaskWithRequest:self.request];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    //[self.request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    self.task = [self.session downloadTaskWithRequest:self.request];
    
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



- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"bytes written so far %lld",totalBytesWritten/totalBytesExpectedToWrite);
    //send progress
    NSLog(@"%@",downloadTask.originalRequest.allHTTPHeaderFields);
    self.downloadProgress.totalUnitCount = totalBytesExpectedToWrite;
    self.downloadProgress.completedUnitCount = totalBytesWritten;
    
    if(self.progress){
        self.progress(self.downloadProgress);
    }
}



-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"downloaded");
    
    NSError* serializationError = nil;
    __block id responseObj = nil;
    //responseObj = [self.responseSerializer responseObjectForResponse:downloadTask.response data:self.responseData error:&serializationError];
    
    if(self.destinationPath){
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.destinationPath] error:&serializationError];
        
        self.didCompleteWithDataErrorBlock(session, downloadTask,nil,nil);
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    self.didCompleteWithDataErrorBlock(session, downloadTask, data, nil);
    
}

@end
