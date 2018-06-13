//
//  MASMultiFactorHandler.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

/**
 MASMultiFactorHandler class is responsible to handle, and proceed original request which triggered by MASMultiFactorAuthenticator.
 */
@interface MASMultiFactorHandler : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 MASRequest object that MASMultiFactorHandler to proceed with additional information after multi factor authentication is done.
 */
@property (nonatomic, strong, nonnull) MASRequest *request;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 Designated initializer to perfrom default object initialization with MASRequest object.

 @param request MASRequest object for the original request that MASMultiFactorHandler to proceed
 @return MASMultiFactorHandler object
 */
- (instancetype _Nullable)initWithRequest:(MASRequest * _Nonnull)request;



/**
 This initializer is not available.  Please use [[MASMultiFactorHandler alloc] initWithRequest:(MASRequest *)].
 
 @return nil will always be returned with this initialization method.
 */
- (instancetype _Nullable)init NS_UNAVAILABLE;



/**
 This initializer is not available.  Please use [[MASMultiFactorHandler alloc] initWithRequest:(MASRequest *)].
 
 @return nil will always be returned with this initialization method.
 */
+ (instancetype _Nullable)new NS_UNAVAILABLE;



///--------------------------------------
/// @name Multi Factor Authentication methods
///--------------------------------------

# pragma mark - Multi Factor Authentication methods

/**
 Proceeds with additional headers that can be injected to the original request.

 @param headers NSDictionary of additional headers to be added into original request.  If no additional headers are required, nil can also be passed in.
 */
- (void)proceedWithHeaders:(NSDictionary * _Nullable)headers;



/**
 Cancels the original request with specific error defined in multi factor authentication process.

 @param error NSError of a specific error defined during multi factor authentication process.
 */
- (void)cancelWithError:(NSError * _Nullable)error;



/**
 Cancels the original request with multifactor authentication error.  The original request will receive an error with error code of MASFoundationErrorCodeMultiFactorAuthenticationCancelled, and MASFoundationErrorDomainLocal domain.
 */
- (void)cancel;

@end
