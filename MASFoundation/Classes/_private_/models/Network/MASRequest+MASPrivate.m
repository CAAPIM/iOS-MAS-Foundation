//
//  MASRequest+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASRequest+MASPrivate.h"


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
@property (assign, readwrite) NSTimeInterval timeoutInterval;

@end

@implementation MASRequest (MASPrivate)

# pragma mark - Lifecycle

- (instancetype)initWithBuilder:(MASRequestBuilder *)builder
{
    self = [super init];
    if(self)
    {
        //
        // copy parameters from builder
        //
        self.endPoint = builder.endPoint;
        self.isPublic = builder.isPublic;
        self.sign = builder.sign;
        self.requestType = builder.requestType;
        self.responseType = builder.responseType;
        self.httpMethod = builder.httpMethod;
        self.privateKey = builder.privateKey;
        self.header = builder.header;
        self.body = builder.body;
        self.query = builder.query;
        self.timeoutInterval = builder.timeoutInterval;
        
        
        //
        // check if query parameters are provided
        //
        if(self.query)
        {
            //
            // add query parameters into URL
            //
            NSURL *url = [NSURL URLWithString:self.endPoint];
            
            NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray array];
            for (NSString *key in self.query) {
                NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:key value:self.query[key]];
                [queryItems addObject:queryItem];
            }
            
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            components.queryItems = [queryItems copy];
            
            self.endPoint = [components.URL absoluteString];
        }

    }
    
    return self;
}


@end
