//
//  MASMultiPartFormData.h
//  MASFoundation
//
//  Created by nimma01 on 11/07/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#ifndef MASMultiPartFormData_h
#define MASMultiPartFormData_h

@protocol MASMultiPartFormData <NSObject>


/**
 Appends the HTTP header `Content-Disposition: file; filename=#{generated filename}; name=#{name}"` and `Content-Type: #{generated mimeType}`, followed by the encoded file data and the multipart form boundary.
 
 The filename and MIME type for this data in the form will be automatically generated, using the last path component of the `fileURL` and system associated MIME type for the `fileURL` extension, respectively.
 
 @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 
 @return `YES` if the file data was successfully appended, otherwise `NO`.
 */
- (BOOL)appendPartWithFileURL:(NSURL * __nonnull)fileURL name:(NSString * __nonnull)name error:(NSError *_Nullable* _Nullable)error;


/**
 Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 
 @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param fileName The file name to be used in the `Content-Disposition` header. This parameter must not be `nil`.
 @param mimeType The declared MIME type of the file data. This parameter must not be `nil`.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 
 @return `YES` if the file data was successfully appended otherwise `NO`.
 */
- (BOOL)appendPartWithFileURL:(NSURL * __nonnull)fileURL name:(NSString * __nonnull)name fileName:(NSString * __nonnull)fileName mimeType:(NSString * __nonnull)mimeType error:(NSError *_Nullable* _Nullable)error;


/**
 Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
 
 @param data The data to be encoded and appended to the form data.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param fileName The filename to be associated with the specified data. This parameter must not be `nil`.
 @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 */
- (void)appendPartWithFileData:(NSData * __nonnull)data name:(NSString * __nonnull)name fileName:(NSString * __nonnull)fileName mimeType:(NSString * __nonnull)mimeType;

/**
 Appends the HTTP headers `Content-Disposition: form-data; name=#{name}"`, followed by the encoded data and the multipart form boundary.
 
 @param data The data to be encoded and appended to the form data.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 */

- (void)appendPartWithFormData:(NSData * __nonnull)data name:(NSString * __nonnull)name;

@end
#endif /* MASMultiPartFormData_h */
