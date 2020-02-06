//
//  MASAuthenticationProvider.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


/**
 * The `MASAuthenticationProvider` class is a representation of a single provider.
 */
@interface MASAuthenticationProvider : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The MASAuthenticationProvider identifier.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *identifier;


/**
 * The MASAuthenticationProvider URL.
 */
@property (nonatomic, copy, readonly, nonnull) NSURL *authenticationUrl;


/**
 *  The MASAuthenticationProvider polling URL, only applicable to QR codes.  
 *  Nil for social login providers.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *pollUrl;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Does the MASAuthenticationProvider represent Enterprise.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isEnterprise;


/**
 * Does the MASAuthenticationProvider represent Facebook.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isFacebook;


/**
 * Does the MASAuthenticationProvider represent Google.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isGoogle;


/**
 * Does the MASAuthenticationProvider represent LinkedIn.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isLinkedIn;


/**
 * Does the MASAuthenticationProvider represent a QR code provider.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isQrCode;


/**
 * Does the MASAuthenticationProvider represent Salesforce.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isSalesforce;

@end
