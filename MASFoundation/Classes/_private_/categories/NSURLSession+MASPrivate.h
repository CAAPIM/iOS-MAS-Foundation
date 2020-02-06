//
//  NSURLSession+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (MASPrivate)


///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Requests data synchronously through a give request.
 *
 * @param request An NSURLRequest object detailing the endpoint parameters.
 *
 * @return Data returned after synchronous request.
 */
+ (NSData *)requestSynchronousData:(NSURLRequest *)request;


/**
 * Requests data synchronously through a give URL string.
 *
 * @param requestString A URL string.
 *
 * @return Data returned after synchronous request.
 */
+ (NSData *)requestSynchronousDataWithURLString:(NSString *)requestString;


/**
 * Requests JSON synchronously through a give request.
 *
 * @param request An NSURLRequest object detailing the endpoint parameters.
 *
 * @return JSON dictionary returned after synchronous request.
 */
+ (NSDictionary *)requestSynchronousJSON:(NSURLRequest *)request;


/**
 * Requests JSON synchronously through a give URL string.
 *
 * @param requestString A URL string.
 *
 * @return JSON dictionary returned after synchronous request.
 */
+ (NSDictionary *)requestSynchronousJSONWithURLString:(NSString *)requestString;


@end

NS_ASSUME_NONNULL_END
