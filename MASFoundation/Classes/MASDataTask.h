//
//  MASDataTask.h
//  MASFoundation
//
//  Created by nimma01 on 28/11/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
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
