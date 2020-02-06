//
//  MASObject.m
//  MASFoundation
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASObject.h"


@interface MASObject ()

@property (nonatomic, readwrite, copy) NSString *className;
@property (nonatomic, readwrite, copy) NSString *objectId;
@property (nonatomic, readwrite, copy) NSMutableDictionary *_attributes;

@end


@implementation MASObject

//Used for Encoding Object <NSCoding>
#define kObjectIdDefaultsKey                @"com.ca.MASFoundation:objectId"
#define kClassNameDefaultsKey               @"com.ca.MASFoundation:className"
#define kAttributesDefaultsKey               @"com.ca.MASFoundation:attributes"

//SCIM - Cloud Database Mapping Keys (JSON)
#define kServerAPIObjectIDKey               @"id"
#define kServerAPIClassNameKey              @"className"


- (instancetype)init
{
    self = [super init];
    if (self) {

        self._attributes = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
        
    self.objectId       = [attributes valueForKey:kServerAPIObjectIDKey];
    self.className      = [attributes valueForKey:kServerAPIObjectIDKey];
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    return self;
}


+ (instancetype)objectWithClassName:(NSString *)className
{
    MASObject *masObject = [[MASObject alloc] init];
    [masObject setClassName:className];
    return masObject;
}


+ (instancetype)objectWithClassName:(NSString *)className
                           withData:(NSDictionary *)dictionary
{
    MASObject *masObject = [[MASObject alloc] initWithAttributes:dictionary];
    [masObject setClassName:className];
    return masObject;
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"(%@) objectId: %@, className: %@, attributes: %@",
        [self class], self.objectId, self.className, self._attributes];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MASObject *item =  [[self class] allocWithZone:zone];//[[MASObject alloc] init];
    
    item.objectId        = self.objectId;
    item.className       = self.className;
    item._attributes     = self._attributes;
    
    return item;
}


#pragma mark - NSCoding

- (void)safeEncodeObject:(id)object forKey:(NSString *)key coder:(NSCoder *)coder
{
    if (object && key && coder) {
        
        [coder encodeObject:object forKey:key];
    }
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self safeEncodeObject:self.objectId forKey:kObjectIdDefaultsKey coder:aCoder];
    [self safeEncodeObject:self.className forKey:kClassNameDefaultsKey coder:aCoder];
    [self safeEncodeObject:self._attributes forKey:kAttributesDefaultsKey coder:aCoder];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        self.objectId = [aDecoder decodeObjectForKey:kObjectIdDefaultsKey];
        self.className = [aDecoder decodeObjectForKey:kClassNameDefaultsKey];
        self._attributes = [aDecoder decodeObjectForKey:kAttributesDefaultsKey];
    }
    
    return self;
}


#pragma mark - isEqual (Used to compare objects)

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    
    return [self isEqualToMASObject:other];
}

- (BOOL)isEqualToMASObject:(MASObject *)aObject
{
    if (self == aObject)
        return YES;
    if (![(id)[self objectId] isEqual:[aObject objectId]])
        return NO;
    if (![(id)[self className] isEqual:[aObject className]])
        return NO;

    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = 0;
    hash += [[self objectId] hash];
    hash += [[self className] hash];

    return hash;
}


#pragma mark - Dictionary Methods normal / subscript

- (id)objectForKey:(id)key
{
    return [self._attributes objectForKey:key];
}


- (void)setObject:(id)object forKey:(id <NSCopying>)key
{
    [self._attributes setObject:object forKey:key];
}


- (id)objectForKeyedSubscript:(id)key
{
    return self._attributes[key];
}


- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    self._attributes[key] = obj;
}

#pragma mark - Print Attributes

- (void)listAttributes
{
    DLog(@"%@",self._attributes);
}

@end
