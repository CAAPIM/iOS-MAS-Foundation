//
//  MASURLRequest.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import "MASConstantsPrivate.h"


/**
 * The MAS specific base class which all of it's version's of NSURLRequest extend.
 */
@interface MASURLRequest : NSURLRequest


///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Format the incoming parameter info dictionary specified by the request type and turn it into
 * data.  This method is typically used for HTTP PATCH, POST, PUT requests.
 *
 * @param parameterInfo A dictionary of type/value parameters to put into the body of a request.
 * @param requestType The MASRequestResponseType that specifies what type formatting is required.
 * @return NSData that is formatted correctly to be place into the HTTP request body.
 */
+ (NSString *)endPoint:(NSString *)endPoint byAppendingParameterInfo:(NSDictionary *)parameterInfo;


/**
 * Format the incoming parameter info dictionary specified by the request type and turn it into
 * data.  This method is typically used for HTTP PATCH, POST, PUT requests.
 *
 * @param parameterInfo A dictionary of type/value parameters to put into the body of a request.
 * @param requestType The MASRequestResponseType that specifies what type formatting is required.
 * @return NSData that is formatted correctly to be place into the HTTP request body.
 */
+ (NSData *)dataForBodyFromParameterInfo:(NSDictionary *)parameterInfo forRequestType:(MASRequestResponseType)type;


/**
 * Format the incoming parameter info dictionary of type/value parameters to put into the query formatted string.  
 * This method is typically used for HTTP DELETE and GET requests.
 *
 * @param parameterInfo A dictionary of type/value parameters to put into the query formatted string.
 * @return NSString with query parameter formatting.
 */
+ (NSString *)queryParametersFromInfo:(NSDictionary *)parameterInfo;


/**
 * Retrieve an HTTP response serializer that can handle the given MASRequestResponseType.
 * 
 * @param type The MASRequestResponseType.
 * @return MASIHTTPResponseSerializer of the requested type.
 */
+ (MASIHTTPResponseSerializer *)responseSerializerForType:(MASRequestResponseType)type;

@end
