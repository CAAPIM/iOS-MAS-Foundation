//
//  MASPostURLRequest.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASPostURLRequest.h"

#import "MASAccessService.h"

#define kMASHTTPPostRequestMethod @"POST"


@implementation MASPostURLRequest


# pragma mark - Public

+ (MASPostURLRequest *)requestForEndpoint:(NSString *)endPoint
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
    // Full URL path (no query parameters go here)
    //
    NSURL *url = [NSURL URLWithString:endPoint relativeToURL:[MASConfiguration currentConfiguration].gatewayUrl];
    
    NSAssert(url, @"URL cannot be nil");
    
    //
    // Create the request
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    //
    // Method
    //
    [request setHTTPMethod:kMASHTTPPostRequestMethod];
    
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
    
    return (MASPostURLRequest *)request;
}

@end
