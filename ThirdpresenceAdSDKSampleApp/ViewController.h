//
//  ViewController.h
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ThirdpresenceAdSDK/ThirdpresenceAdSDK.h>

@interface ViewController : UIViewController <TPRVideoAdDelegate>

// Button outlets
@property (weak) IBOutlet UIButton *initializeButton;
@property (weak) IBOutlet UIButton *loadButton;
@property (weak) IBOutlet UIButton *displayButton;
@property (weak) IBOutlet UIButton *resetButton;
@property (weak) IBOutlet UIButton *removeButton;

// UI message queue
@property (strong) NSMutableArray *pendingMessages;

// Thirdpresence interstitial ad
@property (strong) TPRVideoInterstitial *interstitial;

// Ad loaded property
@property (assign) BOOL adLoaded;

@end

