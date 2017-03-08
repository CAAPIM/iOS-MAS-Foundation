//
//  MASHTTPSessionManager.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASIHTTPSessionManager.h"

#import "MASConstantsPrivate.h"

@interface MASHTTPSessionManager : MASIHTTPSessionManager



# pragma mark - Lifecycle

/**
 *  Return MASHTTPSessionManager object with given URL
 *
 *  @param url NSURL for the host to establish session
 *
 *  @return MASHTTPSessionManager object
 */
- (instancetype)initWithBaseURL:(NSURL *)url;



/**
 *  Return MASHTTPSessionManager object with given URL and SessionConfiguration
 *
 *  @param url           NSURL for the host to establish session
 *  @param configuration NSURLSessionConfiguration to establish session
 *
 *  @return MASHTTPSessionManager object
 */
- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration;

@end
