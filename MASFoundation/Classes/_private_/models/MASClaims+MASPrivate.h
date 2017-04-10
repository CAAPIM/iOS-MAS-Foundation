//
//  MASClaims+MASPrivate.h
//  MASFoundation
//
//  Created by Hun Go on 2017-04-04.
//  Copyright © 2017 CA Technologies. All rights reserved.
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
