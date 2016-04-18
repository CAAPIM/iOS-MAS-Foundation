// MASINetworkActivityLogger.h
//
// Copyright (c) 2013 MASINetworking (http://MASINetworking.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@import Foundation;

typedef NS_ENUM(NSUInteger, MASIHTTPRequestLoggerLevel) {
  MASILoggerLevelOff,
  MASILoggerLevelDebug,
  MASILoggerLevelInfo,
  MASILoggerLevelWarn,
  MASILoggerLevelError,
  MASILoggerLevelFatal = MASILoggerLevelOff,
};

/**
 `MASINetworkActivityLogger` logs requests and responses made by MASINetworking, with an adjustable level of detail.
 
 Applications should enable the shared instance of `MASINetworkActivityLogger` in `AppDelegate -application:didFinishLaunchingWithOptions:`:

        [[MASINetworkActivityLogger sharedLogger] startLogging];
 
 `MASINetworkActivityLogger` listens for `MASINetworkingOperationDidStartNotification` and `MASINetworkingOperationDidFinishNotification` notifications, which are posted by MASINetworking as request operations are started and finish. For further customization of logging output, users are encouraged to implement desired functionality by listening for these notifications.
 */
@interface MASINetworkActivityLogger : NSObject

/**
 The level of logging detail. See "Logging Levels" for possible values. `MASILoggerLevelInfo` by default.
 */
@property (nonatomic, assign) MASIHTTPRequestLoggerLevel level;

/**
 Omit requests which match the specified predicate, if provided. `nil` by default.
 
 @discussion Each notification has an associated `NSURLRequest`. To filter out request and response logging, such as all network activity made to a particular domain, this predicate can be set to match against the appropriate URL string pattern.
 */
@property (nonatomic, strong) NSPredicate *filterPredicate;

/**
 Returns the shared logger instance.
 */
+ (instancetype)sharedLogger;

/**
 Start logging requests and responses.
 */
- (void)startLogging;

/**
 Stop logging requests and responses.
 */
- (void)stopLogging;

@end

///----------------
/// @name Constants
///----------------

/**
 ## Logging Levels

 The following constants specify the available logging levels for `MASINetworkActivityLogger`:

 enum {
 MASILoggerLevelOff,
 MASILoggerLevelDebug,
 MASILoggerLevelInfo,
 MASILoggerLevelWarn,
 MASILoggerLevelError,
 MASILoggerLevelFatal = MASILoggerLevelOff,
 }

 `MASILoggerLevelOff`
 Do not log requests or responses.

 `MASILoggerLevelDebug`
 Logs HTTP method, URL, header fields, & request body for requests, and status code, URL, header fields, response string, & elapsed time for responses.
 
 `MASILoggerLevelInfo`
 Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses.

 `MASILoggerLevelWarn`
 Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses, but only for failed requests.
 
 `MASILoggerLevelError`
 Equivalent to `MASILoggerLevelWarn`

 `MASILoggerLevelFatal`
 Equivalent to `MASILoggerLevelOff`
*/
