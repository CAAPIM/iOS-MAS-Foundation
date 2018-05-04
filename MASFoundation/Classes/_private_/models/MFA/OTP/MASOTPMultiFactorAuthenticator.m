//
//  MASOTPMultiFactorAuthenticator.m
//  MASFoundation
//
//  Copyright (c) 2018 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASOTPMultiFactorAuthenticator.h"

#import "MASOTPService.h"

@interface MASOTPMultiFactorAuthenticator ()

@end

@implementation MASOTPMultiFactorAuthenticator

- (MASMultiFactorHandler *)getMultiFactorHandler:(MASRequest *)request response:(NSHTTPURLResponse *)response
{
    NSDictionary *responseHeader = [response allHeaderFields];
    
    //
    //  Extract the error code from the response headers
    //
    if ([[responseHeader allKeys] containsObject:@"x-ca-err"])
    {
        NSString *magErrorCode = [responseHeader objectForKey:@"x-ca-err"];
        
        //
        //  140, 142, 143, 144, and 145 are x-car-err codes from MAG OTP
        //
        if (magErrorCode && ([magErrorCode hasSuffix:@"140"] || [magErrorCode hasSuffix:@"142"] || [magErrorCode hasSuffix:@"143"] || [magErrorCode hasSuffix:@"144"] || [magErrorCode hasSuffix:@"145"]))
        {
            MASMultiFactorHandler *handler = [[MASMultiFactorHandler alloc] initWithRequest:request];
            return handler;
        }
    }
    
    return nil;
}


- (void)onMultiFactorAuthenticationRequest:(MASRequest *)request response:(NSHTTPURLResponse *)response handler:(MASMultiFactorHandler *)handler
{
    //
    //  Validate OTP with OTP service
    //
    __block MASMultiFactorHandler *blockHandler = handler;
    [[MASOTPService sharedService] validateOTPSessionWithResponseHeaders:[response allHeaderFields] completionBlock:^(NSDictionary *responseInfo, NSError *error) {
         
        NSString *oneTimePassword = [responseInfo objectForKey:MASHeaderOTPKey];
        NSArray *otpChannels = [responseInfo objectForKey:MASHeaderOTPChannelKey];
        
        //
        // If it fails to fetch OTP, notify user
        //
        if (!oneTimePassword || error)
        {
            [blockHandler cancelWithError:error];
        }
        //
        //  Otherwise, proceed with the original request with additional header information
        //
        else {
            
            NSMutableDictionary *otpHeaders = [NSMutableDictionary dictionary];
            NSString *otpSelectedChannelsStr = [otpChannels componentsJoinedByString:@","];
            
            [otpHeaders setObject:oneTimePassword forKey:MASHeaderOTPKey];
            [otpHeaders setObject:otpSelectedChannelsStr forKey:MASHeaderOTPChannelKey];
            
            [blockHandler proceedWithHeaders:otpHeaders];
        }
     }];
}

@end
