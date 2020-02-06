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
@property (nonatomic, copy, readonly, nonnull) NSString *name;


/**
 * The contents of file as NSData.
 */
@property (nonatomic, strong, readonly, nonnull) NSData *contents;


/**
 * The full file path of the file on disk.
 */
@property (nonatomic, assign, readonly, nonnull) NSString *filePath;


/**
 * The file directory type.  Default directory type is MASFileDirectoryTypeApplicationSupport.
 */
@property (assign, readonly) MASFileDirectoryType directoryType;



///--------------------------------------
/// @name Creating a New File
///--------------------------------------

# pragma mark - Creating a New File

/**
 *  Creates a new 'MASFile' object.
 *
 *  Note, that default directory type is MASFileDirectoryTypeApplicationSupport.
 *  If you want to have a file in a specific directory, use fileWithName:contents:directoryType:
 *
 *  Available directory types are:
 *
 *  MASFileDirectoryTypeTemporary
 *  MASFileDirectoryTypeApplicationSupport
 *  MASFileDirectoryTypeCachesDirectory
 *  MASFileDirectoryTypeDocuments
 *  MASFileDirectoryTypeLibrary
 *
 *  Data stored into file will be automatically protected with
 *
 *  @param name The NSString name of the new file.
 *  @param contents The NSData contents of the new file.
 *  @return Returns a new 'MASFile' object.
 */
+ (MASFile *_Nullable)fileWithName:(NSString *_Nonnull)name contents:(NSData *_Nonnull)contents;



/**
 *  Creates a new 'MASFile' object with specified directory type.
 *
 *  Available directory types are:
 *
 *  MASFileDirectoryTypeTemporary
 *  MASFileDirectoryTypeApplicationSupport
 *  MASFileDirectoryTypeCachesDirectory
 *  MASFileDirectoryTypeDocuments
 *  MASFileDirectoryTypeLibrary
 *
 *  @param name The NSString name of the new file.
 *  @param contents The NSData contents of the new file.
 *  @param directoryType The MASFileDirectoryType enumeration value of directory type.
 *  @return Returns a new 'MASFile' object.
 */
+ (MASFile *_Nullable)fileWithName:(NSString *_Nonnull)name contents:(NSData *_Nonnull)contents directoryType:(MASFileDirectoryType)directoryType;



///--------------------------------------
/// @name Finding a File
///--------------------------------------

# pragma mark - Finding a File

/**
 *  Find a specific, MASFile in local storage if it exists.
 *
 *  Note, that file is retrieved from Application Support directory in the application directory by default.
 *  If you want to find a file to a specific directory, use findFileWithName:directoryType:
 *
 *  Available directory types are:
 *
 *  MASFileDirectoryTypeTemporary
 *  MASFileDirectoryTypeApplicationSupport
 *  MASFileDirectoryTypeCachesDirectory
 *  MASFileDirectoryTypeDocuments
 *  MASFileDirectoryTypeLibrary
 *
 *  @param name The name of the file
 *
 *  @return Returns the MASFile that applies to the name, nil if none.
 */
+ (MASFile *_Nullable)findFileWithName:(NSString *_Nonnull)name;



/**
 *  Find a specific, MASFile in local storage from specified directory if it exists.
 *
 *  Available directory types are:
 *
 *  MASFileDirectoryTypeTemporary
 *  MASFileDirectoryTypeApplicationSupport
 *  MASFileDirectoryTypeCachesDirectory
 *  MASFileDirectoryTypeDocuments
 *  MASFileDirectoryTypeLibrary
 *
 *  @param name The name of the file
 *
 *  @return Returns the MASFile that applies to the name, nil if none.
 */
+ (MASFile *_Nullable)findFileWithName:(NSString *_Nonnull)name directoryType:(MASFileDirectoryType)directoryType;



///--------------------------------------
/// @name Save/Delete file
///--------------------------------------

# pragma mark - Save/Delete file

/**
 *  Save the MASFile locally.
 *
 *  By default, NSDataWritingOptions is set to NSDataWritingFileProtectionComplete.
 *
 *  @return Returns YES if success or NO if failure.
 */
- (BOOL)save;



/**
 *  Save the MASFile locally with NSDataWritingOptions option.
 *
 *  This method saves the file into iOS file system with provided NSDataWritingOptions.
 *
 *  @return Returns YES if success or NO if failure.
 */
- (BOOL)saveWithDataWritingOption:(NSDataWritingOptions)option;



/**
 *  Removes the MASFile locally.
 *
 *  @return Returns YES if success or NO if failure.
 */
- (BOOL)remove;



/**
 *  Remove any data at the given file path.
 *
 *  @param filePath The file path to find the data to remove.
 *  @return Returns YES if removed, NO if not.
 */
+ (BOOL)removeItemAtFilePath:(NSString *_Nonnull)filePath;



///--------------------------------------
/// @name Temporary file
///--------------------------------------

# pragma mark - Temporary file

/**
 *  Stores the given NSData at a temporary location.
 *
 *  Temporary items are saved with NSDataWritingFileProtectionNone.
 *
 *  @param data The NSData item to store.
 *  @return Returns the NSString file path where it is stored.
 */
+ (NSString *_Nullable)storeTemporaryItem:(NSData *_Nonnull)data;

@end
