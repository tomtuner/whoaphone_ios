//
//  Devices.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/9/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPAPIClient.h"

@interface Devices : NSObject {
    Devices *device;
}

+ (Devices *) sharedDevice;

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *phNum;

+ (void)globalDeviceRegistrationWithToken:(Devices *) device withBlock:(void (^)(NSDictionary *device, NSError *error))block;

@end
