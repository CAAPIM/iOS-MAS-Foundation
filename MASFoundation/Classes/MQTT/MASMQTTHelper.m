//
//  MASMQTTHelper.m
//  MASFoundation
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASMQTTHelper.h"

#import "MASMQTTClient.h"
#import "MASMQTTConstants.h"


@implementation MASMQTTHelper

+ (void)showLogMessage:(NSString *)message debugMode:(BOOL)debugMode
{
    NSParameterAssert(message);
    
    if (debugMode) {
        
        DLog(@"%@",message);
    }
}


+ (NSString *)mqttClientId
{
    //MQTT ClientId is: <mag_device_id>::<mag_client_id>::<SCIM userID>
    NSString *clientId = [NSString stringWithFormat:@"%@::%@::%@",[MASDevice currentDevice].identifier,[MASApplication currentApplication].identifier,[MASUser currentUser].objectId];
    
    return clientId;
}


+ (NSString *)buildMessageWithString:(NSString *)message andUser:(NSString *)userName
{
    NSParameterAssert(message);
    NSParameterAssert(userName);
    
    //TODO: Add the datatime to this payload
    NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"USER",@"SenderType",
                                 userName,@"DisplayName",
                                 @"text/plain",@"ContentType",
                                 message,@"Payload",
                                 nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


//
//Format the topic depending on the object requesting this format
//Note: This format is compatible only with version 1.0 of the MQTT Policy on the Gateway
//
+ (NSString *)structureTopic:(NSString *)topic forObject:(MASObject *)masObject
{
    NSParameterAssert(topic);
    
    if (!masObject) {
        
        return topic;
    }
    
    NSString *structuredTopic;
    
    NSString *apiVersion = topicApiVersion;
    NSString *organization = [MASConfiguration currentConfiguration].applicationOrganization;
    NSString *clientID = [MASApplication currentApplication].identifier;
    NSString *objectID = masObject.objectId;
    
    
    //
    //MASUser sending message
    //
    if ([masObject isKindOfClass:[MASUser class]]) {
        
        structuredTopic = [NSString stringWithFormat:@"/%@/organization/%@/client/%@/users/%@/custom/%@",apiVersion,organization,clientID,objectID,topic];
    }
    
    
    //
    //MASDevice sending message
    //
    else if ([masObject isKindOfClass:[MASDevice class]]) {
        
        structuredTopic = [NSString stringWithFormat:@"/%@/organization/%@/client/%@/devices/%@/custom/%@",apiVersion,organization,clientID,objectID,topic];
    }
    
    
    //
    //MASApplication sending message
    //
    else if ([masObject isKindOfClass:[MASApplication class]]) {
        
        structuredTopic = [NSString stringWithFormat:@"/%@/organization/%@/client/%@/custom/%@",apiVersion,organization,clientID,topic];
    }
    
    
    //
    //MASGroup sending message
    //
    //    else if ([masObject isKindOfClass:[MASGroup class]]) {
    //
    //        structuredTopic = [NSString stringWithFormat:@"/%@/organization/%@/client/%@/groups/%@/custom/%@",apiVersion,organization,clientID,objectID,topic];
    //    }
    
    return structuredTopic; //[structuredTopic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
