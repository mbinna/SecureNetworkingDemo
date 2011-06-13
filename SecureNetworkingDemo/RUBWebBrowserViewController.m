//
//  SecureNetworkingDemoViewController.m
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 22.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBWebBrowserViewController.h"
#import "RUBWebsiteLoader.h"


@interface RUBWebBrowserViewController ()

@property (nonatomic, retain) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem *stopBarButtonItem;

@end


@implementation RUBWebBrowserViewController

#pragma mark Properties

// Public properties
@synthesize searchBar = _searchBar;
@synthesize refreshBarButtonItem = _refreshBarButtonItem;
@synthesize stopBarButtonItem = _stopBarButtonItem;
@synthesize webView = _webView;

// Private properties
@synthesize websiteLoader = _websiteLoader;

#pragma mark NSObject

- (void)dealloc
{
    [_searchBar release];
    [_refreshBarButtonItem release];
    [_stopBarButtonItem release];
    [_webView setDelegate:nil]; [_webView release];
    
    [_websiteLoader stopLoading]; [_websiteLoader release];
    
    [super dealloc];
}

#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) 
    {
        UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] 
                                                 initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                 target:self 
                                                 action:@selector(refreshBarButtonItemTapped:)];
        [self setRefreshBarButtonItem:refreshBarButtonItem];
        [refreshBarButtonItem release];
        
        UIBarButtonItem *stopBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                              target:self 
                                              action:@selector(stopBarButtonItemTapped:)];
        [self setStopBarButtonItem:stopBarButtonItem];
        [stopBarButtonItem release];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:[self refreshBarButtonItem]];
    
    [[self webView] setDelegate:(id<UIWebViewDelegate>)[self websiteLoader]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setSearchBar:nil];
    [self setRefreshBarButtonItem:nil];
    [self setStopBarButtonItem:nil];
    [[self webView] setDelegate:nil]; [self setWebView:nil];
}

#pragma mark RUBSecureNetworkingDemoAppDelegate

- (void)refreshBarButtonItemTapped:(id)sender
{
    [[self websiteLoader] reload];
}

- (void)stopBarButtonItemTapped:(id)sender
{
    [[self websiteLoader] stopLoading];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSURL *aURL = [NSURL URLWithString:[searchBar text]];
    [[self websiteLoader] stopLoading];
    [[self websiteLoader] startLoadingURL:aURL];
    
    [searchBar resignFirstResponder];
}

#pragma mark RUBWebsiteLoader

- (void)websiteLoaderDidStartLoad:(RUBWebsiteLoader *)websiteLoader
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self navigationItem] setRightBarButtonItem:[self stopBarButtonItem] animated:YES];
}

- (void)websiteLoader:(RUBWebsiteLoader *)websiteLoader didFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self navigationItem] setRightBarButtonItem:[self refreshBarButtonItem] animated:YES];
    
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil 
                                                        message:[error localizedDescription] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void)websiteLoaderDidFinishLoad:(RUBWebsiteLoader *)websiteLoader currentLocation:(NSString *)location
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (location != nil)
        [[self searchBar] setText:location];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self navigationItem] setRightBarButtonItem:[self refreshBarButtonItem] animated:YES];
}

@end
