//
//  MASFileObject.h
//  MASFoundation
//
//  Created by nimma01 on 27/08/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MASFileObject : NSObject

@property (nonatomic, strong, readonly) NSString *filePath;
@property (nonatomic, strong, readonly) NSURL* fileURL;

- (instancetype)initWithFilePath:(NSString*)filePath;

@end

NS_ASSUME_NONNULL_END
