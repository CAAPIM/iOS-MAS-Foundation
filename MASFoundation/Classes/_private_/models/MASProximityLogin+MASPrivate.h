//
//  MASProximityLogin+MASPrivate.h
//  MASFoundation
//
//  Created by Hun Go on 2016-06-03.
//  Copyright © 2016 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>

@interface MASProximityLogin (MASPrivate)

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, assign, readwrite) NSNumber *pollingInterval;
@property (nonatomic, assign, readwrite) NSNumber *pollingDelay;
@property (nonatomic, assign, readwrite) NSNumber *pollingLimit;
@property (nonatomic, copy, readwrite) NSString *authenticationUrl;
@property (nonatomic, copy, readwrite) NSString *pollUrl;
@property (nonatomic, assign, readwrite) int currentPollingCounter;
@property (nonatomic, assign, readwrite) BOOL isPolling;


# pragma mark - Lifecycle

/**
 *  Init the object with given values.
 *  Property values cannot be changed once it is initialized.
 *
 *  @param provider        MASAuthenticationProvider object with authorizationURL and pollingURL for QR Code.
 *  @param initDelay       NSNumber of initial delay in seconds to start making a request to poll for authorization.
 *  @param pollingInterval NSNumber of interval for polling requests.
 *  @param pollingLimit    NSNumber of limit counter for number of polling requests.
 *
 *  @return MASSessionSharingQRCode object
 */
- (instancetype)initPrivateWithAuthenticationUrl:(NSString *)authUrl pollingUrl:(NSString *)pollingUrl initialDelay:(NSNumber *)initDelay pollingInterval:(NSNumber *)pollingInterval pollingLimit:(NSNumber *)pollingLimit;


# pragma mark - Start/Stop displaying QR Code image : Private

/**
 *  Generates QR Code image for session sharing based on provided authentication provider and starts polling request for authorization.
 *  Upon successful start display, NSNotification with notification name, MASSessionSharingQRCodeDidStartDisplayingQRCodeImage, will be sent.
 *
 *  @return UIImage of QR Code.
 */
- (UIImage *)startPrivateDisplayingQRCodeImageForSessionSharing;


/**
 *  Stops displaying QR Code image for session sharing based on provided polling configuration.
 *  Upon successful stop display, NSNotification with notification name, MASSessionSharingQRCodeDidStopDisplayingQRCodeImage, will be sent.
 */
- (void)stopPrivateDisplayingQRCodeImageForSessionSharing;



@end
