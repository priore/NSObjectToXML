//
//  ViewController.m
//  NSObjectToXML
//
//  Created by Danilo Priore on 12/07/12.
//  Copyright (c) 2012 Prioregroup.com. All rights reserved.
//

#import "ViewController.h"
#import "NSObjectToXML.h"
#import "ExampleObject.h"

@implementation ViewController

- (void)viewDidLoad
{
    ExampleObject *obj = [[[ExampleObject alloc] init] autorelease];
    obj.mainValue1 = 1;
    obj.mainValue2 = [NSString stringWithString:@"Example Value"];
    obj.mainValue3.subValue1 = 10;
    obj.mainValue3.subValue2 = [NSString stringWithString:@"Sub Value"];
    
    NSString *xml = [NSObjectToXML convertToXML:obj rootName:@"root"];
    textView.text = xml;
    
}

- (void)dealloc
{
    [textView release];
    [super dealloc];
}

@end
