//
//  Servicer.m
//  RESTtest
//
//  Created by Matthew Mondok on 4/6/11.
//  Copyright 2011 EdenTech. All rights reserved.
//

#import "Servicer.h"
#import "HttpHeader.h"
#import "SBJson.h"
#import <Foundation/Foundation.h>
#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"

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
    [httpBasicUsername setStringValue:[initData objectForKey:@"httpBasicUsername"]];
    
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
  
  NSFont *defaultTextViewFont = [NSFont fontWithName:@"Menlo" size:12.0];
  httpBody.font = defaultTextViewFont;
  httpResponse.font = defaultTextViewFont;

  httpBodyLineNumberView = [[NoodleLineNumberView alloc] initWithScrollView:httpBodyScrollView];
  httpBodyScrollView.verticalRulerView = httpBodyLineNumberView;
  httpBodyScrollView.hasVerticalRuler = YES;
  httpBodyScrollView.rulersVisible = YES;

  httpResponseLineNumberView = [[NoodleLineNumberView alloc] initWithScrollView:httpResponseScrollView];
  httpResponseScrollView.verticalRulerView = httpResponseLineNumberView;
  httpResponseScrollView.hasVerticalRuler = YES;
  httpResponseScrollView.rulersVisible = YES;
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

-(IBAction) rowAction:(id) sender {
  NSSegmentedControl *segment = (NSSegmentedControl *)sender;
  
  NSInteger tag =    [segment selectedSegment];
  if (tag == 0){
    [self addRow:sender];
  }
  else if (tag == 1){
    [self deleteRow:sender];
  }
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
  @try {
    [httpStatusCode setStringValue:@""];
    [httpResponse setString:@""];
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
    NSNumber *numb = [NSNumber numberWithUnsignedLong:body.length];
    NSString *msgLength = [NSString stringWithFormat:@"%d", numb.intValue];
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
    receivedData = [[NSMutableData data] retain];
    [receivedData setLength:0];
    
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (!theConnection) {
      [self showErrorAlert:@"Connection failed"];
    }
  }
  @catch (NSException *exception) {
    [self showErrorAlert:[exception description]];
    [sendButton setEnabled:YES];
  }
  @finally {
    theConnection = nil;
  }
}

-(void) showErrorAlert:(NSString *)message{
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert setMessageText:message];
  [alert runModal];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge previousFailureCount] == 0) {
    NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self->httpBasicUsername.stringValue
                                                                password:self->httpBasicPassword.stringValue
                                                             persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
  }
  else {
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    [httpResponse setString:@"HTTP Basic Authentication failed"];
    [sendButton setEnabled:YES];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [httpResponse setString:@""];
  theResponse = response;
  NSHTTPURLResponse *aResponse = (NSHTTPURLResponse *)response;
  responseHeaders = [[NSMutableDictionary alloc] initWithDictionary: [aResponse allHeaderFields]];
  responseHeadersArray = [[NSMutableArray alloc] initWithArray:[responseHeaders allKeys]];
  statusCode = aResponse.statusCode;
  [httpStatusCode setStringValue:[NSString stringWithFormat:@"Status Code: %li", statusCode]];
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
  @try {
    if (recData && [recData length] > 0){
      SBJsonParser *parser = [[SBJsonParser alloc] init];
      id object = [parser objectWithString:recData];
      if (object) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        writer.humanReadable = YES;
        [httpResponse setString:@""];
        [httpResponse setString:[writer stringWithObject:object]];
        [writer release];
        [parser release];
        [object release];
      }
      else {
        NSError *error;
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:recData options:(NSXMLNodePrettyPrint) error:&error];
        
        if (!error){
          [httpResponse setString:[document XMLStringWithOptions:NSXMLNodePrettyPrint]];
        } else {
          [httpResponse setString:recData];
        }
      }}
    else{
      if (recData.length > 0){
        [httpResponse setString:recData];
      } else {
        [httpResponse setString:@""];
      }
    }
  }
  @catch (NSException *exception) {
    [self showErrorAlert:[exception description]];
  }
  @finally {
    [sendButton setEnabled:YES];
    [receivedData release];
    [theConnection release];
    [recData release];
    receivedData = nil;
    recData = nil;
    theConnection = nil;
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  [sendButton setEnabled:YES];
  [self showErrorAlert:[error localizedDescription]];
  // release the connection, and the data object
  [connection release];
  // receivedData is declared as a method instance elsewhere
  [receivedData release];

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
    @try {
      if (responseHeadersArray.count == 0) return @"";
      
      NSString *key = [responseHeadersArray objectAtIndex:rowIndex];
      NSString *label = (NSString *)[aTableColumn identifier];
      if ([label isEqualToString:@"0"]){
        return key;
      }
      else {
        return [responseHeaders objectForKey:key];
      }
    }
    @catch (NSException *exception) {
      return @"";
    }
    @finally {      
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
  [save setExtensionHidden:NO];
  [save setAllowedFileTypes:@[@"txt"]];
  
  NSInteger result = [save runModal];
  if (result == NSOKButton){
    NSString *output = @"";
    NSURL *selectedFile = [save URL];
    if (statusCode > 0){
      output = [NSString stringWithFormat:@"Status Code: %li\n", statusCode];
    }
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
    [fileData writeToURL:selectedFile atomically:YES];
  }
}

-(IBAction) saveDocument:(id)sender{
  if ([self fileURL]){
    [self saveWithFileName:self.fileURL];
  }
  else{
    [self saveDocumentAs:sender];
  }
}

-(IBAction) saveDocumentAs: (id)sender {
  NSSavePanel *save = [NSSavePanel savePanel];
  
  [save setExtensionHidden:NO];
  [save setAllowedFileTypes:@[@"rstst"]];
  
  NSInteger result = [save runModal];
  if (result == NSOKButton){
    [self saveWithFileName:save.URL];
  }
}

-(void) saveWithFileName:(NSURL *) fileName{
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  [dict setObject:[httpUri stringValue] forKey:@"httpUri"];
  [dict setObject:[httpVerb stringValue] forKey:@"httpVerb"];
  [dict setObject:[[httpBody textStorage] string] forKey:@"httpBody"];
  [dict setObject:[self->httpBasicUsername stringValue] forKey:@"httpBasicUsername"];
  
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
  
  [dict writeToURL: fileName atomically:YES];
  [self setFileURL: fileName];
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
