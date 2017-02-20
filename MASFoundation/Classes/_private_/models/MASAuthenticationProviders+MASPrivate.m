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

@implementation MASAuthenticationProviders (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithInfo:(NSDictionary *)info
{
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
        
        [self setValue:providers forKey:@"providers"];
        
        [self setValue:info[MASIDPRequestResponseKey] forKey:@"idp"];
        
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
    MASAuthenticationProviders *providers;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStore] dataForKey:[MASAuthenticationProviders.class description]];
    if(data)
    {
        providers = (MASAuthenticationProviders *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return providers;
}


- (void)saveToStorage
{
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
            //DLog(@"Error attempting to save data: %@", [error localizedDescription]);
            return;
        }
    }
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
    
    [self setValue:nil forKey:@"providers"];
    
    //
    // Remove from the keychain storage
    //
    [[MASIKeyChainStore keyChainStore] removeItemForKey:[MASAuthenticationProviders.class description]];
}

@end
