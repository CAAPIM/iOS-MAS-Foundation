//
//  MASConfigurationService.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASConfigurationService.h"

#import "MASIFileManager.h"



@implementation MASConfigurationService

static NSString *_configurationFileName_ = @"msso_config";
static NSString *_configurationFileType_ = @"json";
static NSDictionary *_newConfigurationObject_ = nil;
static BOOL _newConfigurationDetected_ = NO;


# pragma mark - Properties

+ (void)setConfigurationFileName:(NSString *)fileName
{
    _configurationFileName_ = fileName;
}


+ (void)setNewConfigurationObject:(NSDictionary *)configuration
{
    _newConfigurationObject_ = configuration;
    _newConfigurationDetected_ = YES;
}


+ (NSDictionary *)getDefaultConfigurationAsDictionary
{
    //
    // Retrieve the path to the required json file
    //
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:_configurationFileName_
                                                         ofType:_configurationFileType_];
    
    if(!jsonPath)
    {
        return nil;
    }
    
    //
    // Retrieve the data in the json file
    //
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    //
    // Detect json configuration file serialization error and stop here
    //
    if(!info || error)
    {
        return nil;
    }
    
    return info;
}


# pragma mark - Shared Service

+ (instancetype)sharedService
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[MASConfigurationService alloc] initProtected];
    });
    
    return sharedInstance;
}


# pragma mark - Lifecycle

+ (NSString *)serviceUUID
{
    return MASConfigurationServiceUUID;
}


- (void)serviceDidLoad
{

    [super serviceDidLoad];
}


- (void)serviceWillStart
{
    //
    // Attempt to retrieve the current configuration from local storage
    //
    _currentConfiguration = [MASConfiguration instanceFromStorage];
    
    //DLog(@"called and retrieved stored configuration: %@\n\n", [_currentConfiguration debugDescription]);
    
    //
    // If found but it is an unloaded version that was somehow stored remove
    // it to start fresh below ... just a safety precaution as it can get into
    // a weird state if this happens
    //
    if(!self.currentConfiguration.isLoaded)
    {
        [self.currentConfiguration reset];
        _currentConfiguration = nil;
    }
    //
    // If the configuration is being loaded dynamically by JSON as parameter,
    // reset the current configuration and load it from the object.
    //
    else if (_newConfigurationDetected_)
    {
        [self.currentConfiguration reset];
        _currentConfiguration = nil;
    }
    
    //
    // If no locally stored configuration is found
    //
    if(!self.currentConfiguration)
    {
        NSDictionary *info = nil;
        
        //
        // If the JSON configuration object was set
        //
        if (_newConfigurationObject_ && _newConfigurationDetected_)
        {
            info = _newConfigurationObject_;
            _newConfigurationDetected_ = NO;
        }
        //
        // Otherwise, load it from default configuration file
        //
        else {
            NSString *fileName = [NSString stringWithFormat:@"%@.%@", _configurationFileName_, _configurationFileType_];
            
            //
            // Retrieve the path to the required json file
            //
            NSString *jsonPath = [[NSBundle mainBundle] pathForResource:_configurationFileName_
                                                                 ofType:_configurationFileType_];
            
            //
            // Detect json configuration file missing and stop here
            //
            if(!jsonPath)
            {
                [self serviceDidFailWithError:[NSError errorConfigurationLoadingFailedFileNotFound:fileName]];
                
                return;
            }
            
            //
            // Retrieve the data in the json file
            //
            NSData *data = [NSData dataWithContentsOfFile:jsonPath];
            NSError *error = nil;
            info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            //
            // Detect json configuration file serialization error and stop here
            //
            if(!info || error)
            {
                [self serviceDidFailWithError:[NSError errorConfigurationLoadingFailedJsonSerialization:fileName description:[error localizedDescription]]];
                
                return;
            }
        }
        
        //
        //  Validate JSON content for given rules
        //
        NSError *validationError = [MASConfiguration validateJSONConfiguration:info];
        
        //
        //  If there is any error from validation, return an error
        //
        if (validationError)
        {
            [self serviceDidFailWithError:validationError];
            
            return;
        }
        
        //
        // Create a new configuration object
        //
        _currentConfiguration = [[MASConfiguration alloc] initWithConfigurationInfo:info];
        
        //
        //  Catch an exception for parsing certificate
        //
        @try {
            NSArray *gatewayCert = _currentConfiguration.gatewayCertificatesAsDERData;
            //DLog(@"gateway cert : %@", gatewayCert);
        }
        @catch (NSException *exception) {
            
            NSError * certError = [NSError errorWithDomain:exception.name code:MASExceptionErrorCodeInvalidCertificate userInfo:@{NSLocalizedDescriptionKey:exception.description}];
            
            [self serviceDidFailWithError:certError];
            
            return;
        }
        
        //
        // If created then store it to local storage
        //
        if(_currentConfiguration)
        {
           [_currentConfiguration saveToStorage];
        }
    }
    
    //DLog(@"\n\ndone and current configuration is:\n\n%@\n\n", [_currentConfiguration debugDescription]);
    
    [super serviceWillStart];
}


- (void)serviceDidReset
{
    //DLog(@"called");
    
    if(self.currentConfiguration)
    {
        [self.currentConfiguration reset];
        _currentConfiguration = nil;
    }
    
    [super serviceDidReset];
}


- (void)serviceDidStop
{
    
    if (_newConfigurationObject_)
    {
        _newConfigurationObject_ = nil;
    }
    
    [super serviceDidStop];
}

# pragma mark - Public

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@\n\n    configuration: %@",
        [super debugDescription],
        [self.currentConfiguration debugDescription]];
}

@end
