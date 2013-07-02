//
//  AppDelegate.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 6/17/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "AppDelegate.h"
#import "WhoaPhone.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    ViewController *vc = (ViewController *)self.window.rootViewController;
    self.phone = [[WhoaPhone alloc] init];
    vc.phone = self.phone;
    [self.phone login];
    
    return YES;
}

#pragma mark -
#pragma mark UIApplication

-(BOOL)isMultitaskingOS
{
	//Check to see if device's OS supports multitasking
	BOOL backgroundSupported = NO;
	UIDevice *currentDevice = [UIDevice currentDevice];
	if ([currentDevice respondsToSelector:@selector(isMultitaskingSupported)])
	{
		backgroundSupported = currentDevice.multitaskingSupported;
	}
	
	return backgroundSupported;
}

-(BOOL)isForeground
{
	//Check to see if app is currently in foreground
	if (![self isMultitaskingOS])
	{
		return YES;
	}
	
	UIApplicationState state = [UIApplication sharedApplication].applicationState;
	return (state==UIApplicationStateActive);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
