//
//  MQTTClient.m
//  Connecta
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASMQTTClient.h"

//
//  MAS
//
#import <MASFoundation/MASFoundation.h>
#import "MASAccessService.h"
#import "MASMQTTHelper.h"
#import "MASMQTTConstants.h"

#import "MQTTLog.h"
#import "MQTTSession.h"
#import "MQTTSessionManager.h"
#import "MQTTSessionLegacy.h"
#import "MQTTSessionSynchron.h"
#import "MQTTProperties.h"
#import "MQTTMessage.h"
#import "MQTTTransport.h"
#import "MQTTCFSocketTransport.h"
#import "MQTTCoreDataPersistence.h"
#import "MQTTSSLSecurityPolicyTransport.h"
#import "ReconnectTimer.h"

#if TARGET_OS_IPHONE == 1
#import "MASMQTTForegroundReconnection.h"
#endif

#define kMQTTDefaultPort    1883
#define kMQTTDefaultTLSPort 8883
#define kKeepAliveTime      60

@interface MASMQTTClient () <MQTTSessionDelegate>

@property (nonatomic,copy) void(^connectionCompletionHandler)(NSUInteger code);

//Arrays for the subscription and unsubscription
@property (nonatomic,strong) NSMutableDictionary *subscriptionHandlers;
@property (nonatomic,strong) NSMutableDictionary *subscriptionBlocks;
@property (nonatomic,strong) NSMutableDictionary *unsubscriptionHandlers;

// Dictionary of mid -> completion handlers for messages published with a QoS of 1 or 2
@property (nonatomic,strong) NSMutableDictionary *publishHandlers;
@property (nonatomic,strong) NSMutableDictionary *publishBlocks;

// Dispatch queue to run the mosquitto_loop_forever.
@property (nonatomic,strong) dispatch_queue_t queue;

// Host name
@property (readwrite,copy) NSString *host;

// Username
@property (readwrite,copy) NSString *username;

// Password
@property (readwrite,copy) NSString *password;

// Server Port
@property (readwrite,assign) unsigned short port;

// KeepAlive - in seconds
@property (readwrite, assign) unsigned short keepAlive;

// Connection status
@property (nonatomic,assign) BOOL connected;

// ReconnectDelay - in seconds (default is 1)
@property (readwrite,assign) unsigned int reconnectDelay;

// ReconnectDelayMax - in seconds (default is 1)
@property (readwrite,assign) unsigned int reconnectDelayMax;

// ReconnectExponentialBackoff - wheter to backoff exponentially the reconnect attempts (default is NO)
@property (readwrite,assign) BOOL reconnectExponentialBackoff;

// CleanSession
@property (readwrite,assign) BOOL cleanSession;

//  MQTT Session
@property (readwrite, strong) MQTTSession *currentSession;

//  TLS setting
@property (readwrite, assign) BOOL enableTLS;

//  MQTT connection status
@property (readwrite, assign) MQTTConnectionReturnCode connectionStatus;

//  Reconnect timer
@property (strong, nonatomic) ReconnectTimer *reconnectTimer;

#if TARGET_OS_IPHONE == 1
//  Foreground reconnection manager
@property (strong, nonatomic) MASMQTTForegroundReconnection *foregroundReconnection;
#endif

@end

@implementation MASMQTTClient

static NSString *clientPassword;
static MASMQTTClient *_sharedClient = nil;


#pragma mark - Initialization methods

+ (instancetype)sharedClient
{
    if (!_sharedClient)
    {
        @synchronized(self)
        {
            if ([MASUser currentUser].isAuthenticated && [MASDevice currentDevice].isRegistered)
            {
                
                //
                // Init MQTT client for current gateway
                //
                _sharedClient = [[MASMQTTClient alloc] initWithClientId:[MASMQTTHelper mqttClientId] cleanSession:NO];
                
                //
                //  Configure default security configuration for internal broker's TLS/SSL
                //
                _sharedClient.allowInvalidCertificates = YES;
                _sharedClient.validateCertificateChain = NO;
                _sharedClient.validateDomainName = YES;
                _sharedClient.pinningMode = MASMQTTSSLPinningModeCertificate;
                _sharedClient.pinnedCertificates = [MASConfiguration currentConfiguration].gatewayCertificatesAsDERData;
                
                NSArray *identities = [[MASAccessService sharedService] getAccessValueIdentities];
                NSMutableArray *certificates = [[MASAccessService sharedService] getAccessValueCertificateWithStorageKey:MASKeychainStorageKeySignedPublicCertificate];
                
                //
                //  If identities and certificates are found, add it as client certificate
                //  Identities and certificates will always be present as [MASMQTTClient sharedClient] will only be constructed after device registration and user authentication
                //
                if (identities && certificates)
                {
                    _sharedClient.clientCertificates = @[[identities objectAtIndex:0], [certificates objectAtIndex:0]];
                }
            }
            else {
                
                //Return nil in case Authentication or Registration is not done yet.
                _sharedClient = nil;
            }
        }
    }
    
    return _sharedClient;
}


- (void)clearConnection
{
    __block MASMQTTClient *blockSelf = self;
    [self disconnectWithCompletionHandler:^(NSUInteger code) {
        
        if ([blockSelf isEqual:_sharedClient])
        {
            @synchronized(blockSelf)
            {
                _sharedClient = nil;
            }
        }
    }];
}


- (MASMQTTClient *)initWithClientId:(NSString *)clientId cleanSession:(BOOL)cleanSession
{
    NSParameterAssert(clientId);
    NSParameterAssert(!cleanSession || cleanSession == YES);
    
    if ((self = [super init]))
    {
    
        self.subscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.subscriptionBlocks = [[NSMutableDictionary alloc] init];
        self.unsubscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.publishHandlers = [[NSMutableDictionary alloc] init];
        self.publishBlocks = [[NSMutableDictionary alloc] init];
        
        self.clientID = clientId;
        self.keepAlive = kKeepAliveTime;
        self.cleanSession = cleanSession;
        
        self.reconnectDelay = 1;
        self.reconnectDelayMax = 1;
        self.reconnectExponentialBackoff = NO;

        self.debugMode = NO;
        
        const char *cstrClientId = [self.clientID cStringUsingEncoding:NSUTF8StringEncoding];
        self.queue = dispatch_queue_create(cstrClientId, NULL);
        
        _currentSession = [[MQTTSession alloc] initWithClientId:clientId];
        _currentSession.keepAliveInterval = self.keepAlive;
        _currentSession.cleanSessionFlag = self.cleanSession;
        _currentSession.delegate = self;
        _currentSession.queue = self.queue;
        
        //
        //  SSL/TLS
        //
        self.allowInvalidCertificates = YES;
        self.validateDomainName = NO;
        self.validateCertificateChain = NO;
        self.pinningMode = MASMQTTSSLPinningModeNone;
        
#if TARGET_OS_IPHONE == 1
        self.foregroundReconnection = [[MASMQTTForegroundReconnection alloc] initWithMQTTClient:self];
#endif
        
        //
        //  Subscribe following information to reset the current MQTT session due to the change in SDK's authenticated session
        //
        //  - user logout
        //  - device de-registration
        //  - device reset locally
        //  - gateway switch
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearConnection) name:MASUserDidLogoutNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearConnection) name:MASDeviceDidDeregisterNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearConnection) name:MASDeviceDidResetLocallyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearConnection) name:MASWillSwitchGatewayServerNotification object:nil];
    }

    return self;
}


# pragma mark - Lifecycle

- (void)dealloc
{
    if (_currentSession)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (_currentSession.status == MQTTSessionStatusConnected || _currentSession.status == MQTTSessionStatusConnecting)
        {
            [_currentSession disconnect];
        }
        
        _currentSession = nil;
    }
}


# pragma mark - Properties

- (BOOL)connected
{
    return (_currentSession && _currentSession.status == MQTTSessionStatusConnected);
}


# pragma mark - Setup methods

+ (void)setClientPassword:(NSString *)password
{
    if (clientPassword != password)
    {
        clientPassword = password;
    }
}


-(void)setUsername:(NSString *)username Password:(NSString *)password
{
    NSParameterAssert(username);
    NSParameterAssert(password);
    
    self.username = username;
    self.password = password;
}


- (void)setWill:(NSString *)payload
        toTopic:(NSString *)willTopic
        withQos:(MQTTQualityOfService)willQos
         retain:(BOOL)retain;
{
    NSParameterAssert(payload);
    NSParameterAssert(willTopic);
    NSParameterAssert(willQos >= 0);
    NSParameterAssert(!retain || retain == YES);
    
    [self setWillData:[payload dataUsingEncoding:NSUTF8StringEncoding]
              toTopic:willTopic
              withQos:willQos
               retain:retain];
}


- (void)setWillData:(NSData *)payload
            toTopic:(NSString *)willTopic
            withQos:(MQTTQualityOfService)willQos
             retain:(BOOL)retain
{
    NSParameterAssert(payload);
    NSParameterAssert(willTopic);
    NSParameterAssert(willQos >= 0);
    NSParameterAssert(!retain || retain == YES);
    
    [_currentSession setWillFlag:YES];
    [_currentSession setWillMsg:payload];
    [_currentSession setWillQoS:[self converToMQTTQoS:willQos]];
    [_currentSession setWillTopic:willTopic];
    [_currentSession setWillRetainFlag:retain];
}


#pragma mark - Connection

- (void)clearWill
{
    [_currentSession setWillFlag:NO];
    [_currentSession setWillMsg:nil];
    [_currentSession setWillQoS:0];
    [_currentSession setWillTopic:nil];
    [_currentSession setWillRetainFlag:NO];
}


- (void)connectToHost:(NSString *)hostName completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    [self connectToHost:hostName withTLS:YES completionHandler:completionHandler];
}


- (void)connectToHost:(NSString *)hostName withTLS:(BOOL)tls completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    self.enableTLS = tls;
    
    if (!tls)
    {
        self.port = kMQTTDefaultPort;
    }
    else {
        self.port = kMQTTDefaultTLSPort;
    }
    
    [self connectWithCompletionHandler:completionHandler];
}


-(void)connectWithHost:(NSString *)hostName withPort:(int)port enableTLS:(BOOL)tls completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    self.port = port;
    self.enableTLS = tls;
    
    [self connectWithCompletionHandler:completionHandler];
}


- (void)connectWithCompletionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    //
    //  Logging level based on the debug mode
    //
    [MQTTLog setLogLevel:self.debugMode ? DDLogLevelAll : DDLogLevelOff];

    //
    //  Construct SSL security transport
    //
    MQTTSSLSecurityPolicyTransport *transport = [[MQTTSSLSecurityPolicyTransport alloc] init];
    transport.host = self.host;
    transport.port = self.port;
    transport.tls = self.enableTLS;
    
    if (self.enableTLS)
    {
        //
        //  Convert SSL pinning mode
        //
        MQTTSSLPinningMode mqttPinningMode;
        switch (self.pinningMode) {
            case MASMQTTSSLPinningModeCertificate:
                mqttPinningMode = MQTTSSLPinningModeCertificate;
                break;
            case MASMQTTSSLPinningModePublicKey:
                mqttPinningMode = MQTTSSLPinningModePublicKey;
                break;
            case MASMQTTSSLPinningModeNone:
            default:
                mqttPinningMode = MQTTSSLPinningModeNone;
                break;
        }
        
        //
        //  Security policy for MQTT
        //
        MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:mqttPinningMode];
        securityPolicy.allowInvalidCertificates = self.allowInvalidCertificates;
        securityPolicy.validatesCertificateChain = self.validateCertificateChain;
        securityPolicy.validatesDomainName = self.validateDomainName;
        securityPolicy.pinnedCertificates = self.pinnedCertificates;
        transport.certificates = self.clientCertificates;
        transport.securityPolicy = securityPolicy;
    }
    
    _currentSession.transport = transport;
    
    //
    // If provided, pass username and password to mosquitto
    //
    if (self.username && self.password)
    {
        _currentSession.userName = self.username;
        _currentSession.password = self.password;
    }
    
    //
    // If using gateway, set MAS username and password
    //
    if ([self.clientID isEqualToString:[MASMQTTHelper mqttClientId]])
    {
        _currentSession.userName = [MASUser currentUser].objectId;
        _currentSession.password = [MASUser currentUser].accessToken;
    }
    
    self.connectionCompletionHandler = completionHandler;
    __block MASMQTTClient *blockSelf = self;
    [_currentSession connectWithConnectHandler:^(NSError *error) {
        
        //
        //  If the session connection was successful
        //
        if (error == nil)
        {
            //
            //  Delegation callback
            //
            if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(onConnected:)]) {
                
                [blockSelf.delegate onConnected:blockSelf.connectionStatus];
            }
        }
        
        if (blockSelf.connectionCompletionHandler)
        {
            blockSelf.connectionCompletionHandler(blockSelf.connectionStatus);
        }
    }];
    
    //
    //  Configure retry mechanism
    //
    if (_reconnectTimer != nil)
    {
        [_reconnectTimer stop];
        _reconnectTimer = nil;
    }
    
    _reconnectTimer = [[ReconnectTimer alloc] initWithRetryInterval:_reconnectDelay maxRetryInterval:_reconnectDelayMax queue:_queue reconnectBlock:^{
        
        //
        //  Reconnect
        //
        [blockSelf reconnect];
    }];
}


- (void)disconnectWithCompletionHandler:(MQTTDisconnectionHandler)completionHandler
{
    if (completionHandler)
    {
        self.disconnectionHandler = completionHandler;
    }
    
    if (_connected)
    {
        [_currentSession disconnect];
        [_reconnectTimer stop];
    }
}


- (void)reconnect:(NSNotification *)notification
{
    [self reconnect];
}


- (void)reconnect
{
    if (!_connected)
    {
        [self connectWithCompletionHandler:nil];
    }
}


- (void)triggerReconnect
{
    if (_reconnectTimer && !_connected)
    {
        [_reconnectTimer schedule];
    }
}

#pragma mark - Publish methods

- (void)publishData:(NSData *)payload
            toTopic:(NSString *)topic
            withQos:(MQTTQualityOfService)qos
             retain:(BOOL)retain
         completion:(MQTTPublishingCompletionBlock)completion
{
    //
    //  Validate parameters
    //
    if (payload == nil || [topic isEmpty] || qos < 0)
    {
        NSError *error = [NSError errorWithDomain:@"com.ca.MASFoundation.localError:ErrorDomain"
                                             code:911001
                                         userInfo:@{ NSLocalizedDescriptionKey:@"MQTT error. Invalid parameter(s)." }];
        
        if (completion)
        {
            completion(NO, error, 0);
        }
    }
    
    if (qos == 0 && completion)
    {
        [self.publishBlocks setObject:completion forKey:[NSNumber numberWithInt:0]];
    }
    
    UInt16 messageId = [_currentSession publishData:payload onTopic:topic retain:retain qos:[self converToMQTTQoS:qos]];
    NSNumber *msgId = [NSNumber numberWithInt:messageId];
    
    if (completion)
    {
        if (qos == 0)
        {
            completion(YES, nil, [msgId intValue]);
        }
        else {
            [self.publishBlocks setObject:completion forKey:msgId];
        }
    }
}

    
- (void)publishString:(NSString *)payload
              toTopic:(NSString *)topic
              withQos:(MQTTQualityOfService)qos
               retain:(BOOL)retain
           completion:(MQTTPublishingCompletionBlock)completion
{
    [self publishData:[payload dataUsingEncoding:NSUTF8StringEncoding]
              toTopic:topic
              withQos:qos
               retain:retain
           completion:completion];
 }


#pragma mark - Subscribe/Unsubscribe methods

- (void)subscribeToTopic:(NSString *)topic
          withCompletion:(MQTTSubscriptionCompletionBlock)completion
{
    [self subscribeToTopic:topic withQos:defaultQoS completion:completion];
}


- (void)subscribeToTopic:(NSString *)topic
                 withQos:(MQTTQualityOfService)qos
              completion:(MQTTSubscriptionCompletionBlock)completion
{
    if (_connected)
    {
        //
        //  If the session is connected
        //
        UInt16 msgId = [_currentSession subscribeToTopic:topic atLevel:[self converToMQTTQoS:qos]];
        
        if (completion && msgId)
        {
            [self.subscriptionBlocks setObject:[completion copy] forKey:[NSNumber numberWithInt:msgId]];
        }
    }
    else {
        //
        //  If the session is not connected
        //
        if (completion)
        {
            NSError *error = [NSError errorWithDomain:@"com.ca.MASFoundation.localError:ErrorDomain"
                                                 code:911001
                                             userInfo:@{ NSLocalizedDescriptionKey:@"MQTT error. No connection available" }];
            
            completion(NO, error, nil);
        }
    }
}


- (void)unsubscribeFromTopic:(NSString *)topic
       withCompletionHandler:(MQTTCompletionErrorBlock)completionHandler
{
    if (_connected)
    {
        UInt16 msgId = [_currentSession unsubscribeTopic:topic];
        
        if (completionHandler)
        {
            [self.unsubscriptionHandlers setObject:[completionHandler copy] forKey:[NSNumber numberWithInt:msgId]];
        }
    }
    else {
        
        NSError *error = [NSError errorWithDomain:@"com.ca.MASFoundation.localError:ErrorDomain"
                                             code:911001
                                         userInfo:@{ NSLocalizedDescriptionKey:@"MQTT error. No connection available" }];
        
        if (completionHandler)
        {
            completionHandler(NO, error);
        }
    }
}


#
#   pragma mark - MQTTSessionDelegate
#

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid
{
    // Ensure these objects are cleaned up quickly by an autorelease pool.
    // The GCD autorelease pool isn't guaranteed to clean this up in any amount of time.
    // Source: https://developer.apple.com/library/ios/DOCUMENTATION/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW1
    @autoreleasepool {
        
        MASMQTTMessage *message = [[MASMQTTMessage alloc] initWithTopic:topic
                                                                payload:data
                                                                    qos:[self converToMASQoS:qos]
                                                                 retain:retained
                                                                    mid:mid];
        
        DLog(@"MASMQTT: New message (%@): \n\t\tdata: %@\n\t\ttopic: %@\n\t\tmessage: %@", session, data, topic, message);
        
        //Notification callback
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:MASConnectaOperationDidReceiveMessageNotification object:message];
        
        if (self.messageHandler)
        {
            self.messageHandler(message);
        }
        
        //Delegation callback
        if (self.delegate && [self.delegate respondsToSelector:@selector(onMessageReceived:)])
        {
            
            [self.delegate onMessageReceived:message];
        }
    }

}


- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error
{
    switch (eventCode)
    {
        case MQTTSessionEventConnected:
            //
            //  Reset reconnect interval if the connection is established
            //
            [self.reconnectTimer resetRetryInterval];
            break;
        case MQTTSessionEventConnectionClosedByBroker:
        case MQTTSessionEventConnectionClosed:
        case MQTTSessionEventProtocolError:
        case MQTTSessionEventConnectionRefused:
        case MQTTSessionEventConnectionError:
            //
            //  Trigger reconnection if it was closed by broker, or closed/refused with an error
            //
            [self triggerReconnect];
            break;
        default:
            break;
    }
    DLog(@"MASMQTT: Event happened (%@): \n\t\tevent:%@\n\t\terror: %@", session, [self convertMQTTEventToString:eventCode], error);
}


- (void)connectionRefused:(MQTTSession *)session error:(NSError *)error
{
    _connectionStatus = ConnectionRefusedNotAuthorized;
    DLog(@"MASMQTT: Connection refused (%@): \n\t\terror: %@", session, error);
}


- (void)connected:(MQTTSession *)session
{
    _connected = YES;
    _connectionStatus = ConnectionAccepted;
    DLog(@"MASMQTT: Connection connected: %@", session);
}


- (void)connectionClosed:(MQTTSession *)session
{
    _connected = NO;
    _connectionStatus = ConnectionRefusedNotAuthorized;
    
    if ([self.publishHandlers count] > 0)
    {
        [self.publishHandlers removeAllObjects];
    }
    
    if ([self.subscriptionHandlers count] > 0)
    {
        [self.subscriptionHandlers removeAllObjects];
    }
    
    if ([self.unsubscriptionHandlers count] > 0)
    {
        [self.unsubscriptionHandlers removeAllObjects];
    }
    
    //Delegation callback
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDisconnect:)]) {
        
        [self.delegate onDisconnect:0];
    }
    
    //Notification callback
    [[NSNotificationCenter defaultCenter] postNotificationName:MASConnectaOperationDidDisconnectNotification object:Nil];
    
    //Block callback
    if (self.disconnectionHandler)
    {
        self.disconnectionHandler(0);
    }
    
    DLog(@"MASMQTT: Connection closed: %@", session);
}


- (void)connectionError:(MQTTSession *)session error:(NSError *)error
{
    _connectionStatus = ConnectionRefusedNotAuthorized;
    DLog(@"MASMQTT: Connection error (%@): \n\t\terror: %@", session, error);
}


- (void)protocolError:(MQTTSession *)session error:(NSError *)error
{
    DLog(@"MASMQTT: Protocol error (%@): \n\t\terror: %@", session, error);
}


- (void)messageDelivered:(MQTTSession *)session
                   msgID:(UInt16)msgID
                   topic:(NSString *)topic
                    data:(NSData *)data
                     qos:(MQTTQosLevel)qos
              retainFlag:(BOOL)retainFlag
{
    DLog(@"MASMQTT: Message delivered (%@): \n\t\ttopic: %@\n\t\tdata: %@\n\t\tqos: %@\n\t\tmessage id: %hu", session, topic, data, [self qosToString:qos], msgID);
    
    NSNumber *msgId = [NSNumber numberWithInt:msgID];
    
    //
    //  Deprecated subscription handler
    //
    if ([self.publishHandlers objectForKey:msgId])
    {
        void (^handler)(int) = [self.publishHandlers objectForKey:msgId];
        
        if (handler)
        {
            handler(msgID);
            [self.publishHandlers removeObjectForKey:msgId];
        }
    }
    else if ([self.publishBlocks objectForKey:msgId])
    {
        void (^MQTTPublishingCompletionBlock)(BOOL completed, NSError *_Nullable error, int mid) = [self.publishBlocks objectForKey:msgId];
        
        if (MQTTPublishingCompletionBlock)
        {
            MQTTPublishingCompletionBlock(YES, nil, msgID);
            [self.publishBlocks removeObjectForKey:msgId];
        }
    }
    
    //
    //  MASMQTTClient Deletgation method callback
    //
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPublishMessage:)])
    {
        [self.delegate onPublishMessage:msgId];
    }
}


- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray<NSNumber *> *)qoss
{
    DLog(@"MASMQTT: subAckReceived (%@)\n\t\tmessageID:%hu\n\t\tqoss: %@", session, msgID, qoss);
    
    NSNumber *msgId = [NSNumber numberWithInt:msgID];
    
    //
    //  Deprecated subscription handler
    //
    if ([self.subscriptionHandlers objectForKey:msgId])
    {
        //
        //  Notify granted QoS
        //
        MQTTSubscriptionCompletionHandler handler = [_sharedClient.subscriptionHandlers objectForKey:msgId];
        
        if (handler)
        {
            handler(qoss);
            
            //
            //  Remove the handler
            //
            [self.subscriptionHandlers removeObjectForKey:msgId];
        }
    }
    else if ([self.subscriptionBlocks objectForKey:msgId])
    {
        //
        //  Notify granted QoS
        //
        void (^MQTTSubscriptionCompletionBlock)(BOOL completed, NSError *_Nullable error, NSArray *grantedQos) = [self.subscriptionBlocks objectForKey:msgId];

        if (MQTTSubscriptionCompletionBlock)
        {
            MQTTSubscriptionCompletionBlock(YES, nil, qoss);
            
            //
            //  Remove the completion block
            //
            [self.subscriptionBlocks removeObjectForKey:msgId];
        }
    }
}


- (void)unsubAckReceived:(MQTTSession *)session msgID:(UInt16)msgID
{
    DLog(@"MASMQTT: subAckReceived (%@)\n\t\tmessageID:%hu", session, msgID);
    
    NSNumber *msgId = [NSNumber numberWithInt:msgID];
    
    if ([self.unsubscriptionHandlers objectForKey:msgId])
    {
        //
        //  Notify the unsubscription
        //
        void (^completionHandler)(BOOL completed, NSError *_Nullable error) = [self.unsubscriptionHandlers objectForKey:msgId];

        if (completionHandler)
        {
            completionHandler(YES, nil);
            
            //
            //  Remove the completion handler
            //
            [self.unsubscriptionHandlers removeObjectForKey:msgId];
        }
    }
}


- (void)sending:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data
{
    DLog(@"Sent %@ %@", self.clientID, [self mqttCommandToString:type]);
}


- (void)received:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data
{
    DLog(@"Received %@ %@", self.clientID, [self mqttCommandToString:type]);
}


# pragma mark - Helper methods


- (MQTTQosLevel)converToMQTTQoS:(MQTTQualityOfService)qos
{
    MQTTQosLevel masQoS = MQTTQosLevelAtMostOnce;
    
    switch (qos)
    {
        case AtMostOnce:
            masQoS = MQTTQosLevelAtMostOnce;
            break;
        case AtLeastOnce:
            masQoS = MQTTQosLevelAtLeastOnce;
            break;
        case ExactlyOnce:
            masQoS = MQTTQosLevelExactlyOnce;
            break;
        default:
            break;
    }
    
    return masQoS;
}


- (MQTTQualityOfService)converToMASQoS:(MQTTQosLevel)qos
{
    MQTTQualityOfService masQoS = AtMostOnce;
    
    switch (qos)
    {
        case MQTTQosLevelAtMostOnce:
            masQoS = AtMostOnce;
            break;
        case MQTTQosLevelAtLeastOnce:
            masQoS = AtLeastOnce;
            break;
        case MQTTQosLevelExactlyOnce:
            masQoS = ExactlyOnce;
            break;
        default:
            break;
    }
    
    return masQoS;
}


- (NSString *)qosToString:(MQTTQosLevel)qos
{
    switch (qos) {
        case MQTTQosLevelAtMostOnce:
            return @"MQTTQosLevelAtMostOnce";
            break;
        case MQTTQosLevelAtLeastOnce:
            return @"MQTTQosLevelAtLeastOnce";
            break;
        case MQTTQosLevelExactlyOnce:
            return @"MQTTQosLevelExactlyOnce";
            break;
        default:
            return @"unknown";
            break;
    }
}


- (NSString *)mqttCommandToString:(MQTTCommandType)command
{
    switch (command) {
        case MQTTConnect:
            return @"MQTTConnect";
            break;
        case MQTTConnack:
            return @"MQTTConnack";
            break;
        case MQTTPublish:
            return @"MQTTPublish";
            break;
        case MQTTPuback:
            return @"MQTTPuback";
            break;
        case MQTTPubrec:
            return @"MQTTPubrec";
            break;
        case MQTTPubrel:
            return @"MQTTPubrel";
            break;
        case MQTTPubcomp:
            return @"MQTTPubcomp";
            break;
        case MQTTSubscribe:
            return @"MQTTSubscribe";
            break;
        case MQTTSuback:
            return @"MQTTSuback";
            break;
        case MQTTUnsubscribe:
            return @"MQTTUnsubscribe";
            break;
        case MQTTUnsuback:
            return @"MQTTUnsuback";
            break;
        case MQTTPingreq:
            return @"MQTTPingreq";
            break;
        case MQTTPingresp:
            return @"MQTTPingresp";
            break;
        case MQTTDisconnect:
            return @"MQTTDisconnect";
            break;
        case MQTTAuth:
            return @"MQTTAuth";
            break;
        case MQTT_None:
        default:
            return @"MQTT_None";
            break;
    }
}


- (NSString *)convertMQTTEventToString:(MQTTSessionEvent)event
{
    switch (event) {
        case MQTTSessionEventConnected:
            return @"Connected";
            break;
        case MQTTSessionEventProtocolError:
            return @"Protocol Error";
            break;
        case MQTTSessionEventConnectionError:
            return @"Connection Error";
            break;
        case MQTTSessionEventConnectionClosed:
            return @"Connection Closed";
            break;
        case MQTTSessionEventConnectionRefused:
            return @"Connection Refused";
            break;
        case MQTTSessionEventConnectionClosedByBroker:
        default:
            return @"Connection Closed by Broker";
            break;
    }
}


# pragma mark - Deprecated

- (void)setMessageRetry:(NSUInteger)seconds
{
    
}


-(void)connectWithHost:(NSString *)hostName
              withPort:(int)port
             enableTLS:(BOOL)tls
        usingSSLCACert:(NSString *)certFile
     completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    self.port = port;
    self.enableTLS = tls;
    
    [self connectWithCompletionHandler:completionHandler];
}


+ (NSString *)version
{
    return @"";
}


/** DEPRECATED */
- (void)publishData:(NSData *)payload
            toTopic:(NSString *)topic
            withQos:(MQTTQualityOfService)qos
             retain:(BOOL)retain
  completionHandler:(void(^)(int mid))completionHandler
{
    //
    //  Validate parameters
    //
    if (payload == nil || [topic isEmpty] || qos < 0)
    {
        completionHandler(0);
    }
    
    if (qos == 0 && completionHandler)
    {
        [self.publishHandlers setObject:completionHandler forKey:[NSNumber numberWithInt:0]];
    }
    
    UInt16 messageId = [_currentSession publishData:payload onTopic:topic retain:retain qos:[self converToMQTTQoS:qos]];
    NSNumber *msgId = [NSNumber numberWithInt:messageId];
    
    if (completionHandler)
    {
        if (qos == 0)
        {
            completionHandler([msgId intValue]);
        }
        else {
            [self.publishHandlers setObject:[completionHandler copy] forKey:msgId];
        }
    }
}


/** DEPRECATED */
- (void)publishString:(NSString *)payload
              toTopic:(NSString *)topic
              withQos:(MQTTQualityOfService)qos
               retain:(BOOL)retain
    completionHandler:(void(^)(int mid))completionHandler
{
    NSParameterAssert(payload);
    NSParameterAssert(topic);
    NSParameterAssert(qos >= 0);
    NSParameterAssert(!retain || retain == YES);
    
    [self publishData:[payload dataUsingEncoding:NSUTF8StringEncoding]
              toTopic:topic
              withQos:qos
               retain:retain
    completionHandler:completionHandler];
}


/** DEPRECATED */
- (void)subscribeToTopic:(NSString *)topic
   withCompletionHandler:(MQTTSubscriptionCompletionHandler)completionHandler
{
    [self subscribeToTopic:topic withQos:defaultQoS completionHandler:completionHandler];
}


/** DEPRECATED */
- (void)subscribeToTopic:(NSString *)topic
                 withQos:(MQTTQualityOfService)qos
       completionHandler:(MQTTSubscriptionCompletionHandler)completionHandler
{
    if (_connected)
    {
        //
        //  If the session is connected
        //
        UInt16 msgId = [_currentSession subscribeToTopic:topic atLevel:[self converToMQTTQoS:qos]];
        
        if (completionHandler && msgId)
        {
            [self.subscriptionHandlers setObject:[completionHandler copy] forKey:[NSNumber numberWithInt:msgId]];
        }
    }
    else {
        //
        //  If the session is not connected
        //
        if (completionHandler)
        {
            completionHandler(nil);
        }
    }
}

@end
