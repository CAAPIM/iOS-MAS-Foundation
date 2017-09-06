//
//  MASRequestBuilder.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import "MASClaims.h"

/**
 MASRequestBuilder class is an object that allows developers to progressively build a request as needed.
 The class is mainly responsible for receive parameters and create a MASRequest object.
 
 Default configuration value for designated initializer, [[MASRequestBuilder alloc] initWithHTTPMethod:], would be:
 isPublic: NO,
 sign: NO,
 requestType:MASRequestResponseTypeJson, 
 responseType:MASRequestResponseTypeJson.
 */
@interface MASRequestBuilder : NSObject

NS_ASSUME_NONNULL_BEGIN

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 NSString value of the HTTP Method (GET, POST, PUT, DELETE).
 */
@property (nonatomic, strong, readonly) NSString *httpMethod;

/**
 BOOL value that determines whether or not the target host is a primary gateway or another gateway/public server.
 */
@property (assign) BOOL isPublic;

/**
 BOOL value that determines whether or not digitally sign the request parameters with JWT signature.
 */
@property (assign) BOOL sign;

/**
 NSString value of the target endpoint.
 */
@property (nonatomic, strong, nullable) NSString *endPoint;

/**
 MASClaims object containing claims for JWT.
 */
@property (nonatomic, strong, nullable) MASClaims *claims;

/**
 NSData value of private key.
 */
@property (nonatomic, strong, nullable) NSData *privateKey;

/**
 NSDictionary of type/value parameters to put into the header of a request.
 */
@property (nonatomic, strong, nullable) NSDictionary *header;

/**
 NSDictionary of type/value parameters to put into the body of a request.
 */
@property (nonatomic, strong, nullable) NSDictionary *body;

/**
 NSDictionary of type/value parameters to put into the URL of a request.
 */
@property (nonatomic, strong, nullable) NSDictionary *query;

/**
 MASRequestResponseType value that specifies what type formatting is required for request body.
 */
@property (assign) MASRequestResponseType requestType;

/**
 MASRequestResponseType value that specifies what type formatting is required for response body.
 */
@property (assign) MASRequestResponseType responseType;

/**
 MASResponseInfoErrorBlock (NSDictionary *responseInfo, NSError *error) property that will
 receive the JSON response object or an NSError object if there is a failure.
 */
@property (nonatomic, strong, nullable) MASResponseInfoErrorBlock completionBlock;


///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle


/**
 Designated initializer for MASRequestBuilder.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param method NSString of the HTTP Method (GET, POST, PUT, DELETE)
 @return MASRequestBuilder object
 */
- (instancetype)initWithHTTPMethod:(NSString *)method NS_DESIGNATED_INITIALIZER;

///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public


/**
 Set to sign the request with a MASClaims object using custom private key in NSData format.
 
 @param privateKey Custom private key in NSData format signed using RS256 algorithm.
 */
- (id)build;


/**
 Set to sign the request with a MASClaims object using default private key from device registration against primary gateway.
 
 @param claims MASClaims object containing claims for JWT
 */
- (void)setSignWithClaims:(MASClaims *)claims;


/**
 Set to sign the request with a MASClaims object using custom private key in NSData format.
 
 @param privateKey Custom private key in NSData format signed using RS256 algorithm.
 */
- (void)setSignWithClaims:(MASClaims *)claims privateKey:(NSData *)privateKey;


/**
 Append parameter into the header of a request.
 
 @param key NSString containing name/type of the parameter.
 @param value NSString containing value of the parameter.
 */
- (void)setHeaderParameter:(NSString *)key value:(NSString *)value;


/**
 Append parameter into the body of a request.
 
 @param key NSString containing name/type of the parameter.
 @param value NSString containing value of the parameter.
 */
- (void)setBodyParameter:(NSString *)key value:(NSString *)value;


/**
 Append parameter into the URL of a request.
 
 @param key NSString containing name/type of the parameter.
 @param value NSString containing value of the parameter.
 */
- (void)setQueryParameter:(NSString *)key value:(NSString *)value;


NS_ASSUME_NONNULL_END

@end
