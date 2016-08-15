//
//  TPRAdmobCustomEventInterstitial.m
//  ThirdpresenceAdmobMediation
//
//  Created by Marko Okkonen on 06/05/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "TPRAdmobCustomEventInterstitial.h"
#import "TPRAdmobCustomEventHelper.h"

#if __has_include(<ThirdpresenceAdSDK/TPRVideoInterstitial.h>)
#import <ThirdpresenceAdSDK/TPRVideoInterstitial.h>
#else
#import "TPRVideoInterstitial.h"
#endif

#import <GoogleMobileAds/GoogleMobileAds.h>

NSString *const TPR_PUBLISHER_PARAM_KEY_ACCOUNT = @"account";
NSString *const TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID = @"placementid";
NSString *const TPR_PUBLISHER_PARAM_KEY_FORCE_LANDSCAPE = @"forcelandscape";
NSString *const TPR_PUBLISHER_PARAM_KEY_FORCE_PORTRAIT = @"forceportrait";

@interface TPRAdmobCustomEventInterstitial () <TPRVideoAdDelegate, GADCustomEventInterstitial>

- (void)loadAd;
- (void)remove;

@property(nonatomic, strong) TPRVideoInterstitial *interstitial;
@property(assign) BOOL adLoaded;

@end

@implementation TPRAdmobCustomEventInterstitial

@synthesize delegate;

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [self remove];
}

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter
                                     label:(NSString *)serverLabel
                                   request:(GADCustomEventRequest *)request {
    
    
    NSDictionary* info = [TPRAdmobCustomEventHelper parseParamsString:serverParameter];
    NSMutableDictionary* environment = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSString *account = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_ACCOUNT];
    if (account) {
        [environment setValue:account forKey:TPR_ENVIRONMENT_KEY_ACCOUNT];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due an account not set" forKey:NSLocalizedDescriptionKey]];
        
         [self.delegate customEventInterstitial:self didFailAd:error];
    }
    
    NSString *placementId = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID];
    if (placementId) {
        [environment setValue:placementId forKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due placement id not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate customEventInterstitial:self didFailAd:error];
    }
    
    NSString* val = [info objectForKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    if (val) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    }
    
    val = [info objectForKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    if (val) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    }
    
    NSMutableDictionary* playerParams = [NSMutableDictionary dictionary];
    
    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment
                                                                   params:playerParams
                                                                  timeout:TPR_PLAYER_DEFAULT_TIMEOUT];

    self.interstitial.delegate = self;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (_adLoaded) {
        [self.delegate customEventInterstitialWillPresent:self];
        [self.interstitial displayAd];
    }
}

- (void)loadAd {
    [self.interstitial loadAd];
}

- (void)remove {
    _adLoaded = NO;
    [self.interstitial removePlayer];
    self.interstitial.delegate = nil;
    self.interstitial = nil;
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.interstitial) {
        [self remove];
        [self.delegate customEventInterstitial:self didFailAd:error];
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
    if (videoAd == self.interstitial) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            [self loadAd];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            _adLoaded = YES;
            [self.delegate customEventInterstitialDidReceiveAd:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                                 code:TPR_ERROR_NO_FILL
                                             userInfo:[NSDictionary dictionaryWithObject:@"Failed to display an ad" forKey:NSLocalizedDescriptionKey]];
            [self.delegate customEventInterstitial:self didFailAd:error];
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            [self.delegate customEventInterstitialWillDismiss:self];
            [self remove];
            [self.delegate customEventInterstitialDidDismiss:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.delegate customEventInterstitialWasClicked:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LEFT_APPLICATION]) {
            [self.delegate customEventInterstitialWasClicked:self];
        }
    }
}



@end
