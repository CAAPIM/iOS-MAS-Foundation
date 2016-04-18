//
//  MASSessionSharingQRCode.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSessionSharingQRCode.h"

#import "MASSessionSharingQRCode+MASPrivate.h"
#import "NSString+MASPrivate.h"
#import "NSError+MASPrivate.h"

@interface MASSessionSharingQRCode ()

@property (nonatomic, strong) UIImage *qrCodeImage;

@property (assign) BOOL isStop;

@property (assign) int pollCount;

@end


@implementation MASSessionSharingQRCode


# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (instancetype)initWithAuthenticationProvider:(MASAuthenticationProvider *)provider initialDelay:(NSNumber *)initDelay pollingInterval:(NSNumber *)pollingInterval pollingLimit:(NSNumber *)pollingLimit
{
    NSParameterAssert(provider);
    NSParameterAssert(provider.authenticationUrl);
    NSParameterAssert(provider.pollUrl);
    NSParameterAssert([initDelay intValue] > 0);
    NSParameterAssert([pollingInterval intValue] > 0);
    NSParameterAssert([pollingLimit intValue] > 0);
    
    return [self initPrivateWithAuthenticationUrl:provider.authenticationUrl.absoluteString pollingUrl:provider.pollUrl.absoluteString initialDelay:initDelay pollingInterval:pollingInterval pollingLimit:pollingLimit];
}


- (instancetype)initWithAuthenticationProvider:(MASAuthenticationProvider *)provider
{
    return [self initWithAuthenticationProvider:provider initialDelay:[NSNumber numberWithInt:10] pollingInterval:[NSNumber numberWithInt:5] pollingLimit:[NSNumber numberWithInt:6]];
}


# pragma mark - Start/Stop displaying QR Code image

- (UIImage *)startDisplayingQRCodeImageForSessionSharing
{
    //
    // Generate image only once
    //
    if (_qrCodeImage == nil)
    {
        _qrCodeImage = [self startPrivateDisplayingQRCodeImageForSessionSharing];
    }
    
    return _qrCodeImage;
}


- (void)stopDisplayingQRCodeImageForSessionSharing
{
    [self stopPrivateDisplayingQRCodeImageForSessionSharing];
}



# pragma mark - Authorize authenticateUrl for session sharing

+ (void)authorizeAuthenticateUrl:(NSString *)authenticateUrl completion:(MASCompletionErrorBlock)completion
{
    NSError *invalidURLError = nil;
    
    //
    // If url is empty
    //
    if ([authenticateUrl isEmpty])
    {
        invalidURLError = [NSError errorForFoundationCode:MASFoundationErrorCodeSessionSharingInvalidAuthenticationURL errorDomain:MASFoundationErrorDomainLocal];
    }
    
    if (invalidURLError)
    {
        if (completion)
        {
            completion(NO, invalidURLError);
        }
        
        return;
    }
    
    //
    // Extract the path of the authorization URL
    //
    NSString *authPath = [authenticateUrl stringByReplacingOccurrencesOfString:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString
                                                                    withString:@""];
    
    [MAS postTo:authPath withParameters:nil andHeaders:nil requestType:MASRequestResponseTypeWwwFormUrlEncoded responseType:MASRequestResponseTypeJson completion:^(NSDictionary *responseInfo, NSError *error) {
       
        if (error)
        {
            if (completion)
            {
                completion(NO, error);
            }
        }
        else {
            if (completion)
            {
                completion(YES, nil);
            }
        }
    }];
}


#pragma mark - Debug methods

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@)\n\n"
            "        objectId: %@\n        auth url: %@\n        poll url: %@\n        polling delay: %@\n        polling interval: %@\n        polling limit: %@\n",
            [self class], [self objectId], [self authenticationUrl], [self pollUrl], [self pollingDelay], [self pollingInterval], [self pollingLimit]];
}
@end
