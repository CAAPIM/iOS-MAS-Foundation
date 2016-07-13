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
 *  @return Returns a new 'MASFile' object.
 */
- (MASFile *)fileWithName:(NSString *)name contents:(NSData *)contents;



///--------------------------------------
/// @name Finding a File
///--------------------------------------

# pragma mark - Finding a File

/**
 *  Find a specific, unsecured MASFile in local storage if it exists.
 *
 *  @return Returns the MASFile that applies to the name, nil if none.
 */
- (MASFile *)findFileWithName:(NSString *)name;


/**
 *  Find a specific, secured MASFile in local storage if it exists.
 *
 *  @param password The password with which to unlock the stored object.
 *  @return Returns the MASFile that applies to the name and can be 
 *  unlocked by the password, nil if none.
 */
- (MASFile *)findFileWithName:(NSString *)name password:(NSString *)password;

@end
