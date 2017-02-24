//
//  MASServiceRegistry.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

#import "MASConstants.h"

@class MASService;


/**
 *
 */
typedef NS_ENUM(NSInteger, MASRegistryState)
{
    MASRegistryStateUnknown = -1,
    MASRegistryStateWillStart,
    MASRegistryStateStarted,
    MASRegistryStateWillStop,
    MASRegistryStateStopped,
    MASRegistryStateShouldStop,
    MASRegistryStateCount
};


/**
 *
 */
@interface MASServiceRegistry : NSObject



///--------------------------------------
/// @name Properties
///-------------------------------------

# pragma mark - Properties

/**
 * The current MASRegistryState of the MASRegistry.
 */
@property (nonatomic, assign, readonly) MASRegistryState state;


/**
 * The known MASService instances.
 */
@property (nonatomic, strong, readonly) NSMutableArray *services;


/**
 * Detect if the UI handling framework is present.  It is an optional
 * set of functionality that can be included in applications.
 */
@property (nonatomic, assign, readonly) BOOL uiHandlingIsPresent;


/**
 * The service that has been detected to handle any UI.  It is an
 * optional set of functionality.
 */
@property (nonatomic, strong, readonly) MASService *uiService;



///--------------------------------------
/// @name Shared Registry
///-------------------------------------

# pragma mark - Shared Registry

/**
 * Retrieve the shared MASServiceRegistry singleton.
 *
 * @return Returns the shared MASServiceRegistry singleton.
 */
+ (instancetype)sharedRegistry;



///--------------------------------------
/// @name Lifecycle
///-------------------------------------

# pragma mark - Lifecycle

/**
 *  Initiates the lifecycle to start the MASServiceRegistry.  This includes the startup lifecycles of all
 *  resident MASServices.
 *
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
- (void)startWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Initiates the lifecycle to stop the MASServiceRegistry.  This includes the stop lifecycles of all
 *  resident MASServices.
 *
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
- (void)stopWithCompletion:(MASCompletionErrorBlock)completion;


/**
 *  Initiates the lifecycle to reset the MASServiceRegistry and it's MASServices to their default 
 *  installation state on the device.  This does NOT affect the Gateway data in any way.
 *
 *  @param completion An MASCompletionErrorBlock type (BOOL completed, NSError *error) that will
 *      receive a YES or NO BOOL indicating the completion state and/or an NSError object if there
 *      is a failure.
 */
- (void)resetWithCompletion:(MASCompletionErrorBlock)completion;



///--------------------------------------
/// @name Registry State
///-------------------------------------

# pragma mark - Registry State

/**
 * Retrieve a human readable string value for the current MASRegistryState.
 */
- (NSString *)registryStateAsString;


/**
 * Retrieve a human readable string value for the given MASRegistryState.
 */
+ (NSString *)registryStateToString:(MASRegistryState)state;



///--------------------------------------
/// @name UI Service
///-------------------------------------

# pragma mark - UI Service

/**
 * Calling this method will attempt to have a resident UI service handle authentication steps.
 *
 * @param basicBlock The MASBasicCredentialsBlock to receive username/password responses.
 * @param authorizationCode The MASAuthorizationCodeCredentialsBlock to receive the authentication 
 *   provider code response.
 * @returns Return YES if handled, NO if not.
 */
- (BOOL)uiServiceWillHandleBasicAuthentication:(MASBasicCredentialsBlock)basicBlock
    authorizationCodeBlock:(MASAuthorizationCodeCredentialsBlock)authorizationCodeBlock;



/**
 * Calling this method will attempt to have a resident UI service handle OTP authentication steps.
 *
 * @param otpBlock The MASOTPFetchCredentialsBlock to receive OTP responses.
 * @param otpError The NSError object to provide the information about the OTP
 *   related error information.
 * @returns Return YES if handled, NO if not.
 */

- (BOOL)uiServiceWillHandleOTPAuthentication:(MASOTPFetchCredentialsBlock)otpBlock
                                       error:(NSError *)otpError;



/**
 * Calling this method will attempt to have a resident UI service handle otp channel selection steps.
 *
 * @param supportedChannels The server supported OTP channels.
 * @param generationBlock The MASOTPGenerationBlock to receive the selected OTP channels response.
 * @returns Return YES if handled, NO if not.
 */

- (BOOL)uiServiceWillHandleOTPChannelSelection:(NSArray *)supportedChannels
                            otpGenerationBlock:(MASOTPGenerationBlock)generationBlock;

@end
