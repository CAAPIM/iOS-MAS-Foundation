//
//  L7SHTTPClient.h
//  L7SSingleSignon SDK
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import "L7SAFHTTPRequestOperation.h"
#import "MASConstants.h"

/**
 
 `L7SHTTPClient` extends a class of AFNetworking, `AFHTTPClient`, that captures the common patterns of communicating with an web application over HTTP. It encapsulates information like base URL, authorization credentials, and HTTP headers, and uses them to construct and manage the execution of HTTP request operations.
 
 ## Automatic Content Parsing
 
 Instances of `L7SHTTPClient` may specify which types of requests it expects and should handle by registering HTTP operation classes for automatic parsing. Registered classes will determine whether they can handle a particular request.
 
 You can override these HTTP headers or define new ones using `setDefaultHeader:value:`.
 
 **Note:**  In the case that a request URL doesn't end with ".json", one needs to add "Accept" header as the example below to indicate the `L7SAFHTTPClient` to parse a response in json format.
 
 [httpClient registerHTTPOperationClass:[L7SAFJSONRequestOperation class]];
 
 [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
 
 
 You may construct a URL request operation accordingly in `enqueueHTTPRequestOperationWithRequest:success:failure`.  `L7SHTTPClient` overwrites the method of constructing an operation with a particular URL request to a protected resources:
 
 - (L7SAFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSMutableURLRequest *)urlRequest
 success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
 failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure
 
 
 
 
 ## Example to Access Protected Resources
 
 L7SHTTPClient *httpClient = [[ L7SHTTPClient alloc] initWithConfiguredBaseURL];
 
 [httpClient registerHTTPOperationClass:[L7SAFJSONRequestOperation class]];
 /set headers to specify the acceptable format
 [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
 NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
 
 [parameters setObject:@"listProducts" forKey:@"operation"];
 
 NSString *path = [NSString stringWithFormat:@"%@/protected/resource/products", [[L7SClientManager sharedClientManager] prefix]];
 
 [httpClient getPath:path
 parameters:parameters
 success:^(L7SAFHTTPRequestOperation *operation, id responseObject){
 //add your code to handle results from the server
 } failure:^(L7SAFHTTPRequestOperation *operation, NSError *error) {
 //add your code to handle the failures
 }];
 
 
 ## Make an Unprotected HTTP request
 
 `L7SHTTPClient` is used only if you intend to make a request to a protected endpoint.  You may use its superclass `L7SAFHTTPClient` directly to make a request to a unprotected endpoint.  Using `L7SHTTPClient` to send a request to a non-protected will result in leaking your access credetials.
 
 
 
 ## Status Notifications
 
 SDK sends notifcations when some key satuse changes through the iOS NSNotificationCenter.
 
 
 
 ## Crafting an HTTP operation with any given parameters and headers
 
 The following is an example of crafing an HTTP operation with any given parameters and headers:
 
 L7SHTTPClient *httpClient = [[ L7SHTTPClient alloc] initWithConfiguredBaseURL];
 
 NSString *authorization = @"some authorization";
 
 [httpClient setDefaultHeader:@"Authorization" value:authorization];
 
 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
 @"password", @"grant_type",
 login, @"username",
 password, @"password",
 nil];
 
 
 NSMutableURLRequest *mutableRequest = [httpClient requestWithMethod:@"POST" path:somePath parameters:parameters];
 NSMutableDictionary * headers = [[NSMutableDictionary alloc] init];
 
 [headers setObject:@"application/json" forKey:@"Accept"];
 
 [mutableRequest setAllHTTPHeaderFields:headers];
 
 
 L7SAFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:mutableRequest
 success:^(L7SAFHTTPRequestOperation *operation, id responseObject)
 {
 //handle success
 } failure:^(L7SAFHTTPRequestOperation *operation, NSError *error) {
 //handle failure
 }];
 
 [httpClient enqueueHTTPRequestOperation:operation];
 
 
 */


typedef enum {
    L7SGrantTypePassword,
    L7SGrantTypeClientCredential
}L7SGrantType DEPRECATED_ATTRIBUTE;

@interface L7SHTTPClient : NSObject



/**
 Initializes an `L7SHTTPClient` object with the configured baseURL
 
 @return The newly-initialized HTTP client
 */
- (id)initWithConfiguredBaseURL DEPRECATED_ATTRIBUTE;

/**
 Initializes an 'L7SHTTPClient' object with configured baseURL and the grantType. Based on the GrantType SDK initiates the registration flow.
 
 @param L7SGrantType type enum which is either L7SGrantTypePassword,L7SGrantTypeClientCredential
 
 @param NSSTring type, the scope value to be set to the request. Can be nil. Multiple scopes should be space separated string.
 
 @return The newly-initialized HTTP client
 */

- (id)initWithConfiguredBaseURLWithGrantFlow:(L7SGrantType)grantType andScope:(NSString*)scope DEPRECATED_ATTRIBUTE;

///-------------------------------
/// @name Creating HTTP Operations
///-------------------------------

/**
 Creates an `L7SAFHTTPRequestOperation`.
 
 @param urlRequest The request object to be loaded asynchronously during execution of the operation.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
//- (L7SAFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSMutableURLRequest *)urlRequest
//                                                       success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
//                                                       failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure;

///---------------------------
/// @name Making HTTP Requests
///---------------------------

/**
 Creates an `L7SAFHTTPRequestOperation` with a `GET` request, and enqueues it to the HTTP client's operation queue.
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param parameters The parameters to be encoded and appended as the query string for the request URL.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */


- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS getFrom:WithParameters:andHeaders:completion:].");


- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS getFrom:WithParameters:andHeaders:requestType:responseType:completion:].");

/**
 Creates an `L7SAFHTTPRequestOperation` with a `POST` request, and enqueues it to the HTTP client's operation queue.
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS postTo:WithParameters:andHeaders:completion:].");


- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
     requestType:(MASRequestResponseType)requestType
    responseType:(MASRequestResponseType)responseType
         success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS postTo:WithParameters:andHeaders:requestType:responseType:completion:].");


/**
 Creates an `L7SAFHTTPRequestOperation` with a `PUT` request, and enqueues it to the HTTP client's operation queue.
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS putTo:WithParameters:andHeaders:completion:].");


- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
        success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS putTo:WithParameters:andHeaders:requestType:responseType:completion:].");


/**
 Creates an `L7SAFHTTPRequestOperation` with a `DELETE` request, and enqueues it to the HTTP client's operation queue.
 
 @param path The path to be appended to the HTTP client's base URL and used as the request URL.
 @param parameters The parameters to be encoded and appended as the query string for the request URL.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the created request operation and the `NSError` object describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS deleteFrom:WithParameters:andHeaders:completion:].");


- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
           success:(void (^)(L7SAFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(L7SAFHTTPRequestOperation *operation, NSError *error))failure DEPRECATED_MSG_ATTRIBUTE("Use [MAS deleteFrom:WithParameters:andHeaders:requestType:responseType:completion:].");

@end




