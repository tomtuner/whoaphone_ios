//
//  WPAPIClient.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/9/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "WPAPIClient.h"

@implementation WPAPIClient

+ (WPAPIClient *)sharedClient {
    static WPAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[WPAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kWPAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
//    [self setDefaultHeader:@"Authorization" value:@"Token token=d2f3dc51d72c3b303a9ed640a98550ae"];
    [self setDefaultHeader:@"format" value:@"json"];
    
    return self;
}
@end
