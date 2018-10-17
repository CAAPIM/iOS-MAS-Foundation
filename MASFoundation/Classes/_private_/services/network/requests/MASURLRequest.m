//
//  MASURLRequest.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASURLRequest.h"

NSString * const MASRequestResponseTypeJsonValue = @"application/json";
NSString * const MASRequestResponseTypeScimJsonValue = @"application/scim+json";
NSString * const MASRequestResponseTypeTextPlainValue = @"text/plain";
NSString * const MASRequestResponseTypeWwwFormUrlEncodedValue = @"application/x-www-form-urlencoded";
NSString * const MASRequestResponseTypeXmlValue = @"application/xml";


@implementation MASURLRequest


# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


# pragma mark - Public

- (MASURLRequest *)rebuildRequest
{
    return self;
}


+ (NSString *)endPoint:(NSString *)endPoint byAppendingParameterInfo:(NSDictionary *)parameterInfo
{
    //
    // If no query parameters, nothing to do
    //
    if(!parameterInfo || parameterInfo.count == 0) return endPoint;
    
    //
    // Retrieve the query parameter string
    //
    NSString *queryParameters = [self queryParametersFromInfo:parameterInfo];
    
    //
    // Append query parameters to the endpoint
    //
    NSString *endpointWithQueryParameters = [NSString stringWithFormat:@"%@?%@", endPoint, queryParameters];
    
    return endpointWithQueryParameters;
}


+ (NSData *)dataForBodyFromParameterInfo:(NSDictionary *)parameterInfo forRequestType:(MASRequestResponseType)requestType
{
    //
    // If no parameters there is no data
    //
    if(!parameterInfo || parameterInfo.count == 0) return nil;
    
    //
    // If the request type is unknown there is no data
    //
    if(requestType == MASRequestResponseTypeUnknown) return nil;
    
    //
    // Otherwiser populate the data
    //
    NSData *data;
    
    //
    // Text/Plain
    //
    if(requestType == MASRequestResponseTypeTextPlain)
    {
        data = [[parameterInfo allValues][0] dataUsingEncoding:NSUTF8StringEncoding];
    }
        
    //
    // JSON (or SCIM variant)
    //
    else if(requestType == MASRequestResponseTypeJson || requestType == MASRequestResponseTypeScimJson)
    {
        data = [NSJSONSerialization dataWithJSONObject:parameterInfo options:NSJSONWritingPrettyPrinted error:nil];
    }
        
    //
    // Form Url Encoded
    //
    else if(requestType == MASRequestResponseTypeWwwFormUrlEncoded)
    {
        data = [[self queryParametersFromInfo:parameterInfo] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return data;
}


+ (NSString *)queryParametersFromInfo:(NSDictionary *)parameterInfo
{
    //
    // If no query parameters, nothing to do
    //
    if(!parameterInfo || parameterInfo.count == 0) return nil;
    
    return [self serializeParams:parameterInfo];
}


+ (NSString *)serializeParams:(NSDictionary *)params
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [params allKeys])
    {
        id value = params[key];
        
        //
        //  If the parameter is nested dictionary
        //
        if ([value isKindOfClass:[NSDictionary class]])
        {
            for (NSString *subKey in value)
            {
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, [self escapeValueForURLParameter:[value objectForKey:subKey]]]];
            }
        }
        //
        //  If parameter is nested array
        //
        else if ([value isKindOfClass:[NSArray class]])
        {
            for (NSString *subValue in value)
            {
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, [self escapeValueForURLParameter:subValue]]];
            }
        }
        //
        //  otherwise, string
        //
        else {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self escapeValueForURLParameter:value]]];
        }
        
    }
    return [pairs componentsJoinedByString:@"&"];
}


+ (NSString *)escapeValueForURLParameter:(NSString *)valueToEscape {
    
    //
    //  Only do the escape for NSString class 
    //
    if ([valueToEscape isKindOfClass:[NSString class]])
    {
        NSString *escape = @"|!*'();:@&=+$,/?%#[] \"";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:escape] invertedSet];
        return [valueToEscape stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    }
    //
    //  Otherwise, just return the value
    //
    else {
        return valueToEscape;
    }
}


+ (MASIHTTPResponseSerializer *)responseSerializerForType:(MASRequestResponseType)type
{
    //
    // Detect type and respond appropriately
    //
    switch(type)
    {
        //
        // XML
        //
        case MASRequestResponseTypeXml: return [MASIXMLParserResponseSerializer serializer];
        
        //
        // Text/Plain
        //
        case MASRequestResponseTypeTextPlain:
        {
            
            MASIHTTPResponseSerializer *serializer = [MASIHTTPResponseSerializer serializer];
            [serializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    
            return serializer;
        }
        
        //
        // JSON
        //
        case MASRequestResponseTypeJson:
        {
            return [MASIJSONResponseSerializer masSerializer];
        }
        
        //
        // Default
        //
        default: return [MASIHTTPResponseSerializer serializer];
    }
}

@end
