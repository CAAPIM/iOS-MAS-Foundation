//
//  MASJWKSet.m
//  MASFoundation
//
//  Created by YUSSY01 on 05/10/18.
//  Copyright © 2018 CA Technologies. All rights reserved.
//

#import "MASJWKSet.h"

#import "MASJWTService.h"
#import "MASConfiguration.h"
#import "MASIKeyChainStore.h"
#import "NSData+MASPrivate.h"
#import "MASKeyChainService.h"


# pragma mark - JSONWebKeySet Constants

static NSString *const MASJWKSetKeysKey = @"keys"; // value is Dictionary


@implementation MASJWKSet

static NSDictionary *_jsonWebKeySetInfo_;


# pragma mark - Current Configuration

+ (MASJWKSet *)currentJWKSet
{
    return [MASJWTService sharedService].currentJWKSet;
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
    if (self)
    {
        
    }
    
    return self;
}


- (id)initWithJWKSetInfo:(NSDictionary *)info
{
    if (self = [super init])
    {
        _jsonWebKeySetInfo_ = info;
        
        [self setValue:[NSNumber numberWithBool:(_jsonWebKeySetInfo_ && ([_jsonWebKeySetInfo_ count] > 0))] forKey:@"isLoaded"];
    }
    
    [self saveToStorage];
    
    return self;
}


+ (MASJWKSet *)instanceFromStorage
{
    MASJWKSet *jasonWebKeySet;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] dataForKey:[MASJWKSet.class description]];
    if (data)
    {
        jasonWebKeySet = (MASJWKSet *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return jasonWebKeySet;
}


- (void)saveToStorage
{
    //
    // Save to the keychain
    //
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (data)
    {
        NSError *error;
        [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] setData:data forKey:[MASJWKSet.class description] error:&error];
        if (error)
        {
            DLog(@"Error attempting to save data: %@", [error localizedDescription]);
        }
    }
}


- (void)reset
{
    [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] removeItemForKey:[MASJWKSet.class description]];
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //
    // Keychain
    //
    MASKeyChainService *keyChainService = [MASKeyChainService keyChainService];
    
    // JWKSet
    if (_jsonWebKeySetInfo_)
    {
        [keyChainService setJsonWebKeySet:_jsonWebKeySetInfo_];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        MASKeyChainService *keyChainService = [MASKeyChainService keyChainService];
        
        _jsonWebKeySetInfo_ = [keyChainService jsonWebKeySet];
        
        
        [self setValue:[NSNumber numberWithBool:(_jsonWebKeySetInfo_ && ([_jsonWebKeySetInfo_ count] > 0))] forKey:@"isLoaded"];
    }
    
    return self;
}


# pragma mark - Properties


- (NSArray *)jsonWebKeys
{
    NSArray *jsonWebKeys = _jsonWebKeySetInfo_[MASJWKSetKeysKey];
    
    return jsonWebKeys;
}

@end
