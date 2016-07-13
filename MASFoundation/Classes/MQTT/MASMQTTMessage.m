//
//  MQTTMessage.m
//  Connecta
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASMQTTMessage.h"

@interface MASMQTTMessage ()

@property (readwrite, assign) unsigned short mid;
@property (readwrite, copy) NSString *topic;
@property (readwrite, copy) NSData *payload;
@property (readwrite, assign) MQTTQualityOfService qos;
@property (readwrite, assign) BOOL retained;

@end

@implementation MASMQTTMessage


- (NSString *)payloadString
{
    return [[NSString alloc] initWithBytes:self.payload.bytes
                                    length:self.payload.length
                                  encoding:NSUTF8StringEncoding];
}

- (UIImage *)payloadImage
{
    UIImage *image= [UIImage imageWithData:self.payload];
    
    if(image != nil){
        
        return image;
    }
    
    return nil;
}

-(id)initWithTopic:(NSString *)topic
                     payload:(NSData *)payload
                         qos:(MQTTQualityOfService)qos
                      retain:(BOOL)retained
                         mid:(short)mid
{
    if ((self = [super init])) {
        
        self.topic = topic;
        self.payload = payload;
        self.qos = qos;
        self.retained = retained;
        self.mid = mid;
    }
    
    return self;
}


# pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //DLog(@"\n\ncalled\n\n");
    
    if(self.topic) [aCoder encodeObject:self.topic forKey:@"topic"];
    if(self.payload) [aCoder encodeDataObject:self.payload];
    
    [aCoder encodeInt:self.mid forKey:@"mid"];
    [aCoder encodeInt:self.qos forKey:@"qos"];
    [aCoder encodeBool:self.retained forKey:@"retained"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    //DLog(@"\n\ncalled\n\n");

    if (self = [super init])
    {
        self.topic = [aDecoder decodeObjectForKey:@"topic"];
        self.payload = [aDecoder decodeDataObject];
        
        self.mid = [aDecoder decodeIntForKey:@"mid"];
        self.qos = [aDecoder decodeIntForKey:@"qos"];
        self.retained = [aDecoder decodeBoolForKey:@"retained"];
    }
    
    return self;
}

@end
