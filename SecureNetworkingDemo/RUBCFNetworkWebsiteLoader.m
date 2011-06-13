//
//  RUBCFNetworkWebsiteLoader.m
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 24.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBCFNetworkWebsiteLoader.h"

#define kInputBufferLength 1024

#pragma mark -

@interface RUBCFNetworkWebsiteLoader ()

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSMutableData *receivedData;

@end


#pragma mark -

@implementation RUBCFNetworkWebsiteLoader

#pragma mark Properties

// Private properteis
@synthesize inputStream = _inputStream;
@synthesize receivedData = _receivedData;

#pragma mark NSObject

- (void)dealloc
{
    [_inputStream close]; [_inputStream release];
    [_receivedData release];
    
    [super dealloc];
}

#pragma mark RUBCFNetworkWebsiteLoader

- (void)startLoadingURL:(NSURL *)URL
{
    [super startLoadingURL:URL];
    
    NSLog(@"Sending HTTP request to host %@", [URL host]);
    
    // Assemble HTTP request
    CFHTTPMessageRef httpRequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault,
                                                              CFSTR("GET"),
                                                              (CFURLRef)[self URL],
                                                              kCFHTTPVersion1_1);
    
    // Configure HTTPS stream. Inspired by:
    // http://blog.asolutions.com/2011/02/using-tls-with-self-signed-certificates-or-custom-root-certificates-in-ios
    CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, 
                                                                  httpRequest);
    CFReadStreamSetProperty(readStream,
                            kCFStreamPropertyHTTPShouldAutoredirect, 
                            kCFBooleanTrue);
    NSDictionary *sslSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                 (id)kCFStreamSocketSecurityLevelTLSv1, (id)kCFStreamSSLLevel,
                                 (id)kCFBooleanFalse, (id)kCFStreamSSLValidatesCertificateChain,
                                 nil];
    CFReadStreamSetProperty(readStream, 
                            kCFStreamPropertySSLSettings, 
                            sslSettings);
    [self setInputStream:(NSInputStream *)readStream];
    [[self inputStream] setDelegate:self];
    
    // Schedule streams in Run Loop
    [[self inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
    
    // Cleanup
    if (httpRequest)
        CFRelease(httpRequest);
    
    // Open streams
    [[self inputStream] open];
}

- (void)reload
{
    
}

- (void)stopLoading
{
    
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    if ([theStream isKindOfClass:[NSInputStream class]]) 
    {
        NSInputStream *theInputStream = (NSInputStream *) theStream;
        switch (streamEvent) 
        {
            case NSStreamEventNone:
                break;
                
            case NSStreamEventOpenCompleted:
            {                
                break;
            }
                
            case NSStreamEventHasBytesAvailable:
            {
                SecTrustRef serverTrust = (SecTrustRef)[theInputStream propertyForKey:(NSString *)kCFStreamPropertySSLPeerTrust];
                
                // Set exceptions
                SecTrustResultType trustResult = kSecTrustResultInvalid;
                OSStatus evaluateStatus = SecTrustEvaluate(serverTrust, &trustResult);
                BOOL trusted = (evaluateStatus == errSecSuccess) && ((trustResult == kSecTrustResultProceed) || 
                                                                     (trustResult == kSecTrustResultUnspecified));
                if (!trusted) 
                {
                    CFDataRef exceptionsData = SecTrustCopyExceptions(serverTrust);
                    if (!SecTrustSetExceptions(serverTrust, exceptionsData))
                    {
                        // Exceptions not set
                        [theInputStream close];
                        
                        if (exceptionsData)
                            CFRelease(exceptionsData);
                        
                        break;
                    }
                    if (exceptionsData)
                        CFRelease(exceptionsData);
                    
                    // Re-evaluate the server certificate again
                    trustResult = kSecTrustResultInvalid;
                    evaluateStatus = SecTrustEvaluate(serverTrust, &trustResult);
                    trusted = (evaluateStatus == errSecSuccess) && ((trustResult == kSecTrustResultProceed) || 
                                                                    (trustResult == kSecTrustResultUnspecified));
                    if (!trusted)
                    {
                        // Error. Could not evaluate trust.
                        [theInputStream close];
                        break;
                    }
                }
                
                if ([self receivedData] == nil) 
                {
                    NSMutableData *data = [[NSMutableData alloc] init];
                    [self setReceivedData:data];
                    [data release];
                }
                
                // Read bytes into buffer
                uint8_t buffer[kInputBufferLength];
                NSInteger bytesRead = [theInputStream read:buffer 
                                                 maxLength:kInputBufferLength];
                
                // Store received bytes
                if (bytesRead > 0) 
                {
                    [[self receivedData] appendBytes:buffer length:bytesRead];
                }

                break;
            }
                
            case NSStreamEventErrorOccurred:
            {
                NSString *errorDescription = [[theInputStream streamError] description];
                NSLog(@"%@", errorDescription);
                
                [theInputStream close];
                
                break;
            }
                
            case NSStreamEventEndEncountered:
            {
                CFHTTPMessageRef httpResponse = 
                    (CFHTTPMessageRef)CFReadStreamCopyProperty((CFReadStreamRef)theInputStream,
                                                               kCFStreamPropertyHTTPResponseHeader);
                NSString *htmlString = [[NSString alloc] initWithData:[self receivedData] 
                                                             encoding:NSUTF8StringEncoding];
                [[[self websiteLoaderDelegate] webView] loadHTMLString:htmlString baseURL:nil];
                
                // Cleanup
                [htmlString release];
                [self setReceivedData:nil];
                if (httpResponse)
                    CFRelease(httpResponse);
                
                [[self websiteLoaderDelegate] websiteLoaderDidFinishLoad:self currentLocation:nil];
                
                [theInputStream close];
                
                 break;
            }
                
            default:
                break;
        }
    }
}

@end
