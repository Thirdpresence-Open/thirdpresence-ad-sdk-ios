//
//  TPRBannerCustomEvent.m
//  ThirdpresenceMopubMediation
//
//  Created by Marko Okkonen on 08/12/16.
//  Copyright © 2016 thirdpresence. All rights reserved.
//

#import "TPRBannerCustomEvent.h"
#import "TPRVideoBanner.h"
#import "TPRBannerView.h"
#import "TPRConstants.h"

@interface TPRBannerCustomEvent () <TPRVideoAdDelegate>
@property (strong) TPRVideoBanner *banner;
@property (strong) TPRBannerView *bannerView;
@property (assign) BOOL adDisplayed;
@end

@implementation TPRBannerCustomEvent

- (void)dealloc {
    if (self.banner) {
        [self.banner removePlayer];
        self.banner.delegate = nil;
        self.banner = nil;
    }
    self.bannerView = nil;
    self.adDisplayed = NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithCapacity:6];
    
    NSString *account = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_ACCOUNT];
    if (account) {
        [environment setValue:account forKey:TPR_ENVIRONMENT_KEY_ACCOUNT];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due an account not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    }
    
    NSString *placementId = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID];
    if (placementId) {
        [environment setValue:placementId forKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize interstitial due placement id not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
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
    
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    self.bannerView = [[TPRBannerView alloc] initWithFrame:frame];
    
    self.banner = [[TPRVideoBanner alloc] initWithBannerView:_bannerView
                                                 environment:environment
                                                      params:info
                                                     timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    self.banner.delegate = self;
    self.banner.disableAutoDisplay = YES;
    
    [self.banner loadAd];
}

- (void)didDisplayAd {
    if (self.banner) {
        [self.banner displayAd];
        self.adDisplayed = YES;
    }
    
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.banner) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
    if (videoAd == self.banner) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        
        if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            [self.delegate bannerCustomEvent:self didLoadAd:_bannerView];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            
            NSString* desc = [event objectForKey:TPR_EVENT_KEY_ARG1];
            NSDictionary* info = nil;
            if (desc) {
                info = [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey];
            }
            
            NSError *error;
            
            if (_adDisplayed) {
                error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                               code:TPR_ERROR_UNKNOWN
                                           userInfo:info];
            } else {
                error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                      code:TPR_ERROR_NO_FILL
                                  userInfo:info];
            }
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LEFT_APPLICATION]) {
            [self.delegate bannerCustomEventWillLeaveApplication:self];
        }
    }
}


@end
