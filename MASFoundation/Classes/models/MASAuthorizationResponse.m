//
//  MASAuthorizationResponse.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAuthorizationResponse.h"

#import "MASAccessService.h"
#import "MASFoundation.h"

@implementation MASAuthorizationResponse

///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Cannot call base init, call designated factory method" userInfo:nil];
    
    return nil;
}


- (instancetype)initProtected
{
    self = [super init];
    
    if(!self)
    {
        return nil;
    }
    
    return self;
}


+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASAuthorizationResponse alloc] initProtected];
                  });
    
    return sharedInstance;
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_3
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    return [self validateURLForAuthorizationURL:url];
}
#endif


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self validateURLForAuthorizationURL:url];
}


# pragma mark - Private

- (BOOL)validateURLForAuthorizationURL:(NSURL *)url
{
    //
    // Ignore if SDK has not properly initialized at the moment
    //
    if ([MAS MASState] != MASStateDidStart)
    {
        //
        // return an error
        //
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveError:)])
        {
            [self.delegate didReceiveError:[NSError errorMASIsNotStarted]];
        }
        
        //
        // Send the notification with the error
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MASAuthorizationResponseDidReceiveErrorNotification object:[NSError errorMASIsNotStarted]];
        
        return NO;
    }
    //
    // If the URL is different from what has been registered in the configuration, return false
    //
    else if (![url.absoluteString containsString:[MASApplication currentApplication].redirectUri.absoluteString])
    {
        //
        // return an error
        //
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveError:)])
        {
            [self.delegate didReceiveError:[NSError errorApplicationRedirectUriInvalid]];
        }
        
        //
        // Send the notification with the error
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:MASAuthorizationResponseDidReceiveErrorNotification object:[NSError errorApplicationRedirectUriInvalid]];
        
        return NO;
    }
    
    NSString *query = [url query];
    NSArray *parameters = [query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *kvPairs = [NSMutableDictionary dictionary];
    
    for (NSString *parameter in parameters) {
        NSArray *kvPair = [parameter componentsSeparatedByString:@"="];
        
        if ([kvPair count] >= 2)
        {
            NSString *key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [kvPairs setObject:value forKey:key];
        }
    }
    
    //
    // If authorization code is not found, return false
    //
    if (![kvPairs objectForKey:@"code"])
    {
        return NO;
    }
    
    NSString *responseState = [kvPairs objectForKey:@"state"];
    NSString *requestState = [[MASAccessService sharedService].currentAccessObj retrievePKCEState];
    
    if (responseState || requestState)
    {
        //
        // If response or request state is nil, invalid request and/or response
        //
        if (responseState == nil || requestState == nil)
        {
            //
            // return an error
            //
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveError:)])
            {
                [self.delegate didReceiveError:[NSError errorInvalidAuthorization]];
            }
            
            //
            // Send the notification with the error
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASAuthorizationResponseDidReceiveErrorNotification object:[NSError errorInvalidAuthorization]];
            
            return NO;
        }
        //
        // verify that the state in the response is the same as the state sent in the request
        //
        else if (![responseState isEqualToString:requestState])
        {
            //
            // return an error
            //
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveError:)])
            {
                [self.delegate didReceiveError:[NSError errorInvalidAuthorization]];
            }
            
            //
            // Send the notification with the error
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:MASAuthorizationResponseDidReceiveErrorNotification object:[NSError errorInvalidAuthorization]];
            
            return NO;
        }
    }
    
    //
    // Return the authorization code through delegation if the delegation is defined
    //
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveAuthorizationCode:)])
    {
        [self.delegate didReceiveAuthorizationCode:[kvPairs objectForKey:@"code"]];
    }
    
    //
    // Send the notification with authoriation code
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:MASAuthorizationResponseDidReceiveAuthorizationCodeNotification object:@{@"code" : [kvPairs objectForKey:@"code"]}];
    
    return YES;
}

@end
