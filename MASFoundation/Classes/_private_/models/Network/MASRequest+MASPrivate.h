//
//  MASRequest+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import "MASRequest.h"
#import "MASRequestBuilder.h"

@interface MASRequest (MASPrivate)

/**
 Private initializer for MASRequest.
 
 @param url NSURL of the target domain
 @return MASRequest object
 */
- (id)initWithBuilder:(MASRequestBuilder *)builder;

@end
