//
//  MASOTPService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

#import "MASConstantsPrivate.h"


/**
 *  The `MASOTPService` class is a service class that provides interfaces of 
 *  Two-factor authentication related services.
 */
@interface MASOTPService : MASService



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Set a OTP channel selection block to handle the case where the channel for Two-factor authentication is required.
 *
 *  @param OTPChannelSelector The MASOTPChannelSelectionBlock to receive the request for OTP channels.
 */
+ (void)setOTPChannelSelectionBlock:(MASOTPChannelSelectionBlock)OTPChannelSelector;



/**
 *  Set a OTP credentials block to handle the case where a Two-factor authentication is required.
 *
 *  @param oneTimePassword The MASOTPCredentialsBlock to receive the request for OTP credentials.
 */
+ (void)setOTPCredentialsBlock:(MASOTPCredentialsBlock)oneTimePassword;



///--------------------------------------
/// @name OTP Session Validation
///--------------------------------------

# pragma mark - OTP Session Validation

/**
 *  Validate the current request's otp session information.
 *  This method will go through the validation process of error codes related to OTP flow.
 *
 *  @param responseHeaderInfo    the value will be an NSDictionary of key/value pairs from the HTTP response header.
 *  @param completion            An MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) that will receive the one time password object and user selected otp channels or an NSError object if there is a failure.
 */
- (void)validateOTPSessionWithResponseHeaders:(NSDictionary *)responseHeaderInfo
                              completionBlock:(MASResponseInfoErrorBlock)completion;

@end
