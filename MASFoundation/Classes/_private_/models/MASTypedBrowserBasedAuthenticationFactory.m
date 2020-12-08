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
#import "MASSafariBrowserBasedAuthentication.h"
#import "MASWebSessionBrowserBasedAuthentication.h"

@implementation MASTypedBrowserBasedAuthenticationFactory

+ (id<MASTypedBrowserBasedAuthenticationInterface>)buildBrowserForType:(MASBrowserBasedAuthenticationType)browserBasedAuthenticationType {
    if (@available(iOS 12.0, macOS 10.15, *)) {
        switch (browserBasedAuthenticationType) {
            case MASBrowserBasedAuthenticationTypeSafari:
                return [[MASSafariBrowserBasedAuthentication alloc] init];
            case MASBrowserBasedAuthenticationTypeWebSession:
                return [[MASWebSessionBrowserBasedAuthentication alloc] init];
        }
    } else {
        return [[MASSafariBrowserBasedAuthentication alloc] init];
    }
}
@end
