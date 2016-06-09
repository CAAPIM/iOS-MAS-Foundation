//
//  MASIJSONResponseSerializer+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASIJSONResponseSerializer+MASPrivate.h"


@implementation MASIJSONResponseSerializer (MASprivate)

+ (MASIJSONResponseSerializer *)masSerializer
{
    MASIJSONResponseSerializer *serializer = [MASIJSONResponseSerializer serializer];
    
    //
    // Must add the SCIM JSON content type to the list of acceptable content types
    //
    NSMutableSet *acceptableContentTypes = [[serializer acceptableContentTypes] mutableCopy];
    [acceptableContentTypes addObject:@"application/scim+json"];
    [serializer setAcceptableContentTypes:acceptableContentTypes];
    
    return serializer;
}

@end
