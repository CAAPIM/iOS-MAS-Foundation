//
//  NSMutableURLRequest+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "NSMutableURLRequest+MASPrivate.h"


@implementation NSMutableURLRequest (MASPrivate)


# pragma mark - Public

- (void)setHeaderInfo:(NSDictionary *)headerInfo forRequestType:(MASRequestResponseType)requestType andResponseType:(MASRequestResponseType)responseType
{   
    //DLog(@"Setting request content type: %@", [self requestResponseTypeAsMimeTypeString:requestType]);
    
    //
    // Content Type based on MASRequestResponseType
    //
    [self setValue:[self requestResponseTypeAsMimeTypeString:requestType] forHTTPHeaderField:MASContentTypeRequestResponseKey];
    
    //DLog(@"Setting response content type: %@", [self requestResponseTypeAsMimeTypeString:responseType]);
    
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
            
        case MASRequestResponseTypeImageData : return MASRequestResponseTypeImageDataValue;
        
        //
        // Default
        //
        default: return MASRequestResponseTypeTextPlainValue;
    }
}


- (MASRequestResponseType)requestResponseTypeFromMimeTypeString:(NSString *)mimeType
{
    //
    // JSON
    //
    if([mimeType isEqualToString:MASRequestResponseTypeJsonValue]) return MASRequestResponseTypeJson;
    
    //
    // SCIM variant JSON
    //
    else if([mimeType isEqualToString:MASRequestResponseTypeScimJsonValue]) return MASRequestResponseTypeScimJson;
    
    //
    // Form URL Encoded
    //
    else if([mimeType isEqualToString:MASRequestResponseTypeWwwFormUrlEncodedValue]) return MASRequestResponseTypeWwwFormUrlEncoded;
    
    //
    // XML
    //
    else if([mimeType isEqualToString:MASRequestResponseTypeXmlValue]) return MASRequestResponseTypeXml;
    
    
    else if([mimeType isEqualToString:MASRequestResponseTypeFormDataValue]) return MASRequestResponseTypeFormData;
    
    else if([mimeType isEqualToString:MASRequestResponseTypeImageDataValue]) return MASRequestResponseTypeImageData;
    //
    // Default to text/plain
    //
    return MASRequestResponseTypeTextPlain;
}

@end
