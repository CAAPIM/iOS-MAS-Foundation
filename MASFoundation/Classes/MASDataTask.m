//
//  MASDataTask.m
//  MASFoundation
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDataTask.h"
#import "MASSessionDataTaskOperation.h"

@interface MASDataTask()
{
    
}
@property(nonatomic,readwrite,weak)MASSessionDataTaskOperation* operation;
@property(readwrite)NSString* taskID;
@end


@implementation MASDataTask

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:@"Cannot create instances of this class, Object can only be used from taskBlock" userInfo:nil];
    
    return nil;
}


@end
