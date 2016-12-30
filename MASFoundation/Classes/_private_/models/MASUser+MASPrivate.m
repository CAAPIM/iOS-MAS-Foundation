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
            DLog(@"\n\nError attempting to save data: %@\n\n", [error localizedDescription]);
        }
    }
}


- (void)saveWithUpdatedInfo:(NSDictionary *)info
{
    DLog(@"\n\ncalled with info: %@\n\n", info);
    
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
    if(uid && ![uid isKindOfClass:[NSNull class]]) [self setValue:uid forKey:@"objectId"];
    
    //
    // Preferred UserName
    //
    NSString *userName = bodyInfo[MASUserPreferredNameRequestResponseKey];
    if(userName && ![userName isKindOfClass:[NSNull class]]) [self setValue:userName forKey:@"userName"];
    
    //
    // Family Name
    //
    NSString *familyName = bodyInfo[MASUserFamilyNameRequestResponseKey];
    [self setValue:(familyName && ![familyName isKindOfClass:[NSNull class]] ?
                    familyName : nil) forKey:@"familyName"];
    
    //
    // Given Name
    //
    NSString *givenName = bodyInfo[MASUserGivenNameRequestResponseKey];
    [self setValue:(givenName && ![givenName isKindOfClass:[NSNull class]] ?
                    givenName : @"") forKey:@"givenName"];

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
    
    if(mutableCopy.length > 0) [self setValue:mutableCopy forKey:@"formattedName"];
    
    //
    // Email Addresses
    //
    NSString *emailValue = bodyInfo[MASUserEmailRequestResponseKey];
    if(emailValue && ![emailValue isKindOfClass:[NSNull class]])
    {
        [self setValue:@{ MASInfoTypeWork : emailValue } forKey:@"emailAddresses"];
    }
    
    //
    // Phone Numbers
    //
    NSString *phoneValue = bodyInfo[MASUserPhoneRequestResponseKey];
    if(phoneValue && ![phoneValue isKindOfClass:[NSNull class]])
    {
        [self setValue:@{ MASInfoTypeWork : phoneValue } forKey:@"phoneNumbers"];
    }
    
    //
    // Addresses
    //
    NSDictionary *addressInfo = bodyInfo[MASUserAddressRequestResponseKey];
    if(addressInfo && ![addressInfo isKindOfClass:[NSNull class]])
    {
        [self setValue:@{ MASInfoTypeWork : addressInfo } forKey:@"addresses"];
    }
    
    //
    // Picture
    //
    NSString *imageUriAsString = bodyInfo[MASUserPictureRequestResponseKey];
    if(imageUriAsString && ![imageUriAsString isKindOfClass:[NSNull class]])
    {
        NSURL *imageUrl = [NSURL URLWithString:imageUriAsString];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        [self setValue:@{ MASInfoTypeThumbnail : [UIImage imageWithData:imageData] } forKey:@"photos"];
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
    [self setValue:[[NSMutableDictionary alloc] initWithDictionary:info] forKey:@"_attributes"];
//    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:info];
    
    
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


# pragma mark - Properties

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


# pragma mark - Public

+ (NSString *)authorizationBasicHeaderValueWithUsername:(NSString *)userName
                                               password:(NSString *)password
{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", userName, password];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
}


+ (NSString *)authorizationBearerWithAccessToken
{
    return [NSString stringWithFormat:@"Bearer %@", [MASAccessService sharedService].currentAccessObj.accessToken];
}


@end
