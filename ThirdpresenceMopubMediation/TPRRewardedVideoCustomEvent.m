//
//  TPRRewardedVideoCustomEvent.m
//  ThirdpresenceMopubMediation
//
//  Created by Marko Okkonen on 28/04/16.
//  Copyright © 2016 thirdpresence. All rights reserved.
//

#import "TPRRewardedVideoCustomEvent.h"
#import "TPRConstants.h"

#if __has_include(<ThirdpresenceAdSDK/TPRVideoInterstitial.h>)
#import <ThirdpresenceAdSDK/TPRVideoInterstitial.h>
#else
#import "TPRVideoInterstitial.h"
#endif

@interface TPRRewardedVideoCustomEvent () <TPRVideoAdDelegate>
- (void) loadAd;
- (void) remove;

@property (strong) TPRVideoInterstitial *interstitial;
@property (assign) BOOL adLoaded;
@property (assign) BOOL adDisplayed;
@property (strong) NSString* rewardTitle;
@property (strong) NSNumber* rewardAmount;

@end

@implementation TPRRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [self remove];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    
    NSString *account = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_ACCOUNT];
    if (!account) {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due an account not set" forKey:NSLocalizedDescriptionKey]];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
    
    NSString *placementId = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID];
    if (!placementId) {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due placement id not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }

    self.rewardTitle = [info objectForKey:TPR_PLAYER_PARAMETER_KEY_REWARD_TITLE];
    if (!_rewardTitle) {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due reward title is not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
    
    self.rewardAmount = [info objectForKey:TPR_PLAYER_PARAMETER_KEY_REWARD_AMOUNT];
    if (!_rewardAmount) {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due reward amount is not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
    
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        account, TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        placementId, TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        _rewardTitle, TPR_ENVIRONMENT_KEY_REWARD_TITLE,
                                        _rewardAmount, TPR_ENVIRONMENT_KEY_REWARD_AMOUNT,
                                        nil];
    
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

- (BOOL)hasAdAvailable {
    return _adLoaded;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if (_adLoaded) {
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
        [self.interstitial displayAd];
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
        _adDisplayed = YES;
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"An ad is not loaded yet" forKey:NSLocalizedDescriptionKey]];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
        [self remove];
    }
}

- (void)handleCustomEventInvalidated {
     [self remove];
}

- (void)loadAd {
    [self.interstitial loadAd];
}

- (void)remove {
    _adLoaded = NO;
    if (_adDisplayed) {
        [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    }
    [self.interstitial removePlayer];
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    
    if (_adDisplayed) {
        [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
        _adDisplayed = NO;
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.interstitial) {
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
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
            [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
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
                [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
            }
            else {
                [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
            }
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_COMPLETE]) {
            MPRewardedVideoReward* reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:_rewardTitle
                                                                                 amount:_rewardAmount];
            [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
        }
    }
}

@end
