//
//  TPRInterstitialCustomEvent.m
//  ThirdpresenceMopubMediation
//
//  Created by Marko Okkonen on 28/04/16.
//  Copyright © 2016 thirdpresence. All rights reserved.
//

#import "TPRInterstitialCustomEvent.h"
#import <ThirdpresenceAdSDK/TPRVideoInterstitial.h>

@interface TPRInterstitialCustomEvent () <TPRVideoAdDelegate>
- (void) loadAd;
- (void) remove;

@property (strong) TPRVideoInterstitial *interstitial;
@property (assign) BOOL adLoaded;

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
 
    NSString *account = [info objectForKey:TPR_ENVIRONMENT_KEY_ACCOUNT];
    if (!account) {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due an account not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
    
    NSString *placementId = [info objectForKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    if (!placementId) {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due placement id not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
    
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"sdk-demo", TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        @"msusprtiz3", TPR_ENVIRONMENT_KEY_PLACEMENT_ID, nil];
    
    NSString* val = [info objectForKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    if (val) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    }

    val = [info objectForKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    if (val) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    }
    
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
    } else {
        [self.delegate interstitialCustomEventDidExpire:self];
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
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
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
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
            [self.delegate interstitialCustomEventDidExpire:self];
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            [self.delegate interstitialCustomEventWillDisappear:self];
            [self remove];
            [self.delegate interstitialCustomEventDidDisappear:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
        }
    }
}

@end