//
//  MASDataTask+MASPrivate.h
//  MASFoundation
//
//  Created by nimma01 on 05/12/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
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
