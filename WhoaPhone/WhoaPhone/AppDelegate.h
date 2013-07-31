//
//  AppDelegate.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 6/17/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Devices.h"
#import "InCallViewController.h"

@class BasicPhoneViewController;
@class WhoaPhone;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) WhoaPhone *phone;
@property(nonatomic, strong) UIAlertView* alertView;

// Returns NO if the app isn't in the foreground in a multitasking OS environment.
-(BOOL)isForeground;

@end
