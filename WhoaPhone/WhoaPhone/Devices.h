//
//  Devices.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/9/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPAPIClient.h"
#import "SettingsManager.h"

@interface Devices : NSObject {
    Devices *device;
}

+ (Devices *) sharedDevice;

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *phNum;

+ (void)globalDeviceRegistrationWithDevice:(Devices *) device withBlock:(void (^)(NSDictionary *device, NSError *error))block;

@end
