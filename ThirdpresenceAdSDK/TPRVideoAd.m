//
//  TPRVideoAd.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRVideoAd.h"

// Environment keys
NSString *const TPR_ENVIRONMENT_KEY_EXT_SDK = @"sdk";
NSString *const TPR_ENVIRONMENT_KEY_EXT_SDK_VERSION = @"sdk_version";
NSString *const TPR_ENVIRONMENT_KEY_SERVER = @"server";
NSString *const TPR_ENVIRONMENT_KEY_ACCOUNT = @"account";
NSString *const TPR_ENVIRONMENT_KEY_PLACEMENT_ID = @"playerid";
NSString *const TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE = @"forcelandscape";
NSString *const TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT = @"forceportrait";
NSString *const TPR_ENVIRONMENT_KEY_FORCE_SECURE_HTTP = @"forcehttps";
NSString *const TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP = @"usehttp";
NSString *const TPR_ENVIRONMENT_KEY_ENABLE_MOAT = @"enablemoat";

// Player parameter keys
NSString *const TPR_PLAYER_PARAMETER_KEY_APP_NAME = @"appname";
NSString *const TPR_PLAYER_PARAMETER_KEY_APP_VERSION = @"appversion";
NSString *const TPR_PLAYER_PARAMETER_KEY_APP_STORE_URL = @"appstoreurl";
NSString *const TPR_PLAYER_PARAMETER_KEY_REWARD_TITLE = @"rewardtitle";
NSString *const TPR_PLAYER_PARAMETER_KEY_REWARD_AMOUNT = @"rewardamount";
NSString *const TPR_PLAYER_PARAMETER_KEY_SKIP_OFFSET = @"closedelaymax";
NSString *const TPR_PLAYER_PARAMETER_KEY_AD_PLACEMENT = @"adplacement";
NSString *const TPR_PLAYER_PARAMETER_KEY_PUBLISHER = @"publisher";
NSString *const TPR_PLAYER_PARAMETER_KEY_BUNDLE_ID = @"bundleid";
NSString *const TPR_PLAYER_PARAMETER_KEY_DEVICE_ID = @"deviceid";
NSString *const TPR_PLAYER_PARAMETER_KEY_VAST_URL = @"vast_url";
NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_LAT = @"geo_lat";
NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_LON = @"geo_lon";
NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_COUNTRY = @"country";
NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_REGION = @"region";
NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_CITY = @"city";
NSString *const TPR_PLAYER_PARAMETER_KEY_USER_GENDER = @"gender";
NSString *const TPR_PLAYER_PARAMETER_KEY_USER_YOB = @"yob";

// Server types
NSString *const TPR_SERVER_TYPE_PRODUCTION = @"production";
NSString *const TPR_SERVER_TYPE_STAGING = @"staging";

// Error domain
NSString *const TPR_AD_SDK_ERROR_DOMAIN = @"com.thirdpresence.adsdk.ErrorDomain";

// Error codes
NSInteger const TPR_ERROR_BASE = -1;
NSInteger const TPR_ERROR_UNKNOWN = TPR_ERROR_BASE - 1;
NSInteger const TPR_ERROR_NETWORK_FAILURE = TPR_ERROR_BASE - 2;
NSInteger const TPR_ERROR_NETWORK_TIMEOUT = TPR_ERROR_BASE - 3;
NSInteger const TPR_ERROR_PLAYER_INIT_FAILED = TPR_ERROR_BASE - 4;
NSInteger const TPR_ERROR_NO_FILL = TPR_ERROR_BASE - 5;
NSInteger const TPR_ERROR_AD_NOT_READY = TPR_ERROR_BASE - 6;
NSInteger const TPR_ERROR_INVALID_STATE = TPR_ERROR_BASE - 7;
NSInteger const TPR_ERROR_LOW_MEMORY = TPR_ERROR_BASE - 8;

// Default timeout for player operations
NSInteger const TPR_PLAYER_DEFAULT_TIMEOUT = 10;

// Player event keys
NSString *const TPR_EVENT_KEY_NAME = @"event";
NSString *const TPR_EVENT_KEY_ARG1 = @"arg1";
NSString *const TPR_EVENT_KEY_ARG2 = @"arg2";
NSString *const TPR_EVENT_KEY_ARG3 = @"arg3";

// Player event names
NSString *const TPR_EVENT_NAME_PLAYER_READY = @"PlayerReady";
NSString *const TPR_EVENT_NAME_PLAYER_ERROR = @"PlayerError";
NSString *const TPR_EVENT_NAME_AD_LOADED = @"AdLoaded";
NSString *const TPR_EVENT_NAME_AD_STARTED = @"AdStarted";
NSString *const TPR_EVENT_NAME_AD_STOPPED = @"AdStopped";
NSString *const TPR_EVENT_NAME_AD_SKIPPED = @"AdSkipped";
NSString *const TPR_EVENT_NAME_AD_PAUSED = @"AdPaused";
NSString *const TPR_EVENT_NAME_AD_PLAYING = @"AdPlaying";
NSString *const TPR_EVENT_NAME_AD_ERROR = @"AdError";
NSString *const TPR_EVENT_NAME_AD_CLICKTHRU = @"AdClickThru";
NSString *const TPR_EVENT_NAME_AD_IMPRESSION = @"AdImpression";
NSString *const TPR_EVENT_NAME_AD_VIDEO_START = @"AdVideoStart";
NSString *const TPR_EVENT_NAME_AD_VIDEO_FIRST_QUARTILE = @"AdVideoFirstQuartile";
NSString *const TPR_EVENT_NAME_AD_VIDEO_MIDPOINT = @"AdVideoMidpoint";
NSString *const TPR_EVENT_NAME_AD_VIDEO_THIRD_QUARTILE = @"AdVideoThirdQuartile";
NSString *const TPR_EVENT_NAME_AD_VIDEO_COMPLETE = @"AdVideoComplete";
NSString *const TPR_EVENT_NAME_AD_FALLBACK_DISPLAYED = @"AdFallbackDisplayed";
NSString *const TPR_EVENT_NAME_AD_LEFT_APPLICATION = @"AdLeftApplication";

// Placement types
NSString *const TPR_PLACEMENT_TYPE_UNKNOWN = @"unknown";
NSString *const TPR_PLACEMENT_TYPE_INTERSTITIAL = @"interstitial";
NSString *const TPR_PLACEMENT_TYPE_REWARDED_VIDEO = @"rewardedvideo";

// Boolean values
NSString *const TPR_VALUE_TRUE = @"true";
NSString *const TPR_VALUE_FALSE = @"false";

void TPRLog(NSString *format, ...) {
#ifdef DEBUG
    va_list arguments;
    va_start(arguments, format);
    NSLogv(format, arguments);
    va_end(arguments);
#endif
}

@implementation TPRVideoAd

- (instancetype)initWithPlacementType:(TPRPlacementType*)placementType {
    self = [super init];
    _placementType = placementType;
    return self;
}

- (void)dealloc {
    _placementType = nil;
    _ready = NO;
}

@end
