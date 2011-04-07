//
//  HttpHeader.m
//  RESTtest
//
//  Created by Matthew Mondok on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HttpHeader.h"


@implementation HttpHeader

@synthesize headerName,headerValue;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id)initWithPair:(NSString *) header withValue:(NSString *) value {
    [self init];
    self.headerName = header;
    self.headerValue = value;
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
