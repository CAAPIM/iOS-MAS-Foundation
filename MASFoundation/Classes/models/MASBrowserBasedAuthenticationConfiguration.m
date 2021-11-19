//
//  MASBrowserBasedAuthenticationConfiguration.m
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
#import "MASBrowserBasedAuthenticationConfiguration.h"


@implementation MASSafariBrowserBasedAuthenticationConfiguration
@end


@implementation MASWebSessionBrowserBasedAuthenticationConfiguration

- (instancetype)initWithCallbackURLScheme:(NSString *)callbackURLScheme
{
    self = [super init];
    self.callbackURLScheme = callbackURLScheme;
    
    return self;
}

@end

