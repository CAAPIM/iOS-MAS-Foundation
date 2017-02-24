//
//  MASDeleteURLRequest.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASURLRequest.h"


/**
 * The HTTP DELETE specific version of the MASURLRequest:NSURLRequest.
 */
@interface MASDeleteURLRequest : MASURLRequest



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Retrieve an MASDeleteURLRequest for the DELETE request of given end point.
 *
 * @param endPoint The URL path fragment indicating which endpoint is being called.
 * @param parameterInfo The parameters dictionary to include in the request.
 * @param headerInfo The headers dictionary to include in the request.
 * @param requestType Represents the expected encoding of the request contents.
 * @param responseType Represents the excepted encoding of the response contents.
 * @return MASDeleteURLRequest which could be used to create NSURLSessionDataTask.
 */
+ (MASDeleteURLRequest *)requestForEndpoint:(NSString *)endPoint
                             withParameters:(NSDictionary *)parameterInfo
                                 andHeaders:(NSDictionary *)headerInfo
                                requestType:(MASRequestResponseType)requestType
                               responseType:(MASRequestResponseType)responseType;

@end
