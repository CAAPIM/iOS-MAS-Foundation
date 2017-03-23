//
//  MASJWTClaim.m
//  MASFoundation
//
//  Created by Hun Go on 2017-03-21.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASJWTClaim.h"

#import "NSError+MASPrivate.h"


@interface MASJWTClaim ()

@property (nonatomic, assign, readwrite) NSInteger iat;
@property (nonatomic, strong, nullable, readwrite) NSMutableDictionary *customClaims;
@property (nonatomic, strong, nonnull) NSArray *reservedClaimKeys;

@end


@implementation MASJWTClaim

# pragma mark - Lifecycle

- (NSString *)debugDescription
{
    return @"";
}

- (NSArray *)reservedClaimKeys
{
    return @[@"iss", @"aud", @"sub", @"exp", @"jti", @"iat"];
}


# pragma mark - Public

- (void)setValue:(id __nonnull)value forClaimKey:(NSString * __nonnull)claimKey error:(NSError * __nullable __autoreleasing * __nullable)error
{
    if (!_customClaims)
    {
        _customClaims = [NSMutableDictionary dictionary];
    }
    
    //
    //  If the key is one of reserved claim key
    //
    if ([[self reservedClaimKeys] containsObject:claimKey])
    {
        NSError *reservedError = [NSError errorStringFormatWithDescription:claimKey code:MASFoundationErrorCodeJWTInvalidClaimKey];
        
        if (error)
        {
            *error = reservedError;
        }
        
        return;
    }
    else {
        
        [_customClaims setObject:value forKey:claimKey];
    }
}

@end
