//
//  BannerViewController.h
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 02/12/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ThirdpresenceAdSDK/ThirdpresenceAdSDK.h>
#import "BaseViewController.h"

@interface BannerViewController : BaseViewController <TPRVideoAdDelegate, UITextFieldDelegate,UIScrollViewDelegate>

// Button outlets
@property (weak) IBOutlet UIButton *reloadButton;
@property (weak) IBOutlet UITextField *accountField;
@property (weak) IBOutlet UITextField *placementField;
@property (weak) IBOutlet UITextField *statusField;
@property (weak) IBOutlet UIScrollView *scrollView;

@property (weak) IBOutlet TPRBannerView *bannerView;

@property (strong) TPRVideoBanner *videoBanner;
@end
