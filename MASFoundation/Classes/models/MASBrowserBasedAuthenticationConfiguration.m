//
//  MASBrowserBasedAuthenticationConfiguration.m
//  MASFoundation
//
//  Created by sander saelmans on 21/12/2020.
//  Copyright © 2020 CA Technologies. All rights reserved.
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

