//
//  MASAuthenticationProviders+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthenticationProviders+MASPrivate.h"

#import <objc/runtime.h>
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"


# pragma mark - Property Constants

static NSString *const MASAuthenticationProvidersPropertyKey = @"providers"; // string

static NSString *const MASAuthenticationProvidersIDPPropertyKey = @"idp"; // string


@implementation MASAuthenticationProviders (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithInfo:(NSDictionary *)info
{
    //DLog(@"called with updated info: %@", info);
    
    NSAssert(info, @"info cannot be nil");
    
    self = [super init];
    if(self)
    {
        //
        // Retrieve the providers array
        //
        NSArray *providersInfo = info[MASProvidersRequestResponseKey];
        
        //
        // Iterate the providers, create and populate the providers
        //
        NSMutableArray *providers = [NSMutableArray new];
        MASAuthenticationProvider *provider;
        for(NSDictionary *providerInfo in providersInfo)
        {
            provider = [[MASAuthenticationProvider alloc] initWithInfo:providerInfo[MASProviderRequestResponseKey]];
            [providers addObject:provider];
        }
        
        self.providers = providers;
        
        self.idp = info[MASIDPRequestResponseKey];
        
        /**
         *  Do not store the authentication provider information into keychain as it will have to be updated as JSON configuration/host is changed
         */
        //
        // Save to storage
        //
//        [self saveToStorage];
    }
    
    return self;
}


+ (MASAuthenticationProviders *)instanceFromStorage;
{
    //DLog(@"\n\ncalled%@\n\n");
    
    MASAuthenticationProviders *providers;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStore] dataForKey:[MASAuthenticationProviders.class description]];
    if(data)
    {
        providers = (MASAuthenticationProviders *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    //DLog(@"\n\n  found in storage: %@\n\n", [provider debugDescription]);
    
    return providers;
}


- (void)saveToStorage
{
    //DLog(@"\n\ncalled%@\n\n");
    
    //
    // Save to the keychain
    //
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if(data)
    {
        NSError *error;
        [[MASIKeyChainStore keyChainStore] setData:data
                                            forKey:[MASAuthenticationProviders.class description]
                                            error:&error];
    
        if(error)
        {
           //tvos  DLog(@"Error attempting to save data: %@", [error localizedDescription]);
            return;
        }
    }
    
    //DLog(@"called with info: %@", [self debugDescription]);
}


- (void)reset
{
    //
    // Reset each instance
    //
    for(MASAuthenticationProvider *provider in self.providers)
    {
        [provider reset];
    }
    self.providers = nil;
    
    //
    // Remove from the keychain storage
    //
    [[MASIKeyChainStore keyChainStore] removeItemForKey:[MASAuthenticationProviders.class description]];
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
    [super encodeWithCoder:aCoder];
    
    if(self.providers) [aCoder encodeObject:self.providers forKey:MASAuthenticationProvidersPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //DLog(@"\n\ncalled\n\n");
    
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.providers = [aDecoder decodeObjectForKey:MASAuthenticationProvidersPropertyKey];
    }
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSArray *)providers
{
    return objc_getAssociatedObject(self, &MASAuthenticationProvidersPropertyKey);
}


- (void)setProviders:(NSArray *)providers
{
    objc_setAssociatedObject(self, &MASAuthenticationProvidersPropertyKey, providers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)idp
{
    return objc_getAssociatedObject(self, &MASAuthenticationProvidersIDPPropertyKey);
}


- (void)setIdp:(NSString *)idp
{
    objc_setAssociatedObject(self, &MASAuthenticationProvidersIDPPropertyKey, idp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
