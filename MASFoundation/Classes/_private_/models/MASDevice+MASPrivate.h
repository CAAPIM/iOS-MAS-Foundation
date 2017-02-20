//
//  MASDevice+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


@interface MASDevice (MASPrivate)
    <NSCoding>


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Initializer to perform a default initialization.
 *
 * @return Returns the newly initialized MASDevice.
 */
- (id)initWithConfiguration;


/**
 * Retrieves the instance of MASDevice from local storage, it it exists.
 *
 * @return Returns the newly initialized MASDevice or nil if none was stored.
 */
+ (MASDevice *)instanceFromStorage;


/**
 * Save the current MASDevice instance with newly provided information.
 *
 * @param info An NSDictionary containing newly provided information.
 */
- (void)saveWithUpdatedInfo:(NSDictionary *)info;


/**
 * Remove all traces of the current device.
 */
- (void)reset;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/*
 * BOOL indicator whether the signed client certificate is about to expire or not.
 * This will calculate the expiration of the client certificate and advanced client certificate renew period defined in MASConstantsPrivate.h
 */
- (BOOL)isClientCertificateExpired;


/**
 * Retrieves the device identifier that is uniquely generated for the 
 * specific device the framework is running upon.  It is Base64 encoded.
 *
 * @return Returns the unique NSString device identifier in Base64 encoding.
 */
+ (NSString *)deviceIdBase64Encoded;


/**
 * Retrieves the device's name.  It is Base64 encoded.
 *
 * @return Returns the unique NSString device name in Base64 encoding.
 */
+ (NSString *)deviceNameBase64Encoded;

@end
