//
//  MASConfiguration.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASConfiguration.h"

#import "MASConstantsPrivate.h"
#import "MASConfigurationService.h"


@implementation MASConfiguration


# pragma mark - Current Configuration

+ (MASConfiguration *)currentConfiguration
{
    return [MASConfigurationService sharedService].currentConfiguration;
}


#pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) is loaded: %@\n\n        application name: %@\n        application type: %@\n"
            "        application description: %@\n        application organization: %@\n        application registered by: %@\n"
            "        gateway host: %@\n        gateway port: %@\n        gateway prefix: %@\n        gateway url: %@\n"
            "        location is required: %@       sso enabled: %@",
        [self class], ([self isLoaded] ? @"Yes" : @"No"), [self applicationName], [self applicationType],
        [self applicationDescription], [self applicationOrganization], [self applicationRegisteredBy],
        [self gatewayHostName], [self gatewayPort], [self gatewayPrefix], [self gatewayUrl],
        ([self locationIsRequired] ? @"Yes" : @"No"), ([self ssoEnabled] ? @"YES" : @"NO")];
}


# pragma mark - Endpoints

- (NSString *)endpointPathForKey:(NSString *)endpointKey
{
    // overriden in private category
    return nil;
}

@end
