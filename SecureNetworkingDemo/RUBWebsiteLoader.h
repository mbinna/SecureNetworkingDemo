//
//  RUBWebsiteLoader.h
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 23.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

@class RUBWebBrowserViewController;
@class RUBWebsiteLoader;


@protocol RUBWebsiteLoaderDelegate <NSObject>

@property (nonatomic, readonly, retain) UIWebView *webView;

- (void)websiteLoaderDidStartLoad:(RUBWebsiteLoader *)websiteLoader;
- (void)websiteLoader:(RUBWebsiteLoader *)websiteLoader didFailWithError:(NSError *)error;
- (void)websiteLoaderDidFinishLoad:(RUBWebsiteLoader *)websiteLoader currentLocation:(NSString *)location;

@end


@interface RUBWebsiteLoader : NSObject <UIWebViewDelegate>
{

}

@property (nonatomic, readonly, retain) NSURL *URL;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, assign) id<RUBWebsiteLoaderDelegate> websiteLoaderDelegate;

- (void)startLoadingURL:(NSURL *)URL;
- (void)reload;
- (void)stopLoading;

@end
