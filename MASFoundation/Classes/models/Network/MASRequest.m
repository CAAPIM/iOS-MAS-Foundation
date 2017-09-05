//
//  MASRequest.m
//  MASFoundation
//
//  Created by Reis, Rodrigo on 2017-08-29.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASRequest.h"

@interface MASRequest ()

@property (nonatomic, readwrite) NSString *endPoint;
@property (nonatomic, readwrite) NSString *httpMethod;
@property (nonatomic, readwrite) MASClaims *claims;
@property (nonatomic, readwrite) NSData *privateKey;
@property (nonatomic, readwrite) NSDictionary *header;
@property (nonatomic, readwrite) NSDictionary *body;
@property (nonatomic, readwrite) NSDictionary *query;
@property (assign, readwrite) BOOL isPublic;
@property (assign, readwrite) BOOL sign;
@property (assign, readwrite) MASRequestResponseType requestType;
@property (assign, readwrite) MASRequestResponseType responseType;

@end

@implementation MASRequest

+ (instancetype)delete:(void (^)(MASRequestBuilder *))block {

    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"DELETE"];
    block(builder);
    return [builder build];
}

+ (instancetype)get:(void (^)(MASRequestBuilder *))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"GET"];
    block(builder);
    return [builder build];
}

+ (instancetype)patch:(void (^)(MASRequestBuilder *))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"PATCH"];
    block(builder);
    return [builder build];
}

+ (instancetype)post:(void (^)(MASRequestBuilder *))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"POST"];
    block(builder);
    return [builder build];
}

+ (instancetype)put:(void (^)(MASRequestBuilder *))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"PUT"];
    block(builder);
    return [builder build];
}

@end
