//
//  MASNetworkConfiguration.m
//  MASFoundation
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASNetworkConfiguration.h"

#import "MASConstantsPrivate.h"


@interface MASNetworkConfiguration ()

@property (nonatomic, strong, readwrite) NSURL *host;

@end


@implementation MASNetworkConfiguration


# pragma mark - Lifecycle

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    
    if (self) {
        self.host = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%@", url.scheme, url.host, url.port]];
        self.timeoutInterval = MASDefaultNetworkTimeoutConfiguration;
    }
    
    return self;
}

@end
