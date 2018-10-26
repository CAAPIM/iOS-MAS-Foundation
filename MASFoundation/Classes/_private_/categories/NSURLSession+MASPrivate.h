//
//  NSURLSession+MASPrivate.h
//  MASFoundation
//
//  Created by YUSSY01 on 07/10/18.
//  Copyright © 2018 CA Technologies. All rights reserved.
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
