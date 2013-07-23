//
//  Devices.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/9/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "Devices.h"

@implementation Devices

static Devices *globalDevice = nil;
static BOOL initialized = NO;


+ (Devices *) sharedDevice {
    if (!globalDevice) {
        globalDevice = [[Devices alloc] init];
    }
    
    return globalDevice;
}

- (id)init
{
    if (initialized) {
        return globalDevice;
    }
    self = [super init];
    if (self) {
        
    }else {
        device = nil;
        initialized = YES;
    }
    return self;
}

+ (void)globalDeviceRegistrationWithDevice:(Devices *) device withBlock:(void (^)(NSDictionary *device, NSError *error))block
{
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               device.token, @"token",
                               [SettingsManager sharedSettingsManager].phoneNumber, @"ph_num", nil];
    NSMutableDictionary *deviceString = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  paramDict, @"device", nil];
    
    
    WPAPIClient *networkingClient = [WPAPIClient sharedClient];
    [networkingClient postPath:[NSString stringWithFormat:@"%@devices", networkingClient.baseURL]
                    parameters:deviceString
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSLog(@"Success");
                           NSLog(@"Response: %@", responseObject);
                           NSDictionary *departmentFromResponse = responseObject;
                           
                           if (block) {
                               block([NSDictionary dictionaryWithDictionary:departmentFromResponse], nil);
                           }
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           NSLog(@"Fail");
                           NSLog(@"%@", [error localizedDescription]);
                           if (block) {
                               block([NSDictionary dictionary], error);
                           }
                       }];
}
@end
