//
//  MASDataTask.h
//  MASFoundation
//
//  Copyright © 2019 CA Technologies. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MASDataTask : NSObject
{
    
}

@property(readonly)NSString* taskID;


- (void)cancel;

@end

NS_ASSUME_NONNULL_END
