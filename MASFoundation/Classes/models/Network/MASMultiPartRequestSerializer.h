//
//  MASMultiPartRequestSerializer.h
//  MASFoundation
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
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
