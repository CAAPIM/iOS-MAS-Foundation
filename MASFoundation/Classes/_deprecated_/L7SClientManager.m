//
//  L7SClientManager.m
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "L7SClientManager.h"

#import <MASFoundation/MASFoundation.h>
#import "MASAccessService.h"
#import "MASModelService.h"
#import "MASProximityLoginQRCode.h"


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


NSString * const L7SDidReceiveStatusUpdateNotification = @"com.layer7tech.msso.process.status";
NSString * const L7SStatusUpdateKey = @"L7SStatusUpdateKey";



@interface L7SClientManager ()

@property (assign) BOOL ignoreInitialLaunch;
@property (assign) BOOL bleSessionSharingRequestReceived;
@property id<L7SBLESessionSharingDelegate> BLEDelegate;

@end



@implementation L7SClientManager

static L7SClientManager *_sharedClientManager;
static id<L7SClientProtocol> _delegate_;


# pragma mark - Properties

+ (id<L7SClientProtocol>)delegate
{
	return _delegate_;
}

+ (void)setDelegate:(id<L7SClientProtocol>)delegate
{
	_delegate_ = delegate;
}


# pragma mark - Lifeycle

- (id)init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
	        reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `configureClientManagerWithEndpoint:` instead.", NSStringFromClass([self class])]
	        userInfo:nil];
}


- (id)initPrivate
{
	if ((self = [super init]))
	{

		//
		// listen to the notification from MAS framework to support old interfaces' notification
		//

		// Registration
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMASNotification:) name:MASDeviceDidRegisterNotification object:nil];

		// Authentication
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMASNotification:) name:MASUserDidAuthenticateNotification object:nil];

		// Listen to app lifecycle notification when MSSOSDKStartAtLaunch is set to true.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ensureMASFrameworkWhenAppBecomesActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        // Listen to the notification that QR Code image disappears
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMASNotification:) name:MASProximityLoginQRCodeDidStopDisplayingQRCodeImage object:nil];
	}

	return self;
}


+ (id)initClientManager
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^
	{
		_sharedClientManager = [[L7SClientManager alloc] initPrivate];

		_sharedClientManager.state = L7SDidSDKStop;

		//
		// old MAG sdk configuration in plist
		// if MSSOSDKStartAtLaunch is set to true, launch all policies (registration, authentication process) as part of initClientManager,
		// if it is set to false, simply don't start it
		//
		BOOL startImmediately = YES;
		id startAtLaunchConfiguration = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MSSOSDKStartAtLaunch"];
		if (startAtLaunchConfiguration)
		{
		        startImmediately = [startAtLaunchConfiguration boolValue];
		}

		if (startImmediately)
		{

		        _sharedClientManager.ignoreInitialLaunch = YES;

		        _sharedClientManager.state = L7SDidSDKStartInit;

		        //
		        //  Old SDK's default is set to user credentials.
		        //
		        [MAS setGrantFlow:MASGrantFlowPassword];


		        [MASDevice setProximityLoginDelegate:_sharedClientManager];

		        //
		        // This is a really bad way to start something up inside a synchronous
		        // method call but what can you do?
		        //
		        [MAS start:^(BOOL completed, NSError *error) {
		                 if(error)
		                 {
		                         if(_delegate_ && [_delegate_ respondsToSelector:@selector(DidReceiveError:)]) {
		                                 [_delegate_ DidReceiveError:error];
					 }

		                         return;
				 }
		                 else if (completed) {
		                         _sharedClientManager.state = L7SDidSDKStart;
				 }

		                 if(_delegate_ && [_delegate_ respondsToSelector:@selector(DidStart)])
		                 {
		                         [_delegate_ DidStart];
				 }
			 }];
		}
	});

	return _sharedClientManager;
}


+ (id)initClientManagerWithJSONObject:(id)json
{
	// todo

	return nil;
}


+ (L7SClientManager *)sharedClientManager
{
	return _sharedClientManager;
}


# pragma mark - Configuration

- (NSString *)prefix
{
	return [MASConfiguration currentConfiguration].gatewayPrefix;
}


# pragma mark - App

- (void)logoffApp
{
	// Redirect to current user logoff
	[[MASUser currentUser] logoutWithCompletion:^(BOOL completed, NSError *error)
	 {
	         DLog(@"\n\n(L7SClientManager.logoffApp() did log off: %@ or error: %@\n\n",
	              (completed ? @"Yes" : @"No"), [error localizedDescription]);

	         if(error)
	         {
	                 if(_delegate_) [_delegate_ DidReceiveError:error];

	                 return;
		 }

	         if(completed)
	         {
	                 //
	                 // if the logoff was successful, send notification
	                 //
	                 NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:L7SDidLogoff], L7SStatusUpdateKey, nil];
	                 [[NSNotificationCenter defaultCenter] postNotificationName:L7SDidReceiveStatusUpdateNotification object:nil userInfo:userinfo];
		 }
	 }];
}


- (BOOL)isAppLogon
{
	return [MASApplication currentApplication].isAuthenticated;
}


# pragma mark - Device

- (void)deRegister
{
	// Redirect to MAS deregistration
	[[MASDevice currentDevice] deregisterWithCompletion:^(BOOL completed, NSError *error)
	 {
	         DLog(@"\n\n(L7SClientManager.deRegister() did deregister: %@ or error: %@\n\n",
	              (completed ? @"Yes" : @"No"), [error localizedDescription]);

	         if(error)
	         {
	                 if(_delegate_) [_delegate_ DidReceiveError:error];

	                 return;
		 }

	         if(completed)
	         {
	                 //
	                 // if the deregistration was successful, send notification
	                 //
	                 NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:L7SDidFinishDeRegistration], L7SStatusUpdateKey, nil];
	                 [[NSNotificationCenter defaultCenter] postNotificationName:L7SDidReceiveStatusUpdateNotification object:nil userInfo:userinfo];
		 }
	 }];
}


- (BOOL)isDeviceLogin
{
	//
	// Check if id_token exists for device log in status
	//
	NSString *idToken = [[MASAccessService sharedService] getAccessValueStringWithType:MASAccessValueTypeIdToken];

	return idToken != nil;
}


- (void)logoutDevice
{
    [[MASUser currentUser] logoutWithCompletion:^(BOOL completed, NSError *error) {
        DLog(@"\n\n(L7SClientManager.logoutDevice() did log off: %@ or error: %@\n\n",
             (completed ? @"Yes" : @"No"), [error localizedDescription]);
        
        if(error)
        {
            if(_delegate_) [_delegate_ DidReceiveError:error];
            
            return;
        }
        
        if(completed)
        {
            //
            // if the logoff was successful, send notification
            //
            NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:L7SDidLogout], L7SStatusUpdateKey, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:L7SDidReceiveStatusUpdateNotification object:nil userInfo:userinfo];
        }
    }];
}


- (BOOL)isRegistered
{
	return [MASDevice currentDevice].isRegistered;
}


- (void) authorize: (NSString *) code failure: (void (^)(NSError *)) callback
{
    [MASProximityLoginQRCode authorizeAuthenticateUrl:code completion:^(BOOL completed, NSError *error) {
       
        if (!completed || error)
        {
            if (callback)
            {
                callback(error);
            }
        }
        
        return;
    }];
}

# pragma mark - BLE

- (void) startBLESessionSharingWithDelegate: (id<L7SBLESessionSharingDelegate>) delegate
{
	_BLEDelegate = delegate;

	if ([MASDevice currentDevice])
	{
		[MASDevice setProximityLoginDelegate:self];

		[[MASDevice currentDevice] startAsBluetoothPeripheral];
	}
}

- (void) stopBLESessionSharing
{
	if ([MASDevice currentDevice])
	{
		[MASDevice setProximityLoginDelegate:self];

		[[MASDevice currentDevice] stopAsBluetoothPeripheral];
	}
}

- (void) enableBLESessionRequestWithDelegate: (id<L7SBLESessionSharingDelegate>) delegate
{
	_BLEDelegate = delegate;

	if ([MASDevice currentDevice] && ![MASUser currentUser].isAuthenticated)
	{
		[MASDevice setProximityLoginDelegate:self];

		_bleSessionSharingRequestReceived = YES;

		if ([MASApplication currentApplication] && [MASApplication currentApplication].isRegistered)
		{
			[[MASModelService sharedService] retrieveAuthenticationProviders:^(id object, NSError *error) {

			         MASAuthenticationProvider *authProvider = [[MASAuthenticationProviders currentProviders] retrieveAuthenticationProviderForProximityLogin];
			         [[MASDevice currentDevice] startAsBluetoothCentralWithAuthenticationProvider:authProvider];
			 }];
		}
		else {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidRegister:) name:MASApplicationDidRegisterNotification object:nil];
		}
	}
}

- (void) disableBLESessionRequest
{
	if ([MASDevice currentDevice])
	{
		[MASDevice setProximityLoginDelegate:self];

		[[MASDevice currentDevice] stopAsBluetoothCentral];
	}
}


- (void)applicationDidRegister:(NSNotification *)notification
{
	_bleSessionSharingRequestReceived = NO;

	[[MASModelService sharedService] retrieveAuthenticationProviders:^(id object, NSError *error) {

	         MASAuthenticationProvider *authProvider = [[MASAuthenticationProviders currentProviders] retrieveAuthenticationProviderForProximityLogin];
	         [[MASDevice currentDevice] startAsBluetoothCentralWithAuthenticationProvider:authProvider];
	 }];
}

# pragma mark - MASDevice BLE delegate

- (void)didReceiveProximityLoginError:(NSError *)error
{
	if (_delegate_ && [_delegate_ respondsToSelector:@selector(DidReceiveError:)])
	{
		[_delegate_ DidReceiveError:error];
	}
}

- (void)didReceiveBLESessionSharingStateUpdate:(MASBLEServiceState)state
{
	L7SBLESessionSharingState l7sState;

	switch (state) {
	case MASBLEServiceStateUnknonw:
		l7sState = L7SBLEStateUnknown;
		break;

	case MASBLEServiceStateCentralStarted:
		l7sState = L7SBLECentralScanStarted;
		break;

	case MASBLEServiceStateCentralStopped:
		l7sState = L7SBLECentralScanStopped;
		break;

	case MASBLEServiceStateCentralDeviceDetected:
		l7sState = L7SBLECentralDeviceDetected;
		break;

	case MASBLEServiceStateCentralDeviceConnected:
		l7sState = L7SBLECentralDeviceConnected;
		break;

	case MASBLEServiceStateCentralDeviceDisconnected:
		l7sState = L7SBLECentralDeviceDisconnected;
		break;

	case MASBLEServiceStateCentralServiceDiscovered:
		l7sState = L7SBLECentralServiceDiscovered;
		break;

	case MASBLEServiceStateCentralCharacteristicDiscovered:
		l7sState = L7SBLECentralCharacteristicDiscovered;
		break;

	case MASBLEServiceStateCentralCharacteristicWritten:
		l7sState = L7SBLECentralCharacteristicWritten;
		break;

	case MASBLEServiceStateCentralAuthorizationSucceeded:
		l7sState = L7SBLECentralAuthorizationSucceeded;
		break;

	case MASBLEServiceStateCentralAuthorizationFailed:
		l7sState = L7SBLECentralAuthorizationFailed;
		break;

	case MASBLEServiceStatePeripheralSubscribed:
		l7sState = L7SBLEPeripheralSubscribed;
		break;

	case MASBLEServiceStatePeripheralUnsubscribed:
		l7sState = L7SBLEPeripheralUnsubscribed;
		break;

	case MASBLEServiceStatePeripheralStarted:
		l7sState = L7SBLEPeripheralStarted;
		break;

	case MASBLEServiceStatePeripheralStopped:
		l7sState = L7SBLEPeripheralStopped;
		break;

	case MASBLEServiceStatePeripheralSessionAuthorized:
		l7sState = L7SBLEPeripheralSessionAuthorized;
		break;

	case MASBLEServiceStatePeripheralSessionNotified:
		l7sState = L7SBLEPeripheralSessionNotified;
		break;

	default:
		break;
	}

	if (_BLEDelegate && [_BLEDelegate respondsToSelector:@selector(didReceiveBLESessionSharingStatusUpdate:)])
	{
		[_BLEDelegate didReceiveBLESessionSharingStatusUpdate:l7sState];
	}
}

- (void)didReceiveAuthorizationCode:(NSString *)authorizationCode
{
//	[[NSNotificationCenter defaultCenter] postNotificationName:MASDeviceDidReceiveAuthorizationCodeFromSessionSharingNotification object:@{@"code" : authorizationCode}];
}

- (void)handleBLEProximityLoginUserConsent:(MASCompletionErrorBlock)completion deviceName:(NSString *)deviceName
{
	if (_BLEDelegate && [_BLEDelegate respondsToSelector:@selector(requestUserConsent:deviceName:)])
	{
		__block MASCompletionErrorBlock blockCompletion = completion;

		[_BLEDelegate requestUserConsent:^(BOOL granted) {

		         if (blockCompletion)
		         {
		                 blockCompletion(granted, nil);
			 }

		 } deviceName:deviceName];
	}

	return;
}

# pragma mark - Authentication

- (void)authenticateWithUserName:(NSString *)userName password:(NSString *)password
{
	// Redirect to user login
	[MASUser loginWithUserName:(NSString *)userName password:(NSString *)password
	 completion:^(BOOL completed, NSError *error)
	 {
	         DLog(@"\n\n(L7SClientManager.authenticateWithUsername:%@ password:%@) did authenticate: %@ or error: %@\n\n",
	              userName, password, (completed ? @"Yes" : @"No"), [error localizedDescription]);

	         if(error)
	         {
	                 if(_delegate_ && [_delegate_ respondsToSelector:@selector(DidReceiveError:)])
	                 {
	                         [_delegate_ DidReceiveError:error];
			 }

	                 return;
		 }
	 }];
}


- (void)cancelAuthentication
{
	// ???? not quite sure what to do here yet
}


# pragma mark - Notification (New Interfaces)

- (void)didReceiveMASNotification:(NSNotification *)notification
{

	// Registration
	if ([notification.name isEqualToString:MASDeviceDidRegisterNotification])
	{
		NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:L7SDidFinishRegistration], L7SStatusUpdateKey, nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:L7SDidReceiveStatusUpdateNotification object:nil userInfo:userinfo];
	}
	// Authentication
	else if ([notification.name isEqualToString:MASUserDidAuthenticateNotification]) {

		NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:L7SDidFinishAuthentication], L7SStatusUpdateKey, nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:L7SDidReceiveStatusUpdateNotification object:nil userInfo:userinfo];
	}
    // QR Code session sharing; stop displaying QR code image
    else if ([notification.name isEqualToString:MASProximityLoginQRCodeDidStopDisplayingQRCodeImage]) {
        
        NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:L7SQRAuthenticationPollingStopped], L7SStatusUpdateKey, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:L7SDidReceiveStatusUpdateNotification object:nil userInfo:userinfo];
    }
}


- (void)ensureMASFrameworkWhenAppBecomesActive:(NSNotification *)notification
{

	//
	// old MAG sdk configuration in plist
	// if MSSOSDKStartAtLaunch is set to true, launch all policies (registration, authentication process) as part of initClientManager,
	// if it is set to false, simply don't start it
	//
	BOOL startImmediately = YES;
	id startAtLaunchConfiguration = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MSSOSDKStartAtLaunch"];
	if (startAtLaunchConfiguration)
	{
		startImmediately = [startAtLaunchConfiguration boolValue];
	}

	if (startImmediately && !self.ignoreInitialLaunch && self.state != L7SDidSDKStartInit)
	{

		if (self.state == L7SDidSDKStart)
		{

			[[MASModelService sharedService] validateCurrentUserSession:^(BOOL completed, NSError *error) {

			         if (error)
			         {

			                 if(_delegate_ && [_delegate_ respondsToSelector:@selector(DidReceiveError:)])
			                 {
			                         [_delegate_ DidReceiveError:error];
					 }
				 }
			 }];
		}
		else {

			[MASDevice setProximityLoginDelegate:self];

			[MAS start:^(BOOL completed, NSError *error) {

			         if (error)
			         {

			                 if(_delegate_ && [_delegate_ respondsToSelector:@selector(DidReceiveError:)])
			                 {
			                         [_delegate_ DidReceiveError:error];
					 }
				 }

			         if(_delegate_ && [_delegate_ respondsToSelector:@selector(DidStart)])
			         {
			                 [_delegate_ DidStart];
				 }

			 }];
		}
	}
	else {
		self.ignoreInitialLaunch = NO;
	}
}

#ifdef DEBUG

# pragma mark - Debug only

+ (void)currentStatusToConsole
{
	L7SClientManager *clientManager = [L7SClientManager sharedClientManager];

	DLog(@"(L7ClientManager) prefix: %@\n\n isAppLogon: %@\n  isRegistered: %@\n  isDeviceLogin: %@\n\n",
	     (![clientManager prefix] ? @"<none found>" :[clientManager prefix]),
	     ([clientManager isAppLogon] ? @"Yes" : @"No"),
	     ([clientManager isRegistered] ? @"Yes" : @"No"),
	     ([clientManager isDeviceLogin] ? @"Yes" : @"No"));
}


+ (void)setGatewayNetworkActivityLogging:(BOOL)enabled
{
	[MAS setGatewayNetworkActivityLogging:enabled];
}

#endif

@end

