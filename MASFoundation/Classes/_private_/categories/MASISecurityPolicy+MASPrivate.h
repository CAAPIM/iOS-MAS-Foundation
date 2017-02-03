//
//  MASISecurityPolicy+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASISecurityPolicy.h"

@interface MASISecurityPolicy (MASPrivate)

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust withPublicKeyHashes:(NSArray *)publicKeyHashes forDomain:(NSString *)domain;

@end
