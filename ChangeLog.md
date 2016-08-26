# Version 1.2.00

### Bug fixes
 
- Adding listAttibutes to MASObject in MASFoundation framework after removing from MASStorage MASObject category.
- Fix the bug where MASUser object's isAuthenticated property returns wrong value for other user objects retrieved from MASIdentityManagement.
- Fix the bug when passing "cancel" as YES into MASBasicCredentialBlock, SDK was failing to notify the original caller of the request; it was only notifying the completion block of MASBasicCredentialBlock.
- Fix the bug where version number and version string were returning incorrect values.

### New features

- 

### Deprecated methods

- 

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

