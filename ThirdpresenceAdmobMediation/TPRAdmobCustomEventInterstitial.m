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

@interface TPRAdmobCustomEventInterstitial () <TPRVideoAdDelegate, GADCustomEventInterstitial>

- (void)loadAd;
- (void)remove;

@property(nonatomic, strong) TPRVideoInterstitial *interstitial;
@property(assign) BOOL adLoaded;
@property(assign) BOOL adDisplayed;

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
    NSMutableDictionary* environment = [NSMutableDictionary dictionaryWithCapacity:6];
    
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
    
    NSString* val = [info objectForKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    if (val && [val isEqualToString:TPR_VALUE_TRUE]) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    } else {
        [environment setValue:TPR_VALUE_TRUE forKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    }
    
    val = [info objectForKey:TPR_PUBLISHER_PARAM_USE_INSECURE_HTTP];
    if (val) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP];
    }
    
    [environment setValue:@"admob" forKey:TPR_ENVIRONMENT_KEY_EXT_SDK];
    
    NSString *version = [NSString stringWithUTF8String:(char *)GoogleMobileAdsVersionString];
    [environment setValue:version forKey:TPR_ENVIRONMENT_KEY_EXT_SDK_VERSION];
    
    NSDictionary *playerParams = [TPRAdmobCustomEventHelper createPlayerParams:request];

    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment
                                                                   params:playerParams
                                                                  timeout:TPR_PLAYER_DEFAULT_TIMEOUT];

    self.interstitial.delegate = self;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (_adLoaded) {
        [self.delegate customEventInterstitialWillPresent:self];
        _adDisplayed = YES;
        [self.interstitial displayAd];
    } else {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_AD_NOT_READY
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to display an ad" forKey:NSLocalizedDescriptionKey]];
        [self.delegate customEventInterstitial:self didFailAd:error];
        [self remove];
    }
}

- (void)loadAd {
    [self.interstitial loadAd];
}

- (void)remove {
    _adLoaded = NO;
    if (_adDisplayed) {
        [self.delegate customEventInterstitialWillDismiss:self];
    }
    [self.interstitial removePlayer];
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    if (_adDisplayed) {
        [self.delegate customEventInterstitialDidDismiss:self];
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.interstitial) {
        [self.delegate customEventInterstitial:self didFailAd:error];
        [self remove];
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
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.delegate customEventInterstitialWasClicked:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LEFT_APPLICATION]) {
            [self.delegate customEventInterstitialWillLeaveApplication:self];
        }
    }
}

@end
