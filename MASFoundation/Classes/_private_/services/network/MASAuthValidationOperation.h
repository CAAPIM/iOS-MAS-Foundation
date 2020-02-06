//
//  MASAuthValidationOperation.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

@interface MASAuthValidationOperation : NSOperation

@property (assign) BOOL result;
@property (nonatomic, strong) NSError *error;


+ (instancetype)sharedOperation;

@end
