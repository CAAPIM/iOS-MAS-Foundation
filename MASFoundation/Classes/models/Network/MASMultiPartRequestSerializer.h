//
//  MASMultiPartRequestSerializer.h
//  MASFoundation
//
//  Created by nimma01 on 11/07/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASMultiPartFormData.h"
#import "MASPostFormURLRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MASMultiPartRequestSerializer : NSObject <MASMultiPartFormData>

- (id)initWithURLRequest:(MASPostFormURLRequest *)request;

- (MASPostFormURLRequest *)requestByFinalizingMultipartFormData;

@end

NS_ASSUME_NONNULL_END
