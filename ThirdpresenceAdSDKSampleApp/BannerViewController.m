//
//  BannerViewController.m
//  ThirdpresenceAdSDKSampleApp
//
//  Created by Marko Okkonen on 02/12/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "BannerViewController.h"
#import "Constants.h"

@interface BannerViewController ()
- (void) loadBanner;
@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accountField.text = DEFAULT_ACCOUNT;
    _accountField.delegate = self;
    
    _placementField.text = DEFAULT_BANNER_PLACEMENT_ID;
    _placementField.delegate = self;
    
    _statusField.text = @"IDLE";
    
    [self loadBanner];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    if (self.videoBanner) {
        [self.videoBanner removePlayer];
        self.videoBanner.delegate = nil;
        self.videoBanner = nil;
    }
 
    self.reloadButton = nil;
    self.accountField = nil;
    self.placementField = nil;
    self.statusField = nil;
    self.bannerView = nil;
}

/**
 *  This method demonstrates how to create and initialize TPRVideoBanner
 */
- (void) loadBanner {
    
    // Release any earlier banner video
    if (self.videoBanner) {
        [self.videoBanner removePlayer];
        self.videoBanner.delegate = nil;
        self.videoBanner = nil;
    }
    
    NSString *account = self.accountField.text;
    NSString *placementId = self.placementField.text;
    
    if (account.length < 1) {
        [self queueMessage:@"Account name not set"];
        return;
    }
    else if (placementId.length < 1) {
        [self queueMessage:@"Placement id not set"];
    }
    
    // Environment dictionary must contain at least key TPR_ENVIRONMENT_KEY_ACCOUNT and
    // TPR_ENVIRONMENT_KEY_PLACEMENT_ID
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        account, TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        placementId, TPR_ENVIRONMENT_KEY_PLACEMENT_ID, nil];
    
    
    // Pass information about the application and user in playerParams dictionary.
    
    // In order to get more targeted ads user gender and year of birth are recommended.
    // You can get the data, for example, from Facebook Graph API if you have integrated with Facekbook.
    // https://developers.facebook.com/docs/graph-api/reference/v2.6/user
    NSString *userGender = @"male";
    NSString *userYearOfBirth = @"1970";
    
    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         APP_NAME, TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                         APP_VERSION,TPR_PLAYER_PARAMETER_KEY_APP_VERSION,
                                         APP_STORE_URL, TPR_PLAYER_PARAMETER_KEY_APP_STORE_URL,
                                         userGender, TPR_PLAYER_PARAMETER_KEY_USER_GENDER,
                                         userYearOfBirth, TPR_PLAYER_PARAMETER_KEY_USER_YOB,
                                         nil];
    
    // Initialize the interstitial
    self.videoBanner = [[TPRVideoBanner alloc] initWithBannerView:_bannerView
                                                      environment:environment
                                                           params:playerParams
                                                          timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    
    // Optional delegate for player events
    self.videoBanner.delegate = self;
    _statusField.text = @"INITIALIZING";
 
    [self.videoBanner loadAd];
}

/**
 *  Delegate handler for video ad failures @see TPRVideoAd
 *
 *  @param videoAd object that sent the error
 *  @param error   NSError object
 */
- (void) videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.videoBanner) {
        _statusField.text = @"ERROR";
        [self queueMessage:error.localizedDescription];
    }
}

/**
 *  Delegate handler for video ad events @see TPRVideoAd
 *
 *  @param videoAd object that sent the event
 *  @param event   event object
 */
- (void) videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
    if (videoAd == self.videoBanner) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            _statusField.text = @"READY";
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            _statusField.text = @"LOADED";
        }  else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STARTED]) {
            _statusField.text = @"DISPLAYING";
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            _statusField.text = @"ERROR";
            [self queueMessage:[NSString stringWithFormat:@"Failure: %@", [event objectForKey:TPR_EVENT_KEY_ARG1]]];
        }
    }
}

/**
 *  UIButton handler
 *
 *  @param sender
 */
- (IBAction) onButtonPressed:(id)sender {
    if (sender == self.reloadButton) {
        [self loadBanner];
    }
}

@end
