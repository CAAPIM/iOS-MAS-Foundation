//
//  MASSafariBrowserAppBasedAuthentication.h
//  MASFoundation
//
//  Copyright (c) 2020 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

@protocol MASTypedBrowserBasedAuthenticationInterface;


/**
 * A Browser Based Authentication type utilising the Safari Browser App
 */
@interface MASSafariBrowserAppBasedAuthentication : NSObject <MASTypedBrowserBasedAuthenticationInterface>

@end

