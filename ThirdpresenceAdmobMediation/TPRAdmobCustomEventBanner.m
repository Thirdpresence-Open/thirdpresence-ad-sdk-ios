//
//  TPRAdmobCustomEventBanner.m
//  ThirdpresenceAdmobMediation
//
//  Created by Marko Okkonen on 09/12/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "TPRAdmobCustomEventBanner.h"
#import "TPRAdmobCustomEventHelper.h"

#if __has_include(<ThirdpresenceAdSDK/TPRVideoBanner.h>)
#import <ThirdpresenceAdSDK/TPRVideoBanner.h>
#import <ThirdpresenceAdSDK/TPRBannerView.h>
#else
#import "TPRVideoBanner.h"
#import "TPRBannerView.h"
#endif

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface TPRAdmobCustomEventBanner () <TPRVideoAdDelegate, GADCustomEventBanner>

- (void)remove;

@property(nonatomic, strong) TPRVideoBanner *banner;
@property(nonatomic, strong) TPRBannerView *bannerView;

@end

@implementation TPRAdmobCustomEventBanner
@synthesize delegate;

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [self remove];
}

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *GAD_NULLABLE_TYPE)serverParameter
                  label:(NSString *GAD_NULLABLE_TYPE)serverLabel
                request:(GADCustomEventRequest *)request {
    
    NSDictionary* info = [TPRAdmobCustomEventHelper parseParamsString:serverParameter];
    NSMutableDictionary* environment = [NSMutableDictionary dictionaryWithCapacity:5];
    
    NSString *account = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_ACCOUNT];
    if (account) {
        [environment setValue:account forKey:TPR_ENVIRONMENT_KEY_ACCOUNT];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize banner due an account not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate customEventBanner:self didFailAd:error];
    }
    
    NSString *placementId = [info objectForKey:TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID];
    if (placementId) {
        [environment setValue:placementId forKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    } else {
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Failed to initialize banner due placement id not set" forKey:NSLocalizedDescriptionKey]];
        
        [self.delegate customEventBanner:self didFailAd:error];
    }
    
    NSString *val = [info objectForKey:TPR_PUBLISHER_PARAM_USE_INSECURE_HTTP];
    if (val) {
        [environment setValue:val forKey:TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP];
    }
    
    [environment setValue:@"admob" forKey:TPR_ENVIRONMENT_KEY_EXT_SDK];
    
    NSString *version = [[NSString alloc]initWithCString:GoogleMobileAdsVersionString encoding:NSUTF8StringEncoding];
    [environment setValue:version forKey:TPR_ENVIRONMENT_KEY_EXT_SDK_VERSION];
    
    NSMutableDictionary* playerParams = [NSMutableDictionary dictionary];
    
    self.bannerView = [[TPRBannerView alloc] initWithFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)];
    
    self.banner = [[TPRVideoBanner alloc] initWithBannerView:self.bannerView
                                                 environment:environment
                                                      params:playerParams
                                                     timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    
    self.banner.delegate = self;
}

- (void)remove {
    [self.banner removePlayer];
    self.banner.delegate = nil;
    self.banner = nil;
    self.bannerView = nil;
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == self.banner) {
        [self.delegate customEventBanner:self didFailAd:error];
        [self remove];
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
    if (videoAd == self.banner) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            [self.banner loadAd];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            [self.delegate customEventBanner:self didReceiveAd:self.bannerView];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                                 code:TPR_ERROR_NO_FILL
                                             userInfo:[NSDictionary dictionaryWithObject:@"Failed to display an ad" forKey:NSLocalizedDescriptionKey]];
            [self.delegate customEventBanner:self didFailAd:error];
            [self remove];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.delegate customEventBannerWasClicked:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LEFT_APPLICATION]) {
            [self.delegate customEventBannerWillLeaveApplication:self];
        }
    }
}

@end
