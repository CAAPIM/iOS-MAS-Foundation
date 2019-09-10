//
//  MASNetworkConfiguration.m
//  MASFoundation
//
//  Created by yussy01 on 05/09/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
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
