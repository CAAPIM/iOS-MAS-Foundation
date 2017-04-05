//
//  MASClaims.m
//  MASFoundation
//
//  Created by Hun Go on 2017-04-04.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASClaims.h"

#import "MASAccessService.h"

static NSString *const kMASClaimsIssKey = @"issClaim"; // string
static NSString *const kMASClaimsAudKey = @"audClaim"; // string
static NSString *const kMASClaimsSubKey = @"subClaim"; // string
static NSString *const kMASClaimsJtiKey = @"jtiClaim"; // string
static NSString *const kMASClaimsExpKey = @"expClaim"; // integer
static NSString *const kMASClaimsIatKey = @"iatClaim"; // integer
static NSString *const kMASClaimsContentKey = @"contentKey"; // object
static NSString *const kMASClaimsContentTypeKey = @"contentTypeKey"; // string

@implementation MASClaims


# pragma mark - LifeCycle

+ (MASClaims *)claims
{
    MASClaims *claims = [[self alloc] initPrivate];

    return claims;
}


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
        
        //
        //  Prepare aud
        //
        [self setValue:[[MASConfiguration currentConfiguration].gatewayUrl absoluteString] forKey:@"aud"];
        
        //
        //  Prepare iss
        //
        NSString *magIdentifier = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier];
        NSString *clientId = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeClientId];
        
        if (magIdentifier && clientId)
        {
            [self setValue:[NSString stringWithFormat:@"device://%@/%@", magIdentifier, clientId] forKey:@"iss"];
        }
        
        //
        //  Prepare sub
        //
        if ([MASUser currentUser] && [MASUser currentUser].objectId)
        {
            [self setValue:[MASUser currentUser].objectId forKey:@"sub"];
        }
        else {
            [self setValue:[MASApplication currentApplication].name forKey:@"sub"];
        }
        
        NSString *uniqueIdentifier = [[NSUUID UUID] UUIDString];
        
        [self setValue:uniqueIdentifier forKey:@"objectId"];
        
        //
        //  Prepare jti
        //
        [self setValue:uniqueIdentifier forKey:@"jti"];
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@)\t\tobjectId = %@\niss = %@\naud = %@\nsub = %@\njti = %@\niat = %ld\nexp = %ld\ncontent = %@\ncontentType = %@", [self class], self.objectId, self.iss, self.aud, self.sub, self.jti, (long)self.iat, (long)self.exp, self.content, self.contentType];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASClaims *claims = [super copyWithZone:zone];
    
    [claims setValue:self.objectId forKey:@"objectId"];
    [claims setValue:self.iss forKey:@"iss"];
    [claims setValue:self.aud forKey:@"aud"];
    [claims setValue:self.sub forKey:@"sub"];
    [claims setValue:self.jti forKey:@"jti"];
    [claims setValue:[NSNumber numberWithInteger:self.iat] forKey:@"iat"];
    [claims setValue:[NSNumber numberWithInteger:self.exp] forKey:@"exp"];
    [claims setValue:self.content forKey:@"content"];
    [claims setValue:self.contentType forKey:@"contentType"];
    
    return claims;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder]; //ObjectID is encoded in the super class MASObject
    
    if (self.iss)
    {
        [aCoder encodeObject:self.iss forKey:kMASClaimsIssKey];
    }
    
    if (self.aud)
    {
        [aCoder encodeObject:self.aud forKey:kMASClaimsAudKey];
    }
    
    if (self.sub)
    {
        [aCoder encodeObject:self.sub forKey:kMASClaimsSubKey];
    }
    
    if (self.jti)
    {
        [aCoder encodeObject:self.jti forKey:kMASClaimsJtiKey];
    }
    
    if (self.iat)
    {
        [aCoder encodeObject:[NSNumber numberWithInteger:self.iat] forKey:kMASClaimsIatKey];
    }
    
    if (self.exp)
    {
        [aCoder encodeObject:[NSNumber numberWithInteger:self.exp] forKey:kMASClaimsExpKey];
    }
    
    if (self.content)
    {
        [aCoder encodeObject:self.content forKey:kMASClaimsContentKey];
    }
    
    if (self.contentType)
    {
        [aCoder encodeObject:self.contentType forKey:kMASClaimsContentTypeKey];
    }
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) //ObjectID is decoded in the super class MASObject
    {
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsIssKey] forKey:@"iss"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsAudKey] forKey:@"aud"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsSubKey] forKey:@"sub"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsJtiKey] forKey:@"jti"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsIatKey] forKey:@"iat"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsExpKey] forKey:@"exp"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsContentKey] forKey:@"content"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsContentTypeKey] forKey:@"contentType"];
    }
    
    return self;
}


@end
