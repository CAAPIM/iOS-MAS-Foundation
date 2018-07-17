//
//  MASDERCertificate.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

@interface MASDERCertificate : NSObject

///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

//
//  Issuer
//
@property (strong, nonatomic) NSArray *issuer;

//
//  Certificate Subject
//
@property (strong, nonatomic) NSArray *subject;

//
//  Validity
//
@property (strong, nonatomic) NSDate *notBefore;
@property (strong, nonatomic) NSDate *notAfter;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

- (instancetype)initWithDERCertificateData:(NSData *)certData NS_DESIGNATED_INITIALIZER;



/**
 This initializer is not available.  Please use [[MASDERCertificate alloc] initWithDERCertificateData:(NSData *)].
 
 @return nil will always be returned with this initialization method.
 */
- (instancetype)init NS_UNAVAILABLE;



/**
 This initializer is not available.  Please use [[MASDERCertificate alloc] initWithDERCertificateData:(NSData *)].
 
 @return nil will always be returned with this initialization method.
 */
+ (instancetype)new NS_UNAVAILABLE;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

- (void)parseCertificateData;

@end
