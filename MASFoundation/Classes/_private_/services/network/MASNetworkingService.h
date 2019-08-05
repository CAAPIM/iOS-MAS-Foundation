//
// MASFoundationService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"
#import "MASConstantsPrivate.h"
#import "MASMultiFactorAuthenticator.h"
#import "MASObject.h"
#import "MASAuthValidationOperation.h"

typedef NSURLRequest* (^MASSessionDataTaskHTTPRedirectBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request);

@interface MASNetworkingService : MASService



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 Http redirection block. Set this block only if you want to handle the redirection coming from the original NSURLRequest.
 */
@property (nonatomic) MASSessionDataTaskHTTPRedirectBlock httpRedirectionBlock;



/**
 Constructs, if not exist, the shared operation that validates current session's registration and authentication status

 @return MASAuthValidationOperation object
 */
- (MASAuthValidationOperation *)sharedOperation;



///--------------------------------------
/// @name Network Reachability
///--------------------------------------

# pragma mark - Network Reachability

/**
 *  Sets the gateway monitoring block defined by the GatewayMonitorStatusBlock type.
 *  This block will be triggered when any change to the current monitoring status
 *  takes place with a MASGatewayMonitoringStatus.
 *
 *  The gateway monitoring status enumerated values are:
 *
 *      MASGatewayMonitoringStatusNotReachable
 *      MASGatewayMonitoringStatusReachableViaWWAN
 *      MASGatewayMonitoringStatusReachableViaWiFi
 *
 *  This is optional and it can be set to nil at any time to stop receiving the notifications.
 *
 *  @param monitor The MASGatewayMonitorStatusBlock that will receive the status updates.
 */
+ (void)setGatewayMonitor:(MASGatewayMonitorStatusBlock)monitor;



/**
 Sets the network reachability monitoring block for the specified hostname.
 The host can be either in DNS format, or IP address format.  If the host is defined as DNS format, the host should be defined without URL scheme, and port number.
 
 This block will be triggered when any change to the current monitoring status of the host.
 
 Available monitoring status enumerated values are:
 
 MASNetworkReachabilityStatusUnknown
 MASNetworkReachabilityStatusNotReachable
 MASNetworkReachabilityStatusReachableViaWWAN
 MASNetworkReachabilityStatusReachableViaWiFi
 MASNetworkReachabilityStatusInitializing
 
 This is optional and it can be set to nil at any time to stop receiving the notifications.

 @param host NSString value of the host to be monitored. Host value should be either DNS format of hostname, or IP address without URL scheme and port.
 @param monitor MASNetworkReachabilityStatusBlock that will update the reachability status.
 */
+ (void)setNetworkReachabilityMonitorForHost:(NSString *)host monitor:(MASNetworkReachabilityStatusBlock)monitor;



/**
 Returns a simple boolean indicator if the specified host is reachable or not.

 @param host NSString value of the host to be monitored. Host value should be either DNS format of hostname, or IP address without URL scheme and port.
 @return Returns YES if it is reachable, NO if not.
 */
+ (BOOL)isNetworkReachableForHost:(NSString *)host;



/**
 Sets or updates gateway reachability monitoring block
 
 @param monitoringBlock MASNetworkReachabilityStatusBlock callback
 */
- (void)setGatewayReachabilityMonitoringBlock:(MASNetworkReachabilityStatusBlock)monitoringBlock;



/**
 *  Debug property to view the network REST calls requests/responses on the console.
 *  Default is NO.
 *
 *  @param enabled YES to log network activity, NO to not.
 */
+ (void)setGatewayNetworkActivityLogging:(BOOL)enabled;



///--------------------------------------
/// @name Multi Factor Authenticator
///--------------------------------------

# pragma mark - Multi Factor Authenticator

+ (void)registerMultiFactorAuthenticator:(MASObject<MASMultiFactorAuthenticator> *)multiFactorAuthenticator;



///--------------------------------------
/// @name Network Monitoring
///--------------------------------------

# pragma mark - Public

/**
 Release operation queue for API requests, if the queue was suspended.
 */
- (void)releaseOperationQueue;


/**
 *  Establish URLSession with given URL and SessionConfiguration to trigger URL authentication challenge with stored certificate
 */
- (void)establishURLSession;



///--------------------------------------
/// @name Network Monitoring
///--------------------------------------

# pragma mark - Network Monitoring

/**
 * Retrieves a simple boolean indicator if the network is currently reachable or not.
 *
 * @return Returns YES if it is reachable, NO if not.
 */
- (BOOL)networkIsReachable;


/**
 * Retrieves the current monitoring status of the network connection.
 *
 * The monitoring status emumerated values to their string equivalents are:
 *
 *     MASGatewayMonitoringStatusNotReachable = "Not Reachable"
 *     MASGatewayMonitoringStatusReachableViaWWAN = "Reachable Via WWAN"
 *     MASGatewayMonitoringStatusReachableViaWiFi = "Reachable Via WiFi"
 *
 * @return Returns the monitoring status as a human readable NSString.
 */
- (NSString *)networkStatusAsString;



///--------------------------------------
/// @name HTTP Requests
///--------------------------------------

# pragma mark - HTTP Requests

/**
 * Request method for an HTTP DELETE call from the Gateway.  This type of HTTP Method type 
 * places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *     https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 * This version defaults the request/response content type encoding to JSON.
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
        completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP DELETE call from the Gateway.  This type of HTTP Method type
 * places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *     https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP DELETE call from the Gateway.  This type of HTTP Method type 
 * places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *     https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param isPublic Represents whether to include or exclude necessary credentials of MAG to inject in the header of the request.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)deleteFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
          isPublic:(BOOL)isPublic
        completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP GET call from the Gateway.  This type of HTTP Method type 
 * places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *     https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 * This version defaults the request/response content type encoding to JSON.
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)getFrom:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
        completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP GET call from the Gateway.  This type of HTTP Method type
 * places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *     https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
     completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP GET call from the Gateway.  This type of HTTP Method type
 * places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *     https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param isPublic Represents whether to include or exclude necessary credentials of MAG to inject in the header of the request.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)getFrom:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
     completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP PATCH call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * This version defaults the request/response content type encoding to JSON.
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)patchTo:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
        completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP PATCH call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
     completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP PATCH call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param isPublic Represents whether to include or exclude necessary credentials of MAG to inject in the header of the request.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)patchTo:(NSString *)endPoint
 withParameters:(NSDictionary *)parameterInfo
     andHeaders:(NSDictionary *)headerInfo
    requestType:(MASRequestResponseType)requestType
   responseType:(MASRequestResponseType)responseType
       isPublic:(BOOL)isPublic
     completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP POST call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * This version defaults the request/response content type encoding to JSON.
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)postTo:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
        completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP POST call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
    completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP POST call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param isPublic Represents whether to include or exclude necessary credentials of MAG to inject in the header of the request.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)postTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
    andHeaders:(NSDictionary *)headerInfo
   requestType:(MASRequestResponseType)requestType
  responseType:(MASRequestResponseType)responseType
      isPublic:(BOOL)isPublic
    completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP PUT call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * This version defaults the request/response content type encoding to JSON.
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)putTo:(NSString *)endPoint
    withParameters:(NSDictionary *)parameterInfo
        andHeaders:(NSDictionary *)headerInfo
        completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP PUT call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
  requestType:(MASRequestResponseType)requestType
 responseType:(MASRequestResponseType)responseType
   completion:(MASResponseInfoErrorBlock)completion;


/**
 * Request method for an HTTP PUT call to the Gateway.  This type of HTTP Method type
 * places it's parameters within the HTTP body in www-form-urlencoded format:
 *
 *     <body>
 *         <type=value&type2=value2&...>
 *     </body>
 *
 * @param endPointPath The specific end point path fragment NSString to append to the base
 *     Gateway URL.
 * @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *     query portion of the URL.
 * @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *     header.
 * @param requestType The expected content type encoding for the parameter values.
 * @param responseType The expected content type encoding for any response data.
 * @param isPublic Represents whether to include or exclude necessary credentials of MAG to inject in the header of the request.
 * @param completion An MASResponseInfoErrorBlock type (NSDictionary *responseInfo, NSError *error) that will
 *     receive the NSDictionary responseInfo and an NSError object if there is a failure.
 *
 * The responseInfo can have two keys:
 *
 *     MASResponseInfoHeaderInfoKey: the value will be an NSDictionary of key/value pairs from the HTTP header.
 *     MASResponseInfoBodyInfoKey: the value will be an NSObject of some kind that is expected in the body of
 *                                    the particular request (optional)
 */
- (void)putTo:(NSString *)endPoint
withParameters:(NSDictionary *)parameterInfo
   andHeaders:(NSDictionary *)headerInfo
  requestType:(MASRequestResponseType)requestType
 responseType:(MASRequestResponseType)responseType
     isPublic:(BOOL)isPublic
   completion:(MASResponseInfoErrorBlock)completion;



# pragma mark - HTTP File Requests

- (void)postMultiPartForm:(NSString*)endPoint withParameters:(NSDictionary *)parameterInfo andHeaders:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic constructingBodyBlock:(nonnull MASMultiPartFormDataBlock)formDataBlock progress:(MASFileRequestProgressBlock)progress completion:(MASResponseObjectErrorBlock)completion;

@end

