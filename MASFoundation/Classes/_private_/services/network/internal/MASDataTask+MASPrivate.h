//
//  MASDataTask+MASPrivate.h
//  MASFoundation
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import "MASDataTask.h"
#import "MASSessionDataTaskOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface MASDataTask (MASPrivate)
{
    
}

- (instancetype)initWithTask:(MASSessionDataTaskOperation*)operation;
- (BOOL)isFinished;
-(BOOL)isCancelled;

@end

NS_ASSUME_NONNULL_END
