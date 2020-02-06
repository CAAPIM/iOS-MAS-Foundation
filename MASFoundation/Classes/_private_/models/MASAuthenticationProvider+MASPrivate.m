//
//  MASAuthenticationProvider+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthenticationProvider+MASPrivate.h"

#import <objc/runtime.h>
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"

@implementation MASAuthenticationProvider (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithInfo:(NSDictionary *)info
{
    NSAssert(info, @"info cannot be nil");
    
    self = [super init];
    if(self)
    {
        //
        // Identifier
        //
        [self setValue:info[MASIdRequestResponseKey] forKey:@"identifier"];
    
        //
        // Authentication URL
        //
        NSString *authenticationUrlValue = info[MASAuthenticationUrlRequestResponseKey];
        if (authenticationUrlValue) [self setValue:[NSURL URLWithString:authenticationUrlValue] forKey:@"authenticationUrl"];
    
        //
        // Poll URL (not all use this)
        //
        NSString *pollUrlValue = info[MASPollUrlRequestResponseKey];
        if (pollUrlValue) [self setValue:[NSURL URLWithString:pollUrlValue] forKey:@"pollUrl"];
        
        //
        // Save to storage
        //
//        [self saveToStorage];
    }
    
    return self;
}


+ (MASAuthenticationProvider *)instanceFromStorage;
{
    MASAuthenticationProvider *provider;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStore] dataForKey:[MASAuthenticationProvider.class description]];
    if(data)
    {
        provider = (MASAuthenticationProvider *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return provider;
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
                                            forKey:[MASAuthenticationProvider.class description]
                                            error:&error];
    
        if(error)
        {
            DLog(@"Error attempting to save data: %@", [error localizedDescription]);
            return;
        }
    }
}


- (void)reset
{
    [[MASIKeyChainStore keyChainStore] removeItemForKey:[MASAuthenticationProvider.class description]];
}

@end
