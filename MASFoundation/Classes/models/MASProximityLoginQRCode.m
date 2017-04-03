//
//  MASProximityLoginQRCode.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASProximityLoginQRCode.h"

#import "MASProximityLoginQRCode+MASPrivate.h"
#import "NSString+MASPrivate.h"
#import "NSError+MASPrivate.h"

# pragma mark - Property Constants

static NSString *const kMASProximityLoginQRCodeAuthenticationUrlKey = @"authenticationUrl"; // string
static NSString *const kMASProximityLoginQRCodePollUrlKey = @"pollUrl"; // string
static NSString *const kMASProximityLoginQRCodePollingDelayKey = @"pollingDelay"; // string
static NSString *const kMASProximityLoginQRCodePollingIntervalKey = @"pollingInterval"; // string
static NSString *const kMASProximityLoginQRCodePollingLimitKey = @"pollingLimit"; // string
static NSString *const kMASProximityLoginQRCodeCurrentPollingCounterKey = @"currentPollingCounter"; // string
static NSString *const kMASProximityLoginQRCodeIsPollingKey = @"isPolling"; // string

@interface MASProximityLoginQRCode ()

@property (nonatomic, strong) UIImage *qrCodeImage;

@property (assign) BOOL isStop;

@property (assign) int pollCount;

@end

@implementation MASProximityLoginQRCode

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

- (UIImage *)startDisplayingQRCodeImageForProximityLogin
{
    //
    // Generate image only once
    //
    if (_qrCodeImage == nil)
    {
        _qrCodeImage = [self startPrivateDisplayingQRCodeImageForProximityLogin];
    }
    
    return _qrCodeImage;
}


- (void)stopDisplayingQRCodeImageForProximityLogin
{
    [self stopPrivateDisplayingQRCodeImageForProximityLogin];
}



# pragma mark - Authorize authenticateUrl for proximity login

+ (void)authorizeAuthenticateUrl:(NSString *)authenticateUrl completion:(MASCompletionErrorBlock)completion
{
    NSError *invalidURLError = nil;
    
    //
    // If url is empty
    //
    if ([authenticateUrl isEmpty])
    {
        invalidURLError = [NSError errorForFoundationCode:MASFoundationErrorCodeProximityLoginInvalidAuthenticationURL errorDomain:MASFoundationErrorDomainLocal];
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
    //  Retrieve the absolute URL of the authorizing device's gateway URL
    //  Due to TLS Caching issue, if the authenticating device is on iOS 8, the auth url may come with trailing dot.
    //  Make sure to handle both of them.
    //
    NSString *absoluteURL = [NSString stringWithFormat:@"https://%@:%@",[MASConfiguration currentConfiguration].gatewayHostName, [MASConfiguration currentConfiguration].gatewayPort];
    NSString *absoluteURLWithTrailingDot = [NSString stringWithFormat:@"https://%@.:%@",[MASConfiguration currentConfiguration].gatewayHostName, [MASConfiguration currentConfiguration].gatewayPort];
    
    if ([MASConfiguration currentConfiguration].gatewayPrefix)
    {
        absoluteURL = [NSString stringWithFormat:@"%@/%@", absoluteURL, [MASConfiguration currentConfiguration].gatewayPrefix];
        absoluteURLWithTrailingDot = [NSString stringWithFormat:@"%@/%@", absoluteURLWithTrailingDot, [MASConfiguration currentConfiguration].gatewayPrefix];
    }
    
    NSString *authPath = @"";
    
    if ([authenticateUrl rangeOfString:absoluteURL].location != NSNotFound || [authenticateUrl rangeOfString:absoluteURLWithTrailingDot].location != NSNotFound)
    {
        //
        // Extract the path of the authorization URL
        //
        authPath = [authenticateUrl stringByReplacingOccurrencesOfString:absoluteURL withString:@""];
        authPath = [authPath stringByReplacingOccurrencesOfString:absoluteURLWithTrailingDot withString:@""];
    }
    else {
        
        if (completion)
        {
            completion(NO, [NSError errorProximityLoginInvalidAuthroizeURL]);
        }
        
        return;
    }

    
    [MAS postTo:authPath withParameters:nil andHeaders:nil requestType:MASRequestResponseTypeWwwFormUrlEncoded responseType:MASRequestResponseTypeTextPlain completion:^(NSDictionary *responseInfo, NSError *error) {
        
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASProximityLoginQRCode *qrCode = [super copyWithZone:zone];
    
    [qrCode setValue:self.authenticationUrl forKey:@"authenticationUrl"];
    [qrCode setValue:self.pollUrl forKey:@"pollUrl"];
    [qrCode setValue:self.pollingDelay forKey:@"pollingDelay"];
    [qrCode setValue:self.pollingInterval forKey:@"pollingInterval"];
    [qrCode setValue:self.pollingLimit forKey:@"pollingLimit"];
    
    return qrCode;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder]; //ObjectID is encoded in the super class MASObject
    
    if (self.authenticationUrl) [aCoder encodeObject:self.authenticationUrl forKey:kMASProximityLoginQRCodeAuthenticationUrlKey];
    if (self.pollUrl) [aCoder encodeObject:self.pollUrl forKey:kMASProximityLoginQRCodePollUrlKey];
    if (self.pollingDelay) [aCoder encodeObject:self.pollingDelay forKey:kMASProximityLoginQRCodePollingDelayKey];
    if (self.pollingInterval) [aCoder encodeObject:self.pollingInterval forKey:kMASProximityLoginQRCodePollingIntervalKey];
    if (self.pollingLimit) [aCoder encodeObject:self.pollingLimit forKey:kMASProximityLoginQRCodePollingLimitKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) //ObjectID is decoded in the super class MASObject
    {
        [self setValue:[aDecoder decodeObjectForKey:kMASProximityLoginQRCodeAuthenticationUrlKey] forKey:@"authenticationUrl"];
        [self setValue:[aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollUrlKey] forKey:@"pollUrl"];
        [self setValue:[aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollingDelayKey] forKey:@"pollingDelay"];
        [self setValue:[aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollingIntervalKey] forKey:@"pollingInterval"];
        [self setValue:[aDecoder decodeObjectForKey:kMASProximityLoginQRCodePollingLimitKey] forKey:@"pollingLimit"];
    }
    
    return self;
}


@end
