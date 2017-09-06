//
//  MASRequestBuilder.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASRequestBuilder.h"

#import "MASRequest+MASPrivate.h"

@interface MASRequestBuilder ()

@property (nonatomic, strong, readwrite) NSString *httpMethod;

@end

@implementation MASRequestBuilder


# pragma mark - Lifecycle


- (instancetype)initWithHTTPMethod:(NSString *)method
{
    self = [super init];
    
    if (self) {
        self.httpMethod = method;
        self.isPublic = NO;
        self.sign = NO;
        self.requestType = MASRequestResponseTypeJson;
        self.responseType = MASRequestResponseTypeJson;
    }
    
    return self;
}


# pragma mark - Public

- (id)build
{
    return [[MASRequest alloc] initWithBuilder:self];
}


- (void)setSignWithClaims:(MASClaims *)claims
{
    self.sign = TRUE;
    self.claims = claims;
}


- (void)setSignWithClaims:(MASClaims *)claims privateKey:(NSData *)privateKey
{
    self.sign = TRUE;
    self.claims = claims;
    self.privateKey = privateKey;
}


- (void)setHeaderParameter:(NSString *)key value:(NSString *)value
{
    if(self.header)
    {
        [self.header setValue:value forKey:key];
    }
    else {
        self.header = [[NSDictionary alloc] initWithObjectsAndKeys:value,key, nil];
    }
}

- (void)setBodyParameter:(NSString *)key value:(NSString *)value
{
    if(self.body)
    {
        [self.body setValue:value forKey:key];
    }
    else {
        self.body = [[NSDictionary alloc] initWithObjectsAndKeys:value,key, nil];
    }
}

- (void)setQueryParameter:(NSString *)key value:(NSString *)value
{
    if(self.query)
    {
        [self.query setValue:value forKey:key];
    }
    else {
        self.query = [[NSDictionary alloc] initWithObjectsAndKeys:value,key, nil];
    }
}


@end
