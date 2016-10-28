//
//  MASApplication+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASApplication+MASPrivate.h"

#import <objc/runtime.h>
#import "MASAccessService.h"
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"


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


@implementation MASApplication (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithConfiguration
{
    self = [super init];
    if(self)
    {
        //
        // Retrieve the current configuration
        //
        MASConfiguration *configuration = [MASConfiguration currentConfiguration];
        
        //
        // Retrieve the default client info
        //
        NSDictionary *info = [configuration defaultApplicationClientInfo];
        
        //
        // Set the values
        //
        self.organization = [configuration applicationOrganization];
        self.name = [configuration applicationName];
        self.detailedDescription = [configuration applicationDescription];
        
        self.identifier = info[MASClientIdentifierRequestResponseKey];
        self.environment = info[MASEnvironmentRequestResponseKey];
        self.registeredBy = info[MASRegisteredByRequestResponseKey];
        self.scope = info[MASScopeRequestResponseKey];
        self.scopeAsString = info[MASScopeRequestResponseKey];
        self.status = info[MASStatusRequestResponseKey];
        
        self.redirectUri = (info[MASRedirectUriRequestResponseKey] ?
            [NSURL URLWithString:info[MASRedirectUriRequestResponseKey]] :
            nil);
        
        MASAccessService *accessService = [MASAccessService sharedService];
        
        NSData *trustedServerCertificate = [accessService getAccessValueDataWithType:MASAccessValueTypeTrustedServerCertificate];
        if(!trustedServerCertificate)
        {
            //
            // Trusted Server Certificate (not sure if this really belongs here, think about that)
            //
            NSArray *certificates = [MASConfiguration currentConfiguration].gatewayCertificatesAsPEMData;
            if(certificates && certificates.count > 0)
            {
                trustedServerCertificate = certificates[0];
                [accessService setAccessValueData:trustedServerCertificate withAccessValueType:MASAccessValueTypeTrustedServerCertificate];
            }
        }
        
        //
        // If the credentials are NOT dynamic set them here
        //
        if(!configuration.applicationCredentialsAreDynamic)
        {
            NSDictionary *credentialsFromConfiguration = @
            {
                MASClientExpirationRequestResponseKey : [NSNumber numberWithInt:0],
                MASClientKeyRequestResponseKey : info[MASClientKeyRequestResponseKey],
                MASClientSecretRequestResponseKey : info[MASClientSecretRequestResponseKey]
            };
            
            [self saveWithUpdatedInfo:credentialsFromConfiguration];
        }
        
        //
        // Else it is dynamic and those values will be updated later
        //
        else
        {
            [self saveToStorage];
        }
    }
    
    /*DLog(@"\n\nSupported SCOPES in scope configuration string: %@\n\n  openId: %@\n  address: %@\n  email: %@\n  phone: %@\n  profile: %@\n  userRole: %@\n  msso: %@\n  msso client register: %@\n  msso register: %@\n\n",
        self.scopeAsString,
        (self.isScopeTypeOpenIdSupported ? @"Yes" : @"No"),
        (self.isScopeTypeAddressSupported ? @"Yes" : @"No"),
        (self.isScopeTypeEmailSupported ? @"Yes" : @"No"),
        (self.isScopeTypePhoneSupported ? @"Yes" : @"No"),
        (self.isScopeTypeProfileSupported ? @"Yes" : @"No"),
        (self.isScopeTypeUserRoleSupported ? @"Yes" : @"No"),
        (self.isScopeTypeMssoSupported ? @"Yes" : @"No"),
        (self.isScopeTypeMssoClientRegisterSupported ? @"Yes" : @"No"),
        (self.isScopeTypeMssoRegisterSupported ? @"Yes" : @"No"));*/
    
    return self;
}

+ (MASApplication *)instanceFromStorage
{
    //DLog(@"\n\ncalled%@\n\n");
    
    MASApplication *application;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStore] dataForKey:[MASApplication.class description]];
    if(data)
    {
        application = (MASApplication *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    //DLog(@"\n\n  found in storage: %@\n\n", [application debugDescription]);
    
    
    /**
     *  Duplication, reading some portion of information from JSON configuration rather than keychain as JSON can get updated any time
     */
    //
    // Retrieve the current configuration
    //
    MASConfiguration *configuration = [MASConfiguration currentConfiguration];
    
    //
    // Retrieve the default client info
    //
    NSDictionary *info = [configuration defaultApplicationClientInfo];
    
    //
    // Set the values
    //
    application.organization = [configuration applicationOrganization];
    application.name = [configuration applicationName];
    application.detailedDescription = [configuration applicationDescription];
    
    application.identifier = info[MASClientIdentifierRequestResponseKey];
    application.environment = info[MASEnvironmentRequestResponseKey];
    application.registeredBy = info[MASRegisteredByRequestResponseKey];
    application.scope = info[MASScopeRequestResponseKey];
    application.scopeAsString = info[MASScopeRequestResponseKey];
    application.status = info[MASStatusRequestResponseKey];
    
    application.redirectUri = (info[MASRedirectUriRequestResponseKey] ?
                        [NSURL URLWithString:info[MASRedirectUriRequestResponseKey]] :
                        nil);
    
    
    return application;
}


- (void)saveToStorage
{
    //DLog(@"\n\ncalled%@\n\n");
    
    //
    // Save to the keychain
    //
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if(data)
    {
        NSError *error;
        [[MASIKeyChainStore keyChainStore] setData:data
                                            forKey:[MASApplication.class description]
                                            error:&error];
    
        if(error)
        {
            DLog(@"Error attempting to save data: %@", [error localizedDescription]);
            return;
        }
    }
    
    //DLog(@"called with info: %@", [self debugDescription]);
}


- (void)saveWithUpdatedInfo:(NSDictionary *)info
{
    //DLog(@"called with updated info: %@", info);
    
    NSAssert(info, @"info cannot be nil");
    
    //
    // Access Service to retrieve information from keychain
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    //
    // Body Info
    //
    NSDictionary *bodyInfo = info[MASResponseInfoBodyInfoKey];
    
    //
    // Client Expiration
    //
    NSNumber *clientExpiration = bodyInfo[MASClientExpirationRequestResponseKey];
    if(clientExpiration)
    {
        [accessService setAccessValueNumber:clientExpiration withAccessValueType:MASAccessValueTypeClientExpiration];
    }
    
    //
    // Client Key
    //
    NSString *clientId = bodyInfo[MASClientKeyRequestResponseKey];
    if(clientId)
    {
        [accessService setAccessValueString:clientId withAccessValueType:MASAccessValueTypeClientId];
    }
    
    //
    // Client Secret
    //
    NSString *clientSecret = bodyInfo[MASClientSecretRequestResponseKey];
    if(clientSecret)
    {
        [accessService setAccessValueString:clientSecret withAccessValueType:MASAccessValueTypeClientSecret];
    }
    
    //
    // Save to the keychain
    //
    [self saveToStorage];
}


- (void)reset
{
    MASAccessService *accessService = [MASAccessService sharedService];
    
    [accessService setAccessValueString:nil withAccessValueType:MASAccessValueTypeClientId];
    [accessService setAccessValueString:nil withAccessValueType:MASAccessValueTypeClientSecret];
    [accessService setAccessValueNumber:nil withAccessValueType:MASAccessValueTypeClientExpiration];
    
    [[MASIKeyChainStore keyChainStore] removeItemForKey:[MASApplication.class description]];
}


- (id)initWithEnterpriseInfo:(NSDictionary *)info
{
    //DLog(@"\n\ncalled with info: %@\n\n", info);
    
    self = [super init];
    if(self)
    {
        self.identifier = info[MASApplicationIdRequestResponseKey];
        self.name = info[MASApplicationNameRequestResponseKey];
        self.authUrl = info[MASApplicationAuthUrlRequestResponseKey];
        self.iconUrl = info[MASApplicationIconUrlRequestResponseKey];
        self.nativeUrl = info[MASApplicationNativeUrlRequestResponseKey];
        
        self.customProperties = info[MASApplicationCustomRequestResponseKey];
    }
    
    return self;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
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
    //DLog(@"\n\ncalled\n\n");
    
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.organization = [aDecoder decodeObjectForKey:MASApplicationOrganizationPropertyKey];
        self.name = [aDecoder decodeObjectForKey:MASApplicationNamePropertyKey];
        self.detailedDescription = [aDecoder decodeObjectForKey:MASApplicationDescriptionPropertyKey];
        self.identifier = [aDecoder decodeObjectForKey:MASApplicationIdentifierPropertyKey];
        self.environment = [aDecoder decodeObjectForKey:MASApplicationEnvironmentPropertyKey];
        self.redirectUri = [aDecoder decodeObjectForKey:MASApplicationRedirectUriPropertyKey];
        self.registeredBy = [aDecoder decodeObjectForKey:MASApplicationRegisteredByPropertyKey];
        self.scope = [aDecoder decodeObjectForKey:MASApplicationScopePropertyKey];
        self.scopeAsString = [aDecoder decodeObjectForKey:MASApplicationScopeAsStringPropertyKey];
        self.status = [aDecoder decodeObjectForKey:MASApplicationStatusPropertyKey];
        self.iconUrl = [aDecoder decodeObjectForKey:MASApplicationIconUrlPropertyKey];
        self.authUrl = [aDecoder decodeObjectForKey:MASApplicationAuthUrlPropertyKey];
        self.nativeUrl = [aDecoder decodeObjectForKey:MASApplicationNativeUrlPropertyKey];
        self.customProperties = [aDecoder decodeObjectForKey:MASApplicationCustomPropertiesPropertyKey];
    }
    
    return self;
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
    
    NSNumber *clientExpiration = [accessService getAccessValueNumberWithType:MASAccessValueTypeClientExpiration];
    NSString *clientId = [accessService getAccessValueStringWithType:MASAccessValueTypeClientId];
    NSString *clientSecret = [accessService getAccessValueStringWithType:MASAccessValueTypeClientSecret];
    
    return (clientExpiration && clientId && clientSecret && !self.isExpired);
}


- (NSString *)organization
{
    return objc_getAssociatedObject(self, &MASApplicationOrganizationPropertyKey);
}


- (void)setOrganization:(NSString *)organization
{
    objc_setAssociatedObject(self, &MASApplicationOrganizationPropertyKey, organization, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)name
{
    return objc_getAssociatedObject(self, &MASApplicationNamePropertyKey);
}


- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, &MASApplicationNamePropertyKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)detailedDescription
{
    return objc_getAssociatedObject(self, &MASApplicationDescriptionPropertyKey);
}


- (void)setDetailedDescription:(NSString *)description
{
    objc_setAssociatedObject(self, &MASApplicationDescriptionPropertyKey, description, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)identifier
{
    return objc_getAssociatedObject(self, &MASApplicationIdentifierPropertyKey);
}


- (void)setIdentifier:(NSString *)identifier
{
    objc_setAssociatedObject(self, &MASApplicationIdentifierPropertyKey, identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)environment
{
    return objc_getAssociatedObject(self, &MASApplicationEnvironmentPropertyKey);
}


- (void)setEnvironment:(NSString *)environment
{
    objc_setAssociatedObject(self, &MASApplicationEnvironmentPropertyKey, environment, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSURL *)redirectUri
{
    return objc_getAssociatedObject(self, &MASApplicationRedirectUriPropertyKey);
}


- (void)setRedirectUri:(NSURL *)redirectUri
{
    objc_setAssociatedObject(self, &MASApplicationRedirectUriPropertyKey, redirectUri, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)registeredBy
{
    return objc_getAssociatedObject(self, &MASApplicationRegisteredByPropertyKey);
}


- (void)setRegisteredBy:(NSString *)registeredBy
{
    objc_setAssociatedObject(self, &MASApplicationRegisteredByPropertyKey, registeredBy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)scope
{
    return objc_getAssociatedObject(self, &MASApplicationScopePropertyKey);
}


- (void)setScope:(NSString *)scope
{
    objc_setAssociatedObject(self, &MASApplicationScopePropertyKey, scope, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)scopeAsString
{
    NSString *scopeAsString = objc_getAssociatedObject(self, &MASApplicationScopeAsStringPropertyKey);

    return [scopeAsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


- (void)setScopeAsString:(NSString *)scope
{
    objc_setAssociatedObject(self, &MASApplicationScopeAsStringPropertyKey, scope, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)status
{
    return objc_getAssociatedObject(self, &MASApplicationStatusPropertyKey);
}


- (void)setStatus:(NSString *)status
{
    objc_setAssociatedObject(self, &MASApplicationStatusPropertyKey, status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)authUrl
{
    return objc_getAssociatedObject(self, &MASApplicationAuthUrlPropertyKey);
}


- (void)setAuthUrl:(NSString *)authUrl
{
    objc_setAssociatedObject(self, &MASApplicationAuthUrlPropertyKey, authUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)iconUrl
{
    return objc_getAssociatedObject(self, &MASApplicationIconUrlPropertyKey);
}


- (void)setIconUrl:(NSString *)iconUrl
{
    objc_setAssociatedObject(self, &MASApplicationIconUrlPropertyKey, iconUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)nativeUrl
{
    return objc_getAssociatedObject(self, &MASApplicationNativeUrlPropertyKey);
}


- (void)setNativeUrl:(NSString *)nativeUrl
{
    objc_setAssociatedObject(self, &MASApplicationNativeUrlPropertyKey, nativeUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)customProperties
{
    return objc_getAssociatedObject(self, &MASApplicationCustomPropertiesPropertyKey);
}


- (void)setCustomProperties:(NSDictionary *)customProperties
{
    objc_setAssociatedObject(self, &MASApplicationCustomPropertiesPropertyKey, customProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSString *accessToken = accessService.currentAccessObj.accessToken;
    NSString *refreshToken = accessService.currentAccessObj.refreshToken;
    NSString *idToken = accessService.currentAccessObj.idToken;
    NSNumber *expiresIn = accessService.currentAccessObj.expiresIn;
    NSDate *expiresInDate = accessService.currentAccessObj.expiresInDate;
    
    //DLog(@"\n\n  access token: %@\n  refresh token: %@\n  expiresIn: %@, expires in date: %@\n\n",
    //    accessToken, refreshToken, expiresIn, expiresInDate);
    
    //
    // if accessToken, refreshToken, and exprieDate values exist, we understand that the user is authenticated with username and password
    //
    if (accessToken && refreshToken && expiresIn)
    {
        currentStatus = MASAuthenticationStatusLoginWithUser;
    }
    //
    // if refreshToken is missing, the user has been authenticated anonymously
    //
    else if (accessToken && expiresIn){
        currentStatus = MASAuthenticationStatusLoginAnonymously;
    }
    
    //
    // Then check if expiration has passed
    //
    if (([expiresInDate timeIntervalSinceNow] <= 0))
    {
        currentStatus = MASAuthenticationStatusNotLoggedIn;
        [accessService.currentAccessObj deleteForTokenExpiration];
    }
    
    if (refreshToken || (idToken && [MASAccessService validateIdToken:idToken magIdentifier:[accessService getAccessValueStringWithType:MASAccessValueTypeMAGIdentifier] error:nil]))
    {
        currentStatus = MASAuthenticationStatusLoginWithUser;
    }
    
    //DLog(@"\n\nNOW date is: %@, expiration date is: %@ and interval since now: %f\n\n",
    //    [NSDate date], expiresInDate, [expiresInDate timeIntervalSinceNow]);
    
    return currentStatus;
}


#pragma clang diagnostic pop


# pragma mark - Private

+ (NSDate *)expirationAsDate
{
    //
    // Obtain key chain item
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSNumber *clientExpiration = [accessService getAccessValueNumberWithType:MASAccessValueTypeClientExpiration];
    if(!clientExpiration)
    {
        return nil;
    }
    
    //DLog(@"clientSecret expiration date: %@",[NSDate dateWithTimeIntervalSince1970:[clientExpiration doubleValue]]);
    
    return [NSDate dateWithTimeIntervalSince1970:[clientExpiration doubleValue]];
}


# pragma mark - Public

- (NSString *)clientAuthorizationBasicHeaderValue
{
    //DLog(@"called and client key is: %@ and secret is: %@", key, secret);
    
    //
    // Access Service
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSString *clientId = [accessService getAccessValueStringWithType:MASAccessValueTypeClientId];
    NSString *clientSecret = [accessService getAccessValueStringWithType:MASAccessValueTypeClientSecret];

    NSString *clientAuthStr = [NSString stringWithFormat:@"%@:%@", clientId, clientSecret];
    NSData *clientAuthData = [clientAuthStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"Basic %@", [clientAuthData base64EncodedStringWithOptions:0]];
}


- (BOOL)isExpired
{
    BOOL isExpired = YES;
    
    //
    // Obtain key chain items
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    NSNumber *clientExpiration = [accessService getAccessValueNumberWithType:MASAccessValueTypeClientExpiration];
    NSString *clientId = [accessService getAccessValueStringWithType:MASAccessValueTypeClientId];
    NSString *clientSecret = [accessService getAccessValueStringWithType:MASAccessValueTypeClientSecret];

    //
    // Expiration is nil, then it is considered expired
    //
    if(!clientExpiration)
    {
        isExpired = YES;
    }
    
    //
    // If the value is zero AND both the client id and secret are set then it is not expired and
    // the expiry is actually infinite
    //
    else if([clientExpiration doubleValue] == 0 && clientId && clientSecret)
    {
        isExpired = NO;
    }
    
    //
    // If a positive time interval remains compared to the current time and date then it is not expired
    //
    else if([[MASApplication expirationAsDate] timeIntervalSinceNow] > 0)
    {
        isExpired = NO;
    }
    
    //DLog(@"called and is registered: %@ and is expired: %@",
    //    (_isRegistered ? @"Yes" : @"No"),
    //    (isExpired ? @"Yes" : @"No"));
    
    return isExpired;
}



- (NSString *)authenticationStatusAsString
{
    //
    // Detect status and respond appropriately
    //
    switch([self authenticationStatus])
    {
            //
            // Not Logged In
            //
        case MASAuthenticationStatusNotLoggedIn: return @"Application has not been authenticated";
            
            //
            // Login with User
            //
        case MASAuthenticationStatusLoginWithUser: return @"Application has been authenticated with specific user";
            
            //
            // Login anonymously
            //
        case MASAuthenticationStatusLoginAnonymously: return @"Application has been authenticated with anonymous user";
            
            //
            // Default
            //
        default: return @"Unknown";
    }
}



# pragma mark - Scope

- (NSString *)scopeTypeToString:(MASScopeType)scopeType
{
    //
    // Detect type and respond appropriately
    //
    switch(scopeType)
    {
        //
        // OpenId
        //
        case MASScopeTypeOpenId: return MASScopeValueOpenId;
    
        //
        // Address
        //
        case MASScopeTypeAddress: return MASScopeValueAddress;
        
        //
        // Email
        //
        case MASScopeTypeEmail: return MASScopeValueEmail;
        
        //
        // Phone
        //
        case MASScopeTypePhone: return MASScopeValuePhone;
    
        //
        // Profile
        //
        case MASScopeTypeProfile: return MASScopeValueProfile;
    
        //
        // UserRole
        //
        case MASScopeTypeUserRole: return MASScopeValueUserRole;

        //
        // Msso
        //
        case MASScopeTypeMsso: return MASScopeValueMsso;
        
        //
        // Msso Client Register
        //
        MASScopeValueMssoClientRegister: return MASScopeValueMssoClientRegister;
        
        //
        // Msso Register
        //
        MASScopeValueMssoRegister: return MASScopeValueMssoRegister;
        
        //
        // Default (Unknown)
        //
        default: return MASScopeValueUnknown;
    }
}


- (BOOL)isScopeTypeOpenIdSupported
{
    return ([self.scopeAsString rangeOfString:MASScopeValueOpenId].location != NSNotFound);
}


- (BOOL)isScopeTypeAddressSupported
{
    return ([self isScopeTypeOpenIdSupported] && ([self.scopeAsString rangeOfString:MASScopeValueAddress].location != NSNotFound));
}


- (BOOL)isScopeTypeEmailSupported
{
    return ([self isScopeTypeOpenIdSupported] && ([self.scopeAsString rangeOfString:MASScopeValueEmail].location != NSNotFound));
}


- (BOOL)isScopeTypePhoneSupported
{
    return ([self isScopeTypeOpenIdSupported] && ([self.scopeAsString rangeOfString:MASScopeValuePhone].location != NSNotFound));
}


- (BOOL)isScopeTypeProfileSupported
{
    return ([self isScopeTypeOpenIdSupported] && ([self.scopeAsString rangeOfString:MASScopeValueProfile].location != NSNotFound));
}

- (BOOL)isScopeTypeUserRoleSupported
{
    return ([self.scopeAsString rangeOfString:MASScopeValueUserRole].location != NSNotFound);
}


- (BOOL)isScopeTypeMssoSupported
{
    //DLog(@"\n\nscopeAsString is: %@ ... openId is supported: %@ and msso is found: %@",
    //    self.scopeAsString,
    //    ([self isScopeTypeOpenIdSupported] ? @"Yes" : @"No"),
    //    (([self.scopeAsString rangeOfString:MASScopeValueMsso].location != NSNotFound) ? @"Yes" : @"No"));
    
    return ([self isScopeTypeOpenIdSupported] && ([self.scopeAsString rangeOfString:MASScopeValueMsso].location != NSNotFound));
}


- (BOOL)isScopeTypeMssoClientRegisterSupported
{
    return ([self isScopeTypeMssoSupported] && ([self.scopeAsString rangeOfString:MASScopeValueMssoClientRegister].location != NSNotFound));
}


- (BOOL)isScopeTypeMssoRegisterSupported
{
    return ([self isScopeTypeMssoSupported] && ([self.scopeAsString rangeOfString:MASScopeValueMssoRegister].location != NSNotFound));
}

@end
