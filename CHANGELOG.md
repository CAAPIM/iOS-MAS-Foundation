# Version 1.9.10

### Bug fixes
- CSR Generation fix for SHA256. [DE404260]
- Logout fix for login screen being presented under certain circumstances. [DE395105]

# Version 1.9.00

### New features
- The Mobile SDK now supports client-side validation of ID tokens signed with RS256. [US542359]
- The Mobile SDK now allows SSO between apps that use different bundle identifier structures. [US552675]
- The Mobile SDK now lets you add customized metadata to the registered device. [US507853]

### Bug fixes
- The Mobile SDK improves the device registration experience, and changes device identifier generation in the Mobile SDK. Registered devices that are upgraded to version 1.9.00 will not be impacted, and registration status is persisted. [US552675]
- The Mobile SDK default response serialization was previously set to JSON when response type was set to Unknown. The new default for response data is in byte arrays. [DE389481]
- The Mobile SDK now revokes token(s) against OTK upon locking the user session with local authentication. [DE386922]

# Version 1.8.00

### New features
- In previous releases, the Mobile SDK always enforced id_token validation during device registration and user authentication. This caused a "JWT invalid" failure if the id_token signing algorithm was not supported by the Mobile SDK. The Mobile SDK now provides the option to enable or disable id_token validation to handle unsupported id_token signing algorithms. [US514785]
- The Mobile SDK now supports offline logout. Use the new logout call to delete or keep credentials upon error. [US520138]

### Bug fixes
- The Mobile SDK improves performance during the initial device registration process. [US509357]
- The Mobile SDK improves performance during the geolocation data collecting process. [US509356]
- The Mobile SDK returned device registration error message using an incorrect data format. The Mobile SDK now returns the correct format and message. [DE372726]
- The Mobile SDK returned an invalid state and unexpected error on specific APIs, such as device session lock, and `[[MASUser currentUser] requestUserInfoWithCompletion:]` after Single Sign-On. The Mobile SDK now properly validates the current state, and does not return the error on those APIs. [DE374706][DE374587]  

### Deprecated methods
- `[[MASUser currentUser] logoutWithCompletion:]` is now deprecated to support new feature. Please use `[[MASUser currentUser] logout:completion]` to perform user logout. [US520138]

# Version 1.7.10

### Bug fixes
- MASFoundation's OTP channel selection was returning an internal error to the original request. The Mobile SDK now sends only cancellation of OTP process, and/or results of the original request. [DE366491]
- During device registration, the Mobile SDK was causing an error: "The device has already been registered". This happened when the share keychain was incorrectly configured, preventing users from re-registering the device using different credentials. The Mobile SDK improved the device registration process to minimize this kind of error. [DE369778]
- The Mobile SDK reserved "Content-Type" and "Accept" header for requests, but did not provide an option for developers to override these values. The Mobile SDK now allows developers to override the values as needed. [DE369138]
- The Mobile SDK displayed an incorrect error for session lock when multiple applications are using SSO. The Mobile SDK now provides accurate session lock status. [DE374443]

# Version 1.7.00

### Enhancement
Swift code is added to the [iOS Guide](http://mas.ca.com/docs/ios/latest/guides/). The iOS API Reference documentation is based on Objective-c, but the Objective-c code can be used seamlessly with your Swift code. See the usage section for details.

### Bug fixes
- The Mobile SDK returned incorrect device status after de-registration. `[MASDevice currentDevice].status` now returns correct status after the device de-registration. [DE361039]
- The Mobile SDK caused a crash on using `[MAS setGatewayNetworkActivityLogging:]` on actual devices. The Mobile SDK no longer causes crash using `[MAS setGatewayNetworkActivityLogging:]` on the devices. [DE359604]
- The Mobile SDK caused a delay by retrieving user authorization and geolocation information for every request. The delay has been reduced and the SDK no longer waits for user's authorization. [DE361046]
- During initialization, the Mobile SDK relied on a system prompt for user intervention to be completed. The Mobile SDK now initializes without waiting for user intervention and a system prompt. [DE361046]
- The `MASService` structure has been reorganized. Any external SDK's inherited `MASService` should register through `MASFoundation`'s `[MASService registerSubclass:serviceUUID:]` to be incorporated into the Mobile SDK lifecycle. [DE361045]
- `[MAS setGatewayMonitor:]`, `[MAS gatewayIsReachable]`, and `[MAS gatewayMonitoringStatusAsString]` were providing results of the device's internet connectivity. The Mobile SDK now returns network reachability of the primary gateway for these methods. [DE353042]
- `MASUserLoginWithUserCredentialsBlock` was sending all errors that occurred during user authentication to the original request. The Mobile SDK now sends only cancellation of authentication request, and/or results of the original request, to the original request. [DE351363]
- `MASAuthCredentials` class could not be inherited in Swift because of limitations in accessing private properties and methods. The Mobile SDK now provides proper properties and methods in public, so that MASAuthCredentials can be properly inherited. [DE353904]
- Improved organization of static string constants by separating files. The new classes are MASNotifications and MASError. Also, changed how the SDK exposes the string constants to follow best practices. [US469003]

### Deprecated methods
- `MASSocialLogin` class is completely deprecated and removed. Please use `SFSafariViewController` to display social login web URL from `MASAuthenticationProvider` and use `MASAuthorizationResponse` class to handle incoming response from `SFSafariViewController`. [US461955]
- `MASUserLoginWithUserCredentialsBlock` callback is completely deprecated and removed. Please use `MASUserAuthCredentialsBlock` to perform implicit authentication. [US461955]

# Version 1.6.10

### Bug fixes
- `MASMQTTClient` was unable to establish MQTT connection if the server presents a chain of certificates and the `msso_config.json` file contains only leaf certificate. The Mobile SDK now properly establishes MQTT connection with leaf certificate only in the configuration file. [US436059]
- iOS device with special or foreign characters in the device name failed during device registration. The Mobile SDK now uses device model to register the device. [DE331046]
- Special characters in the URL query parameters were not properly encoding the values. The Mobile SDK now properly encodes special characters in URL query parameters. [DE339566]
- When `NSURL` without any URL query parameter was passed in `[MAS startWithURL:completion:]`, the Mobile SDK crashed.  The Mobile SDK now properly evaluates `NSURL` and does not crash. [DE343807]

### New features
- `MASResponseObjectErrorBlock` is a new method that improves response parsing. `MASResponseObjectErrorBlock` replaces the existing `MASResponseInfoErrorBlock`, which returned `NSDictionary` as an argument that included HTTP response headers, and response payload. `MASResponseObjectErrorBlock` has three arguments in the block: `(^MASResponseObjectErrorBlock)(NSHTTPURLResponse *response, id responseObject, NSError *error)` where `NSHTTPURLResponse` checks HTTP status code, response headers, and response content type from the response.  You should perform proper typecasting for `responseObject` based on `Content-type` in the response header.  `responseObject` can either be `nil`, `NSDictionary`, `NSXMLParser`, and/or `NSString`. [US461954] 

### Deprecated methods
- `+ (void)invoke:(MASRequest *)request completion:(MASResponseInfoErrorBlock)completion` are deprecated immediately and replaced with `+ (void)invoke:(MASRequest *)request completion:(MASResponseObjectErrorBlock)completion` [US461954]
- `[MASRequestBuilder setHeaderParameter:value:]`, `[MASRequestBuilder setBodyParameter:value:]`, and `[MASRequestBuilder setQueryParameter:value:]` are deprecated immediately.  Instead, use `MASRequestBuilder`'s `header`, `body`, and `query` `NSDictionary` properties directly to modify these parameters. [DE346442]

# Version 1.6.00

### Bug fixes
- `MASAuthCredentialsJWT` credentials was marked as re-usable, so the Mobile SDK tried to consume the same credentials for a certain period of time. JWT credentials can now be consumed only one time, and is not reusable. [DE324462]
- Device deregistration was removing all credentials from the Mobile SDK regardless of the result of deregistration request.  Now, the Mobile SDK removes credentials only when the deregistration request succeeds. [DE324142]
- Mobile SDK was changing `MASGrantFlow` to client credentials in a specific scenario with Cordova SDK. The Mobile SDK no longer switches the `MASGrantFlow` by itself. [DE311841]
- Mobile SDK enhances the device registration flow so it handles the device registration record more smoothly. This removes the hassle of developers seeing "This device has already been registered and has not been configured to accept updates" error message in development phase. [US406920]
- `MASConfiguration` was not properly updating the updated endpoint values when switching to a different configuration. It is fixed. [DE321925]
- `MASConfiguration` had some hard-coded values for client credentials device registration endpoint. `MASConfiguration` now reads the value from the configuration. [DE321921]
- `MASMQTTClient` was unable to reestablish MQTT connection when the user session was logged out, and logged in with a different account. Mobile SDK now properly handles session changes for MQTT connection. [US408725]
- Mobile SDK now stores all credentials only to the device. Data will not be backed-up or transferred with iCloud unless `[MAS setKeychainSynchronizable:]` is explicitly set to `YES`. [US388853]
- Mobile SDK's MQTT connection was unable to establish mutual SSL connection with public CA certificate. The Mobile SDK now establishes mutual SSL with public CA certificate when **entire certificate chain** is exported in JSON configuration. [US399506]

### New features
- Mobile SDK introduces a secure way of storing and sharing data across multiple applications using same keychain sharing group with MASFoundation's `MASSharedStorage` class. [US416558]
- Mobile SDK introduces a new way of building API CRUD request with `MASRequestBuilder` and `MASRequest` classes to provide seamless developer experience Android SDK. [US374082]

### Deprecated methods
- `[MASConfiguration setSecurityConfiguration:]` is deprecated.  Please use `[MASSecurityConfiguration setSecurityConfiguration:error:]` for better handling of error cases when setting the security configuration object. [DE328373]

# Version 1.5.00

NOTE: From this version on the frameworks changed to Dynamic instead of Static library

### Bug fixes
- In the implicit authentication flow, errors are now only reported once during the authentication flow or actual result of the endpoint. Previously, the original request was notified for every error that happened during the authentication flow. [DE311261]
- Logout and login notifications now broadcast correctly. Previously, notifications were not sent at the correct time, and the SDK also represented incorrect status for these activities. [DE310488]
- BLE authentication now restarts when authorization is denied. Previously, BLE authentication reported authorization was in progress and did not restart, even after the device denied authorization. [DE310490]
- The SDK now generates the correct URL for external API requests (non Gateway request), when the Gateway has an instance modifier. [DE310249]
- `MASMQTTClient` now connects to a public broker without requiring the username, and password. Previously, `MASMQTTClient` was forcing all brokers to provide user credentials. [DE306921]
- The SDK now properly validates the request response type as defined. Previously, the SDK accepted mismatch content-type for the 200 response as a valid response. [US349551]
- The SDK no longer requires Keychain Sharing to be enabled in Xcode. However, to establish SSO across multiple applications, Keychain Sharing must be enabled. [US320771]
- Mobile SDK now only validates against the leaf certificate for SSL pinning validation by default. The configuration can be changed to validate against entire certificate chain through `MASSecurityConfiguration`. [US374086]

### New features
- Mobile SDK introduces an ability to configure security configuration for external APIs (such as SSL pinning), so that Mobile SDK can securely connect to external API (other than primary Gateway). [US344780]
- The SDK handles multiple concurrent API requests with proper authentication processes. [US362800]
- The SDK supports dynamic framework. All you need to do is update your Xcode settings. [US367604]
- The SDK introduces more flexible and extensible authentication with different types of credentials. For details, see `MASAuthCredentials`. [US349497]
- The SDK introduces the ability to digitally sign the request as JWT. See `MASClaims` to sign the request. [US313137]

### Deprecated methods
- `[MAS setUserLoginBlock:]` is deprecated.  Please use `[MAS setAuthCredentials:]` block to perform implicit authentication with `MASAuthCredentials` object.


# Version 1.4.00

### Bug fixes
- The BLE OS prompt was displaying on SDK initialization. Now the prompt appears only when the SDK actually accesses BLE services.  [US284889]
- Fixes to nullability warnings on public classes. [US284893]
- [MAS gatewayIsReachable] boolean property always returned true. [DE272367]
- SDK was unable to make CRUD operations after SDK initialization because "The network is not started yet." [DE282382]
 
### New features
- Introduces new way of dynamically initializing SDK with enrollment URL. With this feature, application or system administrator can generate an URL specified to a user, so that the user can initialize SDK without having an application with built in `msso_config.json` deployed with the application. Server configuration and application level's implementation is required. [US287274]
- Introduces new way of performing social login through SDK.  SDK now performs social login with `SFSafariViewController` to ensure better security, and adopt morden way of performing oAuth web authentication. Please refer to `MASAuthorizationResponse` class to understand the new flow of social login with `SFSafariViewController`.[US279228]
- Introduces new protection on authorization process with Proof Key for Code Exchange by OAuth Public Clients.  By default, PKCE process is enabled, and it can be disabled; however, it is strongly recommended to not disable it unless there is a specific use case. [US269506]

### Deprecated Methods
- `MASSocialLogin` class is deprecated. Please use `SFSafariViewController` to display social login web URL from `MASAuthenticationProvider` and use `MASAuthorizationResponse` class to handle incoming response from `SFSafariViewController`. [US279228]

# Version 1.3.01

### Bug fixes 
- Fixes an issue with dynamically switching between msso config's when one of the configs has location enabled and another msso config has location disabled. If the user declines location services permission when first opening the app, the app would hang when switching msso's back to the config that allowed location. [DE230814]
- Improved error handling in the case of missing parameters. [US240398]
- Added nullability annotations to certain interfaces. [US240400]
- When changing the master client key , the sdk now recognizes the change. The sdk will clean out the client id, client secret, access token, refresh token. The client will attempt to re-authenticate with the id token. This addresses adding scope to an existing api. [US240404]
- Fixed a bug where Mobile SDK attempted to initialize with invalid configuration file and caches the invalid configuration. [DE244332][DE255042]
- Changed the client id format for MQTT protocol. [US263626]
- ```[[MASDevice currentDevice] clearLocal]``` method will remove all credentials in both local and shared keychain storage.

### New features
- Fingerprint Session Lock feature implementation.  User session can now be locked and unlocked with Fingerprint and/or device passcode (device local authentication). [US246928]
- Client certificate process is newly added.  Mobile SDK will automatically detect the validity of the client certificate and renew it when necessary. [US240412]
- MASAuthenticationProviders can now be retreived as needed through ```[MASAuthenticationProviders retrieveAuthenticationProvidersWithCompletion:] ```.

# Version 1.2.03

### Bug fixes
- Fix the issue where [MAS gatewayISREachable] static property always returns true.
- Fix the bluetooth permission prompt displays everytime SDK is initialized.  Now bluetooth permission prompt will only display when the bluetooth is actually being used.

### New features

-

### Deprecated methods

-

# Version 1.2.01

### Bug fixes
 
- Added listAttibutes method to MASObject in MASFoundation framework. [MCT-436]
- The MASUser object isAuthenticated property returned wrong value for other user objects retrieved from MASIdentityManagement. [MCT-469]
- The isCurrentUser flag was not determined dynamically when retrieved from MASIdentityManagement. MASFoundation will determine isCurrentUser flag dynamically by [MASUser currentUser] and/or user retrival from MASIdentityManagement. [MCT-434]
- When passing "cancel" as YES into MASBasicCredentialBlock, SDK was failing to notify the original caller of the request; it was only notifying the completion block of MASBasicCredentialBlock. [MCT-439]
- Version number and version string returned incorrect values. [MCT-437]
- MSSO is not handled properly for explicit authentication method. [MCT-504]
- A MASFoundation app stops working if geolocation is enabled (location_enabled) in the JSON configuration file and the user selects "Don't Allow" at the allow access to location prompt. Now, the app continues to work, but returns errors from APIs requiring the geolocation information. [MCT-335]


### New features

None.

### Deprecated methods

None.

# Version 1.2.00

### Bug fixes
 
- Handling multiple response types with one session manager.
- SDK offline initialization: a bug where SDK cannot be initialized while the device has no network connectivity is fixed.  SDK now can be used for secure local storage.

### New features

- [One-Time Password (OTP)](http://mas.ca.com/docs/ios/1.2.00/guides/#create-your-own-otp-dialog) feature for accessing APIs
- ```MASSocialLogin``` class is newly added for developers to handle social login on [customized login dialog](http://mas.ca.com/docs/ios/1.2.00/guides/#create-your-own-login-dialog).

### Deprecated methods

- ```[[MASDevice currentDevice] logOutDeviceAndClearLocal:completion:]``` is deprecated to avoid confusion from developers and to align with Android SDK.  Please use ```[[MASUser currentUser] logoutWithCompletion:]``` method to log-out the authenticated user.
- ```[[L7SClientManager sharedManager] logoutDevice]``` behaviour of the method is changed for this method for above reason. 
- ```[MAS setDeviceRegistrationBlock:]``` is completely deprecated.  All registration related process will be done as part of ```[MAS setUserLoginBlock:]``` or ```[MASUser loginWithUsername:password:completion:]```.
- ```[MAS setDeviceRegistrationType:]``` is renamed to ```[MAS setGrantFlow:]```.  
- ```[MAS deviceRegistrationType]``` is renamed to ```[MAS grantFlow]```.
- ```[[MASUser currentUser] logoffWithCompletion:]``` is renamed to ```[[MASUser currentUser] logoutWithCompletion:]```.
- ```MASDeviceRegistrationType``` is renamed to ```MASGrantFlow``` in ```MASConstants.h```.
- ```wasLoggedOff``` property in ```[MASUser currentUser]``` is deprecated.
- ```[[MASDevice currentDevice] resetLocallyWithCompletion:]``` will be deprecated.  Use ```[[MASDevice currentDevice] resetLocally]``` instead.
- ```MASSessionSharingDelegate``` protocol is renamed as ```MASProximityLoginDelegate```.
- All class methods, properties, and notofications containing **sessionSharing** are renamed to **proximityLogin**.



# Version 1.1.00

### Bug fixes

- .

### New features

- .

### Deprecated methods

- .


 [mag]: https://docops.ca.com/mag
 [mas.ca.com]: http://mas.ca.com/
 [docs]: http://mas.ca.com/docs/
 [blog]: http://mas.ca.com/blog/

 [releases]: ../../releases
 [contributing]: /CONTRIBUTING.md
 [license-link]: /LICENSE

