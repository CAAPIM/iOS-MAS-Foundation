//
//  MASProximityLoginQRCode+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

@interface MASProximityLoginQRCode (MASPrivate)

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
 *  @return MASProximityLoginQRCode object
 */
- (instancetype)initPrivateWithAuthenticationUrl:(NSString *)authUrl pollingUrl:(NSString *)pollingUrl initialDelay:(NSNumber *)initDelay pollingInterval:(NSNumber *)pollingInterval pollingLimit:(NSNumber *)pollingLimit;


# pragma mark - Start/Stop displaying QR Code image : Private

/**
 *  Generates QR Code image for proximity login based on provided authentication provider and starts polling request for authorization.
 *  Upon successful start display, NSNotification with notification name, MASProximityLoginQRCodeDidStartDisplayingQRCodeImage, will be sent.
 *
 *  @return UIImage of QR Code.
 */
- (UIImage *)startPrivateDisplayingQRCodeImageForProximityLogin;


/**
 *  Stops displaying QR Code image for proximity login based on provided polling configuration.
 *  Upon successful stop display, NSNotification with notification name, MASProximityLoginQRCodeDidStopDisplayingQRCodeImage, will be sent.
 */
- (void)stopPrivateDisplayingQRCodeImageForProximityLogin;


@end
