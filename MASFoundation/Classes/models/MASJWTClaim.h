//
//  MASJWTClaim.h
//  MASFoundation
//
//  Created by Hun Go on 2017-03-21.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 MASJWTClaim class is a helper class to build customized claimed for JWT signed with key pairs.
 */
@interface MASJWTClaim : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 iss identifies the principal that issued the JWT
 */
@property (nonatomic, strong, nullable) NSString *iss;


/**
 aud identifies the recipients that the JWT is inteded for
 */
@property (nonatomic, strong, nullable) NSString *aud;



/**
 sub identifies the principal that is subject of the JWT
 */
@property (nonatomic, strong, nullable) NSString *sub;


/**
 exp identifies the expiration timestamp of JWT
 */
@property (nonatomic, assign) NSInteger exp;


/**
 iat identifies the issued timestamp of JWT
 */
@property (nonatomic, assign, readonly) NSInteger iat;


/**
 jti identifies a unique identifier for the JWT
 */
@property (nonatomic, strong, nullable) NSString *jti;


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

 @param value Object/value of the attribute
 @param claimKey Key of the attribute
 */
- (void)setValue:(id __nonnull)value forClaimKey:(NSString * __nonnull)claimKey error:(NSError * __nullable __autoreleasing * __nullable)error;

@end
