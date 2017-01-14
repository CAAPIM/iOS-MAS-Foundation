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
#import "mosquitto.h"
#import "MASMQTTHelper.h"
#import "MASMQTTConstants.h"

#import <MASFoundation/MASFoundation.h>
#import "MASSecurityService.h"

#define kMQTTDefaultPort    1883
#define kMQTTDefaultTLSPort 8883
#define kKeepAliveTime      60

NSString * const MAG_CLIENT_CERTIFICATES= @"mag_client_certificates";
NSString * const MAG_SERVER_CERTIFICATES= @"mag_server_certificates";

@interface MASMQTTClient ()

@property (nonatomic,copy) void(^connectionCompletionHandler)(NSUInteger code);

//Arrays for the subscription and unsubscription
@property (nonatomic,strong) NSMutableDictionary *subscriptionHandlers;
@property (nonatomic,strong) NSMutableDictionary *unsubscriptionHandlers;

// Dictionary of mid -> completion handlers for messages published with a QoS of 1 or 2
@property (nonatomic,strong) NSMutableDictionary *publishHandlers;

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

@end

@implementation MASMQTTClient

static NSString *clientPassword;
static MASMQTTClient *_sharedClient = nil;

#pragma mark - Initialization methods

+ (instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    
    if (!_sharedClient) {

        dispatch_once(&onceToken, ^{
            
            if ([MASUser currentUser].isAuthenticated && [MASDevice currentDevice].isRegistered) {

                _sharedClient = [[MASMQTTClient alloc] initWithClientId:[MASMQTTHelper mqttClientId] cleanSession:NO];
            }
            else {
            
                //Return nil in case Authentication or Registration is not done yet.
                _sharedClient = nil;
            }
        });
    }
    
    return _sharedClient;
}


// Initialize is called just before the first object is allocated
- (void)initialize
{
    mosquitto_lib_init();
}


//- (MASMQTTClient *)init
//{
////    if (!self.clientID) {
////        
////        self.clientID = [Helper mqttClientId];
////    }
//    self.clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
//    
//    return [self initWithClientId:self.clientID cleanSession:NO];
//}


//- (MASMQTTClient *)initWithCleanSession:(BOOL)cleanSession
//{
//    NSParameterAssert(!cleanSession || cleanSession == YES);
//    
////    if (!self.clientID) {
////        
////        self.clientID = [Helper mqttClientId];
////    }
//    self.clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
//    
//    return [self initWithClientId:self.clientID cleanSession:cleanSession];
//}


- (MASMQTTClient *)initWithClientId:(NSString *)clientId cleanSession:(BOOL)cleanSession
{
    NSParameterAssert(clientId);
    NSParameterAssert(!cleanSession || cleanSession == YES);
    
    if ((self = [super init])) {
        
        self.clientID = clientId;
        self.keepAlive = kKeepAliveTime;
        self.reconnectDelay = 1;
        self.reconnectDelayMax = 1;
        self.reconnectExponentialBackoff = NO;
        
        self.subscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.unsubscriptionHandlers = [[NSMutableDictionary alloc] init];
        self.publishHandlers = [[NSMutableDictionary alloc] init];
        self.cleanSession = cleanSession;
        
        const char *cstrClientId = [self.clientID cStringUsingEncoding:NSUTF8StringEncoding];
        
        [self initialize];
        
        mosq = mosquitto_new(cstrClientId, self.cleanSession, (__bridge void *)(self));
        
        mosquitto_connect_callback_set(mosq, on_connect);
        mosquitto_disconnect_callback_set(mosq, on_disconnect);
        mosquitto_publish_callback_set(mosq, on_publish);
        mosquitto_message_callback_set(mosq, on_message);
        mosquitto_subscribe_callback_set(mosq, on_subscribe);
        mosquitto_unsubscribe_callback_set(mosq, on_unsubscribe);
        
        //Enabling Debug - Get this data from MASFoundation TBD
//        if (self.debugMode) {
        
            mosquitto_log_callback_set(mosq, on_log);
//        }
        
        self.queue = dispatch_queue_create(cstrClientId, NULL);
    }
    
    _sharedClient = self;
    
    return self;
}

#pragma mark - Setup methods

-(void)setUsername:(NSString *)username Password:(NSString *)password
{
    NSParameterAssert(username);
    NSParameterAssert(password);
    
    self.username = username;
    self.password = password;
}


- (void)setMessageRetry:(NSUInteger)seconds
{
    NSParameterAssert(seconds);
    mosquitto_message_retry_set(mosq, (unsigned int)seconds);
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
    
    const char *cstrTopic = [willTopic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_will_set(mosq, cstrTopic, (int)payload.length, payload.bytes, willQos, retain);
}


#pragma mark - Mosquitto callback methods

static void on_connect(struct mosquitto *mosq, void *obj, int rc)
{
    _sharedClient = (__bridge MASMQTTClient *)obj;
    
    [MASMQTTHelper showLogMessage:[NSString stringWithFormat:@"[%@] on_connect rc = %d", _sharedClient.clientID, rc]
                 debugMode:_sharedClient.debugMode];
    
    [MASMQTTClient sharedClient].connected = (rc == ConnectionAccepted);
    
    //Notification callback 
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:MASConnectaOperationDidConnectNotification object:Nil];
    
    //Delegation callback
    if (_sharedClient.delegate && [_sharedClient.delegate respondsToSelector:@selector(onConnected:)]) {
        
        [_sharedClient.delegate onConnected:rc];
    }
    
    //Block callback
    if (_sharedClient.connectionCompletionHandler) {
        
        _sharedClient.connectionCompletionHandler(rc);
    }
    
    //Subscribe to default Topics
//    [_sharedClient subscribeToDefaultTopics];
}


static void on_disconnect(struct mosquitto *mosq, void *obj, int rc)
{
    _sharedClient = (__bridge MASMQTTClient *)obj;
    
    [MASMQTTHelper showLogMessage:[NSString stringWithFormat:@"[%@] on_disconnect rc = %d", _sharedClient.clientID, rc]
                 debugMode:_sharedClient.debugMode];
    
    if ([_sharedClient.publishHandlers count] > 0) {
        [_sharedClient.publishHandlers removeAllObjects];
    }
    if ([_sharedClient.subscriptionHandlers count] > 0) {
        [_sharedClient.subscriptionHandlers removeAllObjects];
    }
    if ([_sharedClient.unsubscriptionHandlers count]>0) {
        [_sharedClient.unsubscriptionHandlers removeAllObjects];
    }
    
    _sharedClient.connected = NO;
    
    //Notification callback
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:MASConnectaOperationDidDisconnectNotification object:Nil];
    
    //Delegation callback
    if (_sharedClient.delegate && [_sharedClient.delegate respondsToSelector:@selector(onDisconnect:)]) {
        
        [_sharedClient.delegate onDisconnect:rc];
    }
    
    //Block callback
    if (_sharedClient.disconnectionHandler) {
        
        _sharedClient.disconnectionHandler(rc);
    }
}


static void on_publish(struct mosquitto *mosq, void *obj, int message_id)
{
    _sharedClient = (__bridge MASMQTTClient *)obj;
    
    NSNumber *mid = [NSNumber numberWithInt:message_id];
    void (^handler)(int) = [_sharedClient.publishHandlers objectForKey:mid];
    
    if (handler) {
        
        handler(message_id);
        
        if (message_id > 0) {
            
            [_sharedClient.publishHandlers removeObjectForKey:mid];
        }
    }
    
    //Delegation callback
    if (_sharedClient.delegate && [_sharedClient.delegate respondsToSelector:@selector(onPublishMessage:)]) {
        
        [_sharedClient.delegate onPublishMessage:[NSNumber numberWithInt:message_id]];
    }
}


static void on_message(struct mosquitto *mosq, void *obj, const struct mosquitto_message *mosq_msg)
{
    // Ensure these objects are cleaned up quickly by an autorelease pool.
    // The GCD autorelease pool isn't guaranteed to clean this up in any amount of time.
    // Source: https://developer.apple.com/library/ios/DOCUMENTATION/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW1
    @autoreleasepool {
        
        NSString *topic = [NSString stringWithUTF8String: mosq_msg->topic];
        NSData *payload = [NSData dataWithBytes:mosq_msg->payload length:mosq_msg->payloadlen];
        
        MASMQTTMessage *message = [[MASMQTTMessage alloc] initWithTopic:topic
                                                                payload:payload
                                                                    qos:mosq_msg->qos
                                                                 retain:mosq_msg->retain
                                                                    mid:mosq_msg->mid];
        _sharedClient = (__bridge MASMQTTClient *)obj;
        
        [MASMQTTHelper showLogMessage:[NSString stringWithFormat:@"[%@] on message %@", _sharedClient.clientID, message]
                     debugMode:_sharedClient.debugMode];
        
        //Notification callback
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:MASConnectaOperationDidReceiveMessageNotification object:message];
        
        if (_sharedClient.messageHandler) {
            
            _sharedClient.messageHandler(message);
        }
        
        //Delegation callback
        if (_sharedClient.delegate && [_sharedClient.delegate respondsToSelector:@selector(onMessageReceived:)]) {
            
            [_sharedClient.delegate onMessageReceived:message];
        }

    }
}


static void on_subscribe(struct mosquitto *mosq, void *obj, int message_id, int qos_count, const int *granted_qos)
{
    _sharedClient = (__bridge MASMQTTClient *)obj;
    
    NSNumber *mid = [NSNumber numberWithInt:message_id];
    MQTTSubscriptionCompletionHandler handler = [_sharedClient.subscriptionHandlers objectForKey:mid];
    
    if (handler) {
        
        NSMutableArray *grantedQos = [NSMutableArray arrayWithCapacity:qos_count];
        
        for (int i = 0; i < qos_count; i++) {
            
            [grantedQos addObject:[NSNumber numberWithInt:granted_qos[i]]];
        }
        
        handler(grantedQos);
        
        [_sharedClient.subscriptionHandlers removeObjectForKey:mid];
    }
}


static void on_unsubscribe(struct mosquitto *mosq, void *obj, int message_id)
{
    _sharedClient = (__bridge MASMQTTClient *)obj;
    
    NSNumber *mid = [NSNumber numberWithInt:message_id];
    void (^completionHandler)(void) = [_sharedClient.unsubscriptionHandlers objectForKey:mid];
    
    if (completionHandler) {
        
        completionHandler();
        
        [_sharedClient.subscriptionHandlers removeObjectForKey:mid];
    }
}


static void on_log(struct mosquitto *mosq, void *obj, int level, const char *message)
{
    //Log Levels -> MOSQ_LOG_INFO, MOSQ_LOG_NOTICE, MOSQ_LOG_WARNING, MOSQ_LOG_ERR, MOSQ_LOG_DEBUG
    printf("%s\n", message);
}


static int on_password_callback(char *buf, int size, int rwflag, void *userdata)
{
    printf("on_password_callback\n");
    //char *passwd = "client";
    const char *passwd = [clientPassword cStringUsingEncoding:NSASCIIStringEncoding];
    memcpy(buf, passwd, strlen(passwd));
//    size = strlen(passwd);
    return strlen(passwd);
}

#pragma mark - Utilities methods

+ (NSString *)version
{
    int major, minor, revision;
    mosquitto_lib_version(&major, &minor, &revision);
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, revision];
}


- (void)dealloc
{
    if (mosq) {
        
        mosquitto_destroy(mosq);
        mosq = NULL;
    }
}


#pragma mark - Connection

- (void)clearWill
{
    mosquitto_will_clear(mosq);
}


//
//Connect with HostName. TLS is set TRUE as default
//
- (void)connectToHost:(NSString *)hostName
    completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    [self connectToHost:hostName withTLS:YES completionHandler:completionHandler];
}


//
//Connect with HostName and TLS flag
//
- (void)connectToHost:(NSString *)hostName
              withTLS:(BOOL)tls
    completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    
    if (!tls) {
        
        self.port = kMQTTDefaultPort;
    }
    else {
    
        self.port = kMQTTDefaultTLSPort;
        [self setupTLSWithServerCert:nil withClientCert:nil withClientKey:nil];
    }
    
    [self connectWithCompletionHandler:completionHandler];
}


//
//
//
-(void)connectWithHost:(NSString *)hostName
              withPort:(int)port
             enableTLS:(BOOL)tls
     completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    self.port = port;
    
    if (tls) {
        
        [self setupTLSWithServerCert:nil withClientCert:nil withClientKey:nil];
    }
    
    [self connectWithCompletionHandler:completionHandler];
}


//
//
//
-(void)connectWithHost:(NSString *)hostName
              withPort:(int)port
             enableTLS:(BOOL)tls
        usingSSLCACert:(NSString *)certFile
     completionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.host = hostName;
    self.port = port;

    if(tls){
        
        [self setupTLSWithServerCert:certFile withClientCert:nil withClientKey:nil];
    }
    
    [self connectWithCompletionHandler:completionHandler];
}


//
//Completion Block
//
- (void)connectWithCompletionHandler:(void(^)(MQTTConnectionReturnCode code))completionHandler
{
    self.connectionCompletionHandler = completionHandler;
    
    const char *cstrHost = [self.host cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cstrUsername = NULL, *cstrPassword = NULL;
    
    if (!self.username || !self.password) {
        
        //
        // Set the username and password for the connection
        //
        [[MASMQTTClient sharedClient] setUsername:[MASUser currentUser].objectId Password:[MASUser currentUser].accessToken];
    }
    
    if (self.username)
        cstrUsername = [self.username cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (self.password)
        cstrPassword = [self.password cStringUsingEncoding:NSUTF8StringEncoding];
    
    //Unsed for the moment. Validate after we start using it
    mosquitto_username_pw_set(mosq, cstrUsername, cstrPassword);
    mosquitto_reconnect_delay_set(mosq, self.reconnectDelay, self.reconnectDelayMax, self.reconnectExponentialBackoff);

    mosquitto_connect(mosq, cstrHost, self.port, self.keepAlive);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reconnect:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    dispatch_async(self.queue, ^{
        
        [MASMQTTHelper showLogMessage:[NSString stringWithFormat:@"start mosquitto loop on %@", self.queue]
                     debugMode:self.debugMode];
        
        mosquitto_loop_forever(mosq, -1, 1);
        
        [MASMQTTHelper showLogMessage:[NSString stringWithFormat:@"end mosquitto loop on %@", self.queue]
                     debugMode:self.debugMode];
    });
}


- (void)disconnectWithCompletionHandler:(MQTTDisconnectionHandler)completionHandler
{
    if (completionHandler) {
        
        self.disconnectionHandler = completionHandler;
    }
    
    mosquitto_disconnect(mosq);
}

- (void)reconnect:(NSNotification *)notification
{
    [self reconnect];
}

- (void)reconnect
{
    NSLog(@"RECONNECTING MOSQUITTO");
    mosquitto_reconnect(mosq);
}


#pragma mark - Publish methods

- (void)publishData:(NSData *)payload
            toTopic:(NSString *)topic
            withQos:(MQTTQualityOfService)qos
             retain:(BOOL)retain
  completionHandler:(void(^)(int mid))completionHandler
{
    NSParameterAssert(payload);
    NSParameterAssert(topic);
    NSParameterAssert(qos >= 0);
    NSParameterAssert(!retain || retain == YES);
    
    const char *cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (qos == 0 && completionHandler) {
        
        [self.publishHandlers setObject:completionHandler forKey:[NSNumber numberWithInt:0]];
    }
    
    int mid;
    
    mosquitto_publish(mosq, &mid, cstrTopic, (int)payload.length, payload.bytes, qos, retain);
    
    if (completionHandler) {
        
        if (qos == 0) {
            
            completionHandler(mid);
        }
        else {
            
            [self.publishHandlers setObject:completionHandler forKey:[NSNumber numberWithInt:mid]];
        }
    }
}


- (void)publishString:(NSString *)payload
              toTopic:(NSString *)topic
              withQos:(MQTTQualityOfService)qos
               retain:(BOOL)retain
    completionHandler:(void(^)(int mid))completionHandler;
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

#pragma mark - Subscribe/Unsubscribe methods

- (void)subscribeToTopic:(NSString *)topic
   withCompletionHandler:(MQTTSubscriptionCompletionHandler)completionHandler
{
    [self subscribeToTopic:topic withQos:defaultQoS completionHandler:completionHandler];
}


- (void)subscribeToTopic:(NSString *)topic
                 withQos:(MQTTQualityOfService)qos
       completionHandler:(MQTTSubscriptionCompletionHandler)completionHandler
{
    const char *cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    int mid;
    
    mosquitto_subscribe(mosq, &mid, cstrTopic, qos);
    
    if (completionHandler) {
        
        [self.subscriptionHandlers setObject:[completionHandler copy] forKey:[NSNumber numberWithInteger:mid]];
    }
}


- (void)unsubscribeFromTopic:(NSString *)topic
       withCompletionHandler:(void(^)(void))completionHandler
{
    const char *cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    int mid;
    
    mosquitto_unsubscribe(mosq, &mid, cstrTopic);
    
    if (completionHandler) {
        
        [self.unsubscriptionHandlers setObject:[completionHandler copy] forKey:[NSNumber numberWithInteger:mid]];
    }
}

#pragma mark - SSL / TLS

+ (void) setClientPassword:(NSString *)password
{
    if(clientPassword != password){
        clientPassword = password;
    }
}


- (void)setupTLSWithServerCert:(NSString *)certPath withClientCert:(NSString *)clientCertPath withClientKey:(NSString *)clientKeyPath
{
    MASFile *thisFile;
    
    //
    //Get path to the certificates
    //
    if (!certPath) {
        
        thisFile = [[MASSecurityService sharedService] getClientCertificate];
        certPath = [thisFile filePath];
        //[[MASFile findFileWithName:@"MAS.crt"] filePath];
    }
    if (!clientCertPath) {
        
        thisFile = [[MASSecurityService sharedService] getSignedCertificate];
        clientCertPath = [thisFile filePath];
        //[[MASFile findFileWithName:@"MASSigned.crt"] filePath];
    }
    if (!clientKeyPath) {
        
        thisFile = [[MASSecurityService sharedService] getPrivateKey];
        clientKeyPath = [thisFile filePath];
        //[[MASFile findFileWithName:@"MAS.key"] filePath];
    }
    

    //
    //Disable certificate CommonName validation
    //
    [self setSSLInsecure:YES];
    
    
    //
    //Set TLS options
    //
    mosquitto_tls_opts_set(mosq, 1, nil, nil);

    
    //
    //Set TLS parameters with certificates and key
    //
    int success = mosquitto_tls_set(mosq,
                                    [certPath cStringUsingEncoding:NSUTF8StringEncoding],
                                    nil,
                                    [clientCertPath cStringUsingEncoding:NSASCIIStringEncoding],
                                    [clientKeyPath cStringUsingEncoding:NSASCIIStringEncoding],
                                    on_password_callback);
    
    
    //
    //Validate TLS settings
    //
    if(success == MOSQ_ERR_SUCCESS){
        
        [MASMQTTHelper showLogMessage:@"TLS Set successful" debugMode:self.debugMode];
    }
    else{

        [MASMQTTHelper showLogMessage:[NSString stringWithFormat:@"TLS connection failed with error %d", success]
                     debugMode:self.debugMode];
    }
}


#pragma mark - Utilities methods

- (void)setSSLInsecure:(BOOL)insecure
{
    mosquitto_tls_insecure_set(mosq,insecure);
}


- (void)subscribeToDefaultTopics
{
    //TODO: This method will get the topics from the configuration file via the MASFoundation.
    //TODO: Get a final agreement from Victor and Sasha about the structure of the topic and from where we can get all data to build this structure. JSON?
    /*
     //This comment will be deleted after clarification with Victor about the structure of the status topic --lsanches
    /<prepend>/apps/<appKey>/data/<dataKey>/status
    This allows for monitoring the status of data for an app. Messages will be published when the data is updated, delete, etc…
     
     /1.0/tenant/tenantId12345/apps/MAG12345/data/datakey12345/status
     
     Definitions
     <prepend> - This is: <version>/tenant/<tenantId>
     <version> - This is the API version. For example: 1.0
     <tenantId> - This is the tenant ID, it is needed for multi-tenanted environments
     <userId> - This is a user’s unique ID.
     <groupId> - This is a groups unique ID.
     <appKey> - This is the MAG public app key.
     <topic> - This is a custom user defined topic. It can be arbitrarily deep.
     <dataKey> - This is a key for a data item
     */
    
    //We might add the organization in this structure and use the MAG public key as the client ID.
    // /org/ca technologies/
    NSArray *defaultTopics = @[@"/1.0/tenant/tenantId12345/apps/MAG12345/data/datakey12345/status",
                               ];
    for (NSString *topic in defaultTopics) {
        
        [self subscribeToTopic:topic withCompletionHandler:nil];
    }
}


//
//Format the topic depending on the object requesting this format
//Note: This format is compatible only with version 1.0 of the MQTT Policy on the Gateway
//
- (NSString *)structureTopic:(NSString *)topic forObject:(MASObject *)masObject
{
    NSParameterAssert(topic);

    if (!masObject) {
        
        return topic;
    }
    
    NSString *structuredTopic;
    
    NSString *apiVersion = @"1.0";
    NSString *organization = [MASConfiguration currentConfiguration].applicationOrganization;
    NSString *clientID = [MASMQTTClient sharedClient].clientID;
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
        
        structuredTopic = [NSString stringWithFormat:@"/%@/organization/%@/client/%@/applications/%@/custom/%@",apiVersion,organization,clientID,objectID,topic];
    }
    
    
    return structuredTopic;
}


#pragma mark - Helpers
//TODO: remove this method
- (void)listDirectoryContent
{
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Support directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask, YES);
    NSString *supportDirectory = [paths firstObject];

    // Write out the contents of home directory to console
    [MASMQTTHelper showLogMessage:[NSString stringWithFormat:@"Support directory: %@", [fileMgr contentsOfDirectoryAtPath:supportDirectory error:&error]] debugMode:self.debugMode];
    
}

//TODO: Remove this method
- (NSString *)getPathOfFile:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *supportDirectory = [paths objectAtIndex:0];
    return [supportDirectory stringByAppendingPathComponent:fileName];
}


@end
