//
//  WhoaPhone.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 6/17/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "WhoaPhone.h"


// private methods
@interface WhoaPhone ()

@property(nonatomic) BOOL speakerEnabled;

//TCDevice Capability Token
-(NSString*)getCapabilityToken:(NSError**)error;
-(BOOL)capabilityTokenValid;

-(void)updateAudioRoute;

+(NSError*)errorFromHTTPResponse:(NSHTTPURLResponse*)response domain:(NSString*)domain;

@end

@implementation WhoaPhone

-(id)init
{
	if ( self = [super init] )
	{
        self.speakerEnabled = YES; // enable the speaker by default
	}
	return self;
}

-(void)login
{
	[[NSNotificationCenter defaultCenter] postNotificationName:WPLoginDidStart object:nil];
	
	NSError* loginError = nil;
	NSString* capabilityToken = [self getCapabilityToken:&loginError];
	
	if ( !loginError && capabilityToken )
	{
		if ( !_device )
		{
			// initialize a new device
			_device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken delegate:self];
		}
		else
		{
			// update its capabilities
			[_device updateCapabilityToken:capabilityToken];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:WPLoginDidFinish object:nil];
	}
	else if ( loginError )
	{
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:loginError forKey:@"error"];
		[[NSNotificationCenter defaultCenter] postNotificationName:WPLoginDidFailWithError object:nil userInfo:userInfo];
	}
}

#pragma mark -
#pragma mark TCDevice Capability Token

-(NSString*)getCapabilityToken:(NSError**)error
{
	//Creates a new capability token from the auth.php file on server
	NSString *capabilityToken = nil;
	//Make the URL Connection to your server

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://whoaphone.sweepevents.com/api/twilio_auth?clientName=%@", [SettingsManager sharedSettingsManager].phoneNumber]];
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
										 returningResponse:&response error:error];
	if (data)
	{
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
		
		if (httpResponse.statusCode==200)
		{
			capabilityToken = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
		}
		else
		{
			*error = [WhoaPhone errorFromHTTPResponse:httpResponse domain:@"CapabilityTokenDomain"];
		}
	}
	// else there is likely an error which got assigned to the incoming error pointer.
	
	return capabilityToken;
}

-(BOOL)capabilityTokenValid
{
	//Check TCDevice's capability token to see if it is still valid
	BOOL isValid = NO;
	NSNumber* expirationTimeObject = [_device.capabilities objectForKey:@"expiration"];
	long long expirationTimeValue = [expirationTimeObject longLongValue];
	long long currentTimeValue = (long long)[[NSDate date] timeIntervalSince1970];
    
	if((expirationTimeValue-currentTimeValue)>0)
		isValid = YES;
	
	return isValid;
}

#pragma mark -
#pragma mark TCConnection Implementation

-(void)connect:(NSString *) phNumber
{
	// First check to see if the token we have is valid, and if not, refresh it.
	// Your own client may ask the user to re-authenticate to obtain a new token depending on
	// your security requirements.
	if (![self capabilityTokenValid])
	{
		//Capability token is not valid, so create a new one and update device
		[self login];
	}
	
	// Now check to see if we can make an outgoing call and attempt a connection if so
	NSNumber* hasOutgoing = [_device.capabilities objectForKey:TCDeviceCapabilityOutgoingKey];
	if ( [hasOutgoing boolValue] == YES )
	{
		//Disconnect if we've already got a connection in progress
		if(_connection)
			[self disconnect];
        
        NSDictionary *params = nil;
        if (phNumber.length > 0)
        {
            params = [NSDictionary dictionaryWithObject:phNumber forKey:@"PhoneNumber"];
        }
		
		_connection = [_device connect:params delegate:self];
		
		if ( !_connection ) // if a connection is established, connectionDidStartConnecting: gets invoked next
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:WPConnectionDidFailToConnect object:nil];
		}
	}
}

-(void)disconnect
{
	//Destroy TCConnection
	// We don't release until after the delegate callback for connectionDidConnect:
	[_connection disconnect];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:WPConnectionIsDisconnecting object:nil];
}

-(void)acceptConnection
{
	//Accept the pending connection
	[_pendingIncomingConnection accept];
	_connection = _pendingIncomingConnection;
	_pendingIncomingConnection = nil;
}

-(void)ignoreIncomingConnection
{
	// Ignore the pending connection
	// We don't release until after the delegate callback for connectionDidConnect:
	[_pendingIncomingConnection ignore];
}

#pragma mark -
#pragma mark TCDeviceDelegate Methods

-(void)deviceDidStartListeningForIncomingConnections:(TCDevice*)device
{
	[[NSNotificationCenter defaultCenter] postNotificationName:WPDeviceDidStartListeningForIncomingConnections object:nil];
}

-(void)device:(TCDevice*)device didStopListeningForIncomingConnections:(NSError*)error
{
	// The TCDevice is no longer listening for incoming connections, possibly due to an error.
	NSDictionary* userInfo = nil;
	if ( error )
		userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WPDeviceDidStopListeningForIncomingConnections object:nil userInfo:userInfo];
}

-(void)device:(TCDevice*)device didReceiveIncomingConnection:(TCConnection*)connection
{
	//Device received an incoming connection
	if ( _pendingIncomingConnection )
	{
		NSLog(@"A pending exception already exists");
		return;
	}
	
	// Initalize pending incoming conneciton
	_pendingIncomingConnection = connection;
//    _pendingIncomingConnection = [[TCConnection alloc] init];
	[_pendingIncomingConnection setDelegate:self];
//	[_pendingIncomingConnection accept];
	// Send a notification out that we've received this.
	[[NSNotificationCenter defaultCenter] postNotificationName:WPPendingIncomingConnectionReceived object:nil];
}

#pragma mark -
#pragma mark TCConnectionDelegate

-(void)connectionDidStartConnecting:(TCConnection*)connection
{
	[[NSNotificationCenter defaultCenter] postNotificationName:WPConnectionIsConnecting object:nil];
}

-(void)connectionDidConnect:(TCConnection*)connection
{
	// Enable the proximity sensor to make sure the call doesn't errantly get hung up.
	UIDevice* device = [UIDevice currentDevice];
	device.proximityMonitoringEnabled = YES;
	
	// set up the route audio through the speaker, if enabled
	[self updateAudioRoute];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:WPConnectionDidConnect object:nil];
}

-(void)connectionDidDisconnect:(TCConnection*)connection
{
	if ( connection == _connection )
	{
		UIDevice* device = [UIDevice currentDevice];
		device.proximityMonitoringEnabled = NO;
        
//		[_connection release];
		_connection = nil;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:WPConnectionDidDisconnect object:nil];
	}
	else if ( connection == _pendingIncomingConnection )
	{
//		[_pendingIncomingConnection release];
		_pendingIncomingConnection = nil;
        
		[[NSNotificationCenter defaultCenter] postNotificationName:WPPendingIncomingConnectionDidDisconnect object:nil];
	}
}

-(void)connection:(TCConnection*)connection didFailWithError:(NSError*)error
{
	//Connection failed
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"]; // autoreleased
	[[NSNotificationCenter defaultCenter] postNotificationName:WPConnectionDidFailWithError object:nil userInfo:userInfo];
}

-(void)setSpeakerEnabled:(BOOL)enabled
{
	_speakerEnabled = enabled;
	
	[self updateAudioRoute];
}

-(void)updateAudioRoute
{
	if (_speakerEnabled)
	{
		UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
		
		AudioSessionSetProperty (
								 kAudioSessionProperty_OverrideAudioRoute,
								 sizeof (audioRouteOverride),
								 &audioRouteOverride
								 );
	}
	else
	{
		UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
		
		AudioSessionSetProperty (
								 kAudioSessionProperty_OverrideAudioRoute,
								 sizeof (audioRouteOverride),
								 &audioRouteOverride
								 );	
	}
}


#pragma mark -
#pragma mark Misc

// Utility method to create a simple NSError* from an HTTP response
+(NSError*)errorFromHTTPResponse:(NSHTTPURLResponse*)response domain:(NSString*)domain
{
	NSString* localizedDescription = [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode];
	
	NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:localizedDescription
															  forKey:NSLocalizedDescriptionKey];
	
	NSError* error = [NSError errorWithDomain:domain
										 code:response.statusCode
									 userInfo:errorUserInfo];
	return error;
}

@end
