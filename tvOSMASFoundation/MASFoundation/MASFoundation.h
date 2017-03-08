//
//  MASFoundation.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <UIKit/UIKit.h>

//! Project version number for MASFoundation.
FOUNDATION_EXPORT double MASFoundationVersionNumber;

//! Project version string for MASFoundation.
FOUNDATION_EXPORT const unsigned char MASFoundationVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MASFoundation/PublicHeader.h>

//
// Top Level
//

#import <MASFoundation/MAS.h>
#import <MASFoundation/MASConstants.h>
#import <MASFoundation/MASProximityLoginDelegate.h>
#import <MASFoundation/MASService.h>


//
// MQTT
//

#import <MASFoundation/MASMQTTClient.h>
#import <MASFoundation/MASMQTTMessage.h>
#import <MASFoundation/MASMQTTConstants.h>

//
// Models
//

#import <MASFoundation/MASApplication.h>
#import <MASFoundation/MASAuthenticationProvider.h>
#import <MASFoundation/MASAuthenticationProviders.h>
#import <MASFoundation/MASConfiguration.h>
#import <MASFoundation/MASDevice.h>
#import <MASFoundation/MASFile.h>
#import <MASFoundation/MASGroup.h>
#import <MASFoundation/MASObject.h>
#import <MASFoundation/MASUser.h>
#import <MASFoundation/MASSocialLogin.h>
#import <MASFoundation/MASProximityLogin.h>
#import <MASFoundation/MASProximityLoginQRCode.h>

//
// Categories
//

#import <MASFoundation/NSData+MAS.h>
