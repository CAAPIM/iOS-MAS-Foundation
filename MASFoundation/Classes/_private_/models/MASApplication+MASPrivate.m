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
#import "MASModelService.h"

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
        [self setValue:[configuration applicationOrganization] forKey:@"organization"];
        [self setValue:[configuration applicationName] forKey:@"name"];
        [self setValue:[configuration applicationDescription] forKey:@"detailedDescription"];
        
        [self setValue:info[MASClientIdentifierRequestResponseKey] forKey:@"identifier"];
        [self setValue:info[MASEnvironmentRequestResponseKey] forKey:@"environment"];
        [self setValue:info[MASRegisteredByRequestResponseKey] forKey:@"registeredBy"];
        
        [self setValue:info[MASScopeRequestResponseKey] forKey:@"scope"];
        [self setValue:info[MASScopeRequestResponseKey] forKey:@"scopeAsString"];
        [self setValue:info[MASStatusRequestResponseKey] forKey:@"status"];
        
        [self setValue:(info[MASRedirectUriRequestResponseKey] ?
                        [NSURL URLWithString:info[MASRedirectUriRequestResponseKey]] :
                        nil) forKey:@"redirectUri"];

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

    return self;
}

+ (MASApplication *)instanceFromStorage
{
    //DLog(@"\n\ncalled%@\n\n");
    
    MASApplication *application;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] dataForKey:[MASApplication.class description]];
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
    [application setValue:[configuration applicationOrganization] forKey:@"organization"];
    [application setValue:[configuration applicationName] forKey:@"name"];
    [application setValue:[configuration applicationDescription] forKey:@"detailedDescription"];
    
    [application setValue:info[MASClientIdentifierRequestResponseKey] forKey:@"identifier"];
    [application setValue:info[MASEnvironmentRequestResponseKey] forKey:@"environment"];
    [application setValue:info[MASRegisteredByRequestResponseKey] forKey:@"registeredBy"];
    
    [application setValue:info[MASScopeRequestResponseKey] forKey:@"scope"];
    [application setValue:info[MASScopeRequestResponseKey] forKey:@"scopeAsString"];
    [application setValue:info[MASStatusRequestResponseKey] forKey:@"status"];
    
    [application setValue:(info[MASRedirectUriRequestResponseKey] ?
                    [NSURL URLWithString:info[MASRedirectUriRequestResponseKey]] :
                    nil) forKey:@"redirectUri"];

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
        [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] setData:data
                                                                                                                         forKey:[MASApplication.class description]
                                                                                                                          error:&error];
    
        if(error)
        {
            //DLog(@"Error attempting to save data: %@", [error localizedDescription]);
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
    
    [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] removeItemForKey:[MASApplication.class description]];
}


- (id)initWithEnterpriseInfo:(NSDictionary *)info
{
    //DLog(@"\n\ncalled with info: %@\n\n", info);
    
    self = [super init];
    if(self)
    {
        [self setValue:info[MASApplicationIdRequestResponseKey] forKey:@"identifier"];
        [self setValue:info[MASApplicationNameRequestResponseKey] forKey:@"name"];
        [self setValue:info[MASApplicationAuthUrlRequestResponseKey] forKey:@"authUrl"];
        [self setValue:info[MASApplicationIconUrlRequestResponseKey] forKey:@"iconUrl"];
        [self setValue:info[MASApplicationNativeUrlRequestResponseKey] forKey:@"nativeUrl"];
        [self setValue:info[MASApplicationCustomRequestResponseKey] forKey:@"customProperties"];
    }
    
    return self;
}


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
