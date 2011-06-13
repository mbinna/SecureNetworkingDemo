//
//  SecureNetworkingDemoAppDelegate.m
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 22.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBSecureNetworkingDemoAppDelegate.h"
#import "RUBWebBrowserViewController.h"
#import "RUBWebViewWebsiteLoader.h"
#import "RUBURLLoadingSystemWebsiteLoader.h"
#import "RUBCFNetworkWebsiteLoader.h"


@interface RUBSecureNetworkingDemoAppDelegate ()

@property (nonatomic, retain) UITabBarController *tabBarController;

- (void)setupTabBar;

@end


#pragma mark -

@implementation RUBSecureNetworkingDemoAppDelegate

#pragma mark Properties

// Public properties
@synthesize window = _window;

// Private
@synthesize tabBarController = _tabBarController;

#pragma mark NSObject

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    
    [super dealloc];
}

#pragma mark UIApplication

- (BOOL)            application:(UIApplication *)application 
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupTabBar];
    [[self window] addSubview:[[self tabBarController] view]];
    
    [[self window] makeKeyAndVisible];
    
    return YES;
}

#pragma mark RUBSecureNetworkingDemoAppDelegate

- (void)setupTabBar
{
    // UIWebView tab
    RUBWebBrowserViewController *webViewWebBrowserVC = [[RUBWebBrowserViewController alloc] 
                                                        initWithNibName:nil bundle:nil];
    [webViewWebBrowserVC setTitle:@"UIWebView"];
    RUBWebViewWebsiteLoader *webViewWebsiteLoader = [[RUBWebViewWebsiteLoader alloc] init];
    [webViewWebsiteLoader setWebsiteLoaderDelegate:webViewWebBrowserVC];
    [webViewWebBrowserVC setWebsiteLoader:webViewWebsiteLoader];
    [webViewWebsiteLoader release];
    UINavigationController *webViewNavController = [[UINavigationController alloc] 
                                                       initWithRootViewController:webViewWebBrowserVC];
    UITabBarItem *webViewTabBarItem = [[UITabBarItem alloc] initWithTitle:@"UIWebView" image:nil tag:0];
    [webViewNavController setTabBarItem:webViewTabBarItem];
    [webViewTabBarItem release];
    [webViewWebBrowserVC release];
    
    // URL Loading System tab
    RUBWebBrowserViewController *loadingSystemWebBrowserVC = [[RUBWebBrowserViewController alloc] 
                                                              initWithNibName:nil bundle:nil];
    [loadingSystemWebBrowserVC setTitle:@"URL Loading System"];
    RUBURLLoadingSystemWebsiteLoader *loadingSystemWebsiteLoader = [[RUBURLLoadingSystemWebsiteLoader alloc] init];
    [loadingSystemWebsiteLoader setWebsiteLoaderDelegate:loadingSystemWebBrowserVC];
    [loadingSystemWebBrowserVC setWebsiteLoader:loadingSystemWebsiteLoader];
    [loadingSystemWebsiteLoader release];
    UINavigationController *loadingSystemNavController = [[UINavigationController alloc] 
                                                            initWithRootViewController:loadingSystemWebBrowserVC];
    UITabBarItem *loadingSystemTabBarItem = [[UITabBarItem alloc] initWithTitle:@"URL Loading System" image:nil tag:0];
    [loadingSystemNavController setTabBarItem:loadingSystemTabBarItem];
    [loadingSystemTabBarItem release];
    [loadingSystemWebBrowserVC release];
    
    // CFNetwork tab
    RUBWebBrowserViewController *cfNetworkWebBrowserVC = [[RUBWebBrowserViewController alloc] 
                                                          initWithNibName:nil bundle:nil];
    [cfNetworkWebBrowserVC setTitle:@"CFNetwork"];
    RUBCFNetworkWebsiteLoader *cfNetworkWebsiteLoader = [[RUBCFNetworkWebsiteLoader alloc] init];
    [cfNetworkWebsiteLoader setWebsiteLoaderDelegate:cfNetworkWebBrowserVC];
    [cfNetworkWebBrowserVC setWebsiteLoader:cfNetworkWebsiteLoader];
    [cfNetworkWebsiteLoader release];
    UINavigationController *cfNetworkNavController = [[UINavigationController alloc] 
                                                         initWithRootViewController:cfNetworkWebBrowserVC];
    UITabBarItem *cfNetworkTabBarItem = [[UITabBarItem alloc] initWithTitle:@"CFNetwork" image:nil tag:0];
    [cfNetworkNavController setTabBarItem:cfNetworkTabBarItem];
    [cfNetworkTabBarItem release];
    [cfNetworkWebBrowserVC release];
    
    // Add tabs to tab bar
    NSArray *tabBarRootViewControllers = [NSArray arrayWithObjects:
                                          webViewNavController, 
                                          loadingSystemNavController, 
                                          cfNetworkNavController,
                                          nil];
    [webViewNavController release];
    [loadingSystemNavController release];
    [cfNetworkNavController release];
    
    UITabBarController *theTabBarController = [[UITabBarController alloc] init];
    [theTabBarController setViewControllers:tabBarRootViewControllers];
    [self setTabBarController:theTabBarController];
    [theTabBarController release];
}

@end
