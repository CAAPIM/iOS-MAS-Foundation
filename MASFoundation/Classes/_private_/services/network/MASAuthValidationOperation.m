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


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark - NSNotification

- (void)didReceiveAuthentication:(NSNotification *)notification
{
    if (self.isExecuting && !self.cancelled && !self.isFinished)
    {
        //
        //  Based on MASUserDidAuthenticateNotification, as it was successful authentication, complete operation with success.
        //
        self.result = YES;
        self.error = nil;
        [self completeOperation];
        [[MASNetworkingService sharedService] releaseOperationQueue];
    }
}


# pragma mark - NSOperation methods

- (void)start
{
    if ([self isCancelled])
    {
        [self setFinished:YES];
        return;
    }
    
    //
    //  Subscribe successful authentication notification.
    //  This will resolve the issue where the MASUserAuthCredentialsBlock, and/or MASUserLoginBlock being on hold while explicit authentication goes through.
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAuthentication:) name:MASUserDidAuthenticateNotification object:nil];
    
    [self setExecuting:YES];
    
    [self validateAuthSession];
}


- (void)cancel
{
    [super cancel];
}


- (void)completeOperation
{
    [self setExecuting:NO];
    [self setFinished:YES];
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
    return [NSString stringWithFormat:@"<%@: %p, executing: %@, cancelled: %@, finished: %@>", NSStringFromClass([self class]), self, self.isExecuting ? @"YES":@"NO", [self isCancelled] ? @"YES":@"NO", self.isFinished ? @"YES":@"NO"];
}


# pragma mark - Private

- (void)validateAuthSession
{
    __block MASAuthValidationOperation *blockSelf = self;
    
    [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError * _Nullable error) {
        //
        //  Only if the operation is still being executed; as explicit authentication may have finished the operation
        //
        if (blockSelf.isExecuting && !blockSelf.cancelled && !blockSelf.isFinished)
        {
            blockSelf.result = completed;
            blockSelf.error = error;
            [blockSelf completeOperation];
            [[MASNetworkingService sharedService] releaseOperationQueue];
        }
    }];
}

@end
