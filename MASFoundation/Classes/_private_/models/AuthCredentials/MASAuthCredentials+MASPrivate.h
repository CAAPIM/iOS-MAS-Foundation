//
//  MASAuthCredentials+MASPrivate.h
//  MASFoundation
//
//  Created by Hun Go on 2017-05-31.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import "MASAuthCredentials.h"

@interface MASAuthCredentials (MASPrivate)

- (instancetype)initPrivate;


- (void)registerDeviceWithCredential:(MASCompletionErrorBlock _Nullable)completion;



- (void)loginWithCredential:(MASCompletionErrorBlock _Nullable)completion;

@end
