//
//  NSString+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "NSString+MASPrivate.h"

#import <CommonCrypto/CommonDigest.h>


# pragma mark - Constants

static NSString *const kMASAlphaNumerics = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";


@implementation NSString (MASPrivate)


# pragma mark - Public

+ (NSString *)randomStringWithLength:(int)length
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];

    for (int i = 0; i < length; i++)
    {
        [randomString appendFormat: @"%C", [kMASAlphaNumerics characterAtIndex:arc4random_uniform((unsigned int)[kMASAlphaNumerics length])]];
    }

    return randomString;
}


- (BOOL)isEmpty
{
    
    BOOL isEmpty = NO;
    
    //
    // if nil
    //
    if (self == nil)
    {
        isEmpty = YES;
    }
    //
    // if zero length
    //
    else if ([self length] == 0)
    {
        isEmpty = YES;
    }
    
    return isEmpty;
}


- (NSString *)md5String
{
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


- (NSData *)sha256Data
{
    NSData *strData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(strData.bytes, (CC_LONG)strData.length, sha256Data.mutableBytes);
    
    return sha256Data;
}


- (NSString *)base64URL
{
    NSData *strData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64URLStr = [strData base64EncodedStringWithOptions:0];
    
    base64URLStr = [base64URLStr stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64URLStr = [base64URLStr stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64URLStr = [base64URLStr stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    return base64URLStr;
}


+ (NSString *)base64URLWithNSData:(NSData *)data
{
    NSString *base64URLStr = [data base64EncodedStringWithOptions:0];
    
    base64URLStr = [base64URLStr stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64URLStr = [base64URLStr stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64URLStr = [base64URLStr stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    return base64URLStr;
}


- (NSString *)replaceStringWithRegexPattern:(NSString *)pattern withString:(NSString *)string
{
    NSMutableString *mutableCopy = [self mutableCopy];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    [regex replaceMatchesInString:mutableCopy options:0 range:NSMakeRange(0, [mutableCopy length]) withTemplate:@""];
    
    return mutableCopy;
}

@end
