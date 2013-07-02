//
//  WhoaPhoneNotifications.m
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/1/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "WhoaPhoneNotifications.h"

NSString* const WPLoginDidStart									= @"WPLoginDidStart";
NSString* const WPLoginDidFinish								= @"WPLoginDidFinish";
NSString* const WPLoginDidFailWithError							= @"WPLoginDidFailWithError";

NSString* const WPPendingIncomingConnectionReceived				= @"WPPendingIncomingConnectionReceived";
NSString* const WPPendingIncomingConnectionDidDisconnect		= @"WPPendingIncomingConnectionDidDisconnect";
NSString* const WPPendingConnectionDidDisconnect				= @"WPPendingConnectionDidDisconnect";
NSString* const WPConnectionDidConnect							= @"WPConnectionDidConnect";
NSString* const WPConnectionDidFailToConnect					= @"WPConnectionDidFailToConnect";
NSString* const WPConnectionIsConnecting						= @"WPConnectionIsConnecting";
NSString* const WPConnectionIsDisconnecting						= @"WPConnectionIsDisconnecting";
NSString* const WPConnectionDidDisconnect						= @"WPConnectionDidDisconnect";
NSString* const WPConnectionDidFailWithError					= @"WPConnectionDidFailWithError";

NSString* const WPDeviceDidStartListeningForIncomingConnections	= @"WPDeviceDidStartListeningForIncomingConnections";
NSString* const WPDeviceDidStopListeningForIncomingConnections	= @"WPDeviceDidStopListeningForIncomingConnections";