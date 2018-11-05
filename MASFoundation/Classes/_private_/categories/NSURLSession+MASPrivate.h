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


+ (NSData *)requestSynchronousData:(NSURLRequest *)request;


+ (NSData *)requestSynchronousDataWithURLString:(NSString *)requestString;


+ (NSDictionary *)requestSynchronousJSON:(NSURLRequest *)request;


+ (NSDictionary *)requestSynchronousJSONWithURLString:(NSString *)requestString;


@end

NS_ASSUME_NONNULL_END
