/*!
 
 @header TPRVideoAd.h
 
 This file contains TPRVideoAd class declaration and commonly used constants.
 
 @author Marko Okkonen
 @copyright 2016 Thirdpresence
 
 */

#import <UIKit/UIKit.h>

// Keys for environment dictionary

/*!
 @brief Environment dictionary key for the Thirdpresence Ad SDK version. 
 @discussion This is intended to be used only by mediation plugins.
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_SDK_VERSION;

/*!
 @brief Environment dictionary key for an external mediator SDK name
 */ 
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_EXT_SDK;

/*! 
 @brief Environment dictionary key for an external mediator SDK version 
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_EXT_SDK_VERSION;

/*! 
 @brief Environment dictionary key for Thirdpresence server environment 
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_SERVER;

/*! 
 @brief Environment dictionary key for Thirdpresence account name 
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_ACCOUNT;

/*! 
 @brief Environment dictionary key for Thirdpresence ad placement id 
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_PLACEMENT_ID;

/*! 
 @brief Environment dictionary key for forcing ad placement to landscape orientation. Use @link TPR_VALUE_TRUE @/link to enable.
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE;

/*! 
 @brief Environment dictionary key for forcing ad placement to portrait orientation. Use @link TPR_VALUE_TRUE @/link to enable.
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT;

/*!
 @brief Environment dictionary key for forcing to use secure HTTP requests
 @discussion From January 2017 Apple requires App Transport Security (ATS) to be used, 
 which requires secure HTTP to be used for network requests. Therefore the value of this
 setting is now true by default. @link TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP @/link to turn off Secure HTTP.
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_FORCE_SECURE_HTTP;

/*! 
 @brief Environment dictionary key for using insecure HTTP requests 
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP;

/*! 
 @brief Environment dictionary key for enabling MOAT tracker 
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_ENABLE_MOAT;

/*!
 @brief Environment dictionary key for a title of the reward to be earned
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_REWARD_TITLE;

/*!
 @brief Environment dictionary key for a title of the reward to be earned
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_REWARD_AMOUNT;

/*!
 @brief Environment dictionary key for MOAT ad tracking. Default enabled. Use @link TPR_VALUE_FALSE @/link to disable.
 */
FOUNDATION_EXPORT NSString *const TPR_ENVIRONMENT_KEY_MOAT_AD_TRACKING;



/**
 @brief Value for production server to be used with the environment key @link TPR_ENVIRONMENT_KEY_SERVER @/link
 */
FOUNDATION_EXPORT NSString *const TPR_SERVER_TYPE_PRODUCTION;

/*! 
 @brief Value for staging server to be used with the environment key @link TPR_ENVIRONMENT_KEY_SERVER @/link
 */
FOUNDATION_EXPORT NSString *const TPR_SERVER_TYPE_STAGING;

// Keys for player parameters dictionary

/*! 
 @brief Player parameter dictionary key for an application name 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_APP_NAME;

/*! 
 @brief Player parameter dictionary key for an application version number 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_APP_VERSION;

/*! 
 @brief Player parameter dictionary key for an application market place URL 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_APP_STORE_URL;

/*! 
 @brief Player parameter dictionary key for a title of the reward to be earned 
 @discussion DEPRACATED: in version 1.4.2 - Use @link TPR_ENVIRONMENT_KEY_REWARD_TITLE @/link instead
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_REWARD_TITLE;

/*! 
 @brief Player parameter dictionary key for an amount of the reward to be earned 
 @discussion DEPRACATED: in version 1.4.2 - Use @link TPR_ENVIRONMENT_KEY_REWARD_AMOUNT @/link instead
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_REWARD_AMOUNT;

/*! 
 @brief Player parameter dictionary key for a skip offset in seconds
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_SKIP_OFFSET;

/*! 
 DEPRECATED: in version 1.5.0
 @brief Player parameter dictionary key for an ad placement type
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_AD_PLACEMENT;

/*! 
 @brief Player parameter dictionary key for a publisher name 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_PUBLISHER;

/*! 
 @brief Player parameter dictionary key for a bundle ID (automatically determined) 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_BUNDLE_ID;

/*! 
 @brief Player parameter dictionary key for an advertising ID (automatically determined) 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_DEVICE_ID;

/*! 
 @brief Player parameter dictionary key for an external VAST tag 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_VAST_URL;

/*! 
 @brief Player parameter dictionary key for a location latitude coordinates 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_LAT;

/*! 
 @brief Player parameter dictionary key for a location longitude coordinates 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_LON;

/*! 
 @brief Player parameter dictionary key for a location country 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_COUNTRY;

/*! 
 @brief Player parameter dictionary key for a location region 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_REGION;

/*! 
 @brief Player parameter dictionary key for a location city 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_GEO_CITY;

/*! 
 @brief Player parameter dictionary key for an user gender 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_USER_GENDER;

/*! 
 @brief Player parameter dictionary key for an user's year of birth 
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_USER_YOB;

/*!
 @brief Player parameter dictionary key for keywords (targeting)
 */
FOUNDATION_EXPORT NSString *const TPR_PLAYER_PARAMETER_KEY_KEYWORDS;


/*!
 @brief Value for user gender
 */
FOUNDATION_EXPORT NSString *const TPR_USER_GENDER_MALE;

/*!
 @brief Value for user gender
 */
FOUNDATION_EXPORT NSString *const TPR_USER_GENDER_FEMALE;


/*!
 @brief Player event 
 @discussion Player event is a dictionary that contains following keys: @link TPR_EVENT_KEY_NAME @/link, @link TPR_EVENT_KEY_ARG1 @/link, @link TPR_EVENT_KEY_ARG2 @/link and @link TPR_EVENT_KEY_ARG3 @/link
 */
typedef NSDictionary TPRPlayerEvent;

/*! 
 @brief Event name 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_NAME;
/*! 
 @brief Event-specific argument 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_ARG1;
/*! 
 @brief Event-specific argument 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_ARG2;
/*! 
 @brief Event-specific argument 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_KEY_ARG3;

// Player event names

/*! 
 @brief Player event name for player ready event
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_PLAYER_READY;

/*! 
 @brief Player event name for player error event
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_PLAYER_ERROR;

/*! 
 @brief Player event name for ad loaded event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_LOADED;

/*! 
 @brief Player event name for ad started event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_STARTED;

/*! 
 @brief Player event name for ad stopped event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_STOPPED;

/*! 
 @brief Player event name for ad skipped event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_SKIPPED;

/*! 
 @brief Player event name for ad paused event
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_PAUSED;

/*! 
 @brief Player event name for ad playing event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_PLAYING;

/*! 
 @brief Player event name for ad error event. @link TPR_EVENT_KEY_ARG1 @/link key contains error text
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_ERROR;

/*! 
 @brief Player event name for ad clicked event. @link TPR_EVENT_KEY_ARG1 @/link key contains url to be opened
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_CLICKTHRU;

/*! 
 @brief Player event name for ad impression event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_IMPRESSION;

/*! 
 @brief Player event name for video started event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_START;

/*! 
 @brief Player event name for video first quartile event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_FIRST_QUARTILE;

/*! 
 @brief Player event name for video midpoint event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_MIDPOINT;

/*! 
 @brief Player event name for video third quartile event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_THIRD_QUARTILE;

/*! 
 @brief Player event name for video complete event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_VIDEO_COMPLETE;

/*! 
 @brief Player event name for fallback ad displayed event 
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_FALLBACK_DISPLAYED;

/*! 
 @brief Player event name for ad left application event
 @discussion Occurs when an another application has been opened, 
 e.g. browser when opening a landing page
 */
FOUNDATION_EXPORT NSString *const TPR_EVENT_NAME_AD_LEFT_APPLICATION;

// Error codes

/*! 
 @brief NSError error domain for Thirdpresence Ad SDK 
 */
FOUNDATION_EXPORT NSString *const TPR_AD_SDK_ERROR_DOMAIN;

/*! 
 @brief Error code for unknown error 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_UNKNOWN;

/*! 
 @brief Error code for network failure 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_NETWORK_FAILURE;

/*! 
 @brief Error code for network timeout 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_NETWORK_TIMEOUT;

/*! 
 @brief Error code for video ad init failed 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_PLAYER_INIT_FAILED;

/*! 
 @brief Error code for no fill 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_NO_FILL;

/*! 
 @brief Error code for ad not ready to be displayed 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_AD_NOT_READY;

/*! 
 @brief Error code for method called on invalid state 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_INVALID_STATE;

/*! 
 @brief Error code for low memory warning 
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_LOW_MEMORY;

/*!
 @brief Error code for ad not displayed in time
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_TIMEOUT_DISPLAYING_AD;

/*!
 @brief Error code for failure during video playback
 */
FOUNDATION_EXPORT NSInteger const TPR_ERROR_VIDEO_PLAYBACK;

/*! 
 @brief Default value for player timeouts (10s) 
 */
FOUNDATION_EXPORT NSInteger const TPR_PLAYER_DEFAULT_TIMEOUT;

/*!
 @brief Timeout for player to display the ad
 */
FOUNDATION_EXPORT NSTimeInterval const TPR_PLAYER_DISPLAY_TIMEOUT;

/*!
 @brief Placement type identifier
 */
typedef NSString TPRPlacementType;

/*! 
 @brief Ad Placement type unknwown 
 */
FOUNDATION_EXPORT NSString *const TPR_PLACEMENT_TYPE_UNKNOWN;

/*! 
 @brief Ad Placement type interstitial ad 
 */
FOUNDATION_EXPORT NSString *const TPR_PLACEMENT_TYPE_INTERSTITIAL;

/*! 
 @brief Ad Placement type rewarded video
 */
FOUNDATION_EXPORT NSString *const TPR_PLACEMENT_TYPE_REWARDED_VIDEO;

/*!
 @brief Ad Placement type banner ad
 */
FOUNDATION_EXPORT NSString *const TPR_PLACEMENT_TYPE_BANNER;

/*! 
 @brief Boolean true value for dictionaries 
 */
FOUNDATION_EXPORT NSString *const TPR_VALUE_TRUE;

/*! 
 @brief Boolean false value for dictionaries 
 */
FOUNDATION_EXPORT NSString *const TPR_VALUE_FALSE;


FOUNDATION_EXPORT void TPRLog(NSString *format, ...);

@class TPRVideoAd;

/*!
 @brief Delegate protocol for TPRVideoAd
 */
@protocol TPRVideoAdDelegate <NSObject>

/*!
 @brief Error callback
 @param videoAd VideoAd object that triggered the error
 @param error NSError object
 */
- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error;

/*!
 @brief Player event callback
 @param videoAd TPRVideoAd instance the event is triggered for
 @param event TPRPlayerEvent event
 */
- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event;

@end

/*!
 @brief Baseclass for a video ad placement implementation
 @discussion All video ad placement implementations shall be derived from this class
 */
@interface TPRVideoAd : NSObject

/*!
 @brief Designated initializer
 @discussion This should be used from derived classes
 @param placementType unique identifier for the placement type
 @return VideoAd instance
 */
- (instancetype)initWithPlacementType:(TPRPlacementType*)placementType;

/*!
 @brief Placement type
 */
@property (strong) TPRPlacementType* placementType;

/*!
 @brief Set true when the placement has been initialised
 */
@property (assign) BOOL ready;

/*!
 @brief Set true when an ad has been loaded and ready for display
 */
@property (assign) BOOL adLoaded;

- (instancetype)init NS_UNAVAILABLE;

@end
