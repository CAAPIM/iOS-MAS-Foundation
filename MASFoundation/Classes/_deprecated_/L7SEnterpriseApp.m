//
//  L7SEnterpriseApps.m
//  sdkdemo
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "L7SEnterpriseApp.h"
#import "MASApplication.h"
#import "UIWebView+MASINetworking.h"
#import "L7SClientManager.h"
#import "L7SAFHTTPRequestOperation.h"
#import "L7SErrors.h"
#import "L7SHTTPClient.h"

@interface L7SEnterpriseApp ()<UIWebViewDelegate,MASEnterpriseAppProtocol> {
    NSString *_enterpriseID;
    NSString *_iconURL;
    NSString *_authURL;
    NSString *_nativeURL;
    UIWebView *_webView;
    
    id _webViewDelegate;
    
}
@property(nonatomic,retain)MASApplication *masAppInstance;
@end


@implementation L7SEnterpriseApp
@synthesize delegate;
@synthesize masAppInstance;

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _enterpriseID = [attributes valueForKeyPath:@"id"];
    _iconURL = [attributes valueForKeyPath:@"icon_url"];
    _authURL = [attributes valueForKeyPath:@"auth_url"];
    _nativeURL = [attributes valueForKeyPath:@"native_url"];
    _appId = [attributes valueForKeyPath:@"id"];
    _appName = [attributes valueForKeyPath:@"name"];
    
    _customFields = [attributes valueForKeyPath:@"custom"];
    
    return self;
}

#pragma mark -

+ (void)enterpriseAppsWithBlock:(void (^)(NSArray *apps, NSError *error))block {

    [[MASApplication currentApplication] retrieveEnterpriseApps:^(NSArray *objects, NSError *error) {
        
        NSMutableArray *enterpriseApps = [[NSMutableArray alloc]init];
        
        if (objects) {
            for (MASApplication *app in objects) {
                
                NSMutableDictionary *appInfo = [[NSMutableDictionary alloc] init];
                if (app.identifier) {
                    [appInfo setObject:app.identifier forKey:@"id"];
                }
                if (app.iconUrl) {
                    [appInfo setObject:app.iconUrl forKey:@"icon_url"];
                }
                if (app.nativeUrl) {
                    [appInfo setObject:app.nativeUrl forKey:@"native_url"];
                }
                if (app.customProperties) {
                    [appInfo setObject:app.customProperties forKey:@"custom"];
                }
                if (app.authUrl) {
                    [appInfo setObject:app.authUrl forKey:@"auth_url"];
                }
                if (app.name) {
                    [appInfo setObject:app.name forKey:@"name"];
                }
                
                L7SEnterpriseApp *application = [[L7SEnterpriseApp alloc]initWithAttributes:appInfo];
                application.masAppInstance = app;
                [enterpriseApps addObject:application];
                
            }
        }
        
        if (block) {
            block(enterpriseApps,error);
        }
    }];
}

-(void)setDelegate:(id<L7SEnterpriseAppProtocol>)mDelegate
{
    MASApplication *masApp = self.masAppInstance;

    [masApp setDelegate:self];
    delegate = mDelegate;
}


- (void)enterpriseWebApp:(MASApplication *)app
{
    [self.delegate enterpriseWebApp:self];
}


- (void)enterpriseApp:(MASApplication *)app didReceiveError:(NSError *)error
{
    if ([L7SClientManager delegate] && [[L7SClientManager delegate]respondsToSelector:@selector(DidReceiveError:)]) {
        [[L7SClientManager delegate] DidReceiveError:error];
    }
}


- (void) loadIconWithImageView:(UIImageView *) imageView{
    [imageView setUserInteractionEnabled:YES];
    [self.masAppInstance enterpriseIconWithImageView:imageView completion:^(BOOL completed, NSError *error) {
        if(error)
        {
            if ([L7SClientManager delegate] && [[L7SClientManager delegate]respondsToSelector:@selector(DidReceiveError:)]) {
                [[L7SClientManager delegate]DidReceiveError:error];
            }
        }
    }];
}

- (void)loadWebApp:(UIWebView *) webView{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveStatusUpdate:)
                                                 name:L7SDidReceiveStatusUpdateNotification
                                               object:nil];
    
    [self.masAppInstance loadWebApp:webView completion:^(BOOL completed, NSError *error) {
        if (error) {
            if ([L7SClientManager delegate] && [[L7SClientManager delegate]respondsToSelector:@selector(DidReceiveError:)]) {
                [[L7SClientManager delegate]DidReceiveError:error];
            }
        }
    }];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"appId: %@, appName: %@, customFields: %@", _appId, _appName, _customFields];
}


- (void)didReceiveStatusUpdate:(NSNotification *) notification{
    DLog(@"receive status update notification %@", notification);
    
    L7SClientState state = (L7SClientState)[[notification.userInfo objectForKey:L7SStatusUpdateKey] intValue];
    
    switch (state) {
        case L7SDidFinishAuthentication:{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_authURL]];

            [_webView loadRequest:request];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
        }break;
            default:
            break;
            
    }
}


- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
