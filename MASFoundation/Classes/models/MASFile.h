//
//  MASFile.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


/**
 * The `MASFile` class is a local representation of file data.
 */
@interface MASFile : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * The name of the file.
 */
@property (nonatomic, copy, readonly) NSString *name;


/**
 * The contents of file as NSData.
 */
@property (nonatomic, strong, readonly) NSData *contents;


/**
 * The full file path of the file on disk.
 */
@property (nonatomic, assign, readonly) NSString *filePath;



///--------------------------------------
/// @name Creating a New File
///--------------------------------------

# pragma mark - Creating a New File

/**
 *  Creates a new 'MASFile' object.
 *
 *  @param name The NSString name of the new file.
 *  @param contents The NSData contents of the new file.
 *  @return Returns a new 'MASFile' object.
 */
+ (MASFile *)fileWithName:(NSString *)name
                 contents:(NSData *)contents;



///--------------------------------------
/// @name Finding a File
///--------------------------------------

# pragma mark - Finding a File

/**
 *  Find a specific, unsecured MASFile in local storage if it exists.
 *
 *  Note, that if you attempt to use this method to find an MASFile
 *  instance that has been secured with credentials then this method
 *  will throw an exception.  In this case, you should be using the
 *  method 'findFileWithName:password:'.
 *
 *  @param name The name of the file
 *
 *  @return Returns the MASFile that applies to the name, nil if none.
 */
+ (MASFile *)findFileWithName:(NSString *)name;



/**
 *  Find a specific, secured MASFile in local storage if it exists.
 *
 *  @param name The name of the file
 *  @param password The password with which to unlock the stored object.
 *  @return Returns the MASFile that applies to the name and can be 
 *  unlocked by the password, nil if none.
 */
+ (MASFile *)findFileWithName:(NSString *)name
                     password:(NSString *)password;



///--------------------------------------
/// @name Secure Storage
///--------------------------------------

# pragma mark - Secure Storage

/**
 *  Save the MASFile locally securely.
 *
 *  @param password The password with which to lock the stored object.
 *  @return Returns YES if success or NO if failure.
 */
- (BOOL)saveWithPassword:(NSString *)password;



/**
 *  Stores the given NSData at a temporary location.
 *
 *  @param data The NSData item to store.
 *  @return Returns the NSString file path where it is stored.
 */
+ (NSString *)storeTemporaryItem:(NSData *)data;



/**
 *  Remove any data at the given file path.
 *
 *  @param filePath The file path to find the data to remove.
 *  @return Returns YES if removed, NO if not.
 */
+ (BOOL)removeItemAtFilePath:(NSString *)filePath;

@end
