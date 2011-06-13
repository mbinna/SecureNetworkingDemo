//
//  RUBWebsiteLoader_Internal.h
//  SecureNetworkingDemo
//
//  Created by Manuel Binna on 03.03.11.
//  Copyright 2011 Manuel Binna. All rights reserved.
//

@interface RUBWebsiteLoader ()

- (SecIdentityRef)copyIdentityFromPKCS12File;
- (OSStatus)extractIdentity:(SecIdentityRef *)identity 
                   andTrust:(SecTrustRef *)trust 
             fromPKCS12Data:(NSData *)PKCS12Data;

@end
