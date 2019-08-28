//
//  MASFileObject.m
//  MASFoundation
//
//  Created by nimma01 on 27/08/19.
//  Copyright © 2019 CA Technologies. All rights reserved.
//

#import "MASFileObject.h"

@interface MASFileObject ()
@property (nonatomic, readwrite) NSString* filePath;
@property (nonatomic, readwrite) NSURL* fileURL;

@end

@implementation MASFileObject

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"init is not a valid initializer, please use a factory method"
                                 userInfo:nil];
    return nil;
}


- (instancetype)initWithFileURL: (NSURL *)fileURL
{
    self = [super init];
    if(self) {
        _fileURL = fileURL;
    }
    
    return self;
}

- (instancetype)initWithFilePath:(NSString*)filePath
{
    self = [super init];
    if(self) {
        _filePath = filePath;
        _fileURL = [NSURL fileURLWithPath:_filePath];
    }
    
    return self;
}
@end
