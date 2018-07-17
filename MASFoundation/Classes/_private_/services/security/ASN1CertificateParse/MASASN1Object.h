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

@interface MASASN1Object : NSObject

@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSMutableArray *sub;
@property (assign) MASASN1Tag tag;

@end
