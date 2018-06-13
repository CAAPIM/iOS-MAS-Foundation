//
//  MASMultiFactorHandler+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASMultiFactorHandler+MASPrivate.h"

@interface MASMultiFactorHandler ()

@property (nonatomic, copy) MASResponseInfoErrorBlock originalCompletionBlock;

@end

@implementation MASMultiFactorHandler (MASPrivate)

# pragma mark - Public Category Method

- (void)setOriginalRequestCompletionBlock:(MASResponseInfoErrorBlock)completionBlock
{
    self.originalCompletionBlock = completionBlock;
}

@end
