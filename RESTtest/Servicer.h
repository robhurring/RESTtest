//
//  Servicer.h
//  RESTtest
//
//  Created by Matthew Mondok on 4/6/11.
//  Copyright 2011 EdenTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NoodleLineNumberView;

@interface Servicer : NSDocument<NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView *headers;
    IBOutlet NSTextField *httpUri;
    IBOutlet NSComboBox *httpVerb;
    IBOutlet NSTextView *httpBody;
    IBOutlet NSScrollView *httpBodyScrollView;
    IBOutlet NSTextView *httpResponse;
    IBOutlet NSScrollView *httpResponseScrollView;
    IBOutlet NSTableView *responseTable;
    IBOutlet NSButton *sendButton;
    IBOutlet NSTextField *httpBasicPassword;    
    IBOutlet NSTextField *httpBasicUsername;
    IBOutlet NSTextField *httpStatusCode;
  
    NoodleLineNumberView	*httpBodyLineNumberView;
    NoodleLineNumberView	*httpResponseLineNumberView;

    long statusCode;
    NSDictionary *initData;
    NSMutableDictionary *responseHeaders;
    NSMutableArray *responseHeadersArray;
    NSMutableData *receivedData;
    NSURLResponse *theResponse;
    NSMutableArray *headerRows;
    NSURLConnection *theConnection;
@private
}

@property(nonatomic, retain) NSMutableArray *headerRows;

-(IBAction) rowAction:(id) sender;
-(IBAction) addRow:(id) sender;
-(IBAction) deleteRow:(id) sender;
-(IBAction) sendRequest: (id) sender;
-(IBAction) saveDocumentAs: (id)sender;
-(IBAction) saveResponseAs: (id)sender;
-(void) saveWithFileName:(NSURL *) fileName;
@end
