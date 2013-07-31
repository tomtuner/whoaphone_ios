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

- (IBAction)deleteButtonPressed:(id)sender
{
    if (self.numberLabel.text.length > 0)
    {
        self.numberLabel.text = [self.numberLabel.text substringToIndex:self.numberLabel.text.length - 1];
    }
}

-(IBAction)callButtonSelected:(id)sender
{
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    WhoaPhone *phone = delegate.phone;
    [phone connect:self.numberLabel.text];
    [self showInCallController];
}

- (void) showInCallController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    InCallViewController *inCallController = [st instantiateViewControllerWithIdentifier:@"inCallViewController"];
    inCallController.outboundNumber = self.numberLabel.text;
    inCallController.initialStatus = @"Calling...";
    //    logInController.departmentKeyItem = self.departmentKeyItem;
    //    logInController.modalPresentationStyle = UIModalPresentationFormSheet;
    inCallController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:inCallController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
