//
//  MASIJSONResponseSerializer+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASIJSONResponseSerializer+MASPrivate.h"

#import "NSError+MASPrivate.h"

@implementation MASIJSONResponseSerializer (MASprivate)

+ (MASIJSONResponseSerializer *)masSerializer
{
    MASIJSONResponseSerializer *serializer = [MASIJSONResponseSerializer serializer];
    
    //
    // Must add the SCIM JSON content type to the list of acceptable content types
    //
    NSMutableSet *acceptableContentTypes = [[serializer acceptableContentTypes] mutableCopy];
    [acceptableContentTypes addObject:@"application/scim+json"];
    [acceptableContentTypes addObject:@"text/plain"];
    [serializer setAcceptableContentTypes:acceptableContentTypes];
    
    return serializer;
}

- (BOOL)validateJSONResponse:(nullable NSHTTPURLResponse *)response
                        data:(nullable NSData *)data
                       error:(NSError * __nullable __autoreleasing * __nullable)error
{
    BOOL isValid = YES;
    
    NSMutableDictionary *mutableUserInfo = [@{
                                              NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: unacceptable content-type: %@", @"MASINetworking", nil), [response MIMEType]],
                                              NSURLErrorFailingURLErrorKey:[response URL],
                                              MASINetworkingOperationFailingURLResponseErrorKey: response,
                                              } mutableCopy];
    
    if (![data isKindOfClass:[NSDictionary class]])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:MASFoundationErrorCodeNetworkUnacceptableContentType userInfo:mutableUserInfo];
        }
        isValid = NO;
    }
    
    return isValid;
}

@end
