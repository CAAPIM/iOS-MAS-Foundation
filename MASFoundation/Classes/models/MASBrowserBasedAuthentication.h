//
//  MASBrowserBasedAuthentication.h
//  MASFoundation
//
//  Created by nimma01 on 20/11/17.
//  Copyright © 2017 CA Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASConstants.h"

@interface MASBrowserBasedAuthentication : NSObject
{
    
}


/**
 * Retrieve the shared MASBrowserBasedAuthentication singleton.
 *
 * @return Returns the shared MASBrowserBasedAuthentication singleton.
 */
+ (instancetype)sharedInstance;



/**
 * Method to load the browser with a URL that loads a templatized login page.
 *
 * @param webLoginBlock completion MASCompletionErrorBlock that receives the results.
 */
-(void)loadWebLoginTemplate : (MASAuthCredentialsBlock)webLoginBlock;

@end
