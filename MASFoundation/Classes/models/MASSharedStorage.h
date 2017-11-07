//
//  MASSharedStorage.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


/**
 MASSharedStorage class is designed for developers to store, and retrieve NSString or NSData data into shared keychain storage,
 so that multiple applications with same keychain sharing group in the same device can share data between applications.
 
 @warning *Important:* there are some of the keys that are reserved by MASFoundation framework which will not store, or retrieve value with the same key.
 Key should be generic to its use-case, and any internal system data reserved by MASFoundation framework will not be readable through this class.
 */
@interface MASSharedStorage : MASObject



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public


/**
 Finds NSString data stored with the key from shared keychain storage.

 @param key NSString of the key used to store the NSString data
 @param error NSError object reference that would notify if there was any error while retrieving the data
 @return NSString of data found with the key
 */
+ (NSString *_Nullable)findStringUsingKey:(NSString *_Nonnull)key error:(NSError * __nullable __autoreleasing * __nullable)error;



/**
 Finds NSData object stored with the key from shared keychain storage.

 @param key NSString of the key used to store the NSData object
 @param error NSError object reference that would notify if there was any error while retrieving the data
 @return NSData of data found with the key
 */
+ (NSData *_Nullable)findDataUsingKey:(NSString *_Nonnull)key error:(NSError * __nullable __autoreleasing * __nullable)error;



/**
 Saves NSString data with the specified key into shared keychain storage.

 @param string NSString data to be stored
 @param key NSString of the key used to store the NSString data
 @param error NSError object reference that would notify if there was any error while storing the data
 @return BOOL result of saving operation
 */
+ (BOOL)saveString:(NSString *_Nonnull)string key:(NSString *_Nonnull)key error:(NSError * __nullable __autoreleasing * __nullable)error;



/**
 Saves NSData object with the specified key into shared keychain storage.

 @param data NSData object to be stored
 @param key NSString of the key used to store the NSData object
 @param error NSError object reference that would notify if there was any error while storing the data
 @return BOOL result of saving operation
 */
+ (BOOL)saveData:(NSData *_Nonnull)data key:(NSString *_Nonnull)key error:(NSError * __nullable __autoreleasing * __nullable)error;

@end
