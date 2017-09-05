//
//  MASRequest+MASPrivate.h
//  MASFoundation
//
//  Created by Reis, Rodrigo on 2017-08-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
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
