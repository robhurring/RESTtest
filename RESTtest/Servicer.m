//
//  Servicer.m
//  RESTtest
//
//  Created by Matthew Mondok on 4/6/11.
//  Copyright 2011 EdenTech. All rights reserved.
//

#import "Servicer.h"
#import "HttpHeader.h"

@implementation Servicer

@synthesize headerRows;

- (id)init
{
    self = [super init];
    if (self) {
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
    return self;
}

- (NSString *)windowNibName
{
    return @"Servicer";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    if (initData){
        [httpUri setStringValue:[initData objectForKey:@"httpUri"]];
        [httpVerb selectItemWithObjectValue:[initData objectForKey:@"httpVerb"]];
        [httpBody setString:[initData objectForKey:@"httpBody"]];
        NSArray *heads = [initData objectForKey:@"headers"];
        if (heads){
            [headerRows removeAllObjects];
            for(NSDictionary *d in heads){
                HttpHeader *head = [[HttpHeader alloc] initWithPair:[d objectForKey:@"key"] withValue:[d objectForKey:@"value"]];
                [headerRows addObject:head];
                [head release];
            }
        }
    } else{
        [httpVerb selectItemAtIndex:0];
    }
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    /*
    Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    */
    NSString *error;  
    NSPropertyListFormat format;  
    initData = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];  
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
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
    [sendButton setEnabled:NO];
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
        [theRequest addValue:head.headerValue forHTTPHeaderField:head.headerName];
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
    [sendButton setEnabled:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    [httpResponse setString:[error localizedDescription]];
    [sendButton setEnabled:YES];
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

-(IBAction) saveResponseAs: (id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    NSInteger result = [save runModal];
    if (result == NSOKButton){
        NSString *selectedFile = [save filename];
        NSString *output = @""; 
        if (responseHeadersArray != nil){
            for (int i = 0; i < [responseHeadersArray count]; i++) {
                NSString *key = [responseHeadersArray objectAtIndex:i];
                NSString *obj = [responseHeaders objectForKey:key];
                output = [output stringByAppendingFormat:@"%@: %@\n", key, obj];            
            }
            if ([responseHeadersArray count] > 0){
                output = [output stringByAppendingString:@"\n"];  
            }
        }
        output = [output stringByAppendingString:[httpResponse string]];
        NSData *fileData = [output dataUsingEncoding:NSUTF8StringEncoding];
        [fileData writeToFile:selectedFile atomically:YES];        
    }    
}

-(IBAction) saveDocument:(id)sender{
    if ([self fileURL]){
        [self saveWithFileName:[[self fileURL] path]];
    }
    else{
        [self saveDocumentAs:sender];
    }
}

-(IBAction) saveDocumentAs: (id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    NSInteger result = [save runModal];
    if (result == NSOKButton){
        NSString *selectedFile = [[save filename] stringByAppendingString:@".rstst"];
        [self saveWithFileName:selectedFile];
    }
}


-(void) saveWithFileName:(NSString *) fileName{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[httpUri stringValue] forKey:@"httpUri"];
    [dict setObject:[httpVerb stringValue] forKey:@"httpVerb"];
    [dict setObject:[[httpBody textStorage] string] forKey:@"httpBody"];
    NSMutableArray *headContents = [[NSMutableArray alloc] initWithCapacity:[headerRows count]];
    for(HttpHeader *head in headerRows){
        if (![head headerValue]){
            continue;
        }
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithCapacity:2];
        [temp setObject:[head headerValue] forKey:@"value"];
        [temp setObject:[head headerName] forKey:@"key"];
        [headContents addObject:temp];
        [temp release];
    }
    [dict setObject:headContents forKey:@"headers"];
    [dict writeToFile:fileName atomically:NO];
    [self setFileURL:[NSURL URLWithString:fileName]];
    [dict release];
    [headContents release];
}


- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    SEL theAction = [anItem action];
    
    if (theAction == @selector(saveResponseAs:))
    {
        return [[httpResponse string] length] > 0;            
    }    
    return YES;
}


@end
