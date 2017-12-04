MASFoundation is the core iOS framework of the iOS Mobile SDK, which is part of CA Mobile API Gateway. MASFoundation handles the communication and authentication layer of the iOS Mobile SDK, making it easy for developers to establish a secure connection (TLS, Mutual SSL) to any CA Mobile API Gateway (MAG).

## Features

The MASFoundation framework has the following features:

- Authentication
    + OAuth
    + OIDC - OpenID Connect
    + BLE
    + Dynamic Client ID & Client Secret
    + QR Code
    + Social Login
    + Single Sign On
    + OTP - One Time Password
    + PKCE - Proof Key for Code Exchange
    + SSL Pinning with certificate, public key, or public key hash
    + Fingerprint Sessions Lock - Support phone unlocking using fingerprint recognition
- Dynamic SDK Configuration
- Enterprise Browser
- Geo Location

## Get Started

- Check out our [documentation][docs] for sample code, video tutorials, and more.
- [Download MASFoundation][download] 


## Communication

- *Have general questions or need help?*, use [Stack Overflow][StackOverflow]. (Tag 'massdk')
- *Find a bug?*, open an issue with the steps to reproduce it.
- *Request a feature or have an idea?*, open an issue.

## How You Can Contribute

Contributions are welcome and much appreciated. To learn more, see the [Contribution Guidelines][contributing].

## Installation

MASFoundation supports multiple methods for installing the library in a project.

### Cocoapods (Podfile) Install

To integrate MASFoundation into your Xcode project using CocoaPods, specify it in your **Podfile:**

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

pod 'MASFoundation'
```
Then, run the following command using the command prompt from the folder of your project:

```
$ pod install
```

### Manual Install

For manual install, you add the Mobile SDK to your Xcode project. Note that you must add the MASFoundation library. For complete MAS functionality, install all of the MAS libraries as shown.

1. Open your project in Xcode.
2. Drag the SDK library files, and drop them into your project in the left navigator panel in Xcode. Select the option, `Copy items if needed`.
3. Select `File->Add files to 'project name'` and add the msso_config.json file from your project folder.
4. In Xcode "Build Setting” of your Project Target, add `-ObjC` for `Other Linker Flags`.
5. Import the following Mobile SDK library header file to the classes or to the .pch file if your project has one.

```
#import <MASFoundation/MASFoundation.h>
```

## Set Up Project and Start the SDK

To start your project, see [developer site](https://mas.ca.com/docs)

After your project is properly configured, you must start the SDK to establish a secure connection with the backend services. The startup process includes: initialize necessary services for library (such as geo-location, BLE, and network services), and load configuration.

Ideally, SDK startup should be processed before app startup (during the splash/loading screen of your app). We recommended that you process any communication with the backend services upon successful completion of the startup method. Otherwise, the secure communication is not guaranteed and may fail.   

MASFoundation includes the following methods to start the SDK.

##### Start with standard method
```objectivec
    //Initializing the SDK.
    [MAS start:^(BOOL completion, NSError *error) {
        //Your code here!
    }];
```
This method starts the SDK with the currently-active configuration. A currently-active configuration is: 1) the last successfully used configuration, 2) the default JSON configuration file (i.e. msso_config.json in your app bundle) or 3) the custom JSON configuration file defined in `[MAS setConfigurationFileName:]`.

**Recommended for**: Most environments, including production.

##### Start with default configuration
```objectivec
    //Initializing the SDK.
    [MAS startWithDefaultConfiguration:YES completion:^(BOOL completed, NSError *error)
        //Your code here!
    }];
```
This method starts the SDK with the currently-active configuration, or the default configuration (depending on the parameter). If you specify the `YES` parameter, this overwrites the currently-active configuration with the default configuration (if two configurations are different.). If you pass the `NO` parameter, this behaves the same as `[MAS start:];`. If the SDK is already started, this method: stops the SDK, then restarts it with the custom JSON object.

**Recommended for**: Development environments where configurations change often.

##### Start using custom JSON
```objectivec
  //Your custom JSON object.
  NSDictionary *jsonObject = @{....};
    
  //Initializing the SDK with custom JSON object.
  [MAS startWithJSON: jsonObject completion:^(BOOL completed, NSError *error) {
    //Your code here!
  }];
```
This method starts the SDK using the custom JSON object in, NSDictionary. This method overwrites the currently-active configuration with the custom JSON object, and stores it as the active configuration. If the SDK is already started, this method: stops SDK, then it restarts it with the custom JSON object.

**Recommended for**: Using multiple MAG servers so you can dynamically change the configuration during runtime. Note: The backend servers must have a version of the product that supports dynamic configuration. 

##### Start using file URL
```objectivec
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"your_file_name"
                                                         ofType:@"json"];
    NSURL *thisURL = [NSURL fileURLWithPath:jsonPath];
    
    //Initializing the SDK with file URL of JSON configuration.
    [MAS startWithURL:thisURL completion:^(BOOL completed, NSError *error) {
        //Your code here!
    }];
```
This method starts the SDK using the custom JSON configuration file. The custom file can be defined in NSURL format, which indicates the path of the custom file. This method overwrites the currently-active configuration with the custom JSON file, and stores it as the active configuration. If the SDK is already started, this method: stops the SDK, then restarts it with the custom JSON file.

The SDK accepts the NSURL only with __local file path__. If the Web URL is provided, the startup method fails.

**Recommended for**: Using multiple MAG servers so you can dynamically change the configuration during runtime. Note: The backend servers must have a version of the product that supports dynamic configuration. 

## Documentation

For more documentation and API references, go to our [main website][docs]

## License

Copyright (c) 2016 CA. All rights reserved.

This software may be modified and distributed under the terms
of the MIT license. See the [LICENSE][license-link] file for details.

 [mag]: https://docops.ca.com/mag
 [mas.ca.com]: http://mas.ca.com/
 [get-started]: http://mas.ca.com/get-started/
 [docs]: http://mas.ca.com/docs/
 [blog]: http://mas.ca.com/blog/
 [videos]: https://www.ca.com/us/developers/mas/videos.html
 [StackOverflow]: http://stackoverflow.com/questions/tagged/massdk
 [download]: https://github.com/CAAPIM/iOS-MAS-Foundation/archive/master.zip
 [contributing]: https://github.com/CAAPIM/iOS-MAS-Foundation/blob/develop/CONTRIBUTING.md
 [license-link]: /LICENSE
