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
#import "ChilkatCipher.h"

NSString * const MASRequestResponseTypeJsonValue = @"application/json";
NSString * const MASRequestResponseTypeScimJsonValue = @"application/scim+json";
NSString * const MASRequestResponseTypeTextPlainValue = @"text/plain";
NSString * const MASRequestResponseTypeWwwFormUrlEncodedValue = @"application/x-www-form-urlencoded";
NSString * const MASRequestResponseTypeXmlValue = @"application/xml";

NSString * const MASRequestResponseTypeBS2RegisterValue = @"text/plain";
NSString * const MASRequestResponseTypeBS2CustomValue = @"text/plain";

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
        NSLog(@"\n\nRequest text plain");
        data = [[parameterInfo allValues][0] dataUsingEncoding:NSUTF8StringEncoding];
        // data = [MASURLRequest dataForBodyFromParameterInfo:parameterInfo];
    }
        
    //
    // JSON (or SCIM variant)
    //
    else if(requestType == MASRequestResponseTypeJson || requestType == MASRequestResponseTypeScimJson)
    {
        NSLog(@"\n\nRequest JSON");
        data = [NSJSONSerialization dataWithJSONObject:parameterInfo options:NSJSONWritingPrettyPrinted error:nil];
        // data = [MASURLRequest dataForBodyFromParameterInfo:parameterInfo];
    }
        
    //
    // Form Url Encoded
    //
    else if(requestType == MASRequestResponseTypeWwwFormUrlEncoded)
    {
        data = [[self queryParametersFromInfo:parameterInfo] dataUsingEncoding:NSUTF8StringEncoding];
        // data = [MASURLRequest dataForBodyFromParameterInfo:parameterInfo];
    }
    
    //
    // Custom Initialize BS2
    //
    else if(requestType == MASRequestResponseTypeBS2Custom) {
        data = [MASURLRequest dataForBodyFromParameterInfo:parameterInfo];
    }
    
    //
    // Custom Register BS2
    //
    else if(requestType == MASRequestResponseTypeBS2Register) {
        data = [MASURLRequest dataForBS2RegisterWithParameterInfo:parameterInfo];
    }
    
    return data;
}

+ (NSData *)dataForBS2RegisterWithParameterInfo:(NSDictionary *)parameterInfo {
    
    if (![MASDevice currentDevice].isRegistered) {
        NSString *certificateSigning = parameterInfo[MASCertificateSigningRequestResponseKey];
        NSString *csr = parameterInfo[MASCertificateSigningRequestResponseKey];
        NSString *passphrase = parameterInfo[@"passphrase"];
        NSLog(@"\n\nRegister passphase: %@", passphrase);
        NSString *plainBody = [NSString stringWithFormat:@"{\"form\":\"passphrase=%@&certificateSigningRequest=%@&csr=%@\"}", [passphrase BS2Base64URL], [certificateSigning URLEncodeString:NSUTF8StringEncoding], [csr URLEncodeString:NSUTF8StringEncoding]];
        NSLog(@"\n\nRegister plain body: %@", plainBody);
        NSString *encryptedBody = [ChilkatCipher encryptPlainText:plainBody];
        return [encryptedBody dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSLog(@"\n\nRequest text plain");
    return [[parameterInfo allValues][0] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)dataForBodyFromParameterInfo:(NSDictionary *)parameterInfo {
    
    NSLog(@"\n\nRequest BS2 Custom");
    NSString *clientId = parameterInfo[MASClientKeyRequestResponseKey];
    NSString *nonce = parameterInfo[MASNonceRequestResponseKey];
    NSString *passphrase = parameterInfo[@"passphrase"];
    NSString *plainBody = [NSString stringWithFormat:@"{\"form\":\"client_id=%@&nonce=%@&passphrase=%@\"}",
                           [clientId BS2Base64URL], [nonce BS2Base64URL], [passphrase URLEncodeString:NSUTF8StringEncoding]];
    
    NSString *encryptedBody = [ChilkatCipher encryptPlainText:plainBody];
    NSLog(@"\n\nPlain body: %@", plainBody);
    
    return [encryptedBody dataUsingEncoding:NSUTF8StringEncoding];
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
        // Default
        //
        default: return [MASIJSONResponseSerializer masSerializer];
    }
}

@end
