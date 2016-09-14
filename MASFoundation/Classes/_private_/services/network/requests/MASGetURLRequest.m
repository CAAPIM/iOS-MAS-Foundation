//
//  MASGetURLRequest.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASGetURLRequest.h"

#import "MASAccessService.h"

#define kMASHTTPGetRequestMethod @"GET"


@implementation MASGetURLRequest


# pragma mark - Public

+ (MASGetURLRequest *)requestForEndpoint:(NSString *)endPoint
                          withParameters:(NSDictionary *)parameterInfo
                              andHeaders:(NSDictionary *)headerInfo
                             requestType:(MASRequestResponseType)requestType
                            responseType:(MASRequestResponseType)responseType
{
    //
    // Adding prefix to the endpoint path
    //
    if ([MASConfiguration currentConfiguration].gatewayPrefix)
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    //
    // Method
    //
    [request setHTTPMethod:kMASHTTPGetRequestMethod];
    
    //
    // Mutable copy of header
    //
    NSMutableDictionary *mutableHeaderInfo = [headerInfo mutableCopy];
    
    //mag-identifier
    if ([MASDevice currentDevice].isRegistered && [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier])
    {
        mutableHeaderInfo[MASMagIdentifierRequestResponseKey] = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier];
    }
    
    // Authorization
    if ([MASAccessService sharedService].currentAccessObj.accessToken && ![[mutableHeaderInfo allKeys] containsObject:MASAuthorizationRequestResponseKey])
    {
        mutableHeaderInfo[MASAuthorizationRequestResponseKey] = [MASUser authorizationBearerWithAccessToken];
    }
    
    //
    // Headers
    //
    [request setHeaderInfo:mutableHeaderInfo forRequestType:requestType andResponseType:responseType];
    
    return (MASGetURLRequest *)request;
}

@end
