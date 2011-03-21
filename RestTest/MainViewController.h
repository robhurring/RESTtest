//
//  MainViewController.h
//  RestTest
//
//  Created by Mondok, Matt (LNG-KOP) on 3/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView *headers;
    IBOutlet NSTextField *httpUri;
    IBOutlet NSComboBox *httpVerb;
    IBOutlet NSTextView *httpBody;    
    IBOutlet NSTextView *httpResponse;
    IBOutlet NSTableView *responseTable;
    
    NSMutableDictionary *responseHeaders;
    NSMutableArray *responseHeadersArray;
    NSMutableData *receivedData;
    NSURLResponse *theResponse;
    NSMutableArray *headerRows;


@private
    
}

@property(nonatomic, retain) NSMutableArray *headerRows;

-(IBAction) addRow:(id) sender;
-(IBAction) deleteRow:(id) sender;
-(IBAction) sendRequest: (id) sender;
-(IBAction) saveDocumentAs: (id)sender;
-(IBAction) newDocument: (id)sender;

@end
