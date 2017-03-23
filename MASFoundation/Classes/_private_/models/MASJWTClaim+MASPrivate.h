//
//  MASJWTClaim+MASPrivate.h
//  MASFoundation
//
//  Created by Hun Go on 2017-03-22.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>

@interface MASJWTClaim (MASPrivate)

/**
 Builds JWT based on the claims
 
 @param error NSError object that may be returned during the build process
 @return NSString of JWT if build process was successful
 */
- (NSString * __nullable)buildWithErrorRef:(NSError * __nullable __autoreleasing * __nullable)error;

@end
