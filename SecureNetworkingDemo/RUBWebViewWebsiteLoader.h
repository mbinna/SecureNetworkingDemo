//
//  RUBWebViewWebsiteLoader.h
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 23.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBWebsiteLoader.h"


@interface RUBWebViewWebsiteLoader : RUBWebsiteLoader <UIWebViewDelegate>
{
    
}

- (void)startLoadingURL:(NSURL *)URL;
- (void)reload;
- (void)stopLoading;

@end
