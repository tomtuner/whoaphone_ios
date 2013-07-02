//
//  WhoaPhone.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 6/17/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "TwilioClient.h"
#import "WhoaPhoneNotifications.h"

@interface WhoaPhone : NSObject <TCDeviceDelegate, TCConnectionDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) TCDevice* device;
@property (nonatomic,strong) TCConnection* connection;
@property (nonatomic,strong) TCConnection* pendingIncomingConnection;

-(void)login;

//TCConnection Methods
-(void)connect;
-(void)disconnect;
-(void)acceptConnection;
-(void)ignoreIncomingConnection;

@end
