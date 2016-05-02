//
//  ViewController.m
//  AdSDKSampleApp
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void) createInterstitial;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pendingMessages = [NSMutableArray arrayWithCapacity:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  This method demonstrates how to create and initialize TPRVideoInterstitial
 */
- (void) createInterstitial {
    
    // Release any earlier interstitial
    if (self.interstitial) {
        [self.interstitial removePlayer];
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
    
    // Environment dictionary must contain at least key TPR_ENVIRONMENT_KEY_ACCOUNT and TPR_ENVIRONMENT_KEY_PLACEMENT_ID
    // TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE allows to force player to landscape orientation
    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"sdk-demo", TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        @"msusprtiz3", TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        TPR_VALUE_TRUE, TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE, nil];

    // Pass info about the application in playerParams dictionary.
    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"AdSDKSampleApp", TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                         @"1.0",TPR_PLAYER_PARAMETER_KEY_APP_VERSION,
                                         @"https://itunes.apple.com/us/app/adsdksampleapp/id999999999?mt=8", TPR_PLAYER_PARAMETER_KEY_APP_STORE_URL,
                                         nil];
    
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
        NSLog(@"VideoAd failed: %@", error.localizedDescription);
        
        [self showMessage:error.localizedDescription];
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
        
        NSLog(@"VideoAd event: %@", event);
        
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            [self showMessage:@"The player is ready"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            _adLoaded = YES;
            [self showMessage:@"An ad is loaded"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
            _adLoaded = NO;
            [self showMessage:@"Player failed to display the ad"];
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
        [self createInterstitial];
    }
    else if (sender == self.loadButton) {
        if (self.interstitial.ready) {
            [self.interstitial loadAd];
        } else {
            [self showMessage:@"Interstitial is not initialized yet"];
        }
    }
    else if (sender == self.displayButton) {
        if (_adLoaded) {
            [self.interstitial displayAd];
        } else {
            [self showMessage:@"No ad loaded yet"];
        }
    }
    else if (sender == self.resetButton) {
        [self.interstitial reset];
    }
    else if (sender == self.removeButton) {
        [self.interstitial removePlayer];
    }
}

/**
 *  Helper function for showing messages to user
 *
 *  @param message to display
 */
- (void) showMessage:(NSString*)message {

    UIViewController *root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if (root.presentedViewController) {
        [_pendingMessages addObject:message];
    }
    else {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [self presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:^{
                if ([_pendingMessages count] > 0) {
                    NSString* newMessage = [_pendingMessages objectAtIndex:0];
                    [_pendingMessages removeObjectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessage:newMessage];
                    });

                }
            }];
        });
        
    }];
    }
}

@end
