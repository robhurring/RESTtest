//
//  Servicer.h
//  RESTtest
//
//  Created by Matthew Mondok on 4/6/11.
//  Copyright 2011 EdenTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Servicer : NSDocument<NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView *headers;
    IBOutlet NSTextField *httpUri;
    IBOutlet NSComboBox *httpVerb;
    IBOutlet NSTextView *httpBody;    
    IBOutlet NSTextView *httpResponse;
    IBOutlet NSTableView *responseTable;
    
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

-(IBAction) addRow:(id) sender;
-(IBAction) deleteRow:(id) sender;
-(IBAction) sendRequest: (id) sender;
-(IBAction) saveDocumentAs: (id)sender;
-(IBAction) saveResponseAs: (id)sender;
-(void) saveWithFileName:(NSString *) fileName;
//- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem;

@end
