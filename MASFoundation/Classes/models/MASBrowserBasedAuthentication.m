//
//  MASBrowserBasedAuthentication.m
//  MASFoundation
//
//  Copyright (c) 2017 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASAccessService.h"
#import "MASAuthorizationResponse.h"
#import "MASBrowserBasedAuthentication.h"
#import "MASConfigurationService.h"
#import "MASGetURLRequest.h"
#import "MASModelService.h"
#import "UIAlertController+MAS.h"
#import <SafariServices/SafariServices.h>

@interface MASBrowserBasedAuthentication () <MASAuthorizationResponseDelegate,SFSafariViewControllerDelegate>
{
    
}

@property (nonatomic) SFSafariViewController *safariViewController;
@property (nonatomic) MASAuthCredentialsBlock webLoginCallBack;

@end

@implementation MASBrowserBasedAuthentication

# pragma mark - Shared Service

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[MASBrowserBasedAuthentication alloc] init];
                  });
    
    return sharedInstance;
}


- (void)loadWebLoginTemplate:(MASAuthCredentialsBlock)webLoginBlock
{
    self.webLoginCallBack = webLoginBlock;
    MASModelService* service = [MASModelService sharedService];
    [[MASAuthorizationResponse sharedInstance] setDelegate:self];
    __block MASBrowserBasedAuthentication *blockSelf = self;
    
    //
    // Try to register so that all the essential things are set up in that API call and we get a valid URL. If Application is already registered the API returns without doing any work.
    //
    [service  registerApplication:^(BOOL completed, NSError *error) {
        [blockSelf getURLForWebLogin];
    }];
}


- (void)getURLForWebLogin
{
    //
    // Headers
    //
    MASIMutableOrderedDictionary *headerInfo = [MASIMutableOrderedDictionary new];
    
    //
    // Parameters
    //
    MASIMutableOrderedDictionary *parameterInfo = [MASIMutableOrderedDictionary new];
    
    // ClientId
    parameterInfo[MASClientKeyRequestResponseKey] = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientId];
    
    // RedirectUri
    parameterInfo[MASRedirectUriRequestResponseKey] = [[MASApplication currentApplication].redirectUri absoluteString];
    
    // Scope
    NSString *scope = [MASApplication currentApplication].scopeAsString;
    
    //
    // Workaround - msso_register scope should NOT be used to retrieve authenticationProviders when it is going to be used to "authenticate"
    // msso_register scope should only contain for device registration with authorizationCode.
    // When the authroizationCode was granted with msso_register scope and used to retrieve the tokens, it will FAIL with unknown error from the server.
    //
    if (scope && [[MASDevice currentDevice] isRegistered])
    {
        scope = [scope replaceStringWithRegexPattern:@"\\bmsso_register\\b" withString:@""];
    }
    
    //
    //  If sso is disabled, manually remove msso scope, as it will create id_token with msso scope
    //
    if (scope && ![MASConfiguration currentConfiguration].ssoEnabled)
    {
        scope = [scope replaceStringWithRegexPattern:@"\\bmsso\\b" withString:@""];
    }
    
    parameterInfo[MASScopeRequestResponseKey] = scope;
    
    // ResponseType
    parameterInfo[MASRequestResponseTypeRequestResponseKey] = @"code";
    
    // Display
    parameterInfo[MASDisplayRequestResponseKey] = @"template";
    
    // PKCE Support - generate code verifier
    [[MASAccessService sharedService].currentAccessObj generateCodeVerifier];
    
    // PKCE Support - generate state
    [[MASAccessService sharedService].currentAccessObj generatePKCEState];
    
    // Retrieve code verifier
    NSString *codeVerifier = [[MASAccessService sharedService].currentAccessObj retrieveCodeVerifier];
    
    // Retrieve state
    NSString *pkceState = [[MASAccessService sharedService].currentAccessObj retrievePKCEState];
    
    if (codeVerifier)
    {
        // SHA256 the code verifier and encode it with base64url
        NSString *codeChallenge = [NSString base64URLWithNSData:[codeVerifier sha256Data]];
        
        if (codeChallenge)
        {
            parameterInfo[MASPKCECodeChallengeRequestResponseKey] = codeChallenge;
            //
            // code_challenge_method should be S256 if the code challenge is hashed;
            //
            // Otherwise, make code_challenge = code_verifier, and send code_challenge_method as plan, MASPKCECodeChallengeMethodPlainKey
            //
            parameterInfo[MASPKCECodeChallengeMethodRequestResponseKey] = MASPKCECodeChallengeMethodSHA256Key;
            
            parameterInfo[MASPKCEStateRequestResponseKey] = pkceState;
        }
    }
    
    //Put the mag-identifier in the url as query parameter for the device to be identified
    NSString* magIdentifier = [[MASAccessService sharedService] getAccessValueStringWithStorageKey:MASKeychainStorageKeyMAGIdentifier];
    
    if(magIdentifier && magIdentifier.length > 0)
    {
        parameterInfo[MASMagIdentifierRequestResponseKey] = magIdentifier;
    }
    
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].authorizationEndpointPath;
    
    //
    // preserve the redirection block that was set earlier
    //
    MASSessionDataTaskHTTPRedirectBlock previousRedirectionBlock = [[MASNetworkingService sharedService] httpRedirectionBlock];
    [[MASNetworkingService sharedService] setHttpRedirectionBlock:[self getRedirectionBlock]];
    __block MASBrowserBasedAuthentication *blockSelf = self;
    
    //
    // This get request would result in a redirection which contains the actual URL to be loaded into browser and hence this would be canceled after the redirection
    //
    [[MASNetworkingService sharedService] getFrom:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:MASRequestResponseTypeWwwFormUrlEncoded responseType:MASRequestResponseTypeWwwFormUrlEncoded completion:^(NSDictionary* response, NSError* error){
        
            //
            // We expect this API to be cancelled in the redirection and hence the only acceptable error here is cancel.Any other error could mean an error for authenticaion itself. Hence cancel authorization.
            //
            if(error.code != NSURLErrorCancelled)
            {
                DLog(@"error occured in BBA error info: %@",error);
                blockSelf.webLoginCallBack(nil, YES, nil);
                return;
            }
        
            [[MASNetworkingService sharedService] setHttpRedirectionBlock:previousRedirectionBlock];
    }];
}

- (MASSessionDataTaskHTTPRedirectBlock)getRedirectionBlock
{
    __block MASBrowserBasedAuthentication *blockSelf = self;
    MASSessionDataTaskHTTPRedirectBlock redirectionBlock = ^(NSURLSession *session, NSURLSessionTask *task, NSURLResponse * response, NSURLRequest *request){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if(httpResponse.statusCode == 302 && [self isBBARedirection:task.originalRequest])
            {
                DLog(@"all headers %@",httpResponse.allHeaderFields);
                NSString* locationURL = [httpResponse.allHeaderFields objectForKey:@"Location"];
                NSURL* redirectURL = [NSURL URLWithString:locationURL];
                [task cancel];
                
                if(![blockSelf redirectURLHasErrors:redirectURL])
                {
                    [blockSelf launchBrowserWithURL:redirectURL];
                }
                else{
                    blockSelf.webLoginCallBack(nil, YES, nil);
                }
            }
            return request;
    };
    
    return redirectionBlock;
}

- (BOOL)isBBARedirection:(NSURLRequest*)request
{
    if([request.URL.absoluteString containsString:[MASConfiguration currentConfiguration].authorizationEndpointPath] && [request.URL.absoluteString containsString:@"display=template"])
    {
        return YES;
    }
    
    return NO;
}


- (BOOL)redirectURLHasErrors :(NSURL*)redirectURL
{
    NSString* redirectURLString = redirectURL.absoluteString;
    if([redirectURLString containsString:@"x-ca-err"] && [redirectURLString containsString:@"error"] && [redirectURLString containsString:@"error_description"])
    {
        return YES;
    }
    return NO;
}


- (void)launchBrowserWithURL:(NSURL*)templatizedURL
{
    __block MASBrowserBasedAuthentication *blockSelf = self;
    __weak __typeof__(self) weakSelf = self;
    blockSelf.safariViewController = [[SFSafariViewController alloc] initWithURL:templatizedURL];
    blockSelf.safariViewController.delegate = weakSelf;
     
     dispatch_async(dispatch_get_main_queue(), ^{
         [UIAlertController rootViewController].modalTransitionStyle = UIModalTransitionStyleCoverVertical;
         
         [[UIAlertController rootViewController] presentViewController:blockSelf.safariViewController animated:YES
         completion:^{
         
             DLog(@"Successfully displayed login template");
         }];
         
         return;
     });
}


#pragma mark - SafariViewController Delegates

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    self.webLoginCallBack(nil, YES, ^(BOOL completed, NSError* error){
        if(error)
        {
            DLog(@"Browser cancel clicked");
        }
    });
}


#pragma mark - Authorization Response delegate

- (void)didReceiveAuthorizationCode:(NSString *)code
{
    MASAuthCredentialsAuthorizationCode *authCredentials = [MASAuthCredentialsAuthorizationCode initWithAuthorizationCode:code];
    [[MASNetworkingService sharedService] setHttpRedirectionBlock:nil];
    
    self.webLoginCallBack(authCredentials, NO, ^(BOOL completed, NSError* error){
        //
        // In either success or error case dismiss the browser and just log the status. The caller would pass the error state/success back to user.
        //
        if(error)
        {
            DLog(@"successfully logged in");
        }
        DLog(@"successfully logged in");
        [self dismissBrowser];
    });
}


- (void)didReceiveError:(NSError *)error
{
    self.webLoginCallBack(nil, YES, ^(BOOL completed, NSError* error){
        if(error)
        {
            DLog(@"Did not receive Authorization code");
        }
    });
}

#pragma mark - UI

- (void)dismissBrowser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIAlertController rootViewController] dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
