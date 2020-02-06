//
//  MASMultiFactorHandler+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

/**
 MASMultiFactorHandler+MASPrivate class is responsible to set private property that is required to re-process the original request.
 */
@interface MASMultiFactorHandler (MASPrivate)

///--------------------------------------
/// @name Public Category Method
///--------------------------------------

# pragma mark - Public Category Method

/**
 Private method for setting original request's completion block for MASMultiFactorHandler.

 @param completionBlock MASResponseInfoErrorBlock of the original request.
 */
- (void)setOriginalRequestCompletionBlock:(MASResponseInfoErrorBlock)completionBlock;

@end
