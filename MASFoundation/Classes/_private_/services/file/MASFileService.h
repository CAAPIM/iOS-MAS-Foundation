//
//  MASFileService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASService.h"

#import "MASConstantsPrivate.h"


@interface MASFileService : MASService



///--------------------------------------
/// @name Creating a New File
///--------------------------------------

# pragma mark - Creating a New File

/**
 *  Creates a new 'MASFile' object.
 *
 *  @param name The NSString name of the new file.
 *  @param contents The NSData contents of the new file.
 *  @param directoryType The MASFileDirectoryType enumeration value indicating the directory of the file to be stored.
 *  @return Returns a new 'MASFile' object.
 */
- (MASFile *)fileWithName:(NSString *)name contents:(NSData *)contents directoryType:(MASFileDirectoryType)directoryType;



///--------------------------------------
/// @name Finding a File
///--------------------------------------

# pragma mark - Finding a File

/**
 *  Find a specific MASFile object with given file name and directory type.
 *
 *  @param name The NSString name of the file name.
 *  @param directoryType The MASFileDirectoryType enumeration value that specifies directories where the file is stored.
 *  @return Returns the MASFile that applies to the name and directory type, nil if none.
 */
- (MASFile *)findFileWithName:(NSString *)name directoryType:(MASFileDirectoryType)directoryType;



/**
 *  Find a full file path with given file name and directory type.
 *
 *  @param fileName The NSString fileName of the file name.
 *  @param fileDirectoryType The MASFileDirectoryType enumeration value that specifies directories where the file is stored.
 *  @return Returns NSString of full file path of given file name and directory type.
 */
- (NSString *)getFilePathForFileName:(NSString *)fileName fileDirectoryType:(MASFileDirectoryType)fileDirectoryType;



///--------------------------------------
/// @name Wrtie/remove a file
///--------------------------------------

# pragma mark - Wrtie/remove a file

/**
 *  Remove a file with given file name from specified directory in directoryType
 *
 *  @param directoryType The MASFileDirectoryType enumeration value that specifies directories where the file is stored.
 *  @param fileName The NSString fileName of the file name.
 *  @return Returns boolean of whether the operation was successful or not.
 */
- (BOOL)removeFileAtDirectoryType:(MASFileDirectoryType)directoryType fileName:(NSString *)fileName;



/**
 *  Write a file with given file name from specified directory in directoryType
 *
 *  @param directoryType The MASFileDirectoryType enumeration value that specifies directories where the file is stored.
 *  @param fileName The NSString fileName of the file name.
 *  @param dataWritingOption NSDataWritingOptions value that specifies data protection in iOS file system.
 *  @param error NSError reference.
 *  @return Returns boolean of whether the operation was successful or not.
 */
- (BOOL)writeFileAtDirectoryType:(MASFileDirectoryType)directoryType fileName:(NSString *)fileName content:(NSObject *)content dataWritingOption:(NSDataWritingOptions)dataWritingOption error:(NSError **)error;

@end
