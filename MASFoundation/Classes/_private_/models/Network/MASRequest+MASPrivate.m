//
//  MASRequest+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>

#import "MASRequest+MASPrivate.h"


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

@implementation MASRequest (MASPrivate)

# pragma mark - Lifecycle

- (id)initWithBuilder:(MASRequestBuilder *)builder
{
    self = [super init];
    if(self)
    {
        self.endPoint = builder.endPoint;
        self.isPublic = builder.isPublic;
        self.sign = builder.sign;
        self.requestType = builder.requestType;
        self.responseType = builder.responseType;
        self.httpMethod = builder.httpMethod;
        self.claims = builder.claims;
        self.privateKey = builder.privateKey;
        self.header = builder.header;
        self.body = builder.body;
        self.query = builder.query;
        
        NSError *error;
        
        //
        // determines whether or not digitally sign the request parameters with JWT signature
        //
        if(self.sign)
        {
            NSString *jwt;
            
            //
            // check if MASClaims was provided, if not create a new and set the body content
            //
            if(!self.claims)
            {
                MASClaims *claims = [MASClaims claims];
                claims.content = self.body;
                claims.contentType = @"application/json";
                self.claims = claims;
            }
                
            //
            // check if custom private key was provided
            //
            if(self.claims && self.privateKey)
            {
                jwt = [MAS signWithClaims:self.claims privateKey:self.privateKey error:&error];
            }
            else {
                jwt = [MAS signWithClaims:self.claims error:&error];
            }
            
            //
            // injects JWT claims into the payload
            //
            if (!error)
            {
                [self setBody:@{@"jwt":jwt}];
            }
            else {
                //
                // Notify block
                //
                if(builder.completionBlock)
                {
                    builder.completionBlock(nil, error);
                    
                    return nil;
                }
            }
                
        }
        
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

        
        //
        // Notify block
        //
        if(builder.completionBlock)
        {
            builder.completionBlock(nil, error);
        }
    }
    
    return self;
}


@end
