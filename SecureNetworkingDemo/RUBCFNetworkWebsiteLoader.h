//
//  RUBCFNetworkWebsiteLoader.h
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 24.02.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

#import "RUBWebsiteLoader.h"


@interface RUBCFNetworkWebsiteLoader : RUBWebsiteLoader <NSStreamDelegate>
{
    
}

- (void)startLoadingURL:(NSURL *)URL;
- (void)reload;
- (void)stopLoading;

@end
