//
//  RUBURLLoadingSystemWebsiteLoader.m
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 24.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBURLLoadingSystemWebsiteLoader.h"
#import "RUBWebsiteLoader_Internal.h"


@interface RUBURLLoadingSystemWebsiteLoader ()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;

@end


#pragma mark -

@implementation RUBURLLoadingSystemWebsiteLoader

#pragma mark Properties

// Private properties
@synthesize connection = _connection;
@synthesize receivedData = _receivedData;

#pragma NSObject

- (void)dealloc
{
    [_connection cancel]; [_connection release];
    [_receivedData release];
    
    [super dealloc];
}

#pragma mark RUBURLLoadingSystemWebsiteLoader

- (void)startLoadingURL:(NSURL *)URL
{
    [super startLoadingURL:URL];
    
    [self stopLoading];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [self setReceivedData:data];
    [data release];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:URL] 
                                                                  delegate:self];
    [self setConnection:connection];
    [connection release];
    
    [[self websiteLoaderDelegate] websiteLoaderDidStartLoad:self];
}

- (void)reload
{
    [self stopLoading];
    [self startLoadingURL:[self URL]];
}

- (void)stopLoading
{
    [[self connection] cancel];
    [self setConnection:nil];
}

#pragma mark NSURLConnection delegate methods

- (void)    connection:(NSURLConnection *)connection 
    didReceiveResponse:(NSURLResponse *)response
{
    [[self receivedData] setLength:0];  // Anticipate redirection
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)data
{
    [[self receivedData] appendData:data];
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
    [[self websiteLoaderDelegate] websiteLoader:self didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *htmlString = [[NSString alloc] initWithData:[self receivedData] 
                                                 encoding:NSUTF8StringEncoding];
    [[[self websiteLoaderDelegate] webView] loadHTMLString:htmlString baseURL:nil];
    [htmlString release];
    
    [[self websiteLoaderDelegate] websiteLoaderDidFinishLoad:self currentLocation:nil];
}

@end
