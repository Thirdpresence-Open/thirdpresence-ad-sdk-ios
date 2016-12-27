//
//  TPRAdmobCustomEventRewardedVideo.m
//  ThirdpresenceAdmobMediation
//
//  Created by Marko Okkonen on 09/12/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "TPRAdmobCustomEventRewardedVideo.h"
#import "TPRAdmobCustomEventHelper.h"
#import <GoogleMobileAds/Mediation/GADMRewardBasedVideoAdNetworkAdapterProtocol.h>

#if __has_include(<ThirdpresenceAdSDK/TPRRewardedVideo.h.h>)
#import <ThirdpresenceAdSDK/TPRRewardedVideo.h.h>
#else
#import "TPRRewardedVideo.h"
#endif

@interface TPRAdmobCustomEventRewardedVideo () <TPRVideoAdDelegate, GADMRewardBasedVideoAdNetworkAdapter>

- (void)remove;

@property(nonatomic, strong) TPRRewardedVideo *rewardedVideo;
@property(nonatomic, weak) id<GADMRewardBasedVideoAdNetworkConnector> networkConnector;
@property(assign) BOOL adLoaded;
@property(assign) BOOL adDisplayed;

@end

@implementation TPRAdmobCustomEventRewardedVideo

+ (NSString *)adapterVersion {
    NSBundle* libBundle = [NSBundle bundleWithIdentifier:@"com.thirdpresence.ThirdpresenceAdmobMediation"];
    NSString *versionString = [libBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    if (!versionString) {
        // If CocoaPods used the plist file is in the main bundle
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"com.thirdpresence.ThirdpresenceAdmobMediation-Info" ofType:@"plist"]];
        
        versionString = [dictionary objectForKey:@"CFBundleShortVersionString"];
    }
    return versionString;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

- (instancetype)initWithRewardBasedVideoAdNetworkConnector:
(id<GADMRewardBasedVideoAdNetworkConnector>)connector {
    if (!connector) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.networkConnector = connector;
    }
    return self;
}

- (void)dealloc {
    [self remove];
}

- (void)setUp {
    
    NSString *serverParameter = [self.networkConnector.credentials objectForKey:GADCustomEventParametersServer];
    
    NSDictionary* info = [TPRAdmobCustomEventHelper parseParamsString:serverParameter];
    NSMutableDictionary* environment = [NSMutableDictionary dictionaryWithCapacity:8];
    
    NSString *account = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_ACCOUNT];
    if (account) {
        [environment setValue:account forKey:TPR_ENVIRONMENT_KEY_ACCOUNT];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize rewarded video due an account not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.networkConnector adapter:self didFailToSetUpRewardBasedVideoAdWithError:error];
    }
    
    NSString *placementId = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID];
    if (placementId) {
        [environment setValue:placementId forKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize rewarded video due placement id not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.networkConnector adapter:self didFailToSetUpRewardBasedVideoAdWithError:error];
    }
    
    NSString *rewardTitle = [info objectForKey:TPR_PUBLISHER_PARAM_REWARD_TITLE];
    if (rewardTitle) {
        [environment setValue:rewardTitle forKey:TPR_ENVIRONMENT_KEY_REWARD_TITLE];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize rewarded video due reward title not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.networkConnector adapter:self didFailToSetUpRewardBasedVideoAdWithError:error];
    }
    
    NSString *rewardAmount = [info objectForKey:TPR_PUBLISHER_PARAM_REWARD_AMOUNT];
    if (rewardAmount) {
        [environment setValue:rewardAmount forKey:TPR_PLAYER_PARAMETER_KEY_REWARD_AMOUNT];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize rewarded video due reward amount not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.networkConnector adapter:self didFailToSetUpRewardBasedVideoAdWithError:error];
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
    
    NSDictionary *playerParams = [TPRAdmobCustomEventHelper createPlayerParams:self.networkConnector];
    
    self.rewardedVideo = [[TPRRewardedVideo alloc] initWithEnvironment:environment
                                                                params:playerParams
                                                                timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    
    self.rewardedVideo.delegate = self;
}

- (void)requestRewardBasedVideoAd {
    if (self.rewardedVideo) {
        [self.rewardedVideo loadAd];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to request ad. Adapter is not set up" forKey:NSLocalizedDescriptionKey]];
        
        [self.networkConnector adapter:self didFailToLoadRewardBasedVideoAdwithError:error];
    }
}

- (void)presentRewardBasedVideoAdWithRootViewController:(UIViewController *)viewController{
    if (_adLoaded) {
        _adDisplayed = YES;
        [self.rewardedVideo displayAd];
        [self.networkConnector adapterDidOpenRewardBasedVideoAd:self];
    }
}

- (void)stopBeingDelegate {
    [self remove];
}

- (void)remove {
    _adLoaded = NO;
   
    if (self.rewardedVideo) {
        [self.rewardedVideo removePlayer];
        self.rewardedVideo.delegate = nil;
        self.rewardedVideo = nil;
    }
    
    if (_adDisplayed) {
        [self.networkConnector adapterDidCloseRewardBasedVideoAd:self];
    }
    _adDisplayed = NO;
    self.networkConnector = nil;
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.rewardedVideo) {
        [self.networkConnector adapter:self didFailToSetUpRewardBasedVideoAdWithError:error];
        [self remove];
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
    if (videoAd == self.rewardedVideo) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            [self.networkConnector adapterDidSetUpRewardBasedVideoAd:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            _adLoaded = YES;
            [self.networkConnector adapterDidReceiveRewardBasedVideoAd:self];
            
            
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_START]) {
            [self.networkConnector adapterDidStartPlayingRewardBasedVideoAd:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                                 code:TPR_ERROR_NO_FILL
                                             userInfo:[NSDictionary dictionaryWithObject:@"Failed to display an ad" forKey:NSLocalizedDescriptionKey]];
            if (!_adDisplayed) {
                [self.networkConnector adapter:self didFailToLoadRewardBasedVideoAdwithError:error];
            }
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_COMPLETE]) {
            NSString *type = self.rewardedVideo.rewardTitle;
            NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[self.rewardedVideo.rewardAmount decimalValue]];
            GADAdReward* reward = [[GADAdReward alloc] initWithRewardType:type rewardAmount:amount];
            [self.networkConnector adapter:self didRewardUserWithReward:reward];
            
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.networkConnector adapterDidGetAdClick:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LEFT_APPLICATION]) {
            [self.networkConnector adapterWillLeaveApplication:self];
        }
    }
}

@end
