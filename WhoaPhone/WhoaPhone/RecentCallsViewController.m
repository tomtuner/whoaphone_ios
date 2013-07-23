//
//  RecentCallsViewController.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/22/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "RecentCallsViewController.h"
#import "ViewController.h"

@interface RecentCallsViewController ()

@end

@implementation RecentCallsViewController

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
    [self checkForPhoneNumber];
}

-(void) checkForPhoneNumber
{
    if (![SettingsManager sharedSettingsManager].phoneNumber)
    {
        
        [self performSelector:@selector(showNumberController) withObject:nil afterDelay:0.0];

    }
}

- (void) showNumberController
{
    
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    ViewController *vc = [st instantiateViewControllerWithIdentifier:@"enterPhoneViewController"];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;

    //        UITabBarController *tb = [st instantiateViewControllerWithIdentifier:@"tabBarController"];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
