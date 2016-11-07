//
//  TPRInterstitialCustomEvent.m
//  ThirdpresenceMopubMediation
//
//  Created by Marko Okkonen on 28/04/16.
//  Copyright © 2016 thirdpresence. All rights reserved.
//

#import "TPRInterstitialCustomEvent.h"
#import "TPRConstants.h"

#if __has_include(<ThirdpresenceAdSDK/TPRVideoInterstitial.h>)
#import <ThirdpresenceAdSDK/TPRVideoInterstitial.h>
#else
#import "TPRVideoInterstitial.h"
#endif

@interface TPRInterstitialCustomEvent () <TPRVideoAdDelegate>

- (void) loadAd;
- (void) remove;

@property (strong) TPRVideoInterstitial *interstitial;
@property (assign) BOOL adLoaded;
@property (assign) BOOL adDisplayed;
@end

@implementation TPRInterstitialCustomEvent

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [self remove];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary*)info {

    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithCapacity:4];

    NSString *account = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_ACCOUNT];
    if (account) {
        [environment setValue:account forKey:TPR_ENVIRONMENT_KEY_ACCOUNT];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due an account not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
    
    NSString *placementId = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID];
    if (placementId) {
        [environment setValue:placementId forKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due placement id not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
    
    NSString* val = [info objectForKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    if (val && [val isEqualToString:TPR_VALUE_TRUE]) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    } else {
        [environment setValue:TPR_VALUE_TRUE forKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    }
    
    val = [info objectForKey:TPR_ENVIRONMENT_KEY_FORCE_SECURE_HTTP];
    if (val) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_FORCE_SECURE_HTTP];
    }
    
    [environment setValue:@"mopub" forKey:TPR_ENVIRONMENT_KEY_EXT_SDK];
    [environment setValue:[MoPub sharedInstance].version forKey:TPR_ENVIRONMENT_KEY_EXT_SDK_VERSION];
    
    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment
                                                                   params:info
                                                                  timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    self.interstitial.delegate = self;
}

- (void)showInterstitialFromRootViewController:(UIViewController*)rootViewController {
    if (_adLoaded) {
        [self.delegate interstitialCustomEventWillAppear:self];
        [self.interstitial displayAd];
        [self.delegate interstitialCustomEventDidAppear:self];
        _adDisplayed = YES;
    } else {
        [self.delegate interstitialCustomEventDidExpire:self];
        [self remove];
    }
}

- (void)loadAd {
    [self.interstitial loadAd];
}

- (void)remove {
    _adLoaded = NO;
    if (_adDisplayed) {
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
    [self.interstitial removePlayer];
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    if (_adDisplayed) {
        [self.delegate interstitialCustomEventDidDisappear:self];
        _adDisplayed = YES;
    }

}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.interstitial) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
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
            [self.delegate interstitialCustomEvent:self didLoadAd:nil];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            
            NSString* desc = [event objectForKey:TPR_EVENT_KEY_ARG1];
            NSDictionary* info = nil;
            if (desc) {
                info = [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey];
            }
            
            NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                                 code:TPR_ERROR_NO_FILL
                                             userInfo:info];
            
            
            if (_adDisplayed) {
                [self.delegate interstitialCustomEventDidExpire:self];
            } else {
                [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            }
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
        }
    }
}

@end
