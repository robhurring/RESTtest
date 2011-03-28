//
//  RestTestAppDelegate.h
//  RestTest
//
//  Created by Mondok, Matt (LNG-KOP) on 3/12/11.
//  Copyright 2011 EdenTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RestTestAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

-(void) performClose:(id)sender;

@end
