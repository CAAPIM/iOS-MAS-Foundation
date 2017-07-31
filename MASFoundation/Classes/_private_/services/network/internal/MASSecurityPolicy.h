//
//  MASSecurityPolicy.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASISecurityPolicy.h"

/**
 MASSecurityPolicy class is responsible for handling SSL pinning
 */
@interface MASSecurityPolicy : NSObject


/**
 Evaluate the ServerTrust with defined pinning logic of MASSecurityConfiguration object

 @param serverTrust serverTrust SecTrustRef of ServerTrust
 @param domain domain NSString of host domain name challenged for authentication; domain will also determine which MASSecurityConfiguration to be used
 @return BOOL value whether the pinning was successful or not based on defined settings and logic
 */
- (BOOL)evaluateSecurityConfigurationsForServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain;

@end
