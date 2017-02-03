//
//  NSURL+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

@interface NSURL (MASPrivate)

- (BOOL)isProtectedEndpoint:(NSString *)thisEndpoint;

@end
