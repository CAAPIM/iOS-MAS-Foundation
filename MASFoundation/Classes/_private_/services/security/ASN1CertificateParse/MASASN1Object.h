//
//  MASASN1Object.h
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASASN1Decoder.h"
#import "MASObject.h"

/**
 MASASN1Object is a class that represents ASN.1 element containing value, tag which represents type structure, and any child elements
 */
@interface MASASN1Object : MASObject


/**
 Value of the ASN.1 element
 */
@property (strong, nonatomic) id value;


/**
 NSArray of child MASASN1Object elements
 */
@property (strong, nonatomic) NSMutableArray *sub;


/**
 MASASN1Tag enumeration value representing ASN.1 tag for the element
 */
@property (assign) MASASN1Tag tag;

@end
