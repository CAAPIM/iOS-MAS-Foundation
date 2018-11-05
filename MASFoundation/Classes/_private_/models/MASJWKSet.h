//
//  MASJWKSet.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MASJWKSet : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * This indicates the status of the JWKSet loading.  YES if it has succesfully loaded and is
 * ready for use. NO if not yet loaded or perhaps an error has occurred during attempting to load.
 */
@property (nonatomic, assign, readonly) BOOL isLoaded;



/**
 * JSON Web Keys (JWKs)
 * A NSDictionary object that represents a cryptographic key. The members of the object represent properties of the key,
 * including its value.
 *
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<NSDictionary *> *jsonWebKeys;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Initializer to perform a default initialization.
 *
 * @param info NSDictionary of JWKSet information.
 * @return Returns the newly initialized MASJWKSet.
 */
- (instancetype _Nullable)initWithJWKSetInfo:(NSDictionary *_Nonnull)info;



/**
 * Retrieves the instance of MASJWKSet from local storage, if it exists.
 *
 * @return Returns the newly initialized MASJWKSet or nil if none was stored.
 */
+ (MASJWKSet *_Nullable)instanceFromStorage;



/**
 *
 */
- (void)saveToStorage;



/**
 * Remove all traces of the current JWKSet.
 */
- (void)reset;


@end

NS_ASSUME_NONNULL_END
