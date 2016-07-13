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
    
    //
    // Query
    //
    NSString *parameterValue;
    NSString *queryFragment;
    NSMutableString *queryParameters = [NSMutableString new];
    for(NSString *parameterKey in [parameterInfo allKeys])
    {
        //
        // Retrieve the value for the key, trimming any leading or trailer whitespace and encoding
        // percent escape characters for interior whitespaces
        //
        
        // Trim and escape as appropriate
        parameterValue = [[[parameterInfo objectForKey:parameterKey] stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        //
        // Create the query fragment
        //
        queryFragment = [NSString stringWithFormat:@"%@=%@&",
            parameterKey,
            parameterValue];
        
        //
        // Add the query fragment
        //
        [queryParameters appendString:queryFragment];
    }
    
    //
    // Remove the last &
    //
    [queryParameters deleteCharactersInRange:NSMakeRange([queryParameters length]-1, 1)];
    
    return queryParameters;
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
            DLog(@"detected text plain");
            
            MASIHTTPResponseSerializer *serializer = [MASIHTTPResponseSerializer serializer];
            
            NSMutableSet *acceptableContentTypes = [[serializer acceptableContentTypes] mutableCopy];
            [acceptableContentTypes addObject:@"text/plain"];
            
            [serializer setAcceptableContentTypes:acceptableContentTypes];
    
            return serializer;
        }
        
        //
        // Default
        //
        default: return [MASIJSONResponseSerializer masSerializer];
    }
}

@end
