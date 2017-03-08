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


# pragma mark - Property Constants

static NSString *const MASAuthenticationProviderIdentifierPropertyKey = @"identifier"; // string
static NSString *const MASAuthenticationProviderAuthenticationUrlPropertyKey = @"authenticationUrl"; // string
static NSString *const MASAuthenticationProviderPollUrlPropertyKey = @"pollUrl"; // string


@implementation MASAuthenticationProvider (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithInfo:(NSDictionary *)info
{
    //DLog(@"called with updated info: %@", info);
    
    NSAssert(info, @"info cannot be nil");
    
    self = [super init];
    if(self)
    {
        //
        // Identifier
        //
        self.identifier = info[MASIdRequestResponseKey];
    
        //
        // Authentication URL
        //
        NSString *authenticationUrlValue = info[MASAuthenticationUrlRequestResponseKey];
        if (authenticationUrlValue) self.authenticationUrl = [NSURL URLWithString:authenticationUrlValue];
    
        //
        // Poll URL (not all use this)
        //
        NSString *pollUrlValue = info[MASPollUrlRequestResponseKey];
        if (pollUrlValue) self.pollUrl = [NSURL URLWithString:pollUrlValue];
        
        //
        // Save to storage
        //
//        [self saveToStorage];
    }
    
    return self;
}


+ (MASAuthenticationProvider *)instanceFromStorage;
{
    //DLog(@"\n\ncalled%@\n\n");
    
    MASAuthenticationProvider *provider;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStore] dataForKey:[MASAuthenticationProvider.class description]];
    if(data)
    {
        provider = (MASAuthenticationProvider *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    //DLog(@"\n\n  found in storage: %@\n\n", [provider debugDescription]);
    
    return provider;
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
                                            forKey:[MASAuthenticationProvider.class description]
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
    [[MASIKeyChainStore keyChainStore] removeItemForKey:[MASAuthenticationProvider.class description]];
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
    [super encodeWithCoder:aCoder];
    
    if(self.identifier) [aCoder encodeObject:self.identifier forKey:MASAuthenticationProviderIdentifierPropertyKey];
    if(self.authenticationUrl) [aCoder encodeObject:self.authenticationUrl forKey:MASAuthenticationProviderAuthenticationUrlPropertyKey];
    if(self.pollUrl) [aCoder encodeObject:self.pollUrl forKey:MASAuthenticationProviderPollUrlPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //DLog(@"\n\ncalled\n\n");
    
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.identifier = [aDecoder decodeObjectForKey:MASAuthenticationProviderIdentifierPropertyKey];
        self.authenticationUrl = [aDecoder decodeObjectForKey:MASAuthenticationProviderAuthenticationUrlPropertyKey];
        self.pollUrl = [aDecoder decodeObjectForKey:MASAuthenticationProviderPollUrlPropertyKey];
    }
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)identifier
{
    return objc_getAssociatedObject(self, &MASAuthenticationProviderIdentifierPropertyKey);
}


- (void)setIdentifier:(NSString *)identifier
{
    objc_setAssociatedObject(self, &MASAuthenticationProviderIdentifierPropertyKey, identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSURL *)authenticationUrl
{
    return objc_getAssociatedObject(self, &MASAuthenticationProviderAuthenticationUrlPropertyKey);
}


- (void)setAuthenticationUrl:(NSURL *)authenticationUrl
{
    objc_setAssociatedObject(self, &MASAuthenticationProviderAuthenticationUrlPropertyKey, authenticationUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSURL *)pollUrl
{
    return objc_getAssociatedObject(self, &MASAuthenticationProviderPollUrlPropertyKey);
}


- (void)setPollUrl:(NSURL *)pollUrl
{
    objc_setAssociatedObject(self, &MASAuthenticationProviderPollUrlPropertyKey, pollUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
