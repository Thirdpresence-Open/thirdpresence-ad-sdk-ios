//
//  TPRVideoAd.h
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Keys for environment dictionary
 */

// External mediator SDK
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_EXT_SDK;

// External mediator SDK version
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_EXT_SDK_VERSION;

// Thirdpresence server environment
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_SERVER;

// Thirdpresence account name
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_ACCOUNT;

// Thirdpresence ad placement id
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_PLACEMENT_ID;

// Force ad placement to landscape orientation. Use TPR_VALUE_TRUE to enable.
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE;

// Force ad placement to portrait orientation. Use TPR_VALUE_TRUE to enable.
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT;

// Force to use secure HTTP requests.
// From January 2017 Apple requires App Transport Security (ATS) to be used, which
// requires secure HTTP to be used for network requests. Therefore the value of this
// setting is now true by default.
// Use TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP to turn off Secure HTTP.
// @deprecated
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_FORCE_SECURE_HTTP;

// Use insecure HTTP requests
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP;

// Enable MOAT tracker
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_ENABLE_MOAT;

// Title of the reward to be earned
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_REWARD_TITLE;

// Amount of the reward to be earned
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_REWARD_AMOUNT;


/**
 * Server types to be used as a value for environment key TPR_ENVIRONMENT_KEY_SERVER
 */

// Production server
FOUNDATION_EXPORT NSString *const TPR_SERVER_TYPE_PRODUCTION;

// Staging server
FOUNDATION_EXPORT NSString *const TPR_SERVER_TYPE_STAGING;

/**
 * Keys for environment dictionary
 */

// Application name
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_APP_NAME;

// Application version number
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_APP_VERSION;

// Application market place URL
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_APP_STORE_URL;

// Title of the reward to be earned
// DEPRACATED: in version 1.4.2 - Use {@link TPR_ENVIRONMENT_KEY_REWARD_TITLE} instead
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_REWARD_TITLE;

// Amount of the reward to be earned
// DEPRACATED: in version 1.4.2 - Use {@link TPR_ENVIRONMENT_KEY_REWARD_AMOUNT} instead
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_REWARD_AMOUNT;

// Skip offset in seconds
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_SKIP_OFFSET;

// Ad placement type, @see AdPlacementType
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_AD_PLACEMENT;

// Publisher name
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_PUBLISHER;

// Bundle ID (automatically determined)
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_BUNDLE_ID;

// Advertising ID (automatically determined)
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_DEVICE_ID;

// External VAST tag
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_VAST_URL;

// Location latitude coordinates
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_LAT;

// Location longitude coordinates
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_LON;

// Location country
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_COUNTRY;

// Location region
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_REGION;

// Location city
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_CITY;

// User gender
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_USER_GENDER;

// User year of birth
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_USER_YOB;


/**
 * Player event
 */
typedef NSDictionary TPRPlayerEvent;

// Event name
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_NAME;

// Event-specific arguments
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_ARG1;
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_ARG2;
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_ARG3;

/**
 * Player event names
 */

// Player ready for taking actions
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_PLAYER_READY;

// Player error
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_PLAYER_ERROR;

// Ad loaded
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_LOADED;

// Ad started
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_STARTED;

// Ad stopped
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_STOPPED;

// Ad skipped
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_SKIPPED;

// Ad paused
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_PAUSED;

// Ad playing
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_PLAYING;

// Ad error. arg1 contains error text
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_ERROR;

// Ad clicked, arg1 contains url to be opened
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_CLICKTHRU;

// Ad impression
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_IMPRESSION;

// Video started
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_START;

// Video first quartile
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_FIRST_QUARTILE;

// Video midpoint
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_MIDPOINT;

// Video third queartile
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_THIRD_QUARTILE;

// Video complete
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_COMPLETE;

// Fallback ad displayed
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_FALLBACK_DISPLAYED;

// Another application has been opened, e.g. browser when opening a landing page
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_LEFT_APPLICATION;

/**
 * Error codes
 */

// NSError error domain for Thirdpresence Ad SDK
FOUNDATION_EXPORT NSString *const TPR_AD_SDK_ERROR_DOMAIN;

// Unknown error
FOUNDATION_EXPORT NSInteger const TPR_ERROR_UNKNOWN;

// Network failure
FOUNDATION_EXPORT NSInteger const TPR_ERROR_NETWORK_FAILURE;

// Network timeout
FOUNDATION_EXPORT NSInteger const TPR_ERROR_NETWORK_TIMEOUT;

// VideoAd init failed
FOUNDATION_EXPORT NSInteger const TPR_ERROR_PLAYER_INIT_FAILED;

// No fill for the ad placement
FOUNDATION_EXPORT NSInteger const TPR_ERROR_NO_FILL;

// Ad not yet ready to be displayed
FOUNDATION_EXPORT NSInteger const TPR_ERROR_AD_NOT_READY;

// Method called on invalid state
FOUNDATION_EXPORT NSInteger const TPR_ERROR_INVALID_STATE;

// Low memory warning
FOUNDATION_EXPORT NSInteger const TPR_ERROR_LOW_MEMORY;

// Default value for player timeouts (10s)
FOUNDATION_EXPORT NSInteger const TPR_PLAYER_DEFAULT_TIMEOUT;

/**
 * Placement type
 */
typedef NSString TPRPlacementType;

// Ad Placement type unknwown
FOUNDATION_EXPORT NSString *const TPR_PLACEMENT_TYPE_UNKNOWN;

// Ad Placement type interstitial ad
FOUNDATION_EXPORT NSString *const TPR_PLACEMENT_TYPE_INTERSTITIAL;

// Ad Placement type rewarded type
FOUNDATION_EXPORT NSString *const TPR_PLACEMENT_TYPE_REWARDED_VIDEO;

/**
 * Boolean values to be used with dictionaries
 */
FOUNDATION_EXPORT NSString *const TPR_VALUE_TRUE;
FOUNDATION_EXPORT NSString *const TPR_VALUE_FALSE;


FOUNDATION_EXPORT void TPRLog(NSString *format, ...);

@class TPRVideoAd;

/**
 *  Delegate protocol for video ad
 */
@protocol TPRVideoAdDelegate <NSObject>

/**
 *  Video ad failure
 *
 *  @param videoAd that triggered the error
 *  @param error   error object
 */
- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error;

/**
 *  Video ad event
 *
 *  @param videoAd that triggered the event
 *  @param event   videoAd event object
 */
- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event;

@end

@interface TPRVideoAd : NSObject

- (instancetype)initWithPlacementType:(TPRPlacementType*)placementType;

@property (strong) TPRPlacementType* placementType;
@property (assign) BOOL ready;

// Not available
- (instancetype)init NS_UNAVAILABLE;

@end
