//
//  MASFile+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


@interface MASFile (MASPrivate)
    <NSCoding>


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSData *contents;
@property (nonatomic, assign, readwrite) NSString *filePath;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

- (id)initWithName:(NSString *)name contents:(NSData *)contents;

@end
