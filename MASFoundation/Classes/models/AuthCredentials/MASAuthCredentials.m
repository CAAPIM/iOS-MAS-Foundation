//
//  MASAuthCredentials.m
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentials.h"

#import "MASAccessService.h"
#import "MASAuthCredentials+MASPrivate.h"
#import "MASSecurityService.h"
#import "MASModelService.h"
#import "NSError+MASPrivate.h"

#import "MASConstants.h"


@implementation MASAuthCredentials

# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


# pragma mark - Public

- (void)clearCredentials
{
    
}


# pragma mark - Prviate


@end
