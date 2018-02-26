//
//  MASRequestBuilder.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASClaims.h"

@class MASRequest;

/**
 MASRequestBuilder class is an object that allows developers to progressively build a request as needed.
 The class is mainly responsible to receive parameters and create a MASRequest object.
 
 Default configuration value for designated initializer, [[MASRequestBuilder alloc] initWithHTTPMethod:], would be:
 isPublic: NO,
 sign: NO,
 requestType:MASRequestResponseTypeJson, 
 responseType:MASRequestResponseTypeJson.
 */
@interface MASRequestBuilder : MASObject


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 NSString value of the HTTP Method (GET, POST, PUT, DELETE).
 */
@property (nonatomic, strong, readonly) NSString * _Nonnull httpMethod;


/**
 BOOL value that determines whether or not to include credentials of primary gateway in the request.
 */
@property (assign) BOOL isPublic;


/**
 BOOL value that determines whether or not digitally sign the request parameters with JWT signature.
 */
@property (assign, readonly) BOOL sign;


/**
 NSString value of the target endpoint.
 */
@property (nonatomic, strong, nullable) NSString *endPoint;


/**
 MASClaims object containing claims for JWT.
 */
@property (nonatomic, strong, nullable, readonly) MASClaims *claims;


/**
 NSData value of private key.
 */
@property (nonatomic, strong, nullable, readonly) NSData *privateKey;


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
- (instancetype _Nonnull)initWithHTTPMethod:(NSString *_Nonnull)method NS_DESIGNATED_INITIALIZER;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public


/**
 Create a MASRequest object using the parameters from MASRequestBuider
 
 @return MASRequest object
 */
- (MASRequest *_Nullable)build;



/**
 Set to sign the body of request using default private key from device registration against primary gateway.
 
 @param error NSError error reference object that returns any error occurred during JWT signature.
 */
- (void)setSignWithError:(NSError *__nullable __autoreleasing *__nullable)error;



/**
 Set to sign the request with a MASClaims object using default private key from device registration against primary gateway.
 
 @param claims MASClaims object containing claims for JWT
 @param error NSError error reference object that returns any error occurred during JWT signature.
 */
- (void)setSignWithClaims:(MASClaims *_Nonnull)claims error:(NSError *__nullable __autoreleasing *__nullable)error;



/**
 Set to sign the request with a MASClaims object using custom private key in NSData format.
 
 @param privateKey Custom private key in NSData format signed using RS256 algorithm.
 @param error NSError error reference object that returns any error occurred during JWT signature.
 */
- (void)setSignWithClaims:(MASClaims *_Nonnull)claims privateKey:(NSData *_Nonnull)privateKey error:(NSError *__nullable __autoreleasing *__nullable)error;



@end
