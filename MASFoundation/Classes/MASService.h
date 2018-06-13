//
//  MASService.h
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import Foundation;


/**
 * The enumerated status for the Lifecycle of the micro services.
 */
typedef NS_ENUM(NSInteger, MASServiceLifecycleStatus)
{
    MASServiceLifecycleStatusUnknown = -1,
    MASServiceLifecycleStatusInitialized,
    MASServiceLifecycleStatusLoaded,
    MASServiceLifecycleStatusWillStart,
    MASServiceLifecycleStatusDidStart,
    MASServiceLifecycleStatusWillStop,
    MASServiceLifecycleStatusDidStop,
    MASServiceLifecycleStatusStateCount
};


/**
 *  MASService is the base class for all services which are to be run during
 *  the internal service's lifecycle.
 */
@interface MASService : NSObject



///--------------------------------------
/// @name Properties
///-------------------------------------

# pragma mark - Properties

/**
 * The current MASServiceLifecycleStatus of the MASService.
 */
@property (nonatomic, assign, readonly) MASServiceLifecycleStatus lifecycleStatus;



///--------------------------------------
/// @name Shared Service
///-------------------------------------

# pragma mark - Shared Service

/**
 * Retrieve the shared MASService singleton.
 *
 * Note, subclasses should override this version of the method.
 *
 * @return Returns the shared MASService singleton.
 */
+ (instancetype _Nullable)sharedService;



///--------------------------------------
/// @name Lifecycle
///-------------------------------------

# pragma mark - Lifecycle

/**
 * Retreives the UUID assigned to a particular MASService subclass.  All subclasses MUST
 * implement this method with a unique value.  If it does not the super version will
 * return null and the services will be rejected for membership in the internal MASService
 * process.
 *
 * @return Return the UUID assigned to the MASService subclass.
 */
+ (NSString *_Nullable)serviceUUID;



/**
 * The lifecycle method to indicate to the service to perform an processes or
 * acquire any resources it requires at the MASServiceLifecycleStatusLoaded state.
 *
 * Subclasses should override this to do this for their specific requirements.
 */
- (void)serviceDidLoad;



/**
 * The lifecycle method to indicate the service should perform any processes or
 * acquire any resources BEFORE it enters the MASServiceLifecycleStatusWillStart state.
 *
 * Subclasses should override this to do this for their specific requirements.
 * They should call this super version at the start of their override.
 */
- (void)serviceWillStart;



/**
 * The lifecycle method to indicate the service should perform any processes or
 * acquire any resources at the MASServiceLifecycleStatusDidStart state.
 *
 * Subclasses should override this to do this for their specific requirements.
 * They should call this super version at the start of their override.
 */
- (void)serviceDidStart;



/**
 * The lifecycle method to indicate the service should perform any processes or
 * release any resources BEFORE it enters the MASServiceLifecycleStatusWillStop state.
 *
 * Subclasses should override this to do this for their specific requirements.
 * They should call this super version at the start of their override.
 */
- (void)serviceWillStop;



/**
 * The lifecycle method to indicate the service should perform any processes or
 * release any resources at the MASServiceLifecycleStatusDidStop state.
 *
 * Subclasses should override this to do this for their specific requirements.
 * They should call this super version at the start of their override.
 */
- (void)serviceDidStop;



/**
 * The lifecycle method to indicate the service should perform any processes or
 * release any resources to bring the service to a default installation state.
 *
 * Subclasses should override this to do this for their specific requirements.
 * They should call this super version at the start of their override.
 */
- (void)serviceDidReset;



///--------------------------------------
/// @name Lifecycle Status
///-------------------------------------

# pragma mark - Lifecycle Status

/**
 * Retrieve a human readable string value for the current MASServiceLifecycleStatus.
 *
 * @return Returns the MASServiceLifecycleStatus in a human readable string.
 */
- (NSString *_Nonnull)lifecycleStatusAsString;



/**
 * Retrieve a human readable string value for the given MASServiceLifecycleStatus.
 *
 * @param status The MASServiceLifecycleStatus.
 * @return Returns the MASServiceLifecycleStatus in a human readable string.
 */
+ (NSString *_Nonnull)lifecycleStatusToString:(MASServiceLifecycleStatus)status;



///--------------------------------------
/// @name Subclass Registry Methods
///-------------------------------------

# pragma mark - Subclass Registry Methods


/**
 An array of subclass information that is inherited and registered to MASService class

 @return An array of subclasses of MASService
 */
+ (NSArray * _Nullable)getSubclasses;



/**
 A method to register any inherited MASService class to MASServiceRegistry.
 
 @warning Any class that is subclassing `MASService` class MUST register through this method with its own service UUID.  `serviceUUID` MUST be unique to its service, and MUST be registered inside `MASFoundation` to be recognized at the moment.

 @param subclass Class object of subclass
 @param serviceUUID NSString value of its own unique serviceUUID that was registered on MASFoundation
 */
+ (void)registerSubclass:(Class _Nonnull)subclass serviceUUID:(NSString * _Nonnull)serviceUUID;

@end



///--------------------------------------
/// @name Subclass Protected Methods
///-------------------------------------

# pragma mark - Subclass Protected Methods

@interface MASService (SubclassingHooks)

/**
 * Protected initializer to be used by subclasses.  The default init of this
 * object will throw an exception to prevent usage.
 *
 * @return Returns an instance of the MASService.
 */
- (instancetype _Nullable)initProtected;



/**
 * Call for subclasses to use to indicate an error has occurred.
 *
 * @param error the NSError that the service experienced.
 */
- (void)serviceDidFailWithError:(NSError *_Nullable)error;


@end

