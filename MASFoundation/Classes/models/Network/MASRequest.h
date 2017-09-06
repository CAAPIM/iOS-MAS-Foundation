//
//  MASRequest.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import "MASClaims.h"
#import "MASRequestBuilder.h"

/**
 MASRequest class is an object created by MASRequestBuilder. It's contains all parameters necessary to invoke an API.
 The class cannot be constructed or changed directly, only through MASRequestBuilder.
 */
@interface MASRequest : NSObject

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
@property (assign, readonly) BOOL isPublic;

/**
 BOOL value that determines whether or not digitally sign the request parameters with JWT signature.
 */
@property (assign, readonly) BOOL sign;

/**
 NSString value of the specific end point path fragment to append to the base Gateway URL.  endPoint value can also be defined as full URL format; in this case,
 SDK must be configured to add add the external host as a trusted source using MASSecurityConfiguration object.
 */
@property (nonatomic, strong, nullable, readonly) NSString *endPoint;

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
@property (nonatomic, strong, nullable, readonly) NSDictionary *header;

/**
 NSDictionary of type/value parameters to put into the body of a request.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary *body;

/**
 NSDictionary of type/value parameters to put into the URL of a request.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary *query;

/**
 MASRequestResponseType value that specifies what type formatting is required for request body.
 */
@property (assign, readonly) MASRequestResponseType requestType;

/**
 MASRequestResponseType value that specifies what type formatting is required for response body.
 */
@property (assign, readonly) MASRequestResponseType responseType;


# pragma mark - Public


/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP DELETE call. This type of HTTP Method type
 places it's parameters within the NSURL itself as an HTTP query extension.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype)delete:(void (^)(MASRequestBuilder *))block;


/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP GET call. This type of HTTP Method type
 places it's parameters within the NSURL itself as an HTTP query extension.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype)get:(void (^)(MASRequestBuilder *))block;


/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP PATCH call. This type of HTTP Method type
 places it's parameters within the HTTP body in www-form-url-encoded format.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype)patch:(void (^)(MASRequestBuilder *))block;


/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP POST call. This type of HTTP Method type
 places it's parameters within the HTTP body in www-form-url-encoded format.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype)post:(void (^)(MASRequestBuilder *))block;


/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP PUT call. This type of HTTP Method type
 places it's parameters within the HTTP body in www-form-url-encoded format.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype)put:(void (^)(MASRequestBuilder *))block;

NS_ASSUME_NONNULL_END

@end
