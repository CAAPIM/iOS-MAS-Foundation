//
//  MASLog.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASLog.h"

#import "MASDebugService.h"

@implementation MASLog

+ (void)setLogLevel:(MASDebugLevel)logLevel
{
    [MASDebugService setLogLevel:logLevel];
}

+ (void)logError:(NSString *)message
{
    [MASLog logWithDebugLevel:MASDebugLevelError file:nil funtion:nil line:nil message:message];
}


+ (void)logWarning:(NSString *)message
{
    [[MASDebugService sharedService] logMessage:message logLevel:MASDebugLevelWarning];
}


+ (void)logDebug:(NSString *)message
{
    [[MASDebugService sharedService] logMessage:message logLevel:MASDebugLevelDebug];
}



+ (void)logInfo:(NSString *)message
{
    [[MASDebugService sharedService] logMessage:message logLevel:MASDebugLevelInfo];
}



+ (void)logWithDebugLevel:(MASDebugLevel)debugLevel file:(const char *)file funtion:(const char *)function line:(NSUInteger)line message:(NSString *)message, ...
{
    if (([MASDebugService logLevel] & debugLevel) == 0)
    {
        return;
    }
    
    va_list args;
    va_start(args, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    
    NSString *callerDetails = @"";
    
    if (function != nil)
    {
        callerDetails = [callerDetails stringByAppendingString:[NSString stringWithFormat:@"%s", function]];
    }
    
    if (file != nil)
    {
        NSString *fullFilename = [NSString stringWithFormat:@"%s", file];
        NSArray *fileComponents = [fullFilename componentsSeparatedByString:@"/"];
        callerDetails = [callerDetails stringByAppendingString:[NSString stringWithFormat:@" %@", [fileComponents lastObject]]];
    }
    
    if (line > 0)
    {
        callerDetails = [callerDetails stringByAppendingString:[NSString stringWithFormat:@" [Line %lu]", (unsigned long)line]];
    }
    
    logMessage = [NSString stringWithFormat:@"%@\n%@", callerDetails, logMessage];
    [[MASDebugService sharedService] logMessage:logMessage logLevel:debugLevel];
}


+ (NSString *)debugLevelAsString:(MASDebugLevel)debugLevel
{
    if ((debugLevel & MASDebugLevelError) == MASDebugLevelError)
    {
        return @"Error";
    }
    else if ((debugLevel & MASDebugLevelWarning) == MASDebugLevelWarning)
    {
        return @"Warning";
    }
    else if ((debugLevel & MASDebugLevelDebug) == MASDebugLevelDebug)
    {
        return @"Debug";
    }
    else if ((debugLevel & MASDebugLevelInfo) == MASDebugLevelInfo)
    {
        return @"Info";
    }
    else if ((debugLevel & MASDebugLevelInfo) == MASDebugLevelAll)
    {
        return @"All";
    }
    else {
        return @"Unknown";
    }
}

@end
