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
#import "MASObject.h"

/**
 MASDERCertificate is a class that takes DER format certificate as NSData format, and represents certificate information in human-readable and understandable data structure
 */
@interface MASDERCertificate : MASObject


///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
 NSArray containing MASASN1Object(s) which represents issuer
 */
@property (strong, nonatomic) NSArray *issuer;


/**
 NSArray containing MASASN1Object(s) which each element represents subject item
 */
@property (strong, nonatomic) NSArray *subject;


/**
 NSDate which represents validity of the certificate where it is not valid before this date
 */
@property (strong, nonatomic) NSDate *notBefore;


/**
 NSDate which represents validity of the certificate where it is not valid after this date
 */
@property (strong, nonatomic) NSDate *notAfter;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 Designated initialization method of MASDERCertificate that takes NSData of DER format certificate

 @param certData NSData format of DER format certificate
 @return MASDERCertificate object
 */
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

/**
 A method to parse certificate data that was taken from initialization 
 */
- (void)parseCertificateData;

@end
