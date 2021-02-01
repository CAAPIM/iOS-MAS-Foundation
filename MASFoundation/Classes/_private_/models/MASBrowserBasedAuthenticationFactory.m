//
//  MASBrowserBasedAuthenticationFactory.m
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASBrowserBasedAuthenticationFactory.h"
#import "MASSafariBrowserBasedAuthentication.h"
#import "MASWebSessionBrowserBasedAuthentication.h"

@implementation MASBrowserBasedAuthenticationFactory

+ (id<MASBrowserBasedAuthenticationInterface>)buildBrowserOfBrowserType:(MASBrowserBasedAuthenticationBrowserType)browserType {

    switch (browserType) {
    case MASBrowserBasedAuthenticationBrowserTypeSafari:
        return [[MASSafariBrowserBasedAuthentication alloc] init];
    case MASBrowserBasedAuthenticationBrowserTypeWebSession:
        return [[MASWebSessionBrowserBasedAuthentication alloc] init];
    }
}
@end
