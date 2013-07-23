//
//  KeypadViewController.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/22/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "KeypadViewController.h"

@interface KeypadViewController ()

@property(nonatomic, strong) IBOutlet UILabel *numberLabel;

@end

@implementation KeypadViewController

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
}

- (IBAction)keySelected:(id)sender
{
    UIButton *keypadButton = (UIButton *) sender;
    self.numberLabel.text = [NSString stringWithFormat:@"%@%@", self.numberLabel.text, keypadButton.titleLabel.text];
}

-(IBAction)callButtonSelected:(id)sender
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    WhoaPhone *phone = delegate.phone;
    [phone connect:self.numberLabel.text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
