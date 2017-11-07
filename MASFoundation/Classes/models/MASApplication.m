//
//  MASApplication.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASApplication.h"

#import "MASConfiguration.h"
#import "MASConstantsPrivate.h"
#import "MASModelService.h"
#import "MASAccessService.h"

# pragma mark - Property Constants

static NSString *const MASApplicationIsRegisteredPropertyKey = @"isRegistered"; // bool
static NSString *const MASApplicationOrganizationPropertyKey = @"organization"; // string
static NSString *const MASApplicationNamePropertyKey = @"name"; // string
static NSString *const MASApplicationDescriptionPropertyKey = @"description"; // string
static NSString *const MASApplicationIdentifierPropertyKey = @"identifier"; // string
static NSString *const MASApplicationEnvironmentPropertyKey = @"environment"; // string
static NSString *const MASApplicationIconUrlPropertyKey = @"iconUrl"; // string
static NSString *const MASApplicationAuthUrlPropertyKey = @"authUrl"; // string
static NSString *const MASApplicationNativeUrlPropertyKey = @"nativeUrl"; // string
static NSString *const MASApplicationCustomPropertiesPropertyKey = @"customProperties"; // string
static NSString *const MASApplicationExpirationPropertyKey = @"expiration"; // string
static NSString *const MASApplicationKeyPropertyKey = @"key"; // string
static NSString *const MASApplicationRedirectUriPropertyKey = @"redirectUri"; // url
static NSString *const MASApplicationRegisteredByPropertyKey = @"registeredBy"; // string
static NSString *const MASApplicationScopePropertyKey = @"scope"; // string
static NSString *const MASApplicationScopeAsStringPropertyKey = @"scopeAsString"; // string
static NSString *const MASApplicationSecretPropertyKey = @"secret"; // string
static NSString *const MASApplicationStatusPropertyKey = @"status"; // string


@interface MASApplication ()
    <UIWebViewDelegate>
{
    id _originalDelegate;
}

@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, copy) MASCompletionErrorBlock errorBlock;

@end


@implementation MASApplication
@synthesize isRegistered = _isRegistered;
@synthesize isAuthenticated = _isAuthenticated;

# pragma mark - Current Application

+ (MASApplication *)currentApplication
{
    return [MASModelService sharedService].currentApplication;
}


# pragma mark - Lifecycle

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (id)initPrivate
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) is registered: %@\n\n        organization: %@\n        name: %@"
        "\n        detailed description: %@\n        identifier: %@\n        environment: %@\n        status: %@"
        "\n        icon url: %@\n        auth url: %@\n        native url: %@\n        redirect uri: %@"
        "\n        registered by: %@\n        scope: %@\n        custom properties: %@",
        [self class], ([self isRegistered] ? @"Yes" : @"No"), [self organization], [self name], [self detailedDescription],
        [self identifier], [self environment], [self status], [self iconUrl], [self authUrl], [self nativeUrl],
        [self redirectUri],[self registeredBy], [self scopeAsString],
        (![self customProperties] ? @"<none>" : [NSString stringWithFormat:@"\n\n%@", [self customProperties]])];
}

# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)isRegistered
{
    //
    // Obtain key chain items to determine registration status
    //
    MASAccessService *accessService = [MASAccessService sharedService];

    NSNumber *clientExpiration = [accessService getAccessValueNumberWithStorageKey:MASKeychainStorageKeyClientExpiration];
    NSString *clientId = [accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientId];
    NSString *clientSecret = [accessService getAccessValueStringWithStorageKey:MASKeychainStorageKeyClientSecret];

    _isRegistered = (clientExpiration && clientId && clientSecret && !self.isExpired);
    return _isRegistered;
}

- (BOOL)isAuthenticated
{
    
    return [self authenticationStatus] != MASAuthenticationStatusNotLoggedIn;
}


- (MASAuthenticationStatus)authenticationStatus
{
    MASAuthenticationStatus currentStatus = MASAuthenticationStatusNotLoggedIn;
    
    //
    // If the device is not registered, whether the user credentials are in keychain or not,
    // we have to assume that the user is not authenticated.
    //
    if (![MASDevice currentDevice].isRegistered)
    {
        return currentStatus;
    }
    
    //
    // Retrieve the items that determine authentication status
    //
    MASUser *currentUser = [MASUser currentUser];
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSString *accessToken = accessService.currentAccessObj.accessToken;
    NSString *refreshToken = accessService.currentAccessObj.refreshToken;
    NSString *idToken = accessService.currentAccessObj.idToken;
    NSNumber *expiresIn = accessService.currentAccessObj.expiresIn;
    NSDate *expiresInDate = accessService.currentAccessObj.expiresInDate;
    NSString *authCredentialsType = accessService.currentAccessObj.authCredentialsType;
    
    BOOL isClientCrendential = [authCredentialsType isEqualToString:MASGrantTypeClientCredentials];
    
    //DLog(@"\n\n  access token: %@\n  refresh token: %@\n  expiresIn: %@, expires in date: %@\n\n",
    //    accessToken, refreshToken, expiresIn, expiresInDate);
    

    //
    // If there is an idToken and a current user
    //
    if(idToken && currentUser)
    {
        //
        // Check idToken expiration
        //
        if(![MASAccessService isIdTokenExpired:idToken error:nil])
        {
            currentStatus = MASAuthenticationStatusLoginWithUser;
        }
    }
    else {
        //
        // if accessToken, refreshToken, exprieDate values exist and it is the current user, we understand that the user is authenticated with username and password
        //
        if (accessToken && refreshToken && expiresIn && currentUser && currentUser.isCurrentUser)
        {
            currentStatus = MASAuthenticationStatusLoginWithUser;
        }
        //
        //  if accessToken, refrehsToken, and currentUser exist, we understand that the current session was authenticated with user credentials
        //
        else if (accessToken && refreshToken && currentUser)
        {
            currentStatus = MASAuthenticationStatusLoginWithUser;
        }
        //
        // check if it has been authenticated anonymously (Client credential)
        //
        else if (accessToken && expiresIn && !currentUser && isClientCrendential){
            currentStatus = MASAuthenticationStatusLoginAnonymously;
        }
        
        //
        // Then check if expiration has passed
        //
        if (expiresIn && ([expiresInDate timeIntervalSinceNow] <= 0))
        {
            currentStatus = MASAuthenticationStatusNotLoggedIn;
            [[MASAccessService sharedService].currentAccessObj deleteForTokenExpiration];
        }
    }
    
    //DLog(@"\n\nNOW date is: %@, expiration date is: %@ and interval since now: %f\n\n",
    //    [NSDate date], expiresInDate, [expiresInDate timeIntervalSinceNow]);
    
    return currentStatus;
}


# pragma mark - Enterprise Apps

- (void)retrieveEnterpriseApps:(MASObjectsResponseErrorBlock)completion
{
    //
    //  Making sure user has valid session before making a call to retrieve enterprise browser apps
    //
    [[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {
        
        if (completed && !error)
        {
            [[MASModelService sharedService] retrieveEnterpriseApplications:completion];
        }
        
        else
        {
            if(completion) completion(nil, error);
        }
    }];
}


- (void)enterpriseIconWithImageView:(UIImageView *)imageView completion:(MASCompletionErrorBlock)completion
{
    //
    // Create and add a tap gesture recognizer
    //
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    
    self.errorBlock = completion;
    //
    // Set the icon image
    //
    [imageView setImageWithURL:[NSURL URLWithString:self.iconUrl] placeholderImage:nil];
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:singleTap];
}


- (void)loadWebApp:(UIWebView *)webView completion:(MASCompletionErrorBlock)completion
{
    //
    // Validate URL
    //
    if(![MASApplication isProtectedResource:[NSURL URLWithString:self.authUrl]] )
    {
        // Invalid URL
        NSError *error = [NSError errorEnterpriseBrowserWebAppInvalidURL];

        if (completion) completion(NO,error);
        
        return;
    }
    
    //
    // Create the URL request
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.authUrl]];
    
    //
    // If the UIWebView already has a delegate we must store it
    //
    if(webView.delegate != nil)
    {
        _originalDelegate = webView.delegate;
    }
    
    webView.delegate = self;
    _webView = webView;
    
    if (completion) completion(YES,nil);
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(didReceiveStatusUpdate:)
        name:L7SDidReceiveStatusUpdateNotification
        object:nil];
    */
    
    [webView loadRequest:request];
}


+ (BOOL)isProtectedResource:(NSURL *)resourceURL
{
    NSString *resourceURLHost = [resourceURL host];
    NSString *endpointHost = [MASConfiguration currentConfiguration].gatewayHostName;
    
    //
    // If the url has a prefix
    //
    if([resourceURLHost hasPrefix:endpointHost])
    {
        if( resourceURLHost.length == endpointHost.length ||
            [resourceURLHost isEqualToString:[endpointHost stringByAppendingString:@"."]])
        {
            return YES;
        }
    }
    
    return NO;
}


- (void)singleTapping:(UIGestureRecognizer *)recognizer
{
    //
    //  If a valid native url property exists
    //
    if(self.nativeUrl && self.nativeUrl.length != 0)
    {
        //
        // If the native application be opened
        //
        NSURL *nativeURL = [NSURL URLWithString:self.nativeUrl];
        if(![[UIApplication sharedApplication] canOpenURL:nativeURL])
        {
            // Native app does not exist
            NSError *error = [NSError errorEnterpriseBrowserNativeAppDoesNotExist];

            if (self.errorBlock) {
                self.errorBlock(YES,error);
            }
            
            return;
        }
        
        //
        // Attempt to pen the application
        //
        if(![[UIApplication sharedApplication] openURL:nativeURL])
        {
            // Native app failed to open
            NSError *error = [NSError errorEnterpriseBrowserNativeAppCannotOpen];

            if (self.errorBlock) {
                self.errorBlock(YES,error);
            }
            
            return;
        }
        
        if (self.errorBlock) {
            self.errorBlock(YES,nil);
        }
        return;
    }
    
    //
    // If a valid auth url property exists call the deleget
    //
    if(self.authUrl)
    {

        [self.delegate enterpriseWebApp:self];
        
        if (self.errorBlock) {
            self.errorBlock(YES,nil);
        }
        
        return;
    }
    
    // App doesnot exist
    NSError *error = [NSError errorEnterpriseBrowserAppDoesNotExist];
    if (self.delegate && [self.delegate respondsToSelector:@selector(enterpriseApp:didReceiveError:)]) {
        [self.delegate enterpriseApp:self didReceiveError:error];
    }
    if (self.errorBlock) {
        self.errorBlock(NO,error);
    }
}


# pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"didFailLoadWithError %@",error);
    if(_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        return [_originalDelegate webView:webView didFailLoadWithError:error];
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    if(_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        return [_originalDelegate webViewDidStartLoad:webView];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if(_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        return [_originalDelegate webViewDidFinishLoad:webView];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLog(@"shouldStartLoadWithRequest %@",request);
    return (_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)] ?
        
        //
        // Call the original delegate
        //
        [_originalDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType] :
        
        //
        // Just return YES
        //
        YES);
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    if(self.organization) [aCoder encodeObject:self.organization forKey:MASApplicationOrganizationPropertyKey];
    if(self.name) [aCoder encodeObject:self.name forKey:MASApplicationNamePropertyKey];
    if(self.detailedDescription) [aCoder encodeObject:self.detailedDescription forKey:MASApplicationDescriptionPropertyKey];
    if(self.identifier) [aCoder encodeObject:self.identifier forKey:MASApplicationIdentifierPropertyKey];
    if(self.environment) [aCoder encodeObject:self.environment forKey:MASApplicationEnvironmentPropertyKey];
    if(self.redirectUri) [aCoder encodeObject:self.redirectUri forKey:MASApplicationRedirectUriPropertyKey];
    if(self.registeredBy) [aCoder encodeObject:self.registeredBy forKey:MASApplicationRegisteredByPropertyKey];
    if(self.scope) [aCoder encodeObject:self.scope forKey:MASApplicationScopePropertyKey];
    if(self.scopeAsString) [aCoder encodeObject:self.scopeAsString forKey:MASApplicationScopeAsStringPropertyKey];
    if(self.status) [aCoder encodeObject:self.status forKey:MASApplicationStatusPropertyKey];
    if(self.iconUrl) [aCoder encodeObject:self.iconUrl forKey:MASApplicationIconUrlPropertyKey];
    if(self.authUrl) [aCoder encodeObject:self.authUrl forKey:MASApplicationAuthUrlPropertyKey];
    if(self.nativeUrl) [aCoder encodeObject:self.nativeUrl forKey:MASApplicationNativeUrlPropertyKey];
    if(self.customProperties) [aCoder encodeObject:self.customProperties forKey:MASApplicationCustomPropertiesPropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationOrganizationPropertyKey] forKey:@"organization"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationNamePropertyKey] forKey:@"name"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationDescriptionPropertyKey] forKey:@"detailedDescription"];
        
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationIdentifierPropertyKey] forKey:@"identifier"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationEnvironmentPropertyKey] forKey:@"environment"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationRedirectUriPropertyKey] forKey:@"redirectUri"];
        
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationRegisteredByPropertyKey] forKey:@"registeredBy"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationScopePropertyKey] forKey:@"scope"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationScopeAsStringPropertyKey] forKey:@"scopeAsString"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationStatusPropertyKey] forKey:@"status"];
        
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationIconUrlPropertyKey] forKey:@"iconUrl"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationAuthUrlPropertyKey] forKey:@"authUrl"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationNativeUrlPropertyKey] forKey:@"nativeUrl"];
        [self setValue:[aDecoder decodeObjectForKey:MASApplicationCustomPropertiesPropertyKey] forKey:@"customProperties"];
    }
    
    return self;
}

@end
