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
#import <WebKit/WebKit.h>
#import "MASSecurityService.h"



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
<WKUIDelegate, WKNavigationDelegate>
{
    id _originalDelegate;
    NSMutableURLRequest *mutableRequest;
}

@property (nonatomic, strong, readonly) WKWebView *webView;
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
    // If there is a valid idToken and a current user
    //
    if(idToken && ![MASAccessService isIdTokenExpired:idToken error:nil] && currentUser)
    {
        currentStatus = MASAuthenticationStatusLoginWithUser;
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


- (void)loadWebApp:(WKWebView *)webView completion:(MASCompletionErrorBlock)completion
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
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.authUrl]];
    
    //
    //  If user session is valid add the authorization header
    //
    if ([MASApplication currentApplication].isAuthenticated &&
        [self.class isProtectedResource:request.URL])
    {
        [self setAuthorization:request];
    }
    
    
    //
    // If the WKWebView already has a delegate we must store it
    //
    if(webView.UIDelegate != nil)
    {
        _originalDelegate = webView.UIDelegate;
    }
    
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    _webView = webView;
    
    if (completion) completion(YES,nil);
    
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


# pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    DLog(@"didFailLoadWithError %@",error);
    
    if(_originalDelegate != nil &&
       [_originalDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)])
    {
        return [_originalDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}


- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation {
    
    if(_originalDelegate != nil &&
       [_originalDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)])
    {
        return [_originalDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}


- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation {
    
    if(_originalDelegate != nil
       && [_originalDelegate respondsToSelector:@selector(webView:didFinishNavigation:)])
    {
        return [_originalDelegate webView:webView didFinishNavigation:navigation];
    }
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if ([MASApplication currentApplication].isAuthenticated &&
        [self.class isProtectedResource:navigationAction.request.URL]) {
        
        NSString *endPoint = @"/connect/enterprise/browser/websso/login";
        NSMutableURLRequest *request = [navigationAction.request mutableCopy];
        
        //
        //  If websso/login endpoint do not add the authorization header
        //  Gets into a infinite loop as the server refreshes the page.
        //
        if ([request.allHTTPHeaderFields valueForKey:@"Authorization"] == nil &&
            ![request.URL.absoluteString hasSuffix:endPoint]) {
            
            [self setAuthorization:request];
            [webView loadRequest:request];
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    return (_originalDelegate != nil && [_originalDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)] ?
            
            //
            // Call the original delegate
            //
            [_originalDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler] :
            
            //
            // Just return YES
            //
            YES);
}


-(void) setAuthorization: (NSMutableURLRequest *) request {
    
    NSString *authorization = [MASUser authorizationBearerWithAccessToken];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:
(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        SecPolicyRef policy = SecPolicyCreateBasicX509();
        CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
        NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:certificateCount];
        
        for (CFIndex i = 0; i < certificateCount; i++) {
            SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
            
            [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
        }
        
        CFRelease(policy);
        
        {
            for (id serverCertificateData in trustChain) {
                if ([[self.class pinnedCertificates] containsObject:serverCertificateData]) {
                
                    completionHandler(NSURLSessionAuthChallengeUseCredential,
                                      [NSURLCredential credentialForTrust:serverTrust]);
                    
                    return;
                }
            }
            
            SecTrustResultType result = 0;
            SecTrustEvaluate(serverTrust, &result);
            
            if (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed) {
                
                completionHandler(NSURLSessionAuthChallengeUseCredential,
                                  [NSURLCredential credentialForTrust:serverTrust]);
                
            } else {
                
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            }
        }
    }
    else {
        
        if ([challenge previousFailureCount] == 0) {
            //client side authentication
            NSURLCredential * credential = [[MASSecurityService sharedService] createUrlCredential];
            if (credential) {
                
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            } else {
                completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
            }
        } else {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

+ (NSArray *)pinnedCertificates {
    static NSMutableArray *_pinnedCertificates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
        
        NSMutableArray *certificates = [NSMutableArray arrayWithCapacity:[paths count]];
        for (NSString *path in paths) {
            NSData *certificateData = [NSData dataWithContentsOfFile:path];
            [certificates addObject:certificateData];
        }
        
        _pinnedCertificates = [[NSMutableArray alloc] initWithArray:certificates];
        //adding the certificates from Json configuration
        [_pinnedCertificates addObjectsFromArray:[[MASConfiguration currentConfiguration] gatewayCertificatesAsDERData]];
        
    });
    return _pinnedCertificates;
}


+ (NSArray *)pinnedPublicKeys {
    static NSArray *_pinnedPublicKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *pinnedCertificates = [self pinnedCertificates];
        NSMutableArray *publicKeys = [NSMutableArray arrayWithCapacity:[pinnedCertificates count]];
        
        for (NSData *data in pinnedCertificates) {
            SecCertificateRef allowedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
            NSParameterAssert(allowedCertificate);
            
            SecCertificateRef allowedCertificates[] = {allowedCertificate};
            CFArrayRef certificates = CFArrayCreate(NULL, (const void **)allowedCertificates, 1, NULL);
            
            SecPolicyRef policy = SecPolicyCreateBasicX509();
            SecTrustRef allowedTrust = NULL;
            OSStatus status = SecTrustCreateWithCertificates(certificates, policy, &allowedTrust);
            NSAssert(status == errSecSuccess, @"SecTrustCreateWithCertificates error: %ld", (long int)status);
            
            SecTrustResultType result = 0;
            status = SecTrustEvaluate(allowedTrust, &result);
            NSAssert(status == errSecSuccess, @"SecTrustEvaluate error: %ld", (long int)status);
            
            SecKeyRef allowedPublicKey = SecTrustCopyPublicKey(allowedTrust);
            NSParameterAssert(allowedPublicKey);
            [publicKeys addObject:(__bridge_transfer id)allowedPublicKey];
            
            CFRelease(allowedTrust);
            CFRelease(policy);
            CFRelease(certificates);
            CFRelease(allowedCertificate);
        }
        
        _pinnedPublicKeys = [[NSArray alloc] initWithArray:publicKeys];
    });
    
    return _pinnedPublicKeys;
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
