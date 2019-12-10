//
//  MASDataTask+MASPrivate.m
//  MASFoundation
//
//  Created by nimma01 on 05/12/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import "MASDataTask+MASPrivate.h"

@interface MASDataTask()
{
    
}

@property(readwrite)NSString* taskID;
@property(nonatomic,readwrite)MASSessionDataTaskOperation* operation;

@end

@implementation MASDataTask (MASPrivate)


- (instancetype)initWithTask:(MASSessionDataTaskOperation*)operation
{
    if(self = [super init]){
        self.operation = operation;
        self.taskID = operation.taskID;
    }
    
    return self;
}

- (BOOL)isFinished
{
    return [self.operation isFinished];
}


-(BOOL)isCancelled
{
    return [self.operation isCancelled];
}




@end
