//
//  MASDataTask.m
//  MASFoundation
//
//  Created by nimma01 on 28/11/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import "MASDataTask.h"
#import "MASSessionDataTaskOperation.h"

@interface MASDataTask()
{
    
}
@property(nonatomic,readwrite)MASSessionDataTaskOperation* operation;
@property(readwrite)NSString* taskID;
@end


@implementation MASDataTask

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:@"Cannot create instances of this class, Object can only be used from taskBlock" userInfo:nil];
    
    return nil;
}

- (void)cancel
{
    if(![self.operation isFinished] && ![self.operation isCancelled]){
        [self.operation cancel];
    }
    
}

@end
