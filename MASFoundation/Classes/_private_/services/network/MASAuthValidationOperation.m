//
//  MASAuthValidationOperation.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthValidationOperation.h"

#import "MASModelService.h"

@interface MASAuthValidationOperation ()

@property (nonatomic, readwrite, getter = isFinished)  BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;

@end


@implementation MASAuthValidationOperation

@synthesize executing = _executing;
@synthesize finished  = _finished;


# pragma mark - Lifecycle

+ (instancetype)sharedOperation
{
    MASAuthValidationOperation *operation = [[MASAuthValidationOperation alloc] init];
    return operation;
}


# pragma mark - NSOperation methods

- (void)start
{
    if ([self isCancelled])
    {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    [self validateAuthSession];
}


- (void)cancel
{

    [super cancel];
}


- (void)completeOperation
{
    self.executing = NO;
    self.finished = YES;
}


- (BOOL)isConcurrent
{
    return YES;
}


- (void)setExecuting:(BOOL)executing
{
    if (executing != _executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
}


- (void)setFinished:(BOOL)finished
{
    if (finished != _finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
}


# pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, executing: %@, cancelled: %@, finished: %@>", NSStringFromClass([self class]), self, self.executing ? @"YES":@"NO", [self isCancelled] ? @"YES":@"NO", self.isFinished ? @"YES":@"NO"];
}


# pragma mark - Private

- (void)validateAuthSession
{
    __block MASAuthValidationOperation *blockSelf = self;
    
    [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError * _Nullable error) {
    
        blockSelf.result = completed;
        blockSelf.error = error;
        [blockSelf completeOperation];
    }];
}

@end
