//
//  MASMultiFactorAuthenticator.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@class MASRequest;
@class MASMultiFactorHandler;

/**
 MASMultiFactorAuthenticator protocol definition that needs to be implemented in custom MFA class.  A custom MFA class must implement protocols to adhere and properly handle Multi Factor Authentication flow.
 */
@protocol MASMultiFactorAuthenticator <NSObject>

@required

/**
 A protocol method that determines whether the custom MFA object can or will handle flow based on the response of the original request.
 The method will only be triggered when the original request failed, and the original request is not one of MAG/OTK's system endpoints.
 
 The method will provide original request, and response as arguments in the method, and the original request must be used to initialize MASMultiFactorHandler object.
 
 If the custom MFA class can or will handle the MFA flow based on the error codes, or response of the request, the method should return MASMultiFactorHandler class.
 If nil is returned from the method, the original request will deliver the result as it was.

 @warning If the custom class is intended to handle MFA flow based on the response, MASMultiFactorHandler MUST be returned from this method; otherwise, the custom MFA flow will be ignored.  Also, [MASMultiFactorAuthenticator onMultiFactorAuthenticationRequest:response:handler:] MUST be implemented as well to properly handle MFA flow.
 @param request MASRequest object of the original request that must be initialized with for MASMultiFactorHandler
 @param response NSURLResponse of the original request which contains the header, HTTP status code and other information
 @return MASMultiFactorHandler object if the custom class will handle MFA flow
 */
- (MASMultiFactorHandler * _Nullable)getMultiFactorHandler:(MASRequest * _Nonnull)request response:(NSURLResponse * _Nonnull)response;



/**
 A protocol method that performs custom logic of Multi Factor Authentication.
 The method will be triggered when MASFoundation detects that the custom MFA class is responsible to handle MFA flow.
 
 @warning Custom multi factor authentication logic should be implemented within this method, and MASMultiFactorHandler's [MASMultiFactorHandler's proceedWithHeaders:],
 [MASMultiFactorHandler cancelWithError:] or [MASMultiFactorHandler cancel].
 @param request MASRequest object of the original request.
 @param response NSURLResponse object of the original request.
 @param handler MASMultiFactorHandler that must be handled after validation of custom MFA logic.
 */
- (void)onMultiFactorAuthenticationRequest:(MASRequest * _Nonnull)request response:(NSURLResponse * _Nonnull)response handler:(MASMultiFactorHandler * _Nonnull)handler;

@end
