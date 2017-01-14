//
//  MASIJSONResponseSerializer+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASIURLResponseSerialization.h"


@interface MASIJSONResponseSerializer (MASPrivate)

+ (nonnull MASIJSONResponseSerializer *)masSerializer;

- (BOOL)validateJSONResponse:(nullable NSHTTPURLResponse *)response
                        data:(nullable NSData *)data
                       error:(NSError * __nullable __autoreleasing * __nullable)error;

@end
