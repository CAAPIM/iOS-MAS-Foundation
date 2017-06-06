//
//  MASAuthCredentials.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASObject.h"

@interface MASAuthCredentials : MASObject


/**
 *  MASAuthCredentialType enumeration type represents the authentication credential type of MAS SDK.
 */
typedef NS_ENUM(NSInteger, MASAuthCredentialsType) {
    
    /**
     *  MASAuthCredentialTypeClientCredential represents client credential auth credential type which is default flow of SDK.
     */
    MASAuthCredentialsTypeClientCredential = -1,
    
    /**
     *  MASAuthCredentialTypePassword represents username/password flow auth credential type.
     */
    MASAuthCredentialsTypePassword,
    
    /**
     *  MASAuthCredentialTypeAuthCode represents authorization code flow auth credential type.
     */
    MASAuthCredentialsTypeAuthCode,
    
    /**
     *  MASAuthCredentialTypeJWT represents JSON Web Token auth credential type.
     */
    MASAuthCredentialsTypeJWT,
    
    /**
     *  MASAuthCredentialTypeFIDO represents FIDO flow auth credential type.
     */
    MASAuthCredentialsTypeFIDO
};



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Authentication credential type.
 */
@property (nonatomic, assign, readonly) MASAuthCredentialsType credentialsType;



/**
 *  boolean indicator whether this particular auth credentials can be used for device registration.
 */
@property (nonatomic, assign, readonly) BOOL canRegisterDevice;



/**
 *  boolean indicator whether this particular auth credentials can be re-used.
 */
@property (nonatomic, assign, readonly) BOOL isReuseable;



///--------------------------------------
/// @name Public
///--------------------------------------

# pragma mark - Public

/**
 *  A method to clear stored credentials in memory.
 */
- (void)clearCredentials;

@end
