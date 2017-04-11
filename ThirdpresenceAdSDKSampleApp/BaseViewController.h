//
//  BaseViewController.h
//  ThirdpresenceAdSDKSampleApp
//
//  Created by Marko Okkonen on 02/12/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void) showNextMessage;
- (void) queueMessage:(NSString*)message;
- (BOOL) useStagingServer;

// UI alert message queue
@property (strong) NSMutableArray *pendingMessages;
@property (assign) BOOL showingAlert;

// Ad loaded property
@property (assign) BOOL adLoaded;

// Server type
@property (strong) NSString* serverType;

@end
