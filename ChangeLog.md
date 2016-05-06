# Version 1.2.00

### Bug fixes

- 
- Handling multiples response type with one session manager

### New features

- .

### Deprecated methods

- [[MASDevice currentDevice] logOutDeviceAndClearLocal:completion:] is deprecated to avoid confusion from developers and to align with Android SDK.  Please use [[MASUser currentUser] logoutWithCompletion:] method to log-out the authenticated user.
- [[L7SClientManager sharedManager] logoutDevice] is also completely deprecated from the backward-compatibility for above reason. 
- [[MASUser currentUser] logoffWithCompletion:] was renamed to [[MASUser currentUser] logoutWithCompletion:].


# Version 1.1.00

### Bug fixes

- 
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

