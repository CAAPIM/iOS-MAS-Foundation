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
@property (assign, readwrite) BOOL sign;
@property (nonatomic, strong, readwrite) MASClaims *claims;
@property (nonatomic, strong, readwrite) NSData *privateKey;
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


- (MASRequest *)build
{
    return [[MASRequest alloc] initWithBuilder:self];
}


- (void)setSignWithError:(NSError *__nullable __autoreleasing *__nullable)error
{
    self.sign = TRUE;
    
    //
    // create a new MASClaims and set the body content
    //
    MASClaims *claims = [MASClaims claims];
    claims.content = self.body;
    claims.contentType = @"application/json";
    self.claims = claims;
    
    NSString *jwt = [MAS signWithClaims:claims error:error];
    
    //
    // injects JWT claims into the payload
    //
    if (!*error)
    {
        [self setBody:@{@"jwt":jwt}];
    }
    
}

- (void)setSignWithClaims:(MASClaims *)claims error:(NSError *__nullable __autoreleasing *__nullable)error
{
    self.sign = TRUE;
    self.claims = claims;
    
    NSString *jwt = [MAS signWithClaims:claims error:error];
    
    //
    // injects JWT claims into the payload
    //
    if (!*error)
    {
        [self setBody:@{@"jwt":jwt}];
    }
}


- (void)setSignWithClaims:(MASClaims *)claims privateKey:(NSData *)privateKey error:(NSError *__nullable __autoreleasing *__nullable)error
{
    self.sign = TRUE;
    self.claims = claims;
    self.privateKey = privateKey;
    
    NSString *jwt = [MAS signWithClaims:claims privateKey:self.privateKey error:error];
    
    //
    // injects JWT claims into the payload
    //
    if (!*error)
    {
        [self setBody:@{@"jwt":jwt}];
    }
}


@end
