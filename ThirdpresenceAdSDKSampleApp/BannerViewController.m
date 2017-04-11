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

NSInteger const MIN_BANNER_HEIGHT = 50;
NSInteger const MIN_BANNER_WIDTH = 50;

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accountField.text = DEFAULT_ACCOUNT;
    _accountField.delegate = self;
    
    _placementField.text = DEFAULT_BANNER_PLACEMENT_ID;
    _placementField.text = [self useStagingServer] ? STAGING_BANNER_PLACEMENT_ID : DEFAULT_BANNER_PLACEMENT_ID;

    _placementField.delegate = self;
    
    _statusField.text = @"IDLE";

    _scrollView.delegate = self;
    
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
    self.scrollView.delegate = nil;
    self.scrollView = nil;
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
    
    // Staging server does not support HTTPS
    NSString* useInsecureHTTP = [self useStagingServer] ? TPR_VALUE_TRUE : TPR_VALUE_FALSE;

    // Environment dictionary must contain at least key TPR_ENVIRONMENT_KEY_ACCOUNT and
    // TPR_ENVIRONMENT_KEY_PLACEMENT_ID
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
    
    // Initialize the interstitial
    self.videoBanner = [[TPRVideoBanner alloc] initWithBannerView:_bannerView
                                                      environment:environment
                                                           params:playerParams
                                                          timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    
    // Optional delegate for player events
    self.videoBanner.delegate = self;
    // Set disableAutoDisplay = YES when you want to control the actual startup of the ad.
    // For example if having the view in the scroll view, you want to start the ad when
    // the banner view is visible.
    self.videoBanner.disableAutoDisplay = YES;
    
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
            self.adLoaded = YES;
            _statusField.text = @"LOADED";
            if ([self isBannerViewVisible]) {
                 [self.videoBanner displayAd];
            }
        }  else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STARTED]) {
            _statusField.text = @"DISPLAYING";
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            self.adLoaded = NO;
            _statusField.text = @"ERROR";
            [self queueMessage:[NSString stringWithFormat:@"Failure: %@", [event objectForKey:TPR_EVENT_KEY_ARG1]]];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            self.adLoaded = NO;
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

/**
 *  Helper function to check if banner view is visible
 *
 *  @return true if visible
 */
- (BOOL)isBannerViewVisible {
    CGSize bannerSize = self.bannerView.bounds.size;
    if (self.bannerView.window != nil &&
        !self.bannerView.hidden &&
        self.bannerView.alpha > 0 &&
        bannerSize.height >= MIN_BANNER_HEIGHT &&
        bannerSize.width >= MIN_BANNER_WIDTH) {
        
        CGRect bannerRect = [self.bannerView convertRect:self.bannerView.bounds
                                                   toView:self.scrollView];
        
        CGRect intersection = CGRectIntersection(bannerRect, self.scrollView.bounds);
        
        // Consider visible when half of the banner is visible
        if (intersection.size.height >= bannerSize.height * 0.5 &&
            intersection.size.width >= bannerSize.width * 0.5) {
            return YES;
        }
    }
    return NO;
    
}

/**
 *  UIScrollView delegate method
 *
 *  @param scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Start playing the ad if it is loaded and visible
    if (self.adLoaded && [self isBannerViewVisible]) {
        [self.videoBanner displayAd];
    }
}

@end
