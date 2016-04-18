// UIWebView+MASINetworking.m
// Copyright (c) 2011–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIWebView+MASINetworking.h"

#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import "MASIHTTPRequestOperation.h"
#import "MASIURLResponseSerialization.h"
#import "MASIURLRequestSerialization.h"

@interface UIWebView (_MASINetworking)
@property (readwrite, nonatomic, strong, setter = af_setHTTPRequestOperation:) MASIHTTPRequestOperation *af_HTTPRequestOperation;
@end

@implementation UIWebView (_MASINetworking)

- (MASIHTTPRequestOperation *)af_HTTPRequestOperation {
    return (MASIHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(af_HTTPRequestOperation));
}

- (void)af_setHTTPRequestOperation:(MASIHTTPRequestOperation *)operation {
    objc_setAssociatedObject(self, @selector(af_HTTPRequestOperation), operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIWebView (MASINetworking)

- (MASIHTTPRequestSerializer <MASIURLRequestSerialization> *)requestSerializer {
    static MASIHTTPRequestSerializer <MASIURLRequestSerialization> *_af_defaultRequestSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_defaultRequestSerializer = [MASIHTTPRequestSerializer serializer];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(requestSerializer)) ?: _af_defaultRequestSerializer;
#pragma clang diagnostic pop
}

- (void)setRequestSerializer:(MASIHTTPRequestSerializer<MASIURLRequestSerialization> *)requestSerializer {
    objc_setAssociatedObject(self, @selector(requestSerializer), requestSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MASIHTTPResponseSerializer <MASIURLResponseSerialization> *)responseSerializer {
    static MASIHTTPResponseSerializer <MASIURLResponseSerialization> *_af_defaultResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_defaultResponseSerializer = [MASIHTTPResponseSerializer serializer];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(responseSerializer)) ?: _af_defaultResponseSerializer;
#pragma clang diagnostic pop
}

- (void)setResponseSerializer:(MASIHTTPResponseSerializer<MASIURLResponseSerialization> *)responseSerializer {
    objc_setAssociatedObject(self, @selector(responseSerializer), responseSerializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)loadRequest:(NSURLRequest *)request
           progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
            success:(NSString * (^)(NSHTTPURLResponse *response, NSString *HTML))success
            failure:(void (^)(NSError *error))failure
{
    [self loadRequest:request MIMEType:nil textEncodingName:nil progress:progress success:^NSData *(NSHTTPURLResponse *response, NSData *data) {
        NSStringEncoding stringEncoding = NSUTF8StringEncoding;
        if (response.textEncodingName) {
            CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
            if (encoding != kCFStringEncodingInvalidId) {
                stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
            }
        }

        NSString *string = [[NSString alloc] initWithData:data encoding:stringEncoding];
        if (success) {
            string = success(response, string);
        }

        return [string dataUsingEncoding:stringEncoding];
    } failure:failure];
}

- (void)loadRequest:(NSURLRequest *)request
           MIMEType:(NSString *)MIMEType
   textEncodingName:(NSString *)textEncodingName
           progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
            success:(NSData * (^)(NSHTTPURLResponse *response, NSData *data))success
            failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(request);

    if (self.af_HTTPRequestOperation) {
        [self.af_HTTPRequestOperation cancel];
    }

    request = [self.requestSerializer requestBySerializingRequest:request withParameters:nil error:nil];

    self.af_HTTPRequestOperation = [[MASIHTTPRequestOperation alloc] initWithRequest:request];
    self.af_HTTPRequestOperation.responseSerializer = self.responseSerializer;

    __weak __typeof(self)weakSelf = self;
    [self.af_HTTPRequestOperation setDownloadProgressBlock:progress];
    [self.af_HTTPRequestOperation setCompletionBlockWithSuccess:^(MASIHTTPRequestOperation *operation, id __unused responseObject) {
        NSData *data = success ? success(operation.response, operation.responseData) : operation.responseData;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadData:data MIMEType:(MIMEType ?: [operation.response MIMEType]) textEncodingName:(textEncodingName ?: [operation.response textEncodingName]) baseURL:[operation.response URL]];

        if ([strongSelf.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
            [strongSelf.delegate webViewDidFinishLoad:strongSelf];
        }

#pragma clang diagnostic pop
    } failure:^(MASIHTTPRequestOperation * __unused operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

    [self.af_HTTPRequestOperation start];

    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

@end

#endif
