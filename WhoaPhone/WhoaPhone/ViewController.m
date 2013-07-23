//
//  ViewController.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 6/17/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "WhoaPhone.h"
#import "WhoaPhoneNotifications.h"

@interface ViewController ()

@property(nonatomic, strong) UIAlertView* alertView;

-(void)addStatusMessage:(NSString*)message;

// notifications
-(void)loginDidStart:(NSNotification*)notification;
-(void)loginDidFinish:(NSNotification*)notification;
-(void)loginDidFailWithError:(NSNotification*)notification;

-(void)connectionDidConnect:(NSNotification*)notification;
-(void)connectionDidFailToConnect:(NSNotification*)notification;
-(void)connectionIsDisconnecting:(NSNotification*)notification;
-(void)connectionDidDisconnect:(NSNotification*)notification;
-(void)connectionDidFailWithError:(NSNotification*)notification;

-(void)pendingIncomingConnectionDidDisconnect:(NSNotification*)notification;
-(void)pendingIncomingConnectionReceived:(NSNotification*)notification;

-(void)deviceDidStartListeningForIncomingConnections:(NSNotification*)notification;
-(void)deviceDidStopListeningForIncomingConnections:(NSNotification*)notification;

@end

@implementation ViewController

@synthesize phone = _phone;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self registerPhoneNotifications];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Shared Device: %@", [Devices sharedDevice].token);

//    [Devices sharedDevice].phNum = textField.text;
    [SettingsManager sharedSettingsManager].phoneNumber = textField.text;
    [Devices globalDeviceRegistrationWithDevice:[Devices sharedDevice] withBlock:^(NSDictionary *device, NSError *error){
        if (!error)
        {
            NSLog(@"Success");
            NSLog(@"Device: %@", device);
            AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
            self.phone = delegate.phone;
            [self.phone login];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark Notifications

-(void)loginDidStart:(NSNotification*)notification
{
	[self addStatusMessage:@"-Logging in..."];
}

-(void)loginDidFinish:(NSNotification*)notification
{
	NSNumber* hasOutgoing = [self.phone.device.capabilities objectForKey:TCDeviceCapabilityOutgoingKey];
	if ( [hasOutgoing boolValue] == YES )
	{
		[self addStatusMessage:@"-Outgoing calls allowed"];
	}
	else
	{
		[self addStatusMessage:@"-Unable to make outgoing calls with current capabilities"];
	}
	
	if ( [hasOutgoing boolValue] == YES )
	{
		[self addStatusMessage:@"-Incoming calls allowed"];
	}
	else
	{
		[self addStatusMessage:@"-Unable to receive incoming calls with current capabilities"];
	}
}

-(void)loginDidFailWithError:(NSNotification*)notification
{
	NSError* error = [[notification userInfo] objectForKey:@"error"];
	if ( error )
	{
		NSString* message = [NSString stringWithFormat:@"-Error logging in: %@ (%d)",
							 [error localizedDescription],
							 [error code]];
		[self addStatusMessage:message];
	}
	else
	{
		[self addStatusMessage:@"-Unknown error logging in"];
	}
	[self syncMainButton];
}

-(void)connectionIsConnecting:(NSNotification*)notification
{
	[self addStatusMessage:@"-Attempting to connect"];
	[self syncMainButton];
}

-(void)connectionDidConnect:(NSNotification*)notification
{
	[self addStatusMessage:@"-Connection did connect"];
	[self syncMainButton];
}

-(void)connectionDidFailToConnect:(NSNotification*)notification
{
	[self addStatusMessage:@"-Couldn't establish outgoing call"];
}

-(void)connectionIsDisconnecting:(NSNotification*)notification
{
	[self addStatusMessage:@"-Attempting to disconnect"];
	[self syncMainButton];
}

-(void)connectionDidDisconnect:(NSNotification*)notification
{
	[self addStatusMessage:@"-Connection did disconnect"];
	[self syncMainButton];
}

-(void)connectionDidFailWithError:(NSNotification*)notification
{
	NSError* error = [[notification userInfo] objectForKey:@"error"];
	if ( error )
	{
		NSString* message = [NSString stringWithFormat:@"-Connection did fail with error code %d, domain %@",
                             [error code],
                             [error domain]];
		[self addStatusMessage:message];
	}
	[self syncMainButton];
}

-(void)deviceDidStartListeningForIncomingConnections:(NSNotification*)notification
{
	[self addStatusMessage:@"-Device is listening for incoming connections"];
}

-(void)deviceDidStopListeningForIncomingConnections:(NSNotification*)notification
{
	NSError* error = [[notification userInfo] objectForKey:@"error"]; // may be nil
	if ( error )
	{
		[self addStatusMessage:[NSString stringWithFormat:@"-Device is no longer listening for connections due to error %@",
								[error localizedDescription]]];
	}
	else
	{
		[self addStatusMessage:@"-Device is no longer listening for connections"];
	}
}


-(BOOL)isForeground
{
	AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	return [appDelegate isForeground];
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
	
	[self addStatusMessage:@"-Received inbound connection"];
	[self syncMainButton];
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
    
	[self addStatusMessage:@"-Pending connection did disconnect"];
	[self syncMainButton];	
}

-(void)syncMainButton
{
    // Sync the main button according to the current connection's state
    if (self.phone.connection)
    {
        if (self.phone.connection.state == TCConnectionStateDisconnected)
        {
            //Connection state is closed, show idle button
            [self addStatusMessage:@"-idle"];

//            [self.mainButton setImage:[UIImage imageNamed:@"idle"] forState:UIControlStateNormal];
        }
        else if (self.phone.connection.state == TCConnectionStateConnected)
        {
            //Connection state is open, show in progress button
            [self addStatusMessage:@"-inprogress"];

//            [self.mainButton setImage:[UIImage imageNamed:@"inprogress"] forState:UIControlStateNormal];
        }
        else
        {
            //Connection is in the middle of connecting. Show dialing button
            [self addStatusMessage:@"-dialing"];

//            [self.mainButton setImage:[UIImage imageNamed:@"dialing"] forState:UIControlStateNormal];
        }
    }
    else
    {
        if (self.phone.pendingIncomingConnection)
        {
            //A pending incoming connection existed, show dialing button
//            [self.mainButton setImage:[UIImage imageNamed:@"dialing"] forState:UIControlStateNormal];
        }
        else
        {
            //Both connection and _pending connnection do not exist, show idle button
            [self addStatusMessage:@"-idle"];
//            [self.mainButton setImage:[UIImage imageNamed:@"idle"] forState:UIControlStateNormal];
        }
    }
}

-(void)addStatusMessage:(NSString*)message
{
//	if ( ![NSThread isMainThread] )
//	{
//		[self performSelectorOnMainThread:@selector(addStatusMessage:) withObject:message waitUntilDone:NO];
//		return;
//	}
//	
//	//Update the text view to tell the user what the phone is doing
//	self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@",message];
//	
//	//Scroll textview automatically for readability
//	[self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
    NSLog(@"%@", message);
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
}

-(void)cancelAlert
{
    if ( self.alertView )
    {
        [self.alertView dismissWithClickedButtonIndex:1 animated:YES];
        self.alertView = nil; // autoreleased
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView* )alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==0)
	{
		//Accept button pressed
		if(!self.phone.connection)
		{
			[self.phone acceptConnection];
		}
		else
		{
			//A connection already existed, so disconnect old connection and connect to current pending connectioon
			[self.phone disconnect];
			
			//Give the client time to reset itself, then accept connection
			[self.phone performSelector:@selector(acceptConnection) withObject:nil afterDelay:0.2];
		}
	}
	else
	{
		// We don't release until after the delegate callback for connectionDidConnect:
		[self.phone ignoreIncomingConnection];
	}
}


- (void) registerPhoneNotifications
{
    // Register for notifications that will be broadcast from the
	// BasicPhone model/controller.  These may be received on any
	// thread, so calls that may update UI state should perform those
	// changes on the main thread.
	[[NSNotificationCenter defaultCenter] addObserver:self
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
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pendingIncomingConnectionReceived:)
												 name:WPPendingIncomingConnectionReceived
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pendingIncomingConnectionDidDisconnect:)
												 name:WPPendingIncomingConnectionDidDisconnect
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceDidStartListeningForIncomingConnections:)
												 name:WPDeviceDidStartListeningForIncomingConnections
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceDidStopListeningForIncomingConnections:)
												 name:WPDeviceDidStopListeningForIncomingConnections
											   object:nil];
}

@end
