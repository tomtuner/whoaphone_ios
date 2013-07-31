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
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    self.phone = [[WhoaPhone alloc] init];
    [self registerPhoneNotifications];

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

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    [Devices sharedDevice].token = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                                 stringByReplacingOccurrencesOfString: @" " withString: @""];
    if ([SettingsManager sharedSettingsManager].phoneNumber)
    {
        [Devices globalDeviceRegistrationWithDevice:[Devices sharedDevice] withBlock:^(NSDictionary *device, NSError *error){
            if (!error)
            {
                NSLog(@"Success");
                NSLog(@"Device: %@", device);
                AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
                self.phone = delegate.phone;
                [self.phone login];
    //            [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
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

-(void)pendingIncomingConnectionReceived:(NSNotification*)notification
{
	//Show alert view asking if user wants to accept or ignore call
	[self performSelectorOnMainThread:@selector(constructAlert) withObject:nil waitUntilDone:NO];
    //	[self constructAlert];
	//Check for background support
	if ( ![self isForeground] )
	{
		//App is not in the foreground, so send LocalNotification
		UIApplication* app = [UIApplication sharedApplication];
		UILocalNotification* notification = [[UILocalNotification alloc] init];
		NSArray* oldNots = [app scheduledLocalNotifications];
		
		if ([oldNots count]>0)
		{
			[app cancelAllLocalNotifications];
		}
		
		notification.alertBody = @"Incoming Call";
		
		[app presentLocalNotificationNow:notification];
        //		[notification release];
	}
	
	NSLog(@"-Received inbound connection");
//	[self syncMainButton];
}

-(void)pendingIncomingConnectionDidDisconnect:(NSNotification*)notification
{
	// Make sure to cancel any pending notifications/alerts
	[self performSelectorOnMainThread:@selector(cancelAlert) withObject:nil waitUntilDone:NO];
	
	if ( ![self isForeground] )
	{
		//App is not in the foreground, so kill the notification we posted.
		UIApplication* app = [UIApplication sharedApplication];
		[app cancelAllLocalNotifications];
	}
    
	NSLog(@"-Pending connection did disconnect");
//	[self syncMainButton];
}

-(void)deviceDidStartListeningForIncomingConnections:(NSNotification*)notification
{
	NSLog(@"-Device is listening for incoming connections");
}

#pragma mark -
#pragma mark UIAlertView

-(void)constructAlert
{
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Incoming Call"
                                                message:@"Accept or Ignore?"
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"Accept",@"Ignore",nil];
    [self.alertView show];
    NSLog(@"Params: %@", self.phone.connection.parameters);
}

- (void)alertView:(UIAlertView* )alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
	{
		//Accept button pressed
		if(!self.phone.connection)
		{
			[self.phone acceptConnection];
            [self showInCallController];
		}
		else
		{
			//A connection already existed, so disconnect old connection and connect to current pending connectioon
			[self.phone disconnect];
			
			//Give the client time to reset itself, then accept connection
			[self.phone performSelector:@selector(acceptConnection) withObject:nil afterDelay:0.2];
            [self showInCallController];
		}
	}
	else
	{
		// We don't release until after the delegate callback for connectionDidConnect:
		[self.phone ignoreIncomingConnection];
	}
}

- (void) showInCallController
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    InCallViewController *inCallController = [st instantiateViewControllerWithIdentifier:@"inCallViewController"];
//    logInController.departmentKeyItem = self.departmentKeyItem;
//    logInController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.window.rootViewController presentViewController:inCallController animated:NO completion:nil];
}

-(void)cancelAlert
{
    if ( self.alertView )
    {
        [self.alertView dismissWithClickedButtonIndex:1 animated:YES];
        self.alertView = nil; // autoreleased
    }
}

- (void) registerPhoneNotifications
{
    // Register for notifications that will be broadcast from the
	// BasicPhone model/controller.  These may be received on any
	// thread, so calls that may update UI state should perform those
	// changes on the main thread.
	/*[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginDidStart:)
												 name:WPLoginDidStart
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginDidFinish:)
												 name:WPLoginDidFinish
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginDidFailWithError:)
												 name:WPLoginDidFailWithError
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionIsConnecting:)
												 name:WPConnectionIsConnecting
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionDidConnect:)
												 name:WPConnectionDidConnect
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionDidDisconnect:)
												 name:WPConnectionDidDisconnect
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionIsDisconnecting:)
												 name:WPConnectionIsDisconnecting
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionDidFailToConnect:)
												 name:WPConnectionDidFailToConnect
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectionDidFailWithError:)
												 name:WPConnectionDidFailWithError
											   object:nil];*/
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pendingIncomingConnectionReceived:)
												 name:WPPendingIncomingConnectionReceived
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pendingIncomingConnectionDidDisconnect:)
												 name:WPPendingIncomingConnectionDidDisconnect
											   object:nil];
	/*[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceDidStartListeningForIncomingConnections:)
												 name:WPDeviceDidStartListeningForIncomingConnections
											   object:nil];*/
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceDidStopListeningForIncomingConnections:)
												 name:WPDeviceDidStopListeningForIncomingConnections
											   object:nil];
}


@end
