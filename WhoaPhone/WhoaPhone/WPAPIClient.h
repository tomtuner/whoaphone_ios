//
//  WPAPIClient.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/9/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#define kWPAPIBaseURLString @"http://whoaphone.sweepevents.com/api/"

@interface WPAPIClient : AFHTTPClient

+ (WPAPIClient *)sharedClient;
- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className withParameters:(NSDictionary *) passedParameters updatedAfterDate:(NSDate *)updatedDate;


- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;

@end
