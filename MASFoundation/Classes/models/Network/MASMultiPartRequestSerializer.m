//
//  MASMultiPartRequestSerializer.m
//  MASFoundation
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASMultiPartRequestSerializer.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MASMultiPartRequestSerializer()
{
    
}

@property(nonatomic) NSString* boundary;
@property(nonatomic) NSMutableData* body;
@property(nonatomic) MASURLRequest* request;

@end

static NSString * MASCreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}


static inline NSString * MASMultipartFormEncapsulationBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@%@", @"\r\n", boundary, @"\r\n"];
}


static inline NSString * MASMultipartFormFinalBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@--%@", @"\r\n", boundary, @"\r\n"];
}

static inline NSString * MASContentTypeForPathExtension(NSString *extension) {
#ifdef __UTTYPE__
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
#else
#pragma unused (extension)
    return @"application/octet-stream";
#endif
}

@implementation MASMultiPartRequestSerializer


- (id)initWithURLRequest:(MASPostFormURLRequest *)request
{
    if(self = [super init])
    {
        self.request = request;
        self.boundary = MASCreateMultipartFormBoundary();
        self.body = [NSMutableData data];
        [self setInitialHeadersforRequest];
        [self setBodyParameters];
        
    }
    
    return self;
}

-(void)setInitialHeadersforRequest
{
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary];
    [self.request addValue:contentType forHTTPHeaderField:@"Content-Type"];
}


-(void)setBodyParameters
{
    [self.request.parameterInfo enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [self.body appendData:[[NSString stringWithFormat:@"%@", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [self.body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [self.body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
}


- (BOOL)appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name error:(NSError *__autoreleasing  _Nullable *)error
{
    return [self appendPartWithFileURL:fileURL name:name fileName:name mimeType:MASContentTypeForPathExtension([fileURL pathExtension]) error:error];
}

- (BOOL)appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType error:(NSError *__autoreleasing  _Nullable *)error
{
    if(!fileURL || !name)
    {
        return NO;
    }
    
    [self.body appendData:[[NSString stringWithFormat:@"%@", MASMultipartFormEncapsulationBoundary(self.boundary)] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData* data = [NSData dataWithContentsOfURL:fileURL];
    [self.body appendData:data];
    [self.body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    return YES;
}


-(BOOL)appendPartWithFileData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    [self.body appendData:[[NSString stringWithFormat:@"%@", MASMultipartFormEncapsulationBoundary(self.boundary)] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.body appendData:data];
    [self.body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    return YES;
}


- (MASURLRequest *)requestByFinalizingMultipartFormData {
    if (!self.body) {
        return self.request;
    }
    
    [self.body appendData:[[NSString stringWithFormat:@"%@", MASMultipartFormFinalBoundary(self.boundary)] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary] forHTTPHeaderField:@"Content-Type"];
    [self.request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.body length]] forHTTPHeaderField:@"Content-Length"];
    // Reset the initial and final boundaries to ensure correct Content-Length
    [self.request setHTTPBody:self.body];
    
    return self.request;
}

@end
