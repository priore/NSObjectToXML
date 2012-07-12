//
//  ExampleObject.h
//  NSObjectToXML
//
//  Created by Danilo Priore on 12/07/12.
//  Copyright (c) 2012 Prioregroup.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubObject : NSObject

@property (nonatomic, assign) int subValue1;
@property (nonatomic, retain) NSString *subValue2;

@end

@interface ExampleObject : NSObject

@property (nonatomic, assign) int mainValue1;
@property (nonatomic, retain) NSString *mainValue2;
@property (nonatomic, retain) SubObject *mainValue3;

@end
