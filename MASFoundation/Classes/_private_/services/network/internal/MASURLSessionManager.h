//
//  MASURLSessionManager.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import "MASAuthValidationOperation.h"
#import "MASSecurityPolicy.h"
#import "MASSessionDataTaskOperation.h"
#import "MASURLRequest.h"
//  AFNetworking
#import "MASINetworkReachabilityManager.h"

//
//  NSURLSessionDelegate
//
typedef NSURLSessionAuthChallengeDisposition (^MASURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing * credential);
typedef void (^MASNetworkSessionDidFinishEventsForBackgroundURLSessionBlock)(NSURLSession *session);


@interface MASURLSessionManager : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (readonly, nonatomic, strong) NSURLSession *session;

@property (readwrite, nonatomic, strong) MASSecurityPolicy *securityPolicy;

@property (readwrite, nonatomic, strong) MASINetworkReachabilityManager *reachabilityManager;


///--------------------------------------
/// @name Initialization
///--------------------------------------

# pragma mark - Initialization

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;



///--------------------------------------
/// @name CRUD Operations
///--------------------------------------

# pragma mark - CRUD Operations

- (MASSessionDataTaskOperation *)dataOperationWithRequest:(MASURLRequest *)request completionHandler:(MASSessionDataTaskCompletionBlock)completionHandler;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

- (void)updateSession;



- (NSOperationQueue *)operationQueue;



- (NSOperationQueue *)internalOperationQueue;



- (void)addOperation:(NSOperation *)operation;



- (void)setTaskDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential **credential))block;



- (void)setSessionDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential **credential))block;


@end
