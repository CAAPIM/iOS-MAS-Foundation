//
//  MASDebugService.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

@interface MASDebugService : MASService


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

+ (void)setLogLevel:(MASDebugLevel)level;


+ (MASDebugLevel)logLevel;


- (void)logMessage:(NSString *)message logLevel:(MASDebugLevel)logLevel;

@end
