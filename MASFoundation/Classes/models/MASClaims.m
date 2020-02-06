//
//  MASClaims.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASClaims.h"

#import "MASAccessService.h"

static NSString *const kMASClaimsIssKey = @"issClaim"; // string
static NSString *const kMASClaimsAudKey = @"audClaim"; // string
static NSString *const kMASClaimsSubKey = @"subClaim"; // string
static NSString *const kMASClaimsJtiKey = @"jtiClaim"; // string
static NSString *const kMASClaimsExpKey = @"expClaim"; // number
static NSString *const kMASClaimsIatKey = @"iatClaim"; // number
static NSString *const kMASClaimsNbfKey = @"nbfClaim"; // number
static NSString *const kMASClaimsContentKey = @"contentKey"; // object
static NSString *const kMASClaimsContentTypeKey = @"contentTypeKey"; // string
static NSString *const kMASClaimsCustomCliamsKey = @"customClaimKey"; // dictionary


@interface MASClaims ()

@property (nonatomic, strong, nullable, readwrite) NSMutableDictionary *customClaims;
@property (nonatomic, strong, nonnull) NSDictionary *reservedClaimKeys;

@end


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
        NSString *magIdentifier = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier];
        NSString *clientId = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientId];
        
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
    return [NSString stringWithFormat:@"(%@)\t\tobjectId = %@\niss = %@\naud = %@\nsub = %@\njti = %@\niat = %@\nexp = %@\nnbf = %@\ncontent = %@\ncontentType = %@\ncustomClaims = %@", [self class], self.objectId, self.iss, self.aud, self.sub, self.jti, self.iat, self.exp, self.nbf, self.content, self.contentType, self.customClaims];
}


# pragma mark - Properties

- (NSDictionary *)reservedClaimKeys
{
    return @{@"iss" : [NSString class], @"aud" : [NSString class], @"sub" : [NSString class], @"exp" : [NSNumber class], @"iat" : [NSNumber class], @"jti" : [NSString class]};
}


# pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASClaims *claims = [super copyWithZone:zone];
    
    [claims setValue:self.objectId forKey:@"objectId"];
    [claims setValue:self.iss forKey:@"iss"];
    [claims setValue:self.aud forKey:@"aud"];
    [claims setValue:self.sub forKey:@"sub"];
    [claims setValue:self.jti forKey:@"jti"];
    [claims setValue:self.iat forKey:@"iat"];
    [claims setValue:self.exp forKey:@"exp"];
    [claims setValue:self.nbf forKey:@"nbf"];
    [claims setValue:self.content forKey:@"content"];
    [claims setValue:self.contentType forKey:@"contentType"];
    [claims setValue:self.customClaims forKey:@"customClaims"];
    
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
        [aCoder encodeObject:self.iat forKey:kMASClaimsIatKey];
    }
    
    if (self.exp)
    {
        [aCoder encodeObject:self.exp forKey:kMASClaimsExpKey];
    }
    
    if (self.nbf)
    {
        [aCoder encodeObject:self.nbf forKey:kMASClaimsNbfKey];
    }
    
    if (self.content)
    {
        [aCoder encodeObject:self.content forKey:kMASClaimsContentKey];
    }
    
    if (self.contentType)
    {
        [aCoder encodeObject:self.contentType forKey:kMASClaimsContentTypeKey];
    }
    
    if (self.customClaims)
    {
        [aCoder encodeObject:self.customClaims forKey:kMASClaimsCustomCliamsKey];
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
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsNbfKey] forKey:@"nbf"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsContentKey] forKey:@"content"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsContentTypeKey] forKey:@"contentType"];
        [self setValue:[aDecoder decodeObjectForKey:kMASClaimsCustomCliamsKey] forKey:@"customClaims"];
    }
    
    return self;
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
    if ([[[self reservedClaimKeys] allKeys] containsObject:claimKey])
    {
        //
        //  Validate if claim is same as expected class type
        //
        if ([[[self reservedClaimKeys] objectForKey:claimKey] isKindOfClass:[value class]])
        {
            [self setValue:value forKey:claimKey];
        }
        //
        //  If the value is not something expected, return an error
        //
        else {
            
            NSError *typeMismatchError = [NSError errorStringFormatWithDescription:[NSString stringWithFormat:@"claimKey: %@, expected class type [%@ class]", claimKey, NSStringFromClass([[self reservedClaimKeys] objectForKey:claimKey])] code:MASFoundationErrorCodeJWTUnexpectedClassType];
            
            if (error)
            {
                *error = typeMismatchError;
            }
            
            return;
        }
    }
    else {
        
        //
        //  Validate the object that should only be writable to JSON
        //
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]])
        {
            [_customClaims setObject:value forKey:claimKey];
        }
        else {
            
            //
            //  If the object is not writable to JSON, return an error
            //
            NSError *serializationError = [NSError errorStringFormatWithDescription:[NSString stringWithFormat:@"claimKey: %@, class type [%@ class] is not writable to JSON object.", claimKey, NSStringFromClass([value class])] code:MASFoundationErrorCodeJWTSerializationError];
            
            if (error)
            {
                *error = serializationError;
            }
            
            return;
        }
    }
}


@end
