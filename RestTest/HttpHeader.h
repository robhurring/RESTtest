//
//  HttpHeader.h
//  RestTest
//
//  Created by Mondok, Matt (LNG-KOP) on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpHeader : NSObject {
    NSString *headerName;
    NSString *headerValue;
@private
    
}

@property(nonatomic, retain) NSString *headerName;
@property(nonatomic, retain) NSString *headerValue;

-(id)initWithPair:(NSString *) header withValue:(NSString *) value;

@end
