//
//  MASApplication+MASPrivate.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>



///--------------------------------------
/// @name Scope Types
///--------------------------------------

# pragma mark - Scope Types

/**
 * The enumerated MASScopeTypes
 */
typedef NS_ENUM(NSInteger, MASScopeType)
{
    /**
     * Unknown type in case a value is received that is not currently supported
     */
    MASScopeTypeUnknown = -1,
    
    /**
     * This SCOPE will enable clients to send requests to the /userinfo endpoint. 
     * Additionally this SCOPE causes the server to issue an id_token which can be 
     * used within the context of 'Mobile SSO'
     */
    MASScopeTypeOpenId,
    
    /**
     * This SCOPE will return the address information of the current user. It has to be requested with the 'openid' SCOPE.
     */
    MASScopeTypeAddress,
    
    /**
     * This SCOPE will return the email information of the current user. It has to be requested with the 'openid' SCOPE.
     */
    MASScopeTypeEmail,
    
    /**
     * This SCOPE will return the telephone information of the current user. It has to be requested with the 'openid' SCOPE.
     */
    MASScopeTypePhone,
    
    /**
     * This SCOPE will return the profile information of the current user. It has to be requested with the 'openid' SCOPE.
     */
    MASScopeTypeProfile,
    
    /** 
     * This SCOPE will return the role of the resource_owner. By default it will be 'user' or 'admin'. The role 'admin' 
     * is used in MAG Manager to identify an administrator. It has to be requested with the ‘openid’ SCOPE.
     */
    MASScopeTypeUserRole,
    
    /** 
     * This SCOPE is available within the context of 'Mobile SSO' and only with 'grant_type=password'. 
     *
     * Clients have to be registered for 'openid' and 'msso' in order to use it. Clients requesting an access_token using 
     * this SCOPE will additionally receive an id_token. 
     * 
     * This is how 'SSO' on devices is turned on/ off.
     */
    MASScopeTypeMsso,

    /** 
     * This SCOPE is available within the context of 'Mobile SSO' to register a device with client credentials only, not 
     * user credentials.
     *
     * A client that has to be able to register a device on its own behalf has to be registered for this SCOPE.
     */
    MASScopeTypeMssoClientRegister,
    
    /** 
     * This SCOPE is available within the context of 'Mobile SSO' to register a device using social login credentials.
     *
     * A client that must be registered with this SCOPE to be able to register a device using social login credentials.
     *
     * An authorization_code that was granted for this SCOPE cannot be used for anything other than registering a device.
     */
    MASScopeTypeMssoRegister,
    
    /**
     * The total count of the available SCOPE types.
     */
    MASScopeTypeCount
};

static NSString *const MASScopeValueUnknown = @"unknown";
static NSString *const MASScopeValueOpenId = @"openid";
static NSString *const MASScopeValueAddress = @"address";
static NSString *const MASScopeValueEmail = @"email";
static NSString *const MASScopeValuePhone = @"phone";
static NSString *const MASScopeValueProfile = @"profile";
static NSString *const MASScopeValueUserRole = @"user_role";

static NSString *const MASScopeValueMsso = @"msso";
static NSString *const MASScopeValueMssoClientRegister = @"msso_client_register";
static NSString *const MASScopeValueMssoRegister = @"msso_register";



@interface MASApplication (MASPrivate)
    <NSCoding>



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

@property (nonatomic, assign, readonly) MASAuthenticationStatus authenticationStatus;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 * Initializer to perform a default initialization.
 *
 * @return Returns the newly initialized MASApplication.
 */
- (id)initWithConfiguration;


/**
 * Retrieves the instance of MASApplication from local storage, it it exists.
 *
 * @return Returns the newly initialized MASApplication or nil if none was stored.
 */
+ (MASApplication *)instanceFromStorage;


/**
 * Save the current MASApplication instance with newly provided information.
 *
 * @param info An NSDictionary containing newly provided information.
 */
- (void)saveWithUpdatedInfo:(NSDictionary *)info;


/**
 * Remove all traces of the current application.
 */
- (void)reset;


/**
 * Initializer to perform an enterprise app initialization
 *
 * @return Returns the newly initialized MASApplication.
 */
- (id)initWithEnterpriseInfo:(NSDictionary *)info;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 * Retrieves the client authorization header formatted with the
 * available clientId and clientSecret values.
 *
 * This is formatted as: 'Basic <clientId:clientSecret>' with the <...> base64 encoded.
 *
 * @return Returns the value as partially Base64 encoded NSString.
 */
- (NSString *)clientAuthorizationBasicHeaderValue;


/**
 * Returns a simple BOOL YES or NO if the existing credentials of the MASAppication are
 * found to be expired per the clientExpiration date compared to the current date.
 *
 * @return Returns YES if expired, NO if not.
 */
- (BOOL)isExpired;



/**
 * Retrieve the current MASAuthenticationStatus as a human readable string.
 *
 * @return NSString.
 */
- (NSString *)authenticationStatusAsString;



///--------------------------------------
/// @name Scope
///--------------------------------------

# pragma mark - Scope

/**
 * Is the 'openid' SCOPE supported by the application.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeOpenIdSupported;


/**
 * Is the 'address' SCOPE supported by the application. The 'openid. SCOPE must also be supported
 * and is checked internally.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeAddressSupported;


/**
 * Is the 'email' SCOPE supported by the application. The 'openid' SCOPE must also be supported
 * and is checked internally.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeEmailSupported;


/**
 * Is the 'phone' SCOPE supported by the application. The 'openid' SCOPE must also be supported
 * and is checked internally.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypePhoneSupported;


/**
 * Is the 'profile' SCOPE supported by the application. The 'openid' SCOPE must also be supported
 * and is checked internally.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeProfileSupported;


/**
 * Is the 'user_role' SCOPE supported by the application.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeUserRoleSupported;


/**
 * Is the 'msso' SCOPE supported by the application. The 'openid' SCOPE must also be supported
 * and is checked internally.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeMssoSupported;


/**
 * Is the 'msso_client_register' SCOPE supported by the application. The 'openid' SCOPE AND the
 * 'msso' scope must also be supported and are checked internally.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeMssoClientRegisterSupported;


/**
 * Is the 'msso_register' SCOPE supported by the application. The 'openid' SCOPE AND the
 * 'msso' scope must also be supported and are checked internally.
 *
 * @returns Returns YES if so, NO if not.
 */
- (BOOL)isScopeTypeMssoRegisterSupported;


/**
 * Retrieve the string value of the MASScopeType.
 */
- (NSString *)scopeTypeToString:(MASScopeType)scopeType;

@end
