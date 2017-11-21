//
//  MASBrowserBasedAuthentication.m
//  MASFoundation
//
//  Created by nimma01 on 20/11/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASBrowserBasedAuthentication.h"
#import <SafariServices/SafariServices.h>
#import "MASAuthorizationResponse.h"
#import "UIAlertController+MAS.h"
#import "MASConfigurationService.h"
#import "MASAccessService.h"
#import "MASGetURLRequest.h"
#import "MASModelService.h"

@interface MASBrowserBasedAuthentication () <MASAuthorizationResponseDelegate,SFSafariViewControllerDelegate>
{
    
}

@property (nonatomic) SFSafariViewController* safariViewController;
@property (nonatomic) MASCompletionErrorBlock webLoginCallBack;

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


-(void)loadWebLoginTemplate : (MASCompletionErrorBlock)webLoginBlock
{
    self.webLoginCallBack = webLoginBlock;
    MASModelService* service = [MASModelService sharedService];
    [[MASAuthorizationResponse sharedInstance] setDelegate:self];
    __block MASBrowserBasedAuthentication *blockSelf = self;
    __weak __typeof__(self) weakSelf = self;
    //
    // Try to register so that all the essential things are set up in that API call and we get a valid URL. If Application is already registered the API returns without doing any work.
    //
    [service  registerApplication:^(BOOL completed, NSError *error) {
        
        NSURL* url = [blockSelf getURLForWebLogin];
        DLog(@"url used for browser based authentication is %@",url.absoluteString);
        blockSelf.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        blockSelf.safariViewController.delegate = weakSelf;
        __block UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:blockSelf.safariViewController];
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [UIAlertController rootViewController].modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                           
                           [[UIAlertController rootViewController] presentViewController:navigationController animated:YES
                                                                              completion:^{
                                                                                  
                                                                                  navigationController = nil;
                                                                              }];
                           
                           return;
                       });
    }];
}


- (NSURL*)getURLForWebLogin
{
    //
    // Endpoint
    //
    NSString *endPoint = [MASConfiguration currentConfiguration].authorizationEndpointPath;
    
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
    
    //Remove register scopes if device is already registered (required for BBA to work)
  /*  if([[MASDevice currentDevice] isRegistered])
    {
        scope = [scope stringByReplacingOccurrencesOfString:@"msso_client_register" withString:@""];
        scope = [scope stringByReplacingOccurrencesOfString:@"msso_register" withString:@""];
        
    }*/
    
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
    //DLog(@"mag-identifier is %@",magIdentifier);
    if(magIdentifier && magIdentifier.length > 0)
    {
        parameterInfo[MASMagIdentifierRequestResponseKey] = magIdentifier;
    }
    
    return [MASGetURLRequest requestForEndpoint:endPoint withParameters:parameterInfo andHeaders:headerInfo requestType:MASRequestResponseTypeUnknown responseType:MASRequestResponseTypeUnknown isPublic:YES].URL;
}


#pragma mark - SafariViewController Delegates

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    self.webLoginCallBack(NO, nil);
}


#pragma mark - Authorization Response delegate

-(void)didReceiveAuthorizationCode:(NSString *)code
{
    __block MASBrowserBasedAuthentication *blockSelf = self;
    [MASUser loginWithAuthorizationCode:code completion:^(BOOL completed,NSError* error){
        [blockSelf dismissBrowser];
        if(error)
        {
            DLog(@"error occured %@",error.localizedDescription);
            blockSelf.webLoginCallBack(completed, error);
            return;
        }
        
        DLog(@"Browser Based Login Successful");
        blockSelf.webLoginCallBack(completed, error);
        
        
    }];
}


-(void)didReceiveError:(NSError *)error
{
    self.webLoginCallBack(NO, error);
}

#pragma mark - UI

-(void)dismissBrowser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIAlertController rootViewController] dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
