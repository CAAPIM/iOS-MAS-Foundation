//
//  MASPatchURLRequest.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASURLRequest.h"


/**
 * The HTTP PATCH specific version of the MASURLRequest:NSURLRequest.
 */
@interface MASPatchURLRequest : MASURLRequest



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Retrieve an MASPatchURLRequest for the PATCH request of given end point.
 *
 * @param endPoint The URL path fragment indicating which endpoint is being called.
 * @param parameterInfo The parameters dictionary to include in the request.
 * @param headerInfo The headers dictionary to include in the request.
 * @param requestType Represents the expected encoding of the request contents.
 * @param responseType Represents the excepted encoding of the response contents.
 * @param isPublic Represents whether to include or exclude necessary credentials of MAG to inject in the header of the request.
 * @param timeoutInterval Represents the request's timeout interval, in seconds.
 * @return MASPatchURLRequest which could be used to create NSURLSessionDataTask.
 */
+ (MASPatchURLRequest *)requestForEndpoint:(NSString *)endPoint
                          withParameters:(NSDictionary *)parameterInfo
                              andHeaders:(NSDictionary *)headerInfo
                             requestType:(MASRequestResponseType)requestType
                              responseType:(MASRequestResponseType)responseType
                                  isPublic:(BOOL)isPublic
                           timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
