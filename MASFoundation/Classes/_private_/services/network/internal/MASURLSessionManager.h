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

//
//  NSURLSessionDelegate
//
typedef NSURLSessionAuthChallengeDisposition (^MASURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing * credential);
typedef void (^MASNetworkSessionDidFinishEventsForBackgroundURLSessionBlock)(NSURLSession *session);


/**
 MASURLSessionManager is responsible to handle network layer communication of SDK to the back-end services.
 */
@interface MASURLSessionManager : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 NSURLSession object for a network session; responsible for hanlding session level authentication challenge, and constructing session task.
 */
@property (readonly, nonatomic, strong) NSURLSession *session;


/**
 MASSecurityPolicy object; responsible for handling SSL pinning mechanism.
 */
@property (readwrite, nonatomic, strong) MASSecurityPolicy *securityPolicy;



///--------------------------------------
/// @name Initialization
///--------------------------------------

# pragma mark - Initialization


/**
 Designated initializer of MASURLSessionManager

 @param configuration NSURLSessionConfiguration object for NSURLSession
 @return an instance of MASURLSessionManager
 */
- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;



///--------------------------------------
/// @name CRUD Operations
///--------------------------------------

# pragma mark - CRUD Operations


/**
 Constructs MASSessionDataTaskOperation object for API request with given MASURLRequest object and internal NSURLSession object.

 @param request MASURLRequest object that holds header, parameter, URL, and HTTP method of the request.
 @param completionHandler MASSessionDataTaskCompletionBlock hanlder which will be notified upon completion of the request.
 @return an instance of MASSessionDataTaskOperation
 */
- (MASSessionDataTaskOperation *)dataOperationWithRequest:(MASURLRequest *)request completionHandler:(MASSessionDataTaskCompletionBlock)completionHandler;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 Establish new NSURLSession object to clear TLS cache for NSURLSession object.  
 This method is designed to be called upon change of client certificate for mutual SSL.
 */
- (void)updateSession;



/**
 NSOperationQueue for regular API requests.

 @return NSOperationQueue object that contains the current queue of regular API requests.
 */
- (NSOperationQueue *)operationQueue;



/**
 NSOperationQueue for internal API requests; such as registration, authentication, and validation operations.

 @return NSOperationQueue object that contains the current queue of internal API requests, and validation operation.
 */
- (NSOperationQueue *)internalOperationQueue;



/**
 Add NSOperation object into either operationQueue, or internalOperationQueue.  
 This method will automatically filter out the operation and put it into correct queue 
 depending on whether the request is being made to a system endpoint or regular API endpoint.

 @param operation NSOperation to be added into the queue.
 */
- (void)addOperation:(NSOperation *)operation;



/**
 Set code block of task level authentication challenge for the current NSURLSessionTask object.

 @param block NSURLSessionAuthChallengeDisposition code block.
 */
- (void)setTaskDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential **credential))block;



/**
 Set code block of session level authentication challenge for the current NSURLSession object.

 @param block NSURLSessionAuthChallengeDisposition code block.
 */
- (void)setSessionDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential **credential))block;



/**
 Set code block of session level redirection for the current NSURLRequest object.

 @param block http redirection code block.
 */
- (void)setSessionDidReceiveHTTPRedirectBlock:(NSURLRequest* (^)(NSURLSession *session,NSURLSessionTask *task, NSURLResponse* response,NSURLRequest *request))block;

@end
