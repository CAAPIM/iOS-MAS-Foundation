//
//  MASAuthenticationProvider.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthenticationProvider.h"

#import "MASConstantsPrivate.h"
#import "MASModelService.h"


# pragma mark - Header Key Constants

static NSString *const MASAuthenticationProviderEnterpriseId = @"enterprise"; // string
static NSString *const MASAuthenticationProviderFacebookId = @"facebook"; // string
static NSString *const MASAuthenticationProviderGoogleId = @"google"; // string
static NSString *const MASAuthenticationProviderLinkedInId = @"linkedin"; // string
static NSString *const MASAuthenticationProviderQrCodeId = @"qrcode"; // string
static NSString *const MASAuthenticationProviderSalesforceId = @"salesforce"; // string

# pragma mark - Property Constants

static NSString *const MASAuthenticationProviderIdentifierPropertyKey = @"identifier"; // string
static NSString *const MASAuthenticationProviderAuthenticationUrlPropertyKey = @"authenticationUrl"; // string
static NSString *const MASAuthenticationProviderPollUrlPropertyKey = @"pollUrl"; // string


@implementation MASAuthenticationProvider


# pragma mark - Lifecycle

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
    if(self) {
        
    }
    
    return self;
}


- (NSString *)description
{
    return [self debugDescription];
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) identifier: %@\n\n        auth url: %@\n        poll url: %@",
        [self class], [self identifier], [[self authenticationUrl] absoluteString], [[self pollUrl] absoluteString]];
}


# pragma mark - Public

- (BOOL)isEnterprise
{
    return [self.identifier isEqualToString:(MASAuthenticationProviderEnterpriseId)];
}


- (BOOL)isFacebook
{
    return [self.identifier isEqualToString:(MASAuthenticationProviderFacebookId)];
}


- (BOOL)isGoogle
{
    return [self.identifier isEqualToString:(MASAuthenticationProviderGoogleId)];
}


- (BOOL)isLinkedIn
{
    return [self.identifier isEqualToString:(MASAuthenticationProviderLinkedInId)];
}


- (BOOL)isQrCode
{
    return [self.identifier isEqualToString:(MASAuthenticationProviderQrCodeId)];
}


- (BOOL)isSalesforce
{
    return [self.identifier isEqualToString:(MASAuthenticationProviderSalesforceId)];
}

# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    if(self.identifier) [aCoder encodeObject:self.identifier forKey:MASAuthenticationProviderIdentifierPropertyKey];
    if(self.authenticationUrl) [aCoder encodeObject:self.authenticationUrl forKey:MASAuthenticationProviderAuthenticationUrlPropertyKey];
    if(self.pollUrl) [aCoder encodeObject:self.pollUrl forKey:MASAuthenticationProviderPollUrlPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setValue:[aDecoder decodeObjectForKey:MASAuthenticationProviderIdentifierPropertyKey] forKey:@"identifier"];
        [self setValue:[aDecoder decodeObjectForKey:MASAuthenticationProviderAuthenticationUrlPropertyKey] forKey:@"authenticationUrl"];
        [self setValue:[aDecoder decodeObjectForKey:MASAuthenticationProviderPollUrlPropertyKey] forKey:@"pollUrl"];
    }
    
    return self;
}


@end
