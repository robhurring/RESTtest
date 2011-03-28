//
//  MainViewController.m
//  RestTest
//
//  Created by Mondok, Matt (LNG-KOP) on 3/12/11.
//  Copyright 2011 EdenTech. All rights reserved.
//

#import "MainViewController.h"
#import "HttpHeader.h"

@implementation MainViewController

@synthesize headerRows;

-(id) initWithCoder:(NSCoder *)aDecoder{
    responseHeadersArray = [[NSMutableArray alloc] init];
    headerRows = [[NSMutableArray alloc] initWithCapacity:10];
    HttpHeader *head = [[HttpHeader alloc] initWithPair:@"Content-Type" withValue:@"text/html"];
    [headerRows addObject:head];
    [head release];
    head = [[HttpHeader alloc] init];
    [headerRows addObject:head];
    [head release];
    head = [[HttpHeader alloc] init];
    [headerRows addObject:head];
    [head release];
    head = [[HttpHeader alloc] init];
    [headerRows addObject:head];
    [head release];
    head = [[HttpHeader alloc] init];
    [headerRows addObject:head];    
    [head release];
    receivedData = [[NSMutableData alloc] init];    
    return self;
}

-(IBAction) addRow:(id)sender{
    HttpHeader *head = [[HttpHeader alloc] init];
    [headerRows addObject:head];
    [head release];
    [headers reloadData];
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:[headerRows count]-1];
    [headers selectRowIndexes:set byExtendingSelection:NO];
    [headers setNeedsDisplay];
    [set release];
}

-(IBAction) deleteRow:(id)sender{
    if ([headers selectedRow] < 0) return;
    
    [headerRows removeObjectAtIndex:[headers selectedRow]];
    [headers reloadData];
}

-(IBAction) sendRequest:(id)sender {
    if (responseHeaders)
        [responseHeaders removeAllObjects];
    
    [responseHeadersArray removeAllObjects];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[httpUri stringValue]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    NSString *method = [httpVerb stringValue];
    if ([method length] == 0)
        method = @"GET";
    
    NSData *body = [[[httpBody textStorage] string] dataUsingEncoding:NSUTF8StringEncoding];    
    [theRequest setHTTPBody:body];
    [theRequest setHTTPMethod:method];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [body length]];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];    
    
    for (int i = 0; i < [headerRows count]; i++) {
        HttpHeader *head = [headerRows objectAtIndex:i];
        NSString *value = head.headerValue;
        NSString *name = head.headerName;
        if (value.length == 0 || name.length == 0)
            continue;
        [theRequest addValue:head.headerName forHTTPHeaderField:head.headerValue];
    }
    
    // create the connection with the request
    // and start loading the data
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [[NSMutableData data] retain];
        
    } else {
        [httpResponse setString:@"Connection Failed"];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    theResponse = response; 
    responseHeaders = [[NSMutableDictionary alloc] initWithDictionary: [(NSHTTPURLResponse *)response allHeaderFields]];
    responseHeadersArray = [[NSMutableArray alloc] initWithArray:[responseHeaders allKeys]];
    [responseTable reloadData];
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [connection release];
    NSString *recData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [httpResponse setString:recData];
    [receivedData release];
    [recData release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    [httpResponse setString:[error localizedDescription]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
        NSInteger tag = [aTableView tag];
    if (tag == 0)
        return [headerRows count];
    else
        return [responseHeadersArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    NSInteger tag = [aTableView tag];
    if (tag == 0){
        HttpHeader *header = [headerRows objectAtIndex:rowIndex];
        NSString *label = (NSString *)[aTableColumn identifier];
        if ([label isEqualToString:@"0"]){
            return header.headerName;
        }
        else {
            return header.headerValue;
        }
    }
    if (tag == 1){
        NSString *key = [responseHeadersArray objectAtIndex:rowIndex];
        NSString *label = (NSString *)[aTableColumn identifier];
        if ([label isEqualToString:@"0"]){
            return key;
        }
        else {
            return [responseHeaders objectForKey:key];
        }                
    }
    return nil;    
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSInteger tag = [aTableView tag];
    if (tag == 0){
        HttpHeader *header = [headerRows objectAtIndex:rowIndex];
        NSString *label = (NSString *)[aTableColumn identifier];
        if ([label isEqualToString:@"0"]){
            header.headerName = anObject;
        }
        else{
            header.headerValue = anObject;
        }
    }    
}

-(IBAction) saveDocumentAs: (id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    NSInteger result = [save runModal];
    if (result == NSOKButton){
        NSString *selectedFile = [save filename];      
        NSData *fileData = [[httpResponse string] dataUsingEncoding:NSUTF8StringEncoding];
        [fileData writeToFile:selectedFile atomically:YES];        
    }    
}

-(IBAction) newDocument: (id)sender {
    [responseHeaders removeAllObjects];
    [responseHeadersArray removeAllObjects];
    [headerRows removeAllObjects];
    [httpUri setStringValue:@""];
    [httpVerb selectItemAtIndex:0];
    [httpBody setString:@""];
    [httpResponse setString:@""];
    [headers reloadData];
    [responseTable reloadData];
}

- (void)dealloc
{
    [responseHeadersArray release];
    [responseHeaders release];
    [receivedData release];
    [theResponse release];
    [headerRows release];
    [super dealloc];
}

@end
