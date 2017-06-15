//
//  MASAuthCredentials.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASObject.h"

@interface MASAuthCredentials : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties

/**
 *  Authentication credential type.
 */
@property (nonatomic, assign, readonly) NSString *credentialsType;



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
