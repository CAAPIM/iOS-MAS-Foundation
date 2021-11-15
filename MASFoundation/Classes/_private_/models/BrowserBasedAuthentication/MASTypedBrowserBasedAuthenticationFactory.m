//
//  MASTypedBrowserBasedAuthenticationFactory.m
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASTypedBrowserBasedAuthenticationFactory.h"
#import "MASBrowserBasedAuthenticationConfiguration.h"
#import "MASSafariBrowserBasedAuthentication.h"
#import "MASSafariBrowserAppBasedAuthentication.h"
#import "MASWebSessionBrowserBasedAuthentication.h"

@implementation MASTypedBrowserBasedAuthenticationFactory

+ (id<MASTypedBrowserBasedAuthenticationInterface>)buildBrowserWithConfiguration:(id<MASBrowserBasedAuthenticationConfigurationInterface>)configuration {

    if ([configuration isKindOfClass: [MASSafariBrowserBasedAuthenticationConfiguration class]])
    {
        return [[MASSafariBrowserBasedAuthentication alloc] init];
    }
    if ([configuration isKindOfClass:[MASSafariBrowserAppBasedAuthenticationConfiguration class]]) {
        
        return [[MASSafariBrowserAppBasedAuthentication alloc] init];
    }
    if (@available(iOS 12.0, macOS 10.15, *))
    {
        if ([configuration isKindOfClass: [MASWebSessionBrowserBasedAuthenticationConfiguration class]])
        {
            MASWebSessionBrowserBasedAuthenticationConfiguration *castedConfiguration = configuration;
            
            return [[MASWebSessionBrowserBasedAuthentication alloc] initWithCallbackURLScheme:castedConfiguration.callbackURLScheme];
        }
    }

    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot produce result with the provided configuration." userInfo:nil];
    return nil;
}
@end
