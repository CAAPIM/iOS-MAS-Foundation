//
//  MASUser+MASPrivate.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASUser+MASPrivate.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MASAccessService.h"
#import "MASConstantsPrivate.h"
#import "MASIKeyChainStore.h"


# pragma mark - Property Constants

static NSString *const MASUserObjectIdPropertyKey = @"objectId"; // string
static NSString *const MASUserUserNamePropertyKey = @"userName"; // string
static NSString *const MASUserFamilyNamePropertyKey = @"familyName"; // string
static NSString *const MASUserGivenNamePropertyKey = @"givenName"; // string
static NSString *const MASUserFormattedNamePropertyKey = @"formattedName"; // string
static NSString *const MASUserEmailAddressesPropertyKey = @"emailAddresses"; // string
static NSString *const MASUserPhoneNumbersPropertyKey = @"phoneNumbers"; // string
static NSString *const MASUserAddressesPropertyKey = @"addresses"; // string
static NSString *const MASUserPhotosPropertyKey = @"photos"; // string
static NSString *const MASUserGroupsPropertyKey = @"groups"; // string
static NSString *const MASUserActivePropertyKey = @"active"; // bool
static NSString *const MASUserAttributesPropertyKey = @"attributes";

@implementation MASUser (MASPrivate)


# pragma mark - Lifecycle

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if(self)
    {
        [self saveWithUpdatedInfo:info];
    }
    
    return self;
}


+ (MASUser *)instanceFromStorage
{
    //DLog(@"n\ncalled\n\n");
    
    MASUser *user;
    
    //
    // Attempt to retrieve from keychain
    //
    NSData *data = [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString accessGroup:[MASAccessService sharedService].accessGroup] dataForKey:[MASUser.class description]];
    if(data)
    {
        user = (MASUser *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return user;
}


- (void)saveToStorage
{
    //DLog(@"\n\ncalled\n\n");
    
    //
    // Save to the keychain
    //
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if(data)
    {
        NSError *error;
        [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString accessGroup:[MASAccessService sharedService].accessGroup] setData:data
                                                                                                                         forKey:[self.class description]
                                                                                                                          error:&error];
    
        if(error)
        {
            //DLogTVOS(@"\n\nError attempting to save data: %@\n\n", [error localizedDescription]);
        }
    }
    
    //DLog(@"\n\nstored user(x): %@\n\n", [self debugDescription]);
}


- (void)saveWithUpdatedInfo:(NSDictionary *)info
{
    //DLog(@"\n\ncalled with info: %@\n\n", info);
    
    NSAssert(info, @"info cannot be nil");
   
    //
    // Keychain
    //
    MASAccessService *accessService = [MASAccessService sharedService];
    
    //
    // Body Info
    //
    NSDictionary *bodyInfo = info[MASResponseInfoBodyInfoKey];
    
    //
    // Uid --> ObjectId
    //
    NSString *uid = bodyInfo[MASUserPreferredNameRequestResponseKey];
    if(uid && ![uid isKindOfClass:[NSNull class]]) self.objectId = uid;
    
    //
    // Preferred UserName
    //
    NSString *userName = bodyInfo[MASUserPreferredNameRequestResponseKey];
    if(userName && ![userName isKindOfClass:[NSNull class]]) self.userName = userName;
    
    //
    // Family Name
    //
    NSString *familyName = bodyInfo[MASUserFamilyNameRequestResponseKey];
    self.familyName = (familyName && ![familyName isKindOfClass:[NSNull class]] ?
        familyName : nil);
    
    //
    // Given Name
    //
    NSString *givenName = bodyInfo[MASUserGivenNameRequestResponseKey];
    self.givenName = (givenName && ![givenName isKindOfClass:[NSNull class]] ?
        givenName : @"");

    //
    // Formatted Name
    //
    NSMutableString *mutableCopy = [NSMutableString new];
    
    // Given name, if any
    if(self.givenName && ![self.givenName isKindOfClass:[NSNull class]]) [mutableCopy appendString:self.givenName];
    
    // Family name, if any
    if(self.familyName && ![self.familyName isKindOfClass:[NSNull class]])
    {
        // Check if there was a given name first, if so add a space
        if(mutableCopy.length > 0) [mutableCopy appendString:MASDefaultEmptySpace];
        
        [mutableCopy appendString:self.familyName];
    }
    
    if(mutableCopy.length > 0) self.formattedName = mutableCopy;
    
    //
    // Email Addresses
    //
    NSString *emailValue = bodyInfo[MASUserEmailRequestResponseKey];
    if(emailValue && ![emailValue isKindOfClass:[NSNull class]])
    {
        self.emailAddresses = @{ MASInfoTypeWork : emailValue };
    }
    
    //
    // Phone Numbers
    //
    NSString *phoneValue = bodyInfo[MASUserPhoneRequestResponseKey];
    if(phoneValue && ![phoneValue isKindOfClass:[NSNull class]])
    {
        self.phoneNumbers = @{ MASInfoTypeWork : phoneValue };
    }
    
    //
    // Addresses
    //
    NSDictionary *addressInfo = bodyInfo[MASUserAddressRequestResponseKey];
    if(addressInfo && ![addressInfo isKindOfClass:[NSNull class]])
    {
        self.addresses = @{ MASInfoTypeWork : addressInfo };
    }
    
    //
    // Picture
    //
    NSString *imageUriAsString = bodyInfo[MASUserPictureRequestResponseKey];
    if(imageUriAsString && ![imageUriAsString isKindOfClass:[NSNull class]])
    {
        NSURL *imageUrl = [NSURL URLWithString:imageUriAsString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        self.photos = @{ MASInfoTypeThumbnail : [UIImage imageWithData:imageData] };
    }
    
    //
    // set authenticated timestamp
    //
    NSNumber *authenticatedTimestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    [accessService setAccessValueNumber:authenticatedTimestamp withAccessValueType:MASAccessValueTypeAuthenticatedTimestamp];
    
    //
    // set authenticated user's objectId
    //
    [accessService setAccessValueString:self.objectId withAccessValueType:MASAccessValueTypeAuthenticatedUserObjectId];
    
    //
    // storing access information into keychain
    //
    [accessService saveAccessValuesWithDictionary:bodyInfo forceToOverwrite:NO];
    
    
    //
    // All attributes as dictionary
    //
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    
    //
    // Save to the keychain
    //
    [self saveToStorage];
}


- (void)reset
{
    [self resetPartial];
    
    [[MASIKeyChainStore keyChainStoreWithService:[MASConfiguration currentConfiguration].gatewayUrl.absoluteString] removeItemForKey:[self.class description]];
}

- (void)resetPartial
{
    //
    // resetting all current access information
    //
    [[MASAccessService sharedService].currentAccessObj deleteForLogOff];
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
    [super encodeWithCoder:aCoder];
    
    if(self.userName) [aCoder encodeObject:self.userName forKey:MASUserUserNamePropertyKey];
    if(self.familyName) [aCoder encodeObject:self.familyName forKey:MASUserFamilyNamePropertyKey];
    if(self.givenName) [aCoder encodeObject:self.givenName forKey:MASUserGivenNamePropertyKey];
    if(self.formattedName) [aCoder encodeObject:self.formattedName forKey:MASUserFormattedNamePropertyKey];
    if(self.emailAddresses) [aCoder encodeObject:self.emailAddresses forKey:MASUserEmailAddressesPropertyKey];
    if(self.phoneNumbers) [aCoder encodeObject:self.phoneNumbers forKey:MASUserPhoneNumbersPropertyKey];
    if(self.addresses) [aCoder encodeObject:self.addresses forKey:MASUserAddressesPropertyKey];
    if(self.photos) [aCoder encodeObject:self.photos forKey:MASUserPhotosPropertyKey];
    if(self.groups) [aCoder encodeObject:self.groups forKey:MASUserGroupsPropertyKey];
    if(self.active) [aCoder encodeBool:self.active forKey:MASUserActivePropertyKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //DLog(@"\n\ncalled\n\n");
    
    if(self = [super initWithCoder:aDecoder])
    {
        self.userName = [aDecoder decodeObjectForKey:MASUserUserNamePropertyKey];
        self.familyName = [aDecoder decodeObjectForKey:MASUserFamilyNamePropertyKey];
        self.givenName = [aDecoder decodeObjectForKey:MASUserGivenNamePropertyKey];
        self.formattedName = [aDecoder decodeObjectForKey:MASUserFormattedNamePropertyKey];
        self.emailAddresses = [aDecoder decodeObjectForKey:MASUserEmailAddressesPropertyKey];
        self.phoneNumbers = [aDecoder decodeObjectForKey:MASUserPhoneNumbersPropertyKey];
        self.addresses = [aDecoder decodeObjectForKey:MASUserAddressesPropertyKey];
        self.photos = [aDecoder decodeObjectForKey:MASUserPhotosPropertyKey];
        self.groups = [aDecoder decodeObjectForKey:MASUserGroupsPropertyKey];
        self.active = [aDecoder decodeBoolForKey:MASUserActivePropertyKey];
    }
    
    return self;
}


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)isCurrentUser
{
    //
    // Get currently authenticated user's object id to make sure that isCurrentUser flag can be determined properly for other users
    //
    NSString *currentlyAuthenticatedUserObjectId = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeAuthenticatedUserObjectId];

    return [self.objectId isEqualToString:currentlyAuthenticatedUserObjectId];
}


// Special case which is determined by other fields
- (BOOL)isAuthenticated
{
//    DLog(@"\n\ncalled and current user status is: %@ so returning: %@\n\n",
//        [self userStatusAsString], ([self status] != MASUserStatusNotLoggedIn) ? @"Yes" : @"No");
    
    //
    // Get currently authenticated user's object id to make sure that isAuthenticated flag can be determined properly for other users
    //
    NSString *currentlyAuthenticatedUserObjectId = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeAuthenticatedUserObjectId];
    
    //
    // if the user status is not MASUserStatusNotLoggedIn,
    // the user is authenticated either anonymously or with username and password
    //
    return ([MASApplication currentApplication].authenticationStatus == MASAuthenticationStatusLoginWithUser && [self.objectId isEqualToString:currentlyAuthenticatedUserObjectId]);
}


- (BOOL)isSessionLocked
{
    
    //
    // Get currently authenticated user's object id to make sure that isAuthenticated flag can be determined properly for other users
    //
    NSString *currentlyAuthenticatedUserObjectId = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeAuthenticatedUserObjectId];
    
    if ([self.objectId isEqualToString:currentlyAuthenticatedUserObjectId])
    {
        return [MASAccess currentAccess].isSessionLocked;
    }
    else {
        return NO;
    }
}


- (NSString *)objectId
{
    return objc_getAssociatedObject(self, &MASUserObjectIdPropertyKey);
}


- (void)setObjectId:(NSString *)objectId
{
    objc_setAssociatedObject(self, &MASUserObjectIdPropertyKey, objectId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)userName
{
    return objc_getAssociatedObject(self, &MASUserUserNamePropertyKey);
}


- (void)setUserName:(NSString *)userName
{
    objc_setAssociatedObject(self, &MASUserUserNamePropertyKey, userName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)familyName
{
    return objc_getAssociatedObject(self, &MASUserFamilyNamePropertyKey);
}


- (void)setFamilyName:(NSString *)familyName
{
    objc_setAssociatedObject(self, &MASUserFamilyNamePropertyKey, familyName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)givenName
{
    return objc_getAssociatedObject(self, &MASUserGivenNamePropertyKey);
}


- (void)setGivenName:(NSString *)givenName
{
    objc_setAssociatedObject(self, &MASUserGivenNamePropertyKey, givenName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)formattedName
{
    return objc_getAssociatedObject(self, &MASUserFormattedNamePropertyKey);
}


- (void)setFormattedName:(NSString *)formattedName
{
    objc_setAssociatedObject(self, &MASUserFormattedNamePropertyKey, formattedName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)emailAddresses
{
    return objc_getAssociatedObject(self, &MASUserEmailAddressesPropertyKey);
}


- (void)setEmailAddresses:(NSDictionary *)emailAddresses
{
    objc_setAssociatedObject(self, &MASUserEmailAddressesPropertyKey, emailAddresses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)phoneNumbers
{
    return objc_getAssociatedObject(self, &MASUserPhoneNumbersPropertyKey);
}


- (void)setPhoneNumbers:(NSDictionary *)phoneNumbers
{
    objc_setAssociatedObject(self, &MASUserPhoneNumbersPropertyKey, phoneNumbers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)addresses
{
    return objc_getAssociatedObject(self, &MASUserAddressesPropertyKey);
}


- (void)setAddresses:(NSDictionary *)addresses
{
    objc_setAssociatedObject(self, &MASUserAddressesPropertyKey, addresses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)photos
{
    return objc_getAssociatedObject(self, &MASUserPhotosPropertyKey);
}


- (void)setPhotos:(NSDictionary *)photos
{
    objc_setAssociatedObject(self, &MASUserPhotosPropertyKey, photos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSArray *)groups
{
    return objc_getAssociatedObject(self, &MASUserGroupsPropertyKey);
}


- (void)setGroups:(NSArray *)groups
{
    objc_setAssociatedObject(self, &MASUserGroupsPropertyKey, groups, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)active
{
    NSNumber *activeNumber = objc_getAssociatedObject(self, &MASUserActivePropertyKey);
    
    return [activeNumber boolValue];
}


- (void)setActive:(BOOL)active
{
    objc_setAssociatedObject(self, &MASUserActivePropertyKey, [NSNumber numberWithBool:active], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)_attributes
{
    return objc_getAssociatedObject(self, &MASUserAttributesPropertyKey);
}

- (void)set_attributes:(NSDictionary *)attributes
{
    objc_setAssociatedObject(self, &MASUserAttributesPropertyKey, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setWasLoggedOffAndSave:(BOOL)wasLoggedOff
{
    
    //
    // If was logged off remove the keychain stored values
    //
    if(wasLoggedOff) [self resetPartial];
    
    //
    // Save
    //
    [self saveToStorage];
}


- (NSString *)accessToken
{
    NSString *accessToken = [MASAccessService sharedService].currentAccessObj.accessToken;
    
    if (accessToken)
    {
        return accessToken;
    }
    else {
        return nil;
    }
}


#pragma clang diagnostic pop


# pragma mark - Public

+ (NSString *)authorizationBasicHeaderValueWithUsername:(NSString *)userName
                                               password:(NSString *)password
{
    //DLog(@"called and userName: %@ and password: %@", userName, password);
   
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", userName, password];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
}


+ (NSString *)authorizationBearerWithAccessToken
{
    return [NSString stringWithFormat:@"Bearer %@", [MASAccessService sharedService].currentAccessObj.accessToken];
}


@end
