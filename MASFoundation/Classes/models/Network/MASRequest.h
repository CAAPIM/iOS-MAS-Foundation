//
//  MASRequest.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASRequestBuilder.h"

/**
 MASRequest class is an object created by MASRequestBuilder. It contains all necessary information to invoke an API.
 The class cannot be constructed or changed directly, only through MASRequestBuilder.
 */
@interface MASRequest : MASObject


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 NSString value of the HTTP Method (GET, POST, PUT, DELETE).
 */
@property (nonatomic, strong, readonly) NSString *  _Nonnull httpMethod;


/**
 BOOL value that determines whether or not to include credentials of primary gateway in the request.
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
 places its parameters within the NSURL itself as an HTTP query extension.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype _Nullable)deleteFrom:(void (^_Nonnull)(MASRequestBuilder* _Nonnull builder))block;



/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP GET call. This type of HTTP Method type
 places its parameters within the NSURL itself as an HTTP query extension.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype _Nullable)getFrom:(void (^_Nonnull)(MASRequestBuilder* _Nonnull builder))block;



/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP PATCH call. This type of HTTP Method type
 places its parameters within the HTTP body in www-form-url-encoded format.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype _Nullable)patchTo:(void (^_Nonnull)(MASRequestBuilder* _Nonnull builder))block;



/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP POST call. This type of HTTP Method type
 places its parameters within the HTTP body in www-form-url-encoded format.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype _Nullable)postTo:(void (^_Nonnull)(MASRequestBuilder* _Nonnull builder))block;



/**
 Initialize MASRequest using MASRequestBuilder block and defining the request method as a HTTP PUT call. This type of HTTP Method type
 places its parameters within the HTTP body in www-form-url-encoded format.
 
 @discussion default values for designated initializer are: isPublic: NO, sign: NO, requestType:MASRequestResponseTypeJson, responseType:MASRequestResponseTypeJson.
 @param block MASRequestBuilder block containing all paramters to build the request.
 @return MASRequestBuilder object
 */
+ (instancetype _Nullable)putTo:(void (^_Nonnull)(MASRequestBuilder* _Nonnull builder))block;



@end
