//
//  InterstitialViewController.m
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "InterstitialViewController.h"
#import "Constants.h"

@interface InterstitialViewController ()
- (void) initInterstitial;
@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accountField.text = DEFAULT_ACCOUNT;
    _accountField.delegate = self;
    
    _placementField.text = [self useStagingServer] ? STAGING_INTERSTITIAL_PLACEMENT_ID : DEFAULT_INTERSTITIAL_PLACEMENT_ID;
    _placementField.delegate = self;
    
    _statusField.text = @"IDLE";
}

- (void)dealloc {
    if (self.interstitial) {
        [self.interstitial removePlayer];
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
    
    self.initializeButton = nil;
    self.loadButton = nil;
    self.displayButton = nil;
    self.accountField = nil;
    self.placementField = nil;
    self.vastField = nil;
    self.statusField = nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/**
 *  This method demonstrates how to create and initialize TPRVideoInterstitial
 */
- (void) initInterstitial {
    
    // Release any earlier interstitial
    if (self.interstitial) {
        [self.interstitial removePlayer];
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
    
    NSString *account = self.accountField.text;
    NSString *placementId = self.placementField.text;
    NSString *vastTag = self.vastField.text;
    
    if (account.length < 1) {
        [self queueMessage:@"Account name not set"];
        _statusField.text = @"ERROR";
        return;
    }
    else if (placementId.length < 1) {
        [self queueMessage:@"Placement id not set"];
        _statusField.text = @"ERROR";
    }
    
    // Staging server does not support HTTPS
    NSString* useInsecureHTTP = [self useStagingServer] ? TPR_VALUE_TRUE : TPR_VALUE_FALSE;
    
    // Environment dictionary must contain at least key TPR_ENVIRONMENT_KEY_ACCOUNT and
    // TPR_ENVIRONMENT_KEY_PLACEMENT_ID
    // TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE allows to force player to landscape orientation
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        account, TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        placementId, TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        useInsecureHTTP, TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP,
                                        self.serverType, TPR_ENVIRONMENT_KEY_SERVER,
                                        nil];


    // Pass information about the application and user in playerParams dictionary.
    
    // In order to get more targeted ads user gender and year of birth are recommended.
    // You can get the data, for example, from Facebook Graph API if you have integrated with Facekbook.
    // https://developers.facebook.com/docs/graph-api/reference/v2.6/user
    NSString *userGender = @"male";
    NSString *userYearOfBirth = @"1970";
    
    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         APP_NAME, TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                         APP_VERSION,TPR_PLAYER_PARAMETER_KEY_APP_VERSION,
                                         userGender, TPR_PLAYER_PARAMETER_KEY_USER_GENDER,
                                         userYearOfBirth, TPR_PLAYER_PARAMETER_KEY_USER_YOB,
                                         nil];

    if (vastTag.length > 0) {
        if (![@"https://" isEqualToString:[vastTag substringToIndex:8]]) {
            [self queueMessage:@"The URL is not valid. Using secure HTTP URL is mandatory."];
            _statusField.text = @"ERROR";
            return;
        }
        
        [playerParams setValue:vastTag forKey:TPR_PLAYER_PARAMETER_KEY_VAST_URL];
    }

    // Initialize the interstitial
    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment params:playerParams timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    
    self.interstitial.delegate = self;
    _statusField.text = @"INITIALIZING";

}

/**
 *  Delegate handler for video ad failures @see TPRVideoAd
 *
 *  @param videoAd object that sent the error
 *  @param error   NSError object
 */
- (void) videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.interstitial) {
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
    if (videoAd == self.interstitial) {
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
            [self.interstitial reset];
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
        [self initInterstitial];
    }
    else if (sender == self.loadButton) {
        if (self.interstitial.ready) {
            [self.interstitial loadAd];
        } else {
            [self queueMessage:@"The player is not initialized yet"];
        }
    }
    else if (sender == self.displayButton) {
        if (self.interstitial.adLoaded) {
            [self.interstitial displayAd];
        } else {
            [self queueMessage:@"No ad loaded yet"];
        }
    }

}

@end
