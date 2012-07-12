//
//  ExampleObject.m
//  NSObjectToXML
//
//  Created by Danilo Priore on 12/07/12.
//  Copyright (c) 2012 Prioregroup.com. All rights reserved.
//

#import "ExampleObject.h"

@implementation SubObject

@synthesize subValue1, subValue2;

- (void)dealloc
{
    [subValue2 release];
    [super dealloc];
}

@end

@implementation ExampleObject

@synthesize mainValue1, mainValue2, mainValue3;

- (id)init
{
    if (self = [super init])
    {
        mainValue3 = [[SubObject alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [mainValue2 release];
    [mainValue3 release];
    [super dealloc];
}

@end
