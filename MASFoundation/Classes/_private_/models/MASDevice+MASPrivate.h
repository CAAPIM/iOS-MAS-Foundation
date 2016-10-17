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
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, assign, readonly) BOOL isRegistered;
@property (nonatomic, assign, readonly) BOOL isLocked;

@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *status;


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
