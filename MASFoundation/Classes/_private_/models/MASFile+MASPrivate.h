//
//  MASFile+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


@interface MASFile (MASPrivate)
    <NSCoding>


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

- (id)initWithName:(NSString *)name contents:(NSData *)contents directoryType:(MASFileDirectoryType)directoryType;

@end
