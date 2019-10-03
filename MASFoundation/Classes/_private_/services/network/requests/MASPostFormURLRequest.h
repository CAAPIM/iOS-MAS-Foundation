//
//  MASPostFormURLRequest.h
//  MASFoundation
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//


#import "MASURLRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MASPostFormURLRequest : MASURLRequest


+ (MASPostFormURLRequest *)requestForEndpoint:(NSString *)endPoint withParameters:(NSDictionary *)parameterInfo andHeaders:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic timeoutInterval:(NSTimeInterval)timeoutInterval constructingBodyBlock:(nonnull MASMultiPartFormDataBlock)formDataBlock;

@end

NS_ASSUME_NONNULL_END
