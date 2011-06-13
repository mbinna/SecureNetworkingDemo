//
//  SecureNetworkingDemoViewController.h
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 22.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBWebsiteLoader.h"
#import "RUBWebViewWebsiteLoader.h"

#pragma mark -

@interface RUBWebBrowserViewController : UIViewController 
<
    UISearchBarDelegate, 
    RUBWebsiteLoaderDelegate
>
{

}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) RUBWebsiteLoader *websiteLoader;

@end
