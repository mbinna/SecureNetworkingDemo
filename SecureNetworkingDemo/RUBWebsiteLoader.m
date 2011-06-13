//
//  RUBWebsiteLoader.m
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 23.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBWebsiteLoader.h"
#import "RUBWebsiteLoader_Internal.h"
#import "RUBWebBrowserViewController.h"

#define kImportExportPassword   @"test"


@interface RUBWebsiteLoader ()

@property (nonatomic, readwrite, retain) NSURL *URL;

@end


#pragma mark -

@implementation RUBWebsiteLoader

#pragma mark Properties

// Public properties
@synthesize websiteLoaderDelegate = _websiteLoaderDelegate;

// Private properties
@synthesize URL = _URL;
@synthesize webView = _webView;

#pragma mark NSObject

- (void)dealloc
{
    [_URL release];
    [_webView stopLoading]; [_webView release];
    
    [super dealloc];
}

#pragma mark UIWebViewDelegate

- (BOOL)            webView:(UIWebView *)webView 
 shouldStartLoadWithRequest:(NSURLRequest *)request 
             navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)        webView:(UIWebView *)webView 
   didFailLoadWithError:(NSError *)error
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

#pragma mark RUBWebsiteLoader

- (void)startLoadingURL:(NSURL *)URL
{
    [self setURL:URL];
}

- (void)reload
{
    // Intentionally empty implementation
}

- (void)stopLoading
{
    // Intentionally empty implementation
}

#pragma mark RUBWebsiteLoader ()

- (SecIdentityRef)copyIdentityFromPKCS12File
{
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"ClientCert" ofType:@"p12"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    SecIdentityRef identity;
    SecTrustRef trust;
    [self extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data];
    [PKCS12Data release];
    
    CFRetain(identity);
    
    return identity;
}

- (OSStatus)extractIdentity:(SecIdentityRef *)identity 
                   andTrust:(SecTrustRef *)trust 
             fromPKCS12Data:(NSData *)PKCS12Data
{   
    // The password is needed to decrypt the information in the PKCS#12 data
    NSDictionary *options = [NSDictionary dictionaryWithObject:kImportExportPassword 
                                                        forKey:(id)kSecImportExportPassphrase];
    
    NSArray *items = nil;
    OSStatus importStatus = SecPKCS12Import((CFDataRef)PKCS12Data, (CFDictionaryRef)options, (CFArrayRef *)&items);
    if (importStatus == errSecSuccess) 
    {
        // SecPKCS12Import() returns one dictionary for each item (identity or certificate) in the PKCS#12 data.
        NSDictionary *identityAndTrust = [items objectAtIndex:0];
        *identity = (SecIdentityRef)[identityAndTrust objectForKey:(id)kSecImportItemIdentity];
        *trust = (SecTrustRef)[identityAndTrust objectForKey:(id)kSecImportItemTrust];
    }
    
    return importStatus;
}

#pragma mark NSURLConnection delegate methods

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

- (BOOL)                    connection:(NSURLConnection *)connection 
 canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return ([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
            [[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodHTTPDigest] ||
            [[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust] ||
            [[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodClientCertificate]);
}

- (void)                connection:(NSURLConnection *)connection 
 didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
        [[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodHTTPDigest]) 
    {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"mbinna" 
                                                                 password:@"test" 
                                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else if ([[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
        SecTrustResultType trustResult = kSecTrustResultDeny;
		OSStatus err = SecTrustEvaluate(serverTrust, &trustResult);
		BOOL trusted = (err == noErr) && ((trustResult == kSecTrustResultProceed) || 
                                          (trustResult == kSecTrustResultUnspecified));
		if (!trusted)
        {
            CFDataRef exceptionsData = SecTrustCopyExceptions(serverTrust);
            if (!SecTrustSetExceptions(serverTrust, exceptionsData))
            {
                // Exceptions not set
            }
            
            if (exceptionsData)
                CFRelease(exceptionsData);
        }
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        [[challenge sender] useCredential:credential 
               forAuthenticationChallenge:challenge];
    }
    else if ([[[challenge protectionSpace] authenticationMethod] 
              isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        SecIdentityRef identity = [self copyIdentityFromPKCS12File];
        NSURLCredential *clientCertificateCredential = 
            [NSURLCredential credentialWithIdentity:identity 
                                       certificates:nil 
                                        persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:clientCertificateCredential 
               forAuthenticationChallenge:challenge];
    }
    else
    {
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)                connection:(NSURLConnection *)connection 
  didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [[self websiteLoaderDelegate] websiteLoader:self 
                               didFailWithError:[challenge error]];
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
    [[self websiteLoaderDelegate] websiteLoader:self 
                               didFailWithError:error];
}

@end
