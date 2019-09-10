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


+ (MASPostFormURLRequest *)requestForEndpoint:(NSString *)endPoint withParameters:(NSDictionary *)parameterInfo andHeaders:(NSDictionary *)headerInfo requestType:(MASRequestResponseType)requestType responseType:(MASRequestResponseType)responseType isPublic:(BOOL)isPublic timeoutInterval:(NSTimeInterval)timeoutInterval constructingBodyBlock:(nonnull MASMultiPartFormDataBlock)formDataBlock
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
    MASPostFormURLRequest *request = [MASPostFormURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeoutInterval];
    
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

- (MASURLRequest *)rebuildRequest
{
    [self setHeaderInfo:self.headerInfo forRequestType:self.requestType andResponseType:self.responseType];
    
    return self;
}


//overriding the behavior for this class as the super class does not know about boundary string

- (void)setHeaderInfo:(NSDictionary *)headerInfo forRequestType:(MASRequestResponseType)requestType andResponseType:(MASRequestResponseType)responseType
{
    
    //don't set the request type as we don't want to disturb the boundary string
    
    //
    // Accept based on MASRequestResponseType
    //
    [self setValue:[self requestResponseTypeAsMimeTypeString:responseType] forHTTPHeaderField:MASAcceptRequestResponseKey];
    
    NSString *lowerKey;
    NSString *value;
    for(NSString *key in [headerInfo allKeys])
    {
        lowerKey = [key lowercaseString];
        value = [headerInfo objectForKey:key];
        [self setValue:value forHTTPHeaderField:key];
    }
}

//overriding the behavior for this class as the super class does not know about boundary string
- (NSString *)requestResponseTypeAsMimeTypeString:(MASRequestResponseType)type
{
    //
    // Detect type and respond approriately
    //
    switch(type)
    {
            //
            // JSON
            //
        case MASRequestResponseTypeJson: return MASRequestResponseTypeJsonValue;
            
            //
            // SCIM variant JSON
            //
        case MASRequestResponseTypeScimJson: return MASRequestResponseTypeScimJsonValue;
            
            //
            // Form URL Encoded
            //
        case MASRequestResponseTypeWwwFormUrlEncoded: return MASRequestResponseTypeWwwFormUrlEncodedValue;
            
            //
            // XML
            //
        case MASRequestResponseTypeXml: return MASRequestResponseTypeXmlValue;
            
        case MASRequestResponseTypeFormData : return MASRequestResponseTypeFormDataValue;
            
            //
            // Default
            //
        default: return MASRequestResponseTypeTextPlainValue;
    }
}




@end
