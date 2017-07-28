//
//  MASPutURLRequest.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASPutURLRequest.h"

#import "MASAccessService.h"

#define kMASHTTPutRequestMethod @"PUT"


@implementation MASPutURLRequest


# pragma mark - Public

+ (MASPutURLRequest *)requestForEndpoint:(NSString *)endPoint
                          withParameters:(NSDictionary *)parameterInfo
                              andHeaders:(NSDictionary *)headerInfo
                             requestType:(MASRequestResponseType)requestType
                            responseType:(MASRequestResponseType)responseType
                                isPublic:(BOOL)isPublic
{
    //
    // Adding prefix to the endpoint path
    //
    if ([MASConfiguration currentConfiguration].gatewayPrefix)
    {
        endPoint = [NSString stringWithFormat:@"%@%@",[MASConfiguration currentConfiguration].gatewayPrefix, endPoint];
    }
    
    //
    // Full URL path (no query parameters go here)
    //
    NSURL *url = [NSURL URLWithString:endPoint relativeToURL:[MASConfiguration currentConfiguration].gatewayUrl];
    
    NSAssert(url, @"URL cannot be nil");
    
    //
    // Create the request
    //
    MASPutURLRequest *request = [MASPutURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    //
    // Method
    //
    [request setHTTPMethod:kMASHTTPutRequestMethod];
    
    //
    // Headers
    //
    [request setHeaderInfo:headerInfo forRequestType:requestType andResponseType:responseType];
    
    //
    //  capture request
    //
    request.isPublic = isPublic;
    request.requestType = requestType;
    request.responseType = responseType;
    request.headerInfo = headerInfo;
    request.parameterInfo = parameterInfo;
    request.endPoint = endPoint;
    
    //
    // Body ... format the parameter dictionary to data for the request type if there is anything
    // to format.  It's possible there isn't.
    //
    NSData *data = [self dataForBodyFromParameterInfo:parameterInfo forRequestType:requestType];
    if(data)
    {
        //
        // Set the body with the data
        //
        [request setHTTPBody:data];
    }

    return request;
}

- (MASURLRequest *)rebuildRequest
{
    [self setHeaderInfo:self.headerInfo forRequestType:self.requestType andResponseType:self.responseType];
    
    return self;
}

@end
