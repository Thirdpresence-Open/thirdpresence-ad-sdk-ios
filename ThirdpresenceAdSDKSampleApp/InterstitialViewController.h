//
//  InterstitialViewController.h
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ThirdpresenceAdSDK/ThirdpresenceAdSDK.h>
#import "BaseViewController.h"

@interface InterstitialViewController : BaseViewController <TPRVideoAdDelegate, UITextFieldDelegate>

// Button outlets
@property (weak) IBOutlet UIButton *initializeButton;
@property (weak) IBOutlet UIButton *loadButton;
@property (weak) IBOutlet UIButton *displayButton;
@property (weak) IBOutlet UITextField *accountField;
@property (weak) IBOutlet UITextField *placementField;
@property (weak) IBOutlet UITextField *vastField;
@property (weak) IBOutlet UITextField *statusField;

@property (strong) TPRVideoInterstitial *interstitial;


@end

