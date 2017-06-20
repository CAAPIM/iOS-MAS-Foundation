//
//  MASClaims.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASObject.h"

/**
 MASClaims class is a helper class to build JWT signed with key pairs.
 */
@interface MASClaims : MASObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 iss identifies the principal that issued the JWT
 
 @discussion iss is in format of device://{mag-identifier}/{client_id} where both mag-identifier and client_id are known to the primary gateway.
 */
@property (nonatomic, strong, nullable, readwrite) NSString *iss;


/**
 aud identifies the recipients that the JWT is inteded for
 
 @discussion aud is an audience of the JWT where the audience is URL of primary gateway.
 */
@property (nonatomic, strong, nullable, readwrite) NSString *aud;


/**
 sub identifies the principal that is subject of the JWT
 
 @discussion sub is an subject of the JWT that is either authenticated user's username or registered client's client name where both are known to the primary gateway.
 */
@property (nonatomic, strong, nullable, readwrite) NSString *sub;


/**
 exp identifies the expiration timestamp of JWT
 
 @discussion exp is unix timestamp of expiration for JWT.
 */
@property (nonatomic, strong, nullable, readwrite) NSDate *exp;


/**
 iat identifies the issued timestamp of JWT
 
 @discussion iat is an issued timestamp when the JWT was built.  iat will be nil in MASClaims object until JWT is built.
 */
@property (nonatomic, strong, nullable, readwrite) NSDate *iat;


/**
 nbf identifies the time before which the JWT must not be accepted for processing.
 
 @discussion nbf is a timestamp which the JWT should not be used before.  nbf is an optional claim which will not be generated and added to payload if not defined.
 */
@property (nonatomic, strong, nullable, readwrite) NSDate *nbf;


/**
 jti identifies a unique identifier for the JWT
 
 @discussion jti is an unique identifier of JWT.
 */
@property (nonatomic, strong, nullable, readwrite) NSString *jti;


/**
 content will be identified as private claim for the custom contents in payload
 
 @discussion content is an content that will be part of JWT's payload.  
 @remark content can only be in NSString, NSDictionary, or NSArray format. Make sure to convert NSData into base64encoded string.
 */
@property (nonatomic, strong, nullable, readwrite) id content;


/**
 contentType will be identified as private claim for the custom contents' content-type in payload
 
 @discussion contentType is a MIME type of the contents.
 */
@property (nonatomic, strong, nullable, readwrite) NSString *contentType;


/**
 custom claims dictionary added through setValue:forClaimKey.
 */
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary *customClaims;


///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 Setting a custom attribute to JWT
 
 @param value Object/value of the attribute. Object can only be either of NSNumber, NSString, NSDictionary, or NSArray.
 @param claimKey Key of the attribute
 */
- (void)setValue:(id __nonnull)value forClaimKey:(NSString * __nonnull)claimKey error:(NSError * __nullable __autoreleasing * __nullable)error;


///--------------------------------------
/// @name LifeCycle
///--------------------------------------

# pragma mark - LifeCycle


/**
 Designated initializer for MASClaims object.
 This initializer will construct MASClaims object with auto-populated some of claims values.

 @return MASClaims object with auto populated some of claims.
 */
+ (MASClaims *_Nullable)claims;

@end
