//
//  NSObjectToXML.m
//  NSObjectToXML
//
//  Created by Danilo Priore on 12/07/12.
//  Copyright (c) 2012 Prioregroup.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#define XML_ELEMENT         @"<%@>%@</%@>"
#define XML_ELEMENT_CDATA   @"![CDATA[%@]]>"
#define XML_ELEMENT_OPEN    @"<%@>"
#define XML_ELEMENT_CLOSE   @"</%@>"
#define XML_ROOT_NAME       @"root"

#define DATE_FORMAT         @"yyyy-MM-dd"

#import "NSObjectToXML.h"
#import <objc/runtime.h>

@interface NSObjectToXML()

+ (NSString*)convertDictionaryToXML:(NSDictionary*)dictionary rootName:(NSString*)rootName;
+ (NSString*)convertArrayToXML:(NSArray*)array rootName:(NSString*)rootName;
+ (NSString*)convertObjectToXML:(id)object rootName:(NSString*)rootName;

@end

@implementation NSObjectToXML

+ (NSString*)convertToXML:(id)value rootName:(NSString *)rootName 
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    
    if (value == nil) {
        [xml appendFormat:XML_ELEMENT, rootName, @"", rootName];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        [xml appendFormat:XML_ELEMENT, rootName, value, rootName];
    }
    else if ([value isKindOfClass:[NSData class]]) {
        NSString *s_value = [[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] autorelease];
        s_value = [NSString stringWithFormat:XML_ELEMENT_CDATA, s_value];
        [xml appendFormat:XML_ELEMENT, rootName, s_value, rootName];
    }
    else if ([value isKindOfClass:[NSDate class]]) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        formatter.dateFormat = DATE_FORMAT;
        NSString *s_value = [formatter stringFromDate:value];
        [xml appendFormat:XML_ELEMENT, rootName, s_value, rootName];
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        NSString *s_value = [(NSNumber*)value stringValue];
        [xml appendFormat:XML_ELEMENT, rootName, s_value, rootName];
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        [xml appendString:[self convertDictionaryToXML:value rootName:rootName ? rootName : XML_ROOT_NAME]];
    }
    else if ([value isKindOfClass:[NSArray class]]) {
        [xml appendString:[self convertArrayToXML:value rootName:rootName ? rootName : XML_ROOT_NAME]];
    }
    else if ([value isKindOfClass:[NSObject class]]) {
        [xml appendString:[self convertObjectToXML:value rootName:rootName ? rootName : XML_ROOT_NAME]];
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"NSObjectToXML invalid type of value for key '%@'!", rootName];
        NSAssert(YES, msg);
    }
    
    return [xml autorelease];
}

+ (NSString*)convertDictionaryToXML:(NSDictionary*)dictionary rootName:(NSString*)rootName
{
    NSMutableString *xml = [[NSMutableString alloc] init];

    if (rootName)
        [xml appendFormat:XML_ELEMENT_OPEN, rootName];
    
    NSArray *keys = dictionary.allKeys;
    for (int i = 0; i < keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        [xml appendString:[self convertToXML:[dictionary objectForKey:key] rootName:key]];
    }
    
    if (rootName)
        [xml appendFormat:XML_ELEMENT_CLOSE, rootName];
    
    return [xml autorelease];
}

+ (NSString*)convertArrayToXML:(NSArray*)array rootName:(NSString*)rootName 
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    
    if (rootName)
        [xml appendFormat:XML_ELEMENT_OPEN, rootName];
    
    for (int i = 0; i < array.count; i++) {
        id value = [array objectAtIndex:i];
        if (value == nil) {
            [xml appendString:[self convertToXML:@"" rootName:@"string"]];
        }
        else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSData class]]) {
            [xml appendString:[self convertToXML:value rootName:@"string"]];
        }
        else if ([value isKindOfClass:[NSDate class]]) {
            [xml appendString:[self convertToXML:value rootName:@"dateTime"]];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            NSString *s_value = [(NSNumber*)value stringValue];
            CFNumberType numberType = CFNumberGetType((CFNumberRef)value);
            switch (numberType) {
                case kCFNumberIntType:
                case kCFNumberNSIntegerType:
                    [xml appendFormat:XML_ELEMENT, @"int", s_value, @"int"];
                    break;
                case kCFNumberFloatType:
                case kCFNumberCGFloatType:
                    [xml appendFormat:XML_ELEMENT, @"float", s_value, @"float"];
                    break;
                default:
                    [xml appendFormat:XML_ELEMENT, @"double", s_value, @"double"];
                    break;
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]] 
                 || [value isKindOfClass:[NSArray class]]) {
            [xml appendString:[self convertToXML:value rootName:@"item"]];
        }
        else if ([value isKindOfClass:[NSObject class]]) {
            NSString *name = [NSString stringWithCString:class_getName([value class]) encoding:NSUTF8StringEncoding];
            [xml appendString:[self convertToXML:value rootName:name]];
        }
        else {
            NSAssert(YES, @"NSObjectToXML invalid type of value on array values at index #%d!", i);
        }
    }
    
    if (rootName)
        [xml appendFormat:XML_ELEMENT_CLOSE, rootName];
             
    return [xml autorelease];
}

+ (NSString*)convertObjectToXML:(id)object rootName:(NSString*)rootName 
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    
    if (rootName)
        [xml appendFormat:XML_ELEMENT_OPEN, rootName];
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    for (int i = 0; i < count; ++i) {
        
        // name and attributes of properties
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *propertyAttributes = [[[NSString alloc] initWithUTF8String:property_getAttributes(property)] autorelease];
        NSArray *propertyAttributeArray = [propertyAttributes componentsSeparatedByString:@","];
        
        // is a primitive C type (int, float, double) ?
        NSString *cType = nil;
        for (NSString *string in propertyAttributeArray) {
            if ([@"Ti Tf Td" rangeOfString:string].location != NSNotFound) {
                cType = [NSString stringWithString:string];
                break;
            }
        }
        
        id value = [object valueForKey:name];
        if (cType) {
            // primitive C type
            if ([cType isEqualToString:@"Ti"]) {
                NSString *s_value = [[NSNumber numberWithInt:[value integerValue]] stringValue];
                [xml appendFormat:XML_ELEMENT, name, s_value, name];
            } else if ([cType isEqualToString:@"Tf"]) {
                NSString *s_value = [[NSNumber numberWithFloat:[value floatValue]] stringValue];
                [xml appendFormat:XML_ELEMENT, name, s_value, name];
            } else if ([cType isEqualToString:@"Td"]) {
                NSString *s_value = [[NSNumber numberWithDouble:[value doubleValue]] stringValue];
                [xml appendFormat:XML_ELEMENT, name, s_value, name];
            }
        } else {
            // class or nsobject
            [xml appendString:[self convertToXML:value rootName:name]];
        }
    }
    free(properties);
    
    if (rootName)
        [xml appendFormat:XML_ELEMENT_CLOSE, rootName];
    
    return [xml autorelease];
}

@end
