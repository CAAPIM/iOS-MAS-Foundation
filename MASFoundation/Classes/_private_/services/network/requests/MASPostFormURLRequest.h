//
//  MASPostFormURLRequest.h
//  MASFoundation
//
//  Created by nimma01 on 12/07/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import "MASURLRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MASPostFormURLRequest : MASURLRequest


+ (MASPostFormURLRequest *)requestForEndpoint:(NSString *)endPoint withParameters:(NSDictionary *)parameterInfo andHeaders:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic constructingBodyBlock:(nonnull MASMultiPartFormDataBlock)formDataBlock;

@end

NS_ASSUME_NONNULL_END
