//
//  MASSharedStorage.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASSharedStorage.h"

#import "MASAccessService.h"
#import "MASConstantsPrivate.h"

@implementation MASSharedStorage

+ (NSString *)findStringUsingKey:(NSString *)key error:(NSError **)error
{
    //
    //  Check if SDK was initialized
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (error)
        {
            *error = [NSError errorMASIsNotStarted];
        }
        
        return nil;
    }
    
    //
    //  Check for data key
    //
    if (key == nil || [key length] <= 0)
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotNilKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return nil;
    }
    
    //
    //  Retrieve NSString from shared keychain storage
    //
    NSError *operationError = nil;
    NSString *resultString = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:[NSString stringWithFormat:@"%@.%@", MASSharedStorageCustomPrefix, key] error:&operationError];
    
    //
    //  If an error occurred while keychain operation, convert it into MASFoundationErrorDomainLocal error object
    //
    if (operationError)
    {
        NSError *thisError = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:operationError.code userInfo:@{NSLocalizedDescriptionKey : operationError.localizedDescription}];
        
        if (error)
        {
            *error = thisError;
        }
    }
    
    return resultString;
}


+ (NSData *)findDataUsingKey:(NSString *)key error:(NSError **)error
{
    //
    //  Check if SDK was initialized
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (error)
        {
            *error = [NSError errorMASIsNotStarted];
        }
        
        return nil;
    }
    
    //
    //  Check for data key
    //
    if (key == nil || [key length] <= 0)
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotNilKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return nil;
    }
    
    //
    //  Retrieve NSData from shared keychain storage
    //
    NSError *operationError = nil;
    NSData *resultData = [[MASAccessService sharedService] getAccessValueDataWithStorageKey:[NSString stringWithFormat:@"%@.%@", MASSharedStorageCustomPrefix, key] error:&operationError];
    
    //
    //  If an error occurred while keychain operation, convert it into MASFoundationErrorDomainLocal error object
    //
    if (operationError)
    {
        NSError *thisError = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:operationError.code userInfo:@{NSLocalizedDescriptionKey : operationError.localizedDescription}];
        
        if (error)
        {
            *error = thisError;
        }
    }
    
    return resultData;
}


+ (BOOL)saveString:(NSString *)string key:(NSString *)key error:(NSError **)error
{
    //
    //  Check if SDK was initialized
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (error)
        {
            *error = [NSError errorMASIsNotStarted];
        }
        
        return NO;
    }
    
    //
    //  Check for data key
    //
    if (key == nil || [key length] <= 0)
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotNilKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return NO;
    }
    
    //
    //  Store NSString into shared keychain storage
    //
    NSError *operationError = nil;
    BOOL result = [[MASAccessService sharedService] setAccessValueString:string storageKey:[NSString stringWithFormat:@"%@.%@", MASSharedStorageCustomPrefix, key] error:&operationError];
    
    //
    //  If an error occurred while keychain operation, convert it into MASFoundationErrorDomainLocal error object
    //
    if (operationError)
    {
        NSError *thisError = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:operationError.code userInfo:@{NSLocalizedDescriptionKey : operationError.localizedDescription}];
        
        if (error)
        {
            *error = thisError;
        }
    }
    
    return result;
}


+ (BOOL)saveData:(NSData *)data key:(NSString *)key error:(NSError **)error
{
    //
    //  Check if SDK was initialized
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (error)
        {
            *error = [NSError errorMASIsNotStarted];
        }
        
        return NO;
    }
    
    //
    //  Check for data key
    //
    if (key == nil || [key length] <= 0)
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotNilKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return NO;
    }
    
    NSError *operationError = nil;
    BOOL result = [[MASAccessService sharedService] setAccessValueData:data storageKey:[NSString stringWithFormat:@"%@.%@", MASSharedStorageCustomPrefix, key] error:&operationError];
    
    //
    //  If an error occurred while keychain operation, convert it into MASFoundationErrorDomainLocal error object
    //
    if (operationError)
    {
        NSError *thisError = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:operationError.code userInfo:@{NSLocalizedDescriptionKey : operationError.localizedDescription}];
        
        if (error)
        {
            *error = thisError;
        }
    }
    
    return result;
}


+ (void)deleteForKey:(NSString *_Nonnull)key error:(NSError * __nullable __autoreleasing * __nullable)error
{
    //
    //  Check if SDK was initialized
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        if (error)
        {
            *error = [NSError errorMASIsNotStarted];
        }
        
        return;
    }
    
    //
    //  Check for data key
    //
    if (key == nil || [key length] <= 0)
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotNilKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return;
    }
    
    NSError *operationError = nil;
    [[MASAccessService sharedService] deleteForStorageKey:[NSString stringWithFormat:@"%@.%@", MASSharedStorageCustomPrefix, key] error:&operationError];
    
    //
    //  If an error occurred while keychain operation, convert it into MASFoundationErrorDomainLocal error object
    //
    if (operationError)
    {
        NSError *thisError = [NSError errorWithDomain:MASFoundationErrorDomainLocal code:operationError.code userInfo:@{NSLocalizedDescriptionKey : operationError.localizedDescription}];
        
        if (error)
        {
            *error = thisError;
        }
    }
}

@end
