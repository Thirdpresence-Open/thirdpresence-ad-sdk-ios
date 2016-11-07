//
//  ViewController.m
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "ViewController.h"

NSString *const DEFAULT_ACCOUNT = @"sdk-demo";
NSString *const DEFAULT_PLACEMENT_ID = @"sa7nvltbrn";

NSString *const APP_NAME = @"Ad SDK Sample App";
NSString *const APP_VERSION = @"1.0";
NSString *const APP_STORE_URL = @"https://itunes.apple.com/us/app/adsdksampleapp/id999999999?mt=8";

@interface ViewController ()
- (void) initInterstitial;
- (void) showNextMessage;
- (void) queueMessage:(NSString*)message;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pendingMessages = [NSMutableArray arrayWithCapacity:10];
    
    _accountField.text = DEFAULT_ACCOUNT;
    _accountField.delegate = self;
    
    _placementField.text = DEFAULT_PLACEMENT_ID;
    _placementField.delegate = self;
    
    // Requests user's authorization to use location services
    // This is required to get mored targeted ads and therefore better revenue
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self showNextMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return;
    }
    else if (placementId.length < 1) {
        [self queueMessage:@"Placement id not set"];
    }
    
    // Environment dictionary must contain at least key TPR_ENVIRONMENT_KEY_ACCOUNT and TPR_ENVIRONMENT_KEY_PLACEMENT_ID
    // TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE allows to force player to landscape orientation
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        account, TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        placementId, TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        TPR_VALUE_TRUE, TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE,
                                        TPR_VALUE_TRUE, TPR_ENVIRONMENT_KEY_ENABLE_MOAT, nil];


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

    if (vastTag.length > 0) {
        [playerParams setValue:vastTag forKey:TPR_PLAYER_PARAMETER_KEY_VAST_URL];
    }

    // Initialize the interstitial
    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment params:playerParams timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    self.interstitial.delegate = self;
}

/**
 *  Delegate handler for video ad failures @see TPRVideoAd
 *
 *  @param videoAd object that sent the error
 *  @param error   NSError object
 */
- (void) videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.interstitial) {
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
            [self queueMessage:@"The player is ready to load an ad"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            _adLoaded = YES;
            [self queueMessage:@"An ad is ready for display"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            _adLoaded = NO;
            [self queueMessage:[NSString stringWithFormat:@"Failure: %@", [event objectForKey:TPR_EVENT_KEY_ARG1]]];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            _adLoaded = NO;
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
        if (_adLoaded) {
            [self.interstitial displayAd];
        } else {
            [self queueMessage:@"No ad loaded yet"];
        }
    }

}

/**
 *  Show next queued message
 */
- (void) showNextMessage {
    if (!_showingAlert && !self.presentedViewController && [_pendingMessages count] > 0) {

        NSString *msgToShow = [_pendingMessages objectAtIndex:0];
        [_pendingMessages removeObjectAtIndex:0];
        
        _showingAlert = YES;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:msgToShow
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{
                    _showingAlert = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showNextMessage];
                    });
                }];
            });
            
        }];
    }
    
}

/**
 *  Queues a message for displaying
 *
 *  @param message to display
 */
- (void) queueMessage:(NSString*)message {
    if (message) {
        [_pendingMessages addObject:message];
    }
    [self showNextMessage];
}


@end
