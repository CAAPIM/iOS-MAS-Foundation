//
//  MASGroup.h
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

/**
 * The `MASGroup` class is a local representation of group data.
 */
@interface MASGroup : MASObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 * Group Name
 */
@property (nonatomic, copy, readwrite) NSString *groupName;


/**
 *  Group Owner
 */
@property (nonatomic, copy, readwrite) NSString *owner;


/**
 *  Group Members
 */
@property (nonatomic, copy, readwrite) NSArray *members;


# pragma mark - Lifecycle

/**
 *  Init the object with passed attributes in a form of NSDictionary
 *
 *  @param info NSDictionary to be used as attributes
 *
 *  @return The instance of the MASGroup object
 */
- (instancetype)initWithInfo:(NSDictionary *)info;



/**
 *  Create a instance of the MASGroup object
 *
 *  @return The instance of a new MASGroup object
 */
+ (MASGroup *)group;

@end
