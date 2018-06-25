//
//  MASDERCertificate.h
//  MASFoundationTests
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



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

- (void)parseCertificateData;

@end
