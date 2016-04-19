# CA Technologies Mobile App Services Objective-C Style Guide

This document describes the Objective-C coding style of iOS team for CA Technologies Mobile App Services.  This guideline is recommended to comply with all Objective-C implementations of our products.

## Review Apple's Official Coding Guideline

Beyond the guidelines defined in this document, we also recommend reviewing Apple's official coding guidelines.  

* [Programming with Objective-C](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjectiveC/Introduction/introObjectiveC.html)
* [Cocoa Fundamentals Guide](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaFundamentals/Introduction/Introduction.html)
* [Coding Guidelines for Cocoa](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)
* [App Programming Guide for iOS](http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/Introduction/Introduction.html)

### MAS Products

For more information about MAS, see [Mobile App Service developer](http://mas.ca.com).

Mobile App Services consists of multiple functional products separated into individual frameworks.

* MASFoundation
* MASUI
* MASConnecta
* MASIdentityManagement
* MASStorage

All of frameworks are recommended to comply with the coding guideline.

## Table of Contents

* [Documentation](#documentation)
* [Pragma Mark](#pragma-mark)
  * [Commonly Used Pragma Mark](#commonly-used-pragma-mark)
  * [Pragma Mark syntax](#pragma-mark-syntax)
  * [Order of Pragma Mark](#order-of-pragma-mark)
* [Class Naming](#class-naming)
* [Imports](#imports)
* [Constants](#constants)
* [Spacing / Newline](#spacing-newline)
  * [Documentation / In-line Comment](#documentation-in-line-comment)
  * [Property / Enum](#property-enum)
  * [Method](#method)
  * [If/Switch/For and other statements](#if-switch-for-and-other-statements)
* [Nullability for Swift](#nullability-for-swift)
* [Project Configuration Guideline](#project-configuration-guideline)
  * [File Structure](#file-structure)
  * [Class Naming](#class-naming)
  * [Framework Error Handling](#framework-error-handling)

## Documentation

All code **should be properly documented** in `.h` and `.m` files. Code documentation should adhere to Apple Doc's format.

Our team uses a tool that automatically generates document format in Xcode called [VVDocumenter](https://github.com/onevcat/VVDocumenter-Xcode) available through [Alcatraz](http://alcatraz.io/).

**Recommendation:** Install [Alcatraz](http://alcatraz.io/) and [VVDocumenter](https://github.com/onevcat/VVDocumenter-Xcode). This tool automatically generates the proper documentation format for methods, properties, classes, and any other form of section required for documentation.

Recommended elements to document:

* Class description
* Property
* Enum type
* Constant
* Method


For private methods that are not available in a header file, the method should still be documented in the implementation file if it is only in `.m` file.

## Pragma Mark

`# pragma mark - ` categorizes methods or properties in the header and implementation files in Xcode.  It makes the code easier to organize and navigate by other developers.

### Commonly Used Pragma Mark

There are few a commonly used `# pragma mark` in MASFoundation.  Follow these guidelines for categories.

```objc
# pragma mark - Properties
# pragma mark - Lifecycle
# pragma mark - Public
# pragma mark - Private
```

These are commonly used `# pragma mark - ` in MASFoundation.  Any other functional group of methods are fine, as long as it makes sense to everyone.

**For example:**

In `MASDevice.h`, methods that are related to BLE functionalities could be grouped in `# pragma mark - Bluetooth Central/Peripheral`.

### Pragma Mark syntax

Follow the standard format of `pragma mark` that is also compatible with Apple Doc.

**For example:**

```objc
///--------------------------------------
/// @name Properties
///--------------------------------------

# pragma mark - Properties
```

**Not:**

```objc
#pragma mark - 
#pragma mark - Properties
```

* Note: Allow one space between # and the pragma mark.

### Organization of Pragma Mark

- Order of the `# pragma mark` matters.  Place all of the commonly used `# pragma mark` at the top, followed by the others.  
- Order of the `# pragma mark` should be identical in both header and implementation files.
- **All of the methods** under `# pragma mark` should be in **alphabetical order**.


## Imports

* Imports may or may not be in alphabetical order
* Always make use of foward declaration in the interface (.h) file. I.e. `@class MASObject` instead of `#import "MASObject.h"`

**For example:**

```objc
//
// All imported classes should be in alphabetical order
//
#import <MASFoundation/MASApplication.h>
#import <MASFoundation/MASAuthenticationProvider.h>
#import <MASFoundation/MASAuthenticationProviders.h>
#import <MASFoundation/MASConfiguration.h>
#import <MASFoundation/MASDevice.h>
#import <MASFoundation/MASFile.h>
#import <MASFoundation/MASGroup.h>
#import <MASFoundation/MASObject.h>
#import <MASFoundation/MASUser.h>
#import <MASFoundation/MASSessionSharingQRCode.h>
#import <MASFoundation/MASMessage.h>
```

**Not:**

```objc
#import <MASFoundation/MASObject.h>
#import <MASFoundation/MASAuthenticationProviders.h>
#import <MASFoundation/MASAuthenticationProvider.h>
#import <MASFoundation/MASConfiguration.h>
#import <MASFoundation/MASMessage.h>
#import <MASFoundation/MASDevice.h>
#import <MASFoundation/MASFile.h>
#import <MASFoundation/MASApplication.h>
#import <MASFoundation/MASGroup.h>
#import <MASFoundation/MASUser.h>
#import <MASFoundation/MASSessionSharingQRCode.h>
```

## Constants

Constants are meant to be used 1) for easy reproduction of commonly used values in multiple places in same or multiple classes and 2) to avoid insertion of hard coded values in the implementation file.
For contant values that will be publicly available, place constants in `MASConstant.h` file; otherwise, place constants in `MASConstantsPrivate.h` files.

For constants syntax, always declare the variable as a `static` constant and avoid using `#define` unless it is meant to be used as a macro.

**For example:**

```objc
static NSString *const MASPublicConstantValue = @"MASPublicConstantValue";
```

**Not:**

```objc
#define MASAvoidUsingThisConstant @"MASAvoidUsingThisConstant"
```


## Spacing / Newline

* Use consistent spacing format across all places in the code.
* For indentation, use 4 spaces. In `Xcode's preference > Text Editing > Indentation`, Tab and indent 4 spaces (default value).


### Documentation / In-line Comment

#### Documentation
* For methods, properties, and class documentation, use [VVDocumenter](https://github.com/onevcat/VVDocumenter-Xcode) to ensure consistency for documentation styles.

**For example:**
* Method

```objc
/**
 *  Sets the MASDeviceRegistrationType property.  The default is MASDeviceRegistrationTypeClientCredentials.
 *
 *  @param registrationType The MASDeviceRegistrationType.
 */
+ (void)setDeviceRegistrationType:(MASDeviceRegistrationType)registrationType;
```

* Property

```objc
/**
 *  The class name of the object.
 */
@property (nonatomic, readonly, copy) NSString *className;
```

#### In-line Comment

* Add an in-line comment above the line of code
* Add in-line comments to ensure understanding for other developers
* Use leading and trailing empty in-line comment, `//`
* Add **1 space** between the comments and in-line comment section

**For example:**

```objc
//
// Place an in-line comment like this
//
```

**Not:**

```objc
//Don't do in-line comment like this
```

### Property / Enum

#### Spacing
* Spaces should be added for each word and `*` and `property name` should not have a space.

**For examples:**

* Property

```objc
@property (nonatomic, copy, readwrite) NSString *userName;
```

* Enum

```objc
typedef NS_ENUM(NSInteger, MASDeviceRegistrationType)
```


**Not:**

```objc
@property(nonatomic, copy,readwrite) NSString*userName;
```

#### Newline
* Use __2 new lines__ between each property declaration and **1 new line** for the first property in `pragma mark section` in `.h` file. And use proper documentation for the description of the property.

**For examples:**

```objc
///--------------------------------------
/// @name Managing Object Properties
///--------------------------------------

# pragma mark - Managing Object Properties

/**
 *  The class name of the object.
 */
@property (nonatomic, readonly, copy) NSString *className;


/**
 *  The id of the object.
 */
@property (nonatomic, readonly, copy) NSString *objectId;
```

```objc
///--------------------------------------
/// @name MAS Constants
///--------------------------------------

# pragma mark - MAS Constants

/**
 * The enumerated MASRegistrationTypes.
 */
typedef NS_ENUM(NSInteger, MASDeviceRegistrationType)
{
    /**
     * Unknown encoding type.
     */
    MASDeviceRegistrationTypeUnknown = -1,
    
    /**
     * The client credentials registration type.
     */
    MASDeviceRegistrationTypeClientCredentials,
...
...
};


/**
 * The enumerated MASRequestResponseTypes that can indicate what data format is expected
 * in a request or a response.
 */
typedef NS_ENUM(NSInteger, MASRequestResponseType)
{
...
...
```

**Not:**

```objc
///--------------------------------------
/// @name Managing Object Properties
///--------------------------------------
# pragma mark - Managing Object Properties
/**
 *  The class name of the object.
 */
@property (nonatomic, readonly, copy) NSString *className;
/**
 *  The id of the object.
 */
@property (nonatomic, readonly, copy) NSString *objectId;
```

### Method

#### Spacing
* Use **1 space** after the method scope and between the method segments.
* Use **1 space** between `object type` and `*` for every parameter and return type of the method if needed.

**For example:**

```objc
+ (void)start:(MASCompletionErrorBlock)completion;

+ (MASObject *)currentObject;

- (void)setObject:(id)object forKeyedSubscript:(id <NSCopying>)key;
``` 

**Not:**

```objc
+ (void)start: (MASCompletionErrorBlock)completion;

+(MASObject*)currentObject;

-(void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;
``` 

#### Newline

* Use __3 new lines__ between each method declarations and **1 new line** for the first property in `pragma mark section` in `.h` file.
* Use __2 new lines__ between each method declarations and **1 new line** for the first property in `pragma mark section` in `.m` file.
* Opening and closing braces for method implementation should always be in newline.
* All private methods that are not present in `.h` file should also be documented in `.m` file with same documentation format.

**For example: (.h file)**

```objc
///--------------------------------------
/// @name Accessors
///--------------------------------------

# pragma mark - Accessors

/**
 *  Returns the value associated with a given key.
 *
 *  @param key The given identifying key for which to return the corresponding value.
 *
 *  @return The value associated with a given key.
 */
- (id)objectForKey:(id)key;



/**
 *  Sets the object associated with a given key.
 *
 *  @param object The object for `key`. A strong reference to the object is maintaned by MASObject.
 *                Raises an `NSInvalidArgumentException` if `object` is `nil`.
 *                If you need to represent a `nil` value - use `NSNull`.
 *
 *  @param key    The key for `object`. Raises an `NSInvalidArgumentException` if `key` is `nil`.
 */
- (void)setObject:(id)object forKey:(id <NSCopying>)key;
```

**For example: (.m file)**

```objc
#pragma mark - pragma section

- (id)objectForKey:(id)key
{
...
    return object;
}


- (void)setObject:(id)object forKey:(id <NSCopying>)key
{
...
}
```


### If/Switch/For and other statements

#### Spacing / Newline

* Use **1 space** in between control statement and bracket as well as properties and operator.
* Opening brace should always be in new line for first `if` statement, other `else` or `else if`'s opening brace should be placed in the same line.
* Closing brace should always be in new line.
* Opening and closing brace should always be included even for one line of code in the statement.

**For example:**

```objc
if (isBoolean) 
{
...
}
else {

}

if (isBoolean && isNotBoolean && [[MASObject currentObject] isBoolean]) 
{
...
}
else if (otherBoolean) {
...
}

if (isBoolean)
{
  counter++;
}
```

```objc
switch (type) {
    //
    // Configuration
    //
    case MASSwitchValue:
        value = @"value";
        break;
            
    //
    // Default
    //
    default: 
      value = @"default";
      break;
}

for (NSString *stringObj in objects)
{
...
}
```

**Not:**

```objc
if(isBoolean){
...
}else{

}

if (isBoolean && isNotBoolean&& [[MASObject currentObject]isBoolean]){
...
} else if(otherBoolean) 
{
...
}

if (isBoolean) counter++;

```

```objc
switch(type){
    case MASSwitchValue:
        value = @"value";
        break;
            
    default: 
      value = @"default";
      break;
}

for(NSString *stringObj in objects){
...
}
```

## Nullability for Swift

Because we want to support Swift with bridge header, please be aware of Nullability while writing codes in Objective-C.  In Objective-C, Nullability does not make any difference, but it will make a difference when developers are using our framework in Swift.

Use `_Nullable` and `_Nonnull` type annotation in properties and methods.

**For example:**

```objc
@property (copy, nullable) NSString *name;
@property (copy, readonly, nonnull) NSDictionary *thisDictionary;
```

For more detail, see [this blog post](https://developer.apple.com/swift/blog/?id=25)

## Project Configuration Guideline

Because we are maintaining multiple frameworks, ensure that all frameworks use the same style, format, and file structure.

### File Structure

For any new files or folder (groups in xCode), use the following folder structure.

```objc
- Framework name folder (i.e. MASFoundation, MASUI, MASConnecta)
-- Framework public header file
-- Class (Folder)
--- categories
--- models
--- _private_
---- categories
---- services
---- models
-- Vender
```

* All public files should be located under `Classes`, `categories (under Classes)` and `models (under Classes)`.
* All private files should be located under `categories`, `services`, `models`, or any other folders under `_private` folder.
* When making a new group in Xcode, create an **actual directory** in file system, and add the directory into the project as group.
* If third-party libraries are being used, include them in the `Vendor` folder.
* It is recommended to rename the prefix of third-party libraries to avoid any conflict with other developers' project which may use the same library.
* Verify that you have a valid third-party library license, and that you are allowed to use it.

### Class Naming


* All classes should start with the prefix, `MAS`, except for the category class from iOS SDK or other vendors.

#### All frameworks
* For a newly created model class, the class should be inherited from `MASObject.h`.
* For a newly created service class, the class should be inherited from `MASService.h`.
* For a class used in two or more frameworks, a model of the class must be created in `MASFoundation` and a category of the class in the specific framework.

#### MASService

When you create a new service class, make sure to implement a service class that is inherited from `MASService`.

* Define a constant in `MASConstantsPrivate.h` class with a uniquely generated UUID.
* When you are creating a service class in an external framework outside of `MASFoundation`, include the UUID in `MASConstantsPrivate.h` and use the **same** UUID value in the external service class' `+ (NSString *)serviceUUID` property.

**For example:**

```objc
+ (NSString *)serviceUUID
{
    // DO NOT change this without a corresponding change in MASFoundation
    return @"8b66aaa4-efbf-11e5-9ce9-5e5517507c66";
}
```

#### MASUI
* For a newly created `viewController` class, the class should be inherited from `MASViewController.h`.

#### Category Class
For public category classes, specify the name using the framework name. If the category is not public, use the framework name and the word `Private` in the end. Privates categories must be created under the `_private_` folder.  

**For example:**

```objc
// For public category class
@interface NSData (MASFoundation)

// For private category class. Must reside inside the _private_ folder
@interface MASUser (MASFoundationPrivate)
```

### Framework Error Handling

All frameworks handle errors with proper framework error domains.

In MASConstants, or any framework constant file, properly define the error domain constants.  The error domain format should be **com.ca.FRAMEWORKNAME:SUB_DOMAIN**.

**For example:**

```objc
// The NSString error domain used by all MAS server related Foundation level NSErrors.
static NSString *const MASFoundationErrorDomain = @"com.ca.MASFoundation:ErrorDomain";

// The NSString error domain used by all MAS local level NSErrors.
static NSString *const MASFoundationErrorDomainLocal = @"com.ca.MASFoundation.localError:ErrorDomain";

// The NSString error domain used by all target API level NSErrors.
static NSString *const MASFoundationErrorDomainTargetAPI = @"com.ca.MASFoundation.targetAPI:ErrorDomain";
```
