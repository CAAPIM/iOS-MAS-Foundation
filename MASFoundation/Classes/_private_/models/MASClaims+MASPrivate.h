//
//  MASClaims+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASClaims.h"

@interface MASClaims (MASPrivate)

/**
 Builds JWT based on the claims with private key as NSData
 
 @param privateKey NSData format of private key
 @param error NSError object that may be returned during the build process
 @return NSString of JWT if build process was successful
 */
- (NSString * __nullable)buildWithPrivateKey:(NSData * __nonnull)privateKey error:(NSError * __nullable __autoreleasing * __nullable)error;

@end
