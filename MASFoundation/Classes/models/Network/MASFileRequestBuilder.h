//
//  MASFileRequestBuilder.h
//  MASFoundation
//
//  Created by nimma01 on 09/07/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>
#import "MASFileRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MASFileRequestBuilder : MASRequestBuilder

    
@property (nonatomic) NSString* boundary;

//@property (nonatomic)
/**
 Create a MASFileRequest object using the parameters from MASRequestBuider
 
 @return MASFileRequest object
 */
- (MASFileRequest *_Nullable)build;
    

    

@end

NS_ASSUME_NONNULL_END
