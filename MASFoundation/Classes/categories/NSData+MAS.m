//
//  NSData+MAS.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "NSData+MAS.h"

#import "NSData+MASPrivate.h"
#import "RNCryptor.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"



@interface NSData ()

extern bool _encrypted;

@end


@implementation NSData (MAS)


# pragma mark - Encrypt and Decrypt

+ (NSData *)encryptData:(NSData *)data password:(NSString *)password error:(NSError **)anError
{
    NSParameterAssert(data);
    NSParameterAssert(password);
    
    NSError *returnedError = nil;
    
    NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&returnedError];
    
    if (returnedError) {
        
        if (anError) {
            
            *anError = returnedError;
        }
        
        return nil;
    }
    else {
        
        [encryptedData encrypted:YES];
        
        return encryptedData;
    }
}


+ (NSData *)decryptData:(NSData *)data password:(NSString *)password error:(NSError **)anError
{
    
    NSParameterAssert(data);
    NSParameterAssert(password);
    
    NSError *returnedError = nil;
    
    NSData *decryptedData = [RNDecryptor decryptData:data withPassword:password error:&returnedError];
    
    if (returnedError) {
        
        if (anError) {
            
            *anError = returnedError;
        }
        
        return nil;
    }
    else {
        
        [decryptedData encrypted:NO];
        
        return decryptedData;
    }
}


# pragma mark - Public

- (BOOL)isEncrypted
{
    return (_encrypted == YES);
}

@end
