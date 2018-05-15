//
//  MASMultiFactorHandler.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASMultiFactorHandler.h"
#import "NSError+MASPrivate.h"


@interface MASMultiFactorHandler ()

@property (nonatomic, copy) MASResponseInfoErrorBlock originalCompletionBlock;

@end


@implementation MASMultiFactorHandler

# pragma mark - Lifecycle

- (instancetype)initWithRequest:(MASRequest *)request
{
    self = [super init];
    
    if (self)
    {
        self.request = request;
    }
    
    return self;
}


- (instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`-init` is not available. Use `-initWithRequest:` instead"
                                 userInfo:nil];
    return nil;
}


+ (instancetype)new
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"`+new` is not available. Use `-initWithRequest:` instead"
                                 userInfo:nil];
    return nil;
}

- (void)proceedWithHeaders:(NSDictionary *)headers
{
    if (self.request != nil)
    {
        MASRequest *request = nil;
        
        //
        //  If there is no additional information, proceed with the original request
        //
        if (headers == nil)
        {
            request = _request;
        }
        //
        //  Otherwise, re-construct the request with given original request
        //
        else {
            MASRequestBuilder *requestBuilder = [[MASRequestBuilder alloc] initWithHTTPMethod:self.request.httpMethod];
            requestBuilder.endPoint = self.request.endPoint;
            requestBuilder.requestType = self.request.requestType;
            requestBuilder.responseType = self.request.responseType;
            requestBuilder.query = self.request.query;
            requestBuilder.body = self.request.body;
            requestBuilder.isPublic = self.request.isPublic;
            
            //
            //  Append new headers to the original headers
            //
            NSMutableDictionary *updatedHeader = [self.request.header mutableCopy];
            [updatedHeader addEntriesFromDictionary:headers];
            requestBuilder.header = updatedHeader;
            
            request = [requestBuilder build];
        }
        
        //
        //  Proceed with the request
        //
        [MAS invoke:request completion:^(NSHTTPURLResponse *response, id responsePayload, NSError *error) {
            
            //
            //  If the original completion block is defined, re-structure the response payload, and invoke the callback block.
            //
            if (_originalCompletionBlock)
            {
                NSMutableDictionary *responseObject = [NSMutableDictionary dictionary];
                NSDictionary *responseHeaders = [response allHeaderFields];
                
                if (responseHeaders != nil)
                {
                    [responseObject setObject:responseHeaders forKey:MASResponseInfoHeaderInfoKey];
                }
                
                if (responsePayload != nil)
                {
                    [responseObject setObject:responsePayload forKey:MASResponseInfoBodyInfoKey];
                }
                
                _originalCompletionBlock(responseObject, error);
            }
        }];
    }
    else {
        
        //
        //  If the request was not set, return an error
        //
        if (_originalCompletionBlock)
        {
            _originalCompletionBlock(nil, [NSError errorForFoundationCode:MASFoundationErrorCodeMultiFactorAuthenticationInvalidRequest errorDomain:MASFoundationErrorDomainLocal]);
        }
    }
}


- (void)cancelWithError:(NSError *)error
{
    if (_originalCompletionBlock)
    {
        _originalCompletionBlock(nil, error);
    }
}


- (void)cancel
{
    if (_originalCompletionBlock)
    {
        _originalCompletionBlock(nil, [NSError errorForFoundationCode:MASFoundationErrorCodeMultiFactorAuthenticationCancelled errorDomain:MASFoundationErrorDomainLocal]);
    }
}

@end
