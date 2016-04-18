//
//  MASSessionSharingQRCode.h
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

@class MASAuthenticationProvider;


/**
 * The `MASSessionSharingQRCode` class is a local representation of QR Code authentication provider data and handle necessary logic.
 */
@interface MASSessionSharingQRCode : MASObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Polling interval in seconds for QR Code Session Sharing
 */
@property (nonatomic, assign, readonly) NSNumber *pollingInterval;


/**
 *  Initial delay in seconds to make polling request for QR Code authorization
 */
@property (nonatomic, assign, readonly) NSNumber *pollingDelay;


/**
 *  Limit for number of polling requests for QR Code authorization
 */
@property (nonatomic, assign, readonly) NSNumber *pollingLimit;


/**
 *  Counter for current number of polling reuqests made.
 */
@property (nonatomic, assign, readonly) int currentPollingCounter;


/**
 *  Boolean indicator of polling request is in progress or not.
 */
@property (nonatomic, assign, readonly) BOOL isPolling;


/**
 *  NSString of authentication URL
 */
@property (nonatomic, copy, readonly) NSString *authenticationUrl;


/**
 *  NSString of polling URL
 */
@property (nonatomic, copy, readonly) NSString *pollUrl;


# pragma mark - Lifecycle

/**
 *  Init the object with given values.
 *  Property values cannot be changed once it is initialized.
 *
 *  @param provider        MASAuthenticationProvider object with authenticationUrl and pollUrl for QR Code.
 *  @param initDelay       NSNumber of initial delay in seconds to start making a request to poll for authorization.
 *  @param pollingInterval NSNumber of interval for polling requests.
 *  @param pollingLimit    NSNumber of limit counter for number of polling requests.
 *
 *  @return MASSessionSharingQRCode object
 */
- (instancetype)initWithAuthenticationProvider:(MASAuthenticationProvider *)provider initialDelay:(NSNumber *)initDelay pollingInterval:(NSNumber *)pollingInterval pollingLimit:(NSNumber *)pollingLimit;


/**
 *  Init the object with authentication provider and default values for polling configurations
 *  Default values for the objects are
 *
 *  pollingDelay : 10 seconds
 *  pollingInterval : 5 seconds
 *  pollingLimit : 6 times
 *
 *  @param provider MASAuthenticationProvider object with authenticationUrl and pollUrl for QR Code.
 *
 *  @return MASSessionSharingQRCode object
 */
- (instancetype)initWithAuthenticationProvider:(MASAuthenticationProvider *)provider;


# pragma mark - Start/Stop displaying QR Code image

/**
 *  Generates QR Code image for session sharing based on provided authentication provider and starts polling request for authorization.
 *  Upon successful start display, NSNotification with notification name, MASSessionSharingQRCodeDidStartDisplayingQRCodeImage, will be sent.
 *
 *  @return UIImage of QR Code.
 */
- (UIImage *)startDisplayingQRCodeImageForSessionSharing;


/**
 *  Stops displaying QR Code image for session sharing based on provided polling configuration.  
 *  Upon successful stop display, NSNotification with notification name, MASSessionSharingQRCodeDidStopDisplayingQRCodeImage, will be sent.
 */
- (void)stopDisplayingQRCodeImageForSessionSharing;


# pragma mark - Authorize authenticateUrl for session sharing

/**
 *  Authorize given authenticateUrl with gateway.  Method will validate authenticateUrl, and send it over to gateway to authorize.
 *
 *  @param authenticateUrl NSString of authenticateUrl.
 *  @param completion      MASCompletionErrorBlock to notify caller for the result.
 */
+ (void)authorizeAuthenticateUrl:(NSString *)authenticateUrl completion:(MASCompletionErrorBlock)completion;

@end
