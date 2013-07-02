//
//  WhoaPhoneNotifications.h
//  WhoaPhone
//
//  Created by Thomas DeMeo on 7/1/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

extern NSString* const WPLoginDidStart;
extern NSString* const WPLoginDidFinish;
extern NSString* const WPLoginDidFailWithError;

extern NSString* const WPPendingIncomingConnectionReceived;
extern NSString* const WPPendingIncomingConnectionDidDisconnect;
extern NSString* const WPConnectionIsConnecting;
extern NSString* const WPConnectionIsDisconnecting;
extern NSString* const WPConnectionDidConnect;
extern NSString* const WPConnectionDidFailToConnect;
extern NSString* const WPConnectionDidDisconnect;
extern NSString* const WPConnectionDidFailWithError;

extern NSString* const WPDeviceDidStartListeningForIncomingConnections;
extern NSString* const WPDeviceDidStopListeningForIncomingConnections; // has an optional "error" payload in the userInfo