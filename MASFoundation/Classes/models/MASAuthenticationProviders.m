//
//  MASAuthenticationProviders.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthenticationProviders.h"

#import "MASConstantsPrivate.h"
#import "MASModelService.h"

# pragma mark - Property Constants

static NSString *const MASAuthenticationProvidersPropertyKey = @"providers"; // string
static NSString *const MASAuthenticationProvidersIDPPropertyKey = @"idp"; // string

@implementation MASAuthenticationProviders


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
    NSMutableString *providers = [[NSMutableString alloc] initWithString:@"        {\n"];
    for(MASAuthenticationProvider *provider in self.providers)
    {
        [providers appendString:[NSString stringWithFormat:@"          %@\n", provider.identifier]];
        [providers appendString:[NSString stringWithFormat:@"          %@\n\n", provider.authenticationUrl]];
    }
    
    [providers appendString:@"        }"];
    
    return [NSString stringWithFormat:@"(%@) %ld providers found\n\n        providers:\n\n%@",
        [self class], (long)[self providers].count, providers];
}


# pragma mark - Authentication Providers

+ (MASAuthenticationProviders *)currentProviders
{
    return [MASModelService sharedService].currentProviders;
}


+ (void)retrieveAuthenticationProvidersWithCompletion:(MASObjectResponseErrorBlock)completion
{
    __block MASObjectResponseErrorBlock blockCompletion = completion;
    
    [[MASModelService sharedService] registerApplication:^(BOOL completed, NSError *error) {
        
        if (!completed || error)
        {
            blockCompletion(nil, error);
        }
        else {
            
            [[MASModelService sharedService] retrieveAuthenticationProviders:^(id object, NSError *error) {
                
                blockCompletion(object, error);
            }];
        }
    }];
}


# pragma mark - Proximity Login

- (MASAuthenticationProvider *)retrieveAuthenticationProviderForProximityLogin
{
    MASAuthenticationProvider *authProvider = nil;
    
    for (MASAuthenticationProvider *provider in self.providers)
    {
        if (provider.isQrCode)
        {
            authProvider = provider;
        }
    }
    
    return authProvider;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    if(self.providers) [aCoder encodeObject:self.providers forKey:MASAuthenticationProvidersPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setValue:[aDecoder decodeObjectForKey:MASAuthenticationProvidersPropertyKey] forKey:@"providers"];
    }
    
    return self;
}


@end
