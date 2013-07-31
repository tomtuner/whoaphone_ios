//
//  InCallViewController.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WhoaPhone.h"

@interface InCallViewController : UIViewController

@property(nonatomic, strong) IBOutlet UILabel *statusLabel;
@property(nonatomic, strong) IBOutlet UILabel *numberLabel;

@property(nonatomic, strong) NSString *outboundNumber;
@property(nonatomic, strong) NSString *initialStatus;

@end
