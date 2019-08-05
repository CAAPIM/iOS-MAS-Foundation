//
//  MASPostFormURLRequest.m
//  MASFoundation
//
//  Created by nimma01 on 12/07/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import "MASPostFormURLRequest.h"
#import "MASMultiPartRequestSerializer.h"


#define kMASHTTPPostRequestMethod @"POST"

@implementation MASPostFormURLRequest


+ (MASPostFormURLRequest *)requestForEndpoint:(NSString *)endPoint withParameters:(NSDictionary *)parameterInfo andHeaders:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic constructingBodyBlock:(nonnull MASMultiPartFormDataBlock)formDataBlock
{
    //
    // Adding prefix to the endpoint path
    //
    if ([MASConfiguration currentConfiguration].gatewayPrefix && ![endPoint hasPrefix:@"http://"] && ![endPoint hasPrefix:@"https://"])
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
    MASPostFormURLRequest *request = [MASPostFormURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:240];
    
    //
    // Method
    //
    [request setHTTPMethod:kMASHTTPPostRequestMethod];
    
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
    
    __block MASMultiPartRequestSerializer* formData = [[MASMultiPartRequestSerializer alloc] initWithURLRequest:request];
    
    if(formDataBlock){
        formDataBlock(formData);
    }
    
    return [formData requestByFinalizingMultipartFormData];
    
    
}
@end
