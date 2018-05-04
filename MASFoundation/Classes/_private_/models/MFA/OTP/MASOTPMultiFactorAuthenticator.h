//
//  MASOTPMultiFactorAuthenticator.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


/**
 MASOTPMultiFactorAuthenticator class is responsible to handle multi factor authentication for MAG's One Time Password.  This class can also be used as an example of utilizing MASMultiFactorAuthenticator class.
 */
@interface MASOTPMultiFactorAuthenticator : MASObject <MASMultiFactorAuthenticator>

///--------------------------------------
/// @name Multi Factor Authentication methods
///--------------------------------------

# pragma mark - Multi Factor Authentication methods

/**
 One of MASMultiFactorAuthenticator protocol method that needs to be implemented.  The method is responsible to determine whether OTP needs to be handled based on the response from the API.

 @param request MASRequest object of the original request
 @param response NSHTTPURLResponse object of the original request
 @return MASMultiFactorHandler object will be returned if MASOTPMultiFactorAuthenticator will intercept the process and proceed with OTP flow.
 */
- (MASMultiFactorHandler * _Nullable)getMultiFactorHandler:(MASRequest * _Nonnull)request response:(NSHTTPURLResponse * _Nonnull)response;



/**
 One of MASMultiFactorAuthenticator protocol method that needs to be implemented.  The method is responsible to perform OTP process as required, and to decide whether to proceed or cancel the original request based on OTP flow.

 @param request MASRequest object of the original request
 @param handler MASMultiFactorHandler to proceed or cancel the original request.
 */
- (void)onMultiFactorAuthenticationRequest:(MASRequest * _Nonnull)request handler:(MASMultiFactorHandler * _Nonnull)handler;

@end
