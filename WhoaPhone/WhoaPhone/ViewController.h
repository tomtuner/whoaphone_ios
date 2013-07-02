//
//  ViewController.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 6/17/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhoaPhone.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController <UIAlertViewDelegate>
{
    WhoaPhone* _phone;
}

//@property (nonatomic,retain) IBOutlet UIButton* mainButton;
//@property (nonatomic,retain) IBOutlet UITextView* textView;
//@property (nonatomic,retain) IBOutlet UISwitch* speakerSwitch;
@property (nonatomic, strong) WhoaPhone* phone;

@end
