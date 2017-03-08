//
//  L7SBrowserURLProtocol.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>
DEPRECATED_ATTRIBUTE
@interface L7SBrowserURLProtocol : NSURLProtocol
@property (nonatomic, strong) NSURLConnection *connection DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSURLSession *session DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign) BOOL allowsInvalidSSLCertificate DEPRECATED_ATTRIBUTE;
@end
