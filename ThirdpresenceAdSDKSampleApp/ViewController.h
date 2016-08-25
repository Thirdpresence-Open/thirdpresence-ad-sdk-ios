//
//  ViewController.h
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ThirdpresenceAdSDK/ThirdpresenceAdSDK.h>
#import <CoreLocation/CLLocationManager.h>

@interface ViewController : UIViewController <TPRVideoAdDelegate, UITextFieldDelegate>

// Button outlets
@property (weak) IBOutlet UIButton *initializeButton;
@property (weak) IBOutlet UIButton *loadButton;
@property (weak) IBOutlet UIButton *displayButton;
@property (weak) IBOutlet UITextField *accountField;
@property (weak) IBOutlet UITextField *placementField;
@property (weak) IBOutlet UITextField *vastField;

// Location manager for providing location data for Ad SDK
@property (strong) CLLocationManager* locationManager;

// UI alert message queue
@property (strong) NSMutableArray *pendingMessages;
@property (assign) BOOL showingAlert;

// Thirdpresence interstitial ad
@property (strong) TPRVideoInterstitial *interstitial;

// Ad loaded property
@property (assign) BOOL adLoaded;

@end

