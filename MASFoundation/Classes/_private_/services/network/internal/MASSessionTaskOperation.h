//
//  MASSessionTaskOperation.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import "MASConstants.h"
//  AFNetworking
#import "MASIURLResponseSerialization.h"

//
//  NSURLSessionTaskDelegate
//
typedef NSURLSessionAuthChallengeDisposition (^MASTaskDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing * credential);
typedef void (^MASNetworkDidCompleteWithDataErrorBlock)(NSURLSession *session, NSURLSessionTask *task, NSData *data, NSError *error);
typedef void (^MASNetworkDidSendBodyDataBlock)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSEnt, int64_t totalBytesExpectedToSend);
typedef NSInputStream *(^MASNetworkNeedNewBodyStreamBlock)(NSURLSession *session, NSURLSessionTask *task);
typedef NSURLRequest *(^MASNetworkWillPerformHTTPRedirectionBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *, NSURLRequest *request);

//
//  NSURLSessionDataTaskDelegate
//
typedef NSURLSessionResponseDisposition (^MASNetworkDataTaskDidReceiveResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);
typedef void (^MASNetworkDataTaskDidBecomeDownloadTaskBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
typedef void (^MASNetworkDataTaskDidReceiveDataBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
typedef NSCachedURLResponse * (^MASNetworkDataTaskWillCacheResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse);

@interface MASSessionTaskOperation : NSOperation <NSURLSessionTaskDelegate>

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, weak) NSURLSessionTask *task;
@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, strong) dispatch_group_t completionGroup;

@property (nonatomic, copy) MASNetworkDidCompleteWithDataErrorBlock didCompleteWithDataErrorBlock;
@property (nonatomic, copy) MASNetworkDidSendBodyDataBlock didSendBodyDataBlock;
@property (nonatomic, copy) MASNetworkNeedNewBodyStreamBlock needNewBodyStreamBlock;
@property (nonatomic, copy) MASNetworkWillPerformHTTPRedirectionBlock willPerformHTTPRedirectBlock;
@property (nonatomic, strong) id <MASIURLResponseSerialization> responseSerializer;


///--------------------------------------
/// @name Initialization
///--------------------------------------

# pragma mark - Initialization

- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

- (void)setResponseType:(MASRequestResponseType)responseType;



- (void)completeOperation;



- (dispatch_group_t)defaultDispatchGroupForCompletionBlock;



- (void)setTaskDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing * credential))block;

@end
