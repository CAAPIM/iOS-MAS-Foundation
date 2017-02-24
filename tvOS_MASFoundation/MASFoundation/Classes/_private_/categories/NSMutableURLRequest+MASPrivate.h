//
//  NSMutableURLRequest+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASConstantsPrivate.h"

@import Foundation;

extern NSString * const MASRequestResponseTypeJsonValue;
extern NSString * const MASRequestResponseTypeScimJsonValue;
extern NSString * const MASRequestResponseTypeTextPlainValue;
extern NSString * const MASRequestResponseTypeWwwFormUrlEncodedValue;
extern NSString * const MASRequestResponseTypeXmlValue;


@interface NSMutableURLRequest (MASPrivate)



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Set key/values int the header of the NSMutableURLRequest for a specific request/response content type.
 *
 * @param headerInfo NSDictionary of key/value contents to include in the header.
 * @param requestType MASRequestResponseType indicating the expected request content's format.
 * @param responseType MASRequestResponseType indicating the expected response content's format.
 */
- (void)setHeaderInfo:(NSDictionary *)headerInfo forRequestType:(MASRequestResponseType)requestType andResponseType:(MASRequestResponseType)responseType;

/**
 * Retrieve the applicable mime type as a string that corresponds to the given MASRequestResponseType.
 *
 * @param type MASRequestResponseType that maps to a supported mime type.
 * @return The corresponding mime type in string format.
 */
- (NSString *)requestResponseTypeAsMimeTypeString:(MASRequestResponseType)type;


/**
 * Retrieve the applicable MASRequestResponseType that corresponds to the given mime type string.
 *
 * @param mimeType The string version of a mime type that should be mapped to MASRequestResponseType.
 * @return MASRequestResponseType that matches the incoming mime type string.
 */
- (MASRequestResponseType)requestResponseTypeFromMimeTypeString:(NSString *)mimeType;

@end
