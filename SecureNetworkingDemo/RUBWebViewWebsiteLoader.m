//
//  RUBWebViewWebsiteLoader.m
//  SecureNetworkingDemo
//
//  Idea for using UIWebView with self-signed and client certificates:
//  http://stackoverflow.com/questions/1769888/how-to-display-the-authentication-challenge-in-uiwebview
//
//
//  Created by Manuel Binna on 23.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBWebViewWebsiteLoader.h"
#import "RUBWebsiteLoader_Internal.h"


@interface RUBWebViewWebsiteLoader ()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL authenticated;

@end


#pragma mark -

@implementation RUBWebViewWebsiteLoader

#pragma mark Properties

// Public properties
// ...

// Private properties
@synthesize connection = _connection;
@synthesize authenticated = _authenticated;

#pragma mark NSObject

- (void)dealloc
{
    [_connection cancel]; [_connection release];
    
    [super dealloc];
}

#pragma mark RUBWebsiteLoader

- (void)startLoadingURL:(NSURL *)URL
{
    [super startLoadingURL:URL];
    
    UIWebView *webView = [[self websiteLoaderDelegate] webView];
    [webView setDelegate:self];
    [self setWebView:webView];
    
    [self setAuthenticated:NO];
    
    [[self webView] loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)reload
{
    [[self webView] loadRequest:[NSURLRequest requestWithURL:[self URL]]];
}

- (void)stopLoading
{
    [[self webView] stopLoading];
}

#pragma mark UIWebViewDelegate

- (BOOL)            webView:(UIWebView *)webView 
 shouldStartLoadWithRequest:(NSURLRequest *)request 
             navigationType:(UIWebViewNavigationType)navigationType
{
    if (![self authenticated])
    {
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self setConnection:connection];
        [connection release];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[self websiteLoaderDelegate] websiteLoaderDidStartLoad:self];
}

- (void)        webView:(UIWebView *)webView 
   didFailLoadWithError:(NSError *)error
{
    [[self websiteLoaderDelegate] websiteLoader:self didFailWithError:error];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([webView isLoading]) 
        return;
    
    NSString *location = [webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    [[self websiteLoaderDelegate] websiteLoaderDidFinishLoad:self currentLocation:location];
}

#pragma mark NSURLConnection delegate methods

- (void)    connection:(NSURLConnection *)connection 
    didReceiveResponse:(NSURLResponse *)response
{
    [connection cancel];
    [self setConnection:nil];
    
    [self setAuthenticated:YES];
    
    NSURLRequest *originalRequest = [NSURLRequest requestWithURL:[self URL]];
    [[self webView] loadRequest:originalRequest];
}

@end
