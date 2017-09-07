//
//  MASRequest.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASRequest.h"

@interface MASRequest ()

@property (nonatomic, readwrite) NSString *endPoint;
@property (nonatomic, readwrite) NSString *httpMethod;
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


+ (instancetype)deleteFrom:(void (^)(MASRequestBuilder *builder))block {

    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"DELETE"];
    block(builder);
    return [builder build];
}


+ (instancetype)getFrom:(void (^)(MASRequestBuilder *builder))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"GET"];
    block(builder);
    return [builder build];
}


+ (instancetype)patchTo:(void (^)(MASRequestBuilder *builder))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"PATCH"];
    block(builder);
    return [builder build];
}


+ (instancetype)postTo:(void (^)(MASRequestBuilder *builder))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"POST"];
    block(builder);
    return [builder build];
}


+ (instancetype)putTo:(void (^)(MASRequestBuilder *builder))block {
    
    MASRequestBuilder *builder = [[MASRequestBuilder alloc] initWithHTTPMethod:@"PUT"];
    block(builder);
    return [builder build];
}


@end
