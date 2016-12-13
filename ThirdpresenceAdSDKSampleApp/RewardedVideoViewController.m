//
//  RewardedVideoViewController.m
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "RewardedVideoViewController.h"
#import "Constants.h"

@interface RewardedVideoViewController ()
- (void) initRewardedVideo;
@end

@implementation RewardedVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accountField.text = DEFAULT_ACCOUNT;
    _accountField.delegate = self;
    
    _placementField.text = DEFAULT_REWARDED_VIDEO_PLACEMENT_ID;
    _placementField.delegate = self;
    
    _rewardField.text = @"";

    _statusField.text = @"IDLE";
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    if (self.rewardedVideo) {
        [self.rewardedVideo removePlayer];
        self.rewardedVideo.delegate = nil;
        self.rewardedVideo = nil;
    }
    
    self.initializeButton = nil;
    self.loadButton = nil;
    self.displayButton = nil;
    self.accountField = nil;
    self.placementField = nil;
    self.rewardField = nil;
    self.statusField = nil;
}

/**
 *  This method demonstrates how to create and initialize TPRRewardedVideo
 */
- (void) initRewardedVideo {
    
    // Release any earlier interstitial
    if (self.rewardedVideo) {
        [self.rewardedVideo removePlayer];
        self.rewardedVideo.delegate = nil;
        self.rewardedVideo = nil;
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
    
    NSString *rewardTitle = @"diamonds";
    NSString *rewardAmount = @"10";

    // Environment dictionary must contain at least key TPR_ENVIRONMENT_KEY_ACCOUNT and
    // TPR_ENVIRONMENT_KEY_PLACEMENT_ID, TPR_ENVIRONMENT_KEY_REWARD_TITLE and TPR_ENVIRONMENT_KEY_REWARD_AMOUNT
    // TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE allows to force player to landscape orientation
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        account, TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        placementId, TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        rewardTitle, TPR_ENVIRONMENT_KEY_REWARD_TITLE,
                                        rewardAmount, TPR_ENVIRONMENT_KEY_REWARD_AMOUNT, nil];
    
    
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
    
    // Initialize the rewarded video
    self.rewardedVideo = [[TPRRewardedVideo alloc] initWithEnvironment:environment params:playerParams timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    
    self.rewardedVideo.delegate = self;
    _statusField.text = @"INITIALIZING";
    
}

/**
 *  Delegate handler for video ad failures @see TPRVideoAd
 *
 *  @param videoAd object that sent the error
 *  @param error   NSError object
 */
- (void) videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.rewardedVideo) {
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
    if (videoAd == self.rewardedVideo) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            _statusField.text = @"READY";
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            self.adLoaded = YES;
            _statusField.text = @"LOADED";
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            self.adLoaded = NO;
            _statusField.text = @"ERROR";
            [self queueMessage:[NSString stringWithFormat:@"Failure: %@", [event objectForKey:TPR_EVENT_KEY_ARG1]]];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            _statusField.text = @"COMPLETED";
            self.adLoaded = NO;
            [self.rewardedVideo reset];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_COMPLETE]) {
            NSString* reward = [NSString stringWithFormat:@"%@ %@", _rewardedVideo.rewardAmount, _rewardedVideo.rewardTitle];
            _rewardField.text = reward;
        }
    }
}

/**
 *  UIButton handler
 *
 *  @param sender
 */
- (IBAction) onButtonPressed:(id)sender {
    if (sender == self.initializeButton) {
        [self initRewardedVideo];
    }
    else if (sender == self.loadButton) {
        _rewardField.text = @"";

        if (self.rewardedVideo.ready) {
            [self.rewardedVideo loadAd];
        } else {
            [self queueMessage:@"The player is not initialized yet"];
        }
    }
    else if (sender == self.displayButton) {
        if (self.adLoaded) {
            [self.rewardedVideo displayAd];
        } else {
            [self queueMessage:@"No ad loaded yet"];
        }
    }
    
}



@end
