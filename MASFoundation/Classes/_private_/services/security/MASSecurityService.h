//
//  MASSecurityService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;

@class MASApplication;
@class MASDevice;
@class MASFile;
@class MASUser;

#import "MASService.h"


@interface MASSecurityService : MASService



///--------------------------------------
/// @name Shared Service
///--------------------------------------

# pragma mark - Shared Service

/**
 * Retrieve the shared, singleton service.
 *
 * @return Returns the MASSecurityService singleton.
 */
+ (instancetype)sharedService;



///--------------------------------------
/// @name Keys
///--------------------------------------

# pragma mark - Keys

/**
 * Creates a NSURLCredential instance.
 *
 * @return Returns the NSURLCredential based on the server certificate and the private key.
 */
- (NSURLCredential *)createUrlCredential;



/**
 * Delete any existing asymmetic keys.
 */
- (void)deleteAsymmetricKeys;



/**
 * Generate a certificate signing request with a given user name.
 * 
 * @param userName The username to add to the request.
 * @return Returns the CSR as an encocded NSString.  The encoding used is NSNEXTSTEPStringEncoding.
 */
- (NSString *)generateCSRWithUsername:(NSString *)userName;



/**
 * Generate a public/private keypair.
 */
- (void)generateKeypair;



///--------------------------------------
/// @name MASFile Security
///--------------------------------------

# pragma mark - MASFile Security

/**
 *  Generate MASFile object for current gateway's signed certificate.
 *
 *  @return Returns MASFile object of signed certificate for current configuration's gateway.
 */
- (MASFile *)getSignedCertificate;



/**
 *  Generate MASFile object for current gateway's client certificate.
 *
 *  @return Returns MASFile object of client certificate for current configuration's gateway.
 */
- (MASFile *)getClientCertificate;



/**
 *  Generate MASFile object for current gateway's private key.
 *
 *  @return Returns MASFile object of private key for current configuration's gateway.
 */
- (MASFile *)getPrivateKey;



/**
 *  Remove all necessary files upon de-registration.
 */
- (void)removeAllFiles;

@end
