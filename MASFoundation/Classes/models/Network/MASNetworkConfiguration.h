//
//  MASNetworkConfiguration.h
//  MASFoundation
//
//  Created by yussy01 on 05/09/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import "MASObject.h"


@interface MASNetworkConfiguration : MASObject



///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties


/**
The NSTimeInterval value that specifies the global timeInterval of all the requests.
*/
@property (assign) NSTimeInterval timeoutInterval;



/**
 NSURL value of the target host.
 */
@property (nonatomic, strong, readonly, nonnull) NSURL *host;



///--------------------------------------
/// @name Lifecycle
///--------------------------------------

# pragma mark - Lifecycle

/**
 Designated initializer for MASNetworkConfiguration.

 @discussion default values for designated initializer are: timeoutInterval : 60.
 @param url NSURL of the target domain
 @return MASNetworkConfiguration object
 */
- (instancetype _Nonnull)initWithURL:(NSURL * _Nonnull)url NS_DESIGNATED_INITIALIZER;

@end
