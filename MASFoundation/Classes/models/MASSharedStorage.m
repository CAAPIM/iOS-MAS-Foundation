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
    //  Check if key is reserved for internal system data or not
    //
    if ([[MASAccessService sharedService] isInternalDataForStorageKey:key])
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotAllowedDataKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return nil;
    }
    
    //
    //  Retrieve NSString from shared keychain storage
    //
    NSError *operationError = nil;
    NSString *resultString = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:key error:&operationError];
    
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
    //  Check if key is reserved for internal system data or not
    //
    if ([[MASAccessService sharedService] isInternalDataForStorageKey:key])
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotAllowedDataKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return nil;
    }
    
    //
    //  Retrieve NSData from shared keychain storage
    //
    NSError *operationError = nil;
    NSData *resultData = [[MASAccessService sharedService] getAccessValueDataWithStorageKey:key error:&operationError];
    
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
    //  Check if key is reserved for internal system data or not
    //
    if ([[MASAccessService sharedService] isInternalDataForStorageKey:key])
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotAllowedDataKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return NO;
    }
    
    //
    //  Store NSString into shared keychain storage
    //
    NSError *operationError = nil;
    BOOL result = [[MASAccessService sharedService] setAccessValueString:string storageKey:key error:&operationError];
    
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
    //  Check if key is reserved for internal system data or not
    //
    if ([[MASAccessService sharedService] isInternalDataForStorageKey:key])
    {
        if (error)
        {
            *error = [NSError errorForFoundationCode:MASFoundationErrorCodeSharedStorageNotAllowedDataKey errorDomain:MASFoundationErrorDomainLocal];
        }
        
        return NO;
    }
    
    NSError *operationError = nil;
    BOOL result = [[MASAccessService sharedService] setAccessValueData:data storageKey:key error:&operationError];
    
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

@end
