//
//  MASDeleteURLRequest.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDeleteURLRequest.h"

#import "MASAccessService.h"

#define kMASHTTPDeleteRequestMethod @"DELETE"


@implementation MASDeleteURLRequest


# pragma mark - Public

+ (MASDeleteURLRequest *)requestForEndpoint:(NSString *)endPoint
                             withParameters:(NSDictionary *)parameterInfo
                                 andHeaders:(NSDictionary *)headerInfo
                                requestType:(MASRequestResponseType)requestType
                               responseType:(MASRequestResponseType)responseType
                                   isPublic:(BOOL)isPublic
                            timeoutInterval:(NSTimeInterval)timeoutInterval
{
    //
    // Adding prefix to the endpoint path
    //
    if ([MASConfiguration currentConfiguration].gatewayPrefix && ![endPoint hasPrefix:@"http://"] && ![endPoint hasPrefix:@"https://"])
    {
        endPoint = [NSString stringWithFormat:@"%@%@",[MASConfiguration currentConfiguration].gatewayPrefix, endPoint];
    }
    
    //
    // Format endpoint with query parameters, if any
    //
    NSString *endPointWithQueryParameters = [self endPoint:endPoint byAppendingParameterInfo:parameterInfo];
    
    //
    // Full URL path
    //
    NSURL *url = [NSURL URLWithString:endPointWithQueryParameters relativeToURL:[MASConfiguration currentConfiguration].gatewayUrl];
    
    NSAssert(url, @"URL cannot be nil");
    
    //
    // Create the request
    //
    MASDeleteURLRequest *request = [MASDeleteURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeoutInterval];
    
    //
    // Method
    //
    [request setHTTPMethod:kMASHTTPDeleteRequestMethod];
    
    //
    // Headers
    //
    [request setHeaderInfo:headerInfo forRequestType:requestType andResponseType:responseType];
    
    //
    //  capture request
    //
    request.isPublic = isPublic;
    request.timeoutInterval = timeoutInterval;
    request.requestType = requestType;
    request.responseType = responseType;
    request.headerInfo = headerInfo;
    request.parameterInfo = parameterInfo;
    request.endPoint = endPoint;
    
    return request;
}

- (MASURLRequest *)rebuildRequest
{
    [self setHeaderInfo:self.headerInfo forRequestType:self.requestType andResponseType:self.responseType];
    
    return self;
}

@end
