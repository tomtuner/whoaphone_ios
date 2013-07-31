//
//  InCallViewController.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/30/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "InCallViewController.h"

@interface InCallViewController ()

@property(nonatomic, strong) IBOutlet UIButton *endCall;
@property (nonatomic,retain) IBOutlet UISwitch* speakerSwitch;

@end

@implementation InCallViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.numberLabel.text = self.outboundNumber;
    self.statusLabel.text = self.initialStatus;
}

-(IBAction)endCallSelected:(id)sender
{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	WhoaPhone* basicPhone = delegate.phone;
    
    //Perform correct button function based on current connection
	if (basicPhone.connection || basicPhone.connection.state != TCConnectionStateDisconnected)
    {
        [basicPhone disconnect];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)speakerSwitchPressed:(id)sender
{
	AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	WhoaPhone* basicPhone = delegate.phone;
    
	[basicPhone setSpeakerEnabled:self.speakerSwitch.on];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
