//
//  MASMQTTClient.h
//  Connecta
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import UIKit;
@import Foundation;

#import "MASMQTTMessage.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - MQTT Connection Return Codes & Messages

/**
 *  The enumerated MQTTConnectionReturnCode.
 */
typedef NS_ENUM(NSUInteger,MQTTConnectionReturnCode)
{
    /**
     *  Connection Accepted
     */
    ConnectionAccepted,
    
    /**
     *  Connection Refused - Unacceptable Protocol Version
     */
    ConnectionRefusedUnacceptableProtocolVersion,
    
    /**
     *  Connection Refused - Identifier Rejected
     */
    ConnectionRefusedIdentifierRejected,
    
    /**
     *  Connection Refused - Server Unavailable
     */
    ConnectionRefusedServerUnavailable,
    
    /**
     *  Connection Refused - Bad UserName or Password
     */
    ConnectionRefusedBadUserNameOrPassword,
    
    /**
     *  Connection Refused - Not Authorized
     */
    ConnectionRefusedNotAuthorized
};



#define MQTTConnectionReturnMessage   @[NSLocalizedString(@"Connection Accepted", nil), NSLocalizedString(@"Connection Refused - Unacceptable Protocol Version", nil),NSLocalizedString(@"Connection Refused - Identifier Rejected", nil), NSLocalizedString(@"Connection Refused - Server Unavailable", nil), NSLocalizedString(@"Connection Refused - Bad Username or Password", nil), NSLocalizedString(@"Connection Refused - Not Authorized", nil)]


#pragma mark - Return Blocks

/**
 *  MQTTSubscriptionCompletionHandler
 *
 *  @param grantedQos The array of QoS
 */
typedef void (^MQTTSubscriptionCompletionHandler)(NSArray *grantedQos);



/**
 * A standard (BOOL completed, NSError *error) block.
 */
typedef void (^MQTTCompletionErrorBlock)(BOOL completed, NSError *_Nullable error);



/**
 *  MQTTMessageHandler
 *
 *  @param message The MASMQTTMessage object
 */
typedef void (^MQTTMessageHandler)(MASMQTTMessage *message);



/**
 *  MQTTDisconnectionHandler
 *
 *  @param code The returned code
 */
typedef void (^MQTTDisconnectionHandler)(NSUInteger code);



#pragma mark - Delegation

@protocol MASConnectaMessagingClientDelegate <NSObject>

- (void)onMessageReceived:(MASMQTTMessage *)message;
- (void)onPublishMessage:(NSNumber *)messageId;
- (void)onConnected:(MQTTConnectionReturnCode)rc;
- (void)onDisconnect:(MQTTConnectionReturnCode)rc;

@end

#pragma mark - MQTT Connection Notifications

static NSString * const MASConnectaOperationDidConnectNotification = @"com.ca.networking.operation.connect";
static NSString * const MASConnectaOperationDidDisconnectNotification = @"com.ca.networking.operation.disconnect";
static NSString * const MASConnectaOperationDidReceiveMessageNotification = @"com.ca.messaging.receive";

/**
 *  This class is used to create a MQTT Client to connect to any broker
 */
@interface MASMQTTClient : NSObject {
    
    struct mosquitto *mosq;
}

//Delegate - used to set the delegation class
@property (nonatomic, weak) id<MASConnectaMessagingClientDelegate> delegate;

//Connected - Used to identify the connection status
@property (nonatomic, readonly, assign) BOOL connected;

//MessageHandler - block used for message callback from the broker
@property (nonatomic, copy) MQTTMessageHandler messageHandler;

//DisconnectionHandler - block used for disconnect callback from the broker
@property (nonatomic, copy) MQTTDisconnectionHandler disconnectionHandler;

//DebugMode - Used for displaying SDK log messages for debugging purpose
@property (nonatomic, assign) BOOL debugMode;

// MQTT specification restricts client ids to a maximum of 23 characters
@property (readwrite,copy) NSString *clientID;

#pragma mark - Lifecycle

/**
 *  Singlenton instance of the MQTTClient
 *
 *  @return Singlenton instance of the MQTTClient
 */
+ (instancetype)sharedClient;



#pragma mark - Initialization methods

/**
 *  Init Method specifying the ClientID and Session (Clean / Reuse old one if any)
 *
 *  @param clientId     The Client identifier to be used by the MQTTClient
 *  @param cleanSession - YES value will start a new and clean Session with the server. NO will reuse the existing one.
 *
 *  @return MASMQTTClient instance
 */
- (MASMQTTClient *)initWithClientId:(NSString *)clientId cleanSession:(BOOL)cleanSession;


#pragma mark - Utilities methods


/**
 *  Set the username and password to be used in the connection with the broker
 *  NOTE: Must be called before calling connect method incase you are using username and password
 *
 *  @param username The UserName parameter
 *  @param password The Password parameter
 */
-(void)setUsername:(NSString *)username Password:(NSString *)password;



/**
 *  Used to Remove the previously configured Will message.
 */
- (void)clearWill;



/**
 *  Used to Set the number of seconds to wait before retrying messages.
 *
 *  @param seconds - The number of seconds until the next retry
 */
- (void)setMessageRetry:(NSUInteger)seconds;



/**
 *  Used to Configure Will information for a MASMQTTClient instance. This message will be sent when client disconnected from the server.
 *
 *  @param payload   - Message Payload
 *  @param willTopic - Topic that will be send the Will message
 *  @param willQos   - Qos related the Will message
 *  @param retain    - YES to retain the message or NO to otherwise
 */
- (void)setWill:(NSString *)payload
        toTopic:(NSString *)willTopic
        withQos:(MQTTQualityOfService)willQos
         retain:(BOOL)retain;



/**
 *  Shows the version of the Mosquitto Library used
 *
 *  @return The libmosquitto version
 */
+ (NSString*)version;


#pragma mark - Connection methods

/**
 *  Used to Connect to a specific host using TLS as default. It uses a completion handler that allows the developer to call some code depending on the connection response.
 *
 *  @param hostName          The host to connect to
 *  @param completionHandler The completionHandler code block
 */
- (void)connectToHost:(NSString*)hostName completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler;



/**
 *  Used to Connect to a specific host using TLS or not. It uses a completion handler that allows the developer to call some code depending on the connection response.
 *  If TLS Flag is set then it connects to the default port 8883, if not then it connects to 1883 (non tls)
 *
 *  @param hostName                        The host to connect to
 *  @param tls                             Set TLS to True or False during connection
 *  @param completionHandler               The completionHandler code block
 */
- (void)connectToHost:(NSString *)hostName
              withTLS:(BOOL)tls
    completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler;



/**
 *  Connect with remote server with host name, tls flag and port number.
 *  NOTE: Use this if you want to explicitly specify the port number in your application in case you are not using standard ports
 *
 *  @param hostName          The host to connect to
 *  @param port              The port to be used in the connection
 *  @param tls               Set TLS to True or False during connection
 *  @param completionHandler The completionHandler code block
 */
-(void)connectWithHost:(NSString *)hostName
              withPort:(int)port
             enableTLS:(BOOL)tls
     completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler;



/**
 *  Connect with remote server with host name, tls flag , port number and server certificate file.
 *
 *  @param hostName          The host to connect to
 *  @param port              The port to be used in the connection
 *  @param tls               Set TLS to True or False during connection
 *  @param certFile          The path to the cert file
 *  @param completionHandler The completionHandler code block
 */
-(void)connectWithHost:(NSString *)hostName
              withPort:(int)port
             enableTLS:(BOOL)tls
        usingSSLCACert:(NSString *)certFile
     completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler;



/**
 *  Used to Disconnect from the host. It uses a completion handler that allows the developer to take actions after the disconnect.
 *
 *  @param completionHandler The completionHandler code block
 */
- (void)disconnectWithCompletionHandler:(MQTTDisconnectionHandler)completionHandler;



/**
 *  Used to Reconnect to the last connected host
 */
- (void)reconnect;


#pragma mark - Publish methods

/**
 *  Used to Publish a message on a given topic
 *
 *  @param payload           The Payload to be sent
 *  @param topic             The Topic to be sent
 *  @param qos               The Quality of Service to be used
 *  @param retain            Set to true to make the message retained
 *  @param completionHandler The completionHandler code block
 */
- (void)publishString:(NSString *)payload
              toTopic:(NSString *)topic
              withQos:(MQTTQualityOfService)qos
               retain:(BOOL)retain
    completionHandler:(void(^)(int mid))completionHandler;


#pragma mark - Subscribe methods

/**
 *  Used to Subscribe to a topic using QoS = 0. Use subscribeToTopicWithQos method to set a different QoS level
 *
 *  @param topic             The Topic to be subscribed
 *  @param completionHandler The completionHandler code block
 */
- (void)subscribeToTopic:(NSString *)topic
   withCompletionHandler:(MQTTSubscriptionCompletionHandler)completionHandler;



/**
 *  Used to Subscribe to a topic using a specific Quality of Service
 *
 *  @param topic             The Topic to be subscribed to
 *  @param qos               The Quality of Service to be used
 *  @param completionHandler The completionHandler code block
 */
- (void)subscribeToTopic:(NSString *)topic
                 withQos:(MQTTQualityOfService)qos
       completionHandler:(MQTTSubscriptionCompletionHandler)completionHandler;



#pragma mark - Unsubscribe methods

/**
 *  Used to Unsubscribe from a topic
 *
 *  @param topic             The Topic to be unsubscribed from
 *  @param completionHandler The completionHandler code block
 */
- (void)unsubscribeFromTopic:(NSString *)topic
       withCompletionHandler:(MQTTCompletionErrorBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
