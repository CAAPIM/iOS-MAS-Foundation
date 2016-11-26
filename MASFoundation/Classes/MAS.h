//
//  MAS.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

#import "MASConstants.h"


/**
 * The top level MAS object represents the Mobile App Services SDK in it's entirety.  It
 * is where the framework lifecycle begins, and ends if necessary.  It is the front 
 * facing class where many of the configuration settings for the SDK as a whole can be 
 * found and utilized.
 */
@interface MAS : NSObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Set the name of the configuration file.  This gives the ability to set the file's name
 *  to a custom value.
 *
 *  @param fileName The NSString name of the configuration file.
 */
+ (void)setConfigurationFileName:(nonnull NSString *)fileName;



/**
 *  Sets the MASGrantFlow property.  The default is MASGrantFlowClientCredentials.
 *
 *  @param grantFlow The MASGrantFlow.
 */
+ (void)setGrantFlow:(MASGrantFlow)grantFlow;



/**
 *  Returns current MASGrantFlow property.  The default is MASGrantFlowClientCredentials.
 *
 *  @return return MASGrantFlow of current type.
 */
+ (MASGrantFlow)grantFlow;



/**
 *  Set a user login block to handle the case where the type set in 'setDeviceRegistrationType:(MASDeviceRegistrationType)'
 *  is 'MASDeviceRegistrationTypeUserCredentials'.  If it set to 'MASDeviceRegistrationTypeClientCredentials' this
 *  is not called.
 *
 *  @param login The MASUserLoginWithUserCredentialsBlock to receive the request for user credentials.
 */
+ (void)setUserLoginBlock:(nullable MASUserLoginWithUserCredentialsBlock)login;



/**
 *  Set a OTP channel selection block to handle the case where the channel for Two-factor authentication is required.
 *
 *  @param OTPChannelSelector The MASOTPChannelSelectionBlock to receive the request for OTP channels.
 */
+ (void)setOTPChannelSelectionBlock:(nullable MASOTPChannelSelectionBlock) OTPChannelSelector;



/**
 *  Set a OTP credentials block to handle the case where a Two-factor authentication is required.
 *
 *  @param oneTimePassword The MASOTPCredentialsBlock to receive the request for OTP credentials.
 */
+ (void)setOTPCredentialsBlock:(nullable MASOTPCredentialsBlock)oneTimePassword;



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
+ (void)setGatewayMonitor:(nullable MASGatewayMonitorStatusBlock)monitor;



/**
 *  Returns current MASState enumeration value.  The value can be used to determine which state SDK is currently at.
 *
 *  @return return MASState of current state.
 */
+ (MASState)MASState;


#ifdef DEBUG

/**
 *  Turn on or off the logging of the network activity with the Gateway.
 *
 *  @param enabled BOOL YES to turn on logging, NO to turn it off.
 */
+ (void)setGatewayNetworkActivityLogging:(BOOL)enabled;

#endif



///--------------------------------------
/// @name Start & Stop
///--------------------------------------

# pragma mark - Start & Stop

/**
 *  Starts the lifecycle of the MAS processes.  
 *
 *  Although an asynchronous block callback parameter is provided for response usage, 
 *  optionally you can set that to nil and the caller can observe the lifecycle 
 *  notifications instead.
 *
 *  This will load the last used JSON configuration from keychain storage.  If there was none,
 *  it will load from default JSON configuration file (msso_config.json)
 *  or JSON file with file name set through [MAS setConfigurationFileName:].
 *
 *  The MAS lifecycle notifications are:
 *
 *      MASWillStartNotification
 *      MASDidFailToStartNotification
 *      MASDidStartNotification
 *
 *  The application registration notifications are:
 *
 *      MASApplicationWillRegisterNotification
 *      MASApplicationDidFailToRegisterNotification
 *      MASApplicationDidRegisterNotification
 *
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
+ (void)start:(nullable MASCompletionErrorBlock)completion;



/**
 *  Starts the lifecycle of the MAS processes.
 *
 *  Although an asynchronous block callback parameter is provided for response usage,
 *  optionally you can set that to nil and the caller can observe the lifecycle
 *  notifications instead.
 *
 *  This will load the default JSON configuration rather than from keychain storage; if the SDK was already initialized, this method will fully stop and re-start the SDK.
 *  The default JSON configuration file should be msso_config.json or file name defined through [MAS setConfigurationFileName:].
 *  This will ignore the JSON configuration in keychain storage and replace with the default configuration.
 *
 *  The MAS lifecycle notifications are:
 *
 *      MASWillStartNotification
 *      MASDidFailToStartNotification
 *      MASDidStartNotification
 *
 *  The application registration notifications are:
 *
 *      MASApplicationWillRegisterNotification
 *      MASApplicationDidFailToRegisterNotification
 *      MASApplicationDidRegisterNotification
 *
 *  @param shouldUseDefault Boolean value of using default configuration rather than the one in keychain storage.
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
+ (void)startWithDefaultConfiguration:(BOOL)shouldUseDefault completion:(nullable MASCompletionErrorBlock)completion;



/**
 *  Starts the lifecycle of the MAS processes with given JSON configuration data.
 *  This method will overwrite JSON configuration (if they are different) that was stored in keychain.
 *
 *  Although an asynchronous block callback parameter is provided for response usage,
 *  optionally you can set that to nil and the caller can observe the lifecycle
 *
 *  The MAS lifecycle notifications are:
 *
 *      MASWillStartNotification
 *      MASDidFailToStartNotification
 *      MASDidStartNotification
 *
 *  The application registration notifications are:
 *
 *      MASApplicationWillRegisterNotification
 *      MASApplicationDidFailToRegisterNotification
 *      MASApplicationDidRegisterNotification
 *
 *  @param json       NSDictionary of JSON configuration object.
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
+ (void)startWithJSON:(nonnull NSDictionary *)jsonConfiguration completion:(nullable MASCompletionErrorBlock)completion;



/**
 *  Starts the lifecycle of the MAS processes with given JSON configuration file path.
 *  This method will overwrite JSON configuration (if they are different) that was stored in keychain.
 *
 *  Although an asynchronous block callback parameter is provided for response usage,
 *  optionally you can set that to nil and the caller can observe the lifecycle
 *
 *  The MAS lifecycle notifications are:
 *
 *      MASWillStartNotification
 *      MASDidFailToStartNotification
 *      MASDidStartNotification
 *
 *  The application registration notifications are:
 *
 *      MASApplicationWillRegisterNotification
 *      MASApplicationDidFailToRegisterNotification
 *      MASApplicationDidRegisterNotification
 *
 *  @param url       NSURL of JSON configuration file path.
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
+ (void)startWithURL:(nonnull NSURL *)url completion:(nullable MASCompletionErrorBlock)completion;



/**
 *  Stops the lifecycle of all MAS processes.
 *
 *  Although an asynchronous block callback parameter is provided for response usage, 
 *  optionally you can set that to nil and the caller can observe the lifecycle 
 *  notifications instead.
 *
 *  The lifecycle notifications are:
 *
 *      MASWillStopNotification
 *      MASDidFailToStopNotification
 *      MASDidStopNotification
 *
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
+ (void)stop:(nullable MASCompletionErrorBlock)completion;



///--------------------------------------
/// @name Gateway Monitoring
///--------------------------------------

# pragma mark - Gateway Monitoring

/**
 *  Retrieves a simple boolean indicator if the gateway is currently reachable or not.
 *
 *  @return Returns YES if it is reachable, NO if not.
 */
+ (BOOL)gatewayIsReachable;



/**
 *  Retrieves the current gateway monitoring status of the Gateway connection.
 *
 *  The monitoring status enumerated values to their string equivalents are:
 *
 *      MASGatewayMonitoringStatusNotReachable = "Not Reachable"
 *      MASGatewayMonitoringStatusReachableViaWWAN = "Reachable Via WWAN"
 *      MASGatewayMonitoringStatusReachableViaWiFi = "Reachable Via WiFi"
 *
 *  @return Returns the gateway monitoring status as a human readable NSString.
 */
+ (nonnull NSString *)gatewayMonitoringStatusAsString;



///--------------------------------------
/// @name HTTP Requests
///--------------------------------------

# pragma mark - HTTP Requests

/**
 *  Request method for an HTTP DELETE call from the Gateway.  This type of HTTP Method type
 *  places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *      https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 *  This version defaults the request/response content type encoding to JSON.
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)deleteFrom:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerInfo
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP DELETE call from the Gateway.  This type of HTTP Method type
 *  places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *      https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 *  This version defaults the request/response content type encoding to JSON.
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param requestType The mime type content encoding expected for the parameter encoding.
 *  @param responseType The mime type expected in the body of the response.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)deleteFrom:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerInfo
      requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP GET call from the Gateway.  This type of HTTP Method type
 *  places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *      https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 *  This version defaults the request/response content type encoding to JSON.
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)getFrom:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerInfo
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP GET call from the Gateway.  This type of HTTP Method type
 *  places it's parameters within the NSURL itself as an HTTP query extension as so:
 *
 *      https://<hostname>:<port>/<endPointPath><?type=value&type2=value2&...>
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param requestType The mime type content encoding expected for the parameter encoding.
 *  @param responseType The mime type expected in the body of the response.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)getFrom:(nonnull NSString *)endPointPath
     withParameters:(nullable NSDictionary *)parameterInfo
         andHeaders:(nullable NSDictionary *)headerInfo
       requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
         completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP PATCH call to the Gateway.  This type of HTTP Method type
 *  places it's parameters within the HTTP body in www-form-url-encoded format:
 *
 *      <body>
 *          <type=value&type2=value2&...>
 *      </body>
 *
 *  This version defaults the request/response content type encoding to JSON.
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)patchTo:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerInfo
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP PATCH call to the Gateway.  This type of HTTP Method type
 *  places it's parameters within the HTTP body in www-form-url-encoded format:
 *
 *      <body>
 *          <type=value&type2=value2&...>
 *      </body>
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param requestType The mime type content encoding expected for the parameter encoding.
 *  @param responseType The mime type expected in the body of the response.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)patchTo:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerInfo
      requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP POST call to the Gateway.  This type of HTTP Method type
 *  places it's parameters within the HTTP body in www-form-url-encoded format:
 *
 *      <body>
 *          <type=value&type2=value2&...>
 *      </body>
 *
 *  This version defaults the request/response content type encoding to JSON.
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerinfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)postTo:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerinfo
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP POST call to the Gateway.  This type of HTTP Method type
 *  places it's parameters within the HTTP body in www-form-url-encoded format:
 *
 *      <body>
 *          <type=value&type2=value2&...>
 *      </body>
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerinfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param requestType The mime type content encoding expected for the parameter encoding.
 *  @param responseType The mime type expected in the body of the response.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)postTo:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerinfo
      requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP PUT call to the Gateway.  This type of HTTP Method type
 *  places it's parameters within the HTTP body in www-form-url-encoded format:
 *
 *      <body>
 *          <type=value&type2=value2&...>
 *      </body>
 *
 *  This version defaults the request/response content type encoding to JSON.
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)putTo:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerInfo
        completion:(nullable MASResponseInfoErrorBlock)completion;



/**
 *  Request method for an HTTP PUT call to the Gateway.  This type of HTTP Method type
 *  places it's parameters within the HTTP body in www-form-url-encoded format:
 *
 *      <body>
 *          <type=value&type2=value2&...>
 *      </body>
 *
 *  @param endPointPath The specific end point path fragment NSString to append to the base
 *      Gateway URL.
 *  @param parameterInfo An NSDictionary of key/value parameter values that will go into the
 *      query portion of the URL.
 *  @param headerInfo An NSDictionary of key/value header values that will go into the HTTP
 *      header.
 *  @param requestType The mime type content encoding expected for the parameter encoding.
 *  @param responseType The mime type expected in the body of the response.
 *  @param completion An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will
 *      receive the JSON response object or an NSError object if there is a failure.
 */
+ (void)putTo:(nonnull NSString *)endPointPath
    withParameters:(nullable NSDictionary *)parameterInfo
        andHeaders:(nullable NSDictionary *)headerInfo
      requestType:(MASRequestResponseType)requestType
      responseType:(MASRequestResponseType)responseType
        completion:(nullable MASResponseInfoErrorBlock)completion;



#ifdef DEBUG

///--------------------------------------
/// @name Debug Only
///--------------------------------------

# pragma mark - Debug only

/**
 *  Method for debug purposes to view the current runtime contents of the framework on the
 *  debug console.  The debugDescription results of the MASNetworkingService, MASApplication,
 *  MASDevice and MASUser are shown if available.
 *
 *  This will not be compiled into release versions of an application.
 */
+ (void)currentStatusToConsole;

#endif

@end
