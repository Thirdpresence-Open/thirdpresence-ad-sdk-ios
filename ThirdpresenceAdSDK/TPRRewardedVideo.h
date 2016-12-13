/*!
 
 @header TPRRewardedVideo.h
 
 This file contains TPRRewardedVideo class declaration.
 
 @author Marko Okkonen
 @copyright 2016 Thirdpresence
 
 */

#import "TPRVideoInterstitial.h"

/*!
 @brief TPRRewardedVideo implements a rewarded video ad placement
 */
@interface TPRRewardedVideo : TPRVideoInterstitial

/*!
 @brief Inits the rewarded video placement
 @param environment a dictionary containing environment parameters
 @param playerParams a dictionary containing customization parameters for the player
 @param secs timeout in seconds for initializing the player and loading an ad
 @discussion
    See TPRVideoAd.h for keys available to be used with environment and playerParams dictionaries.

    Values for following keys in environment dictionary are mandatory:
        @link TPR_ENVIRONMENT_KEY_ACCOUNT @/link
        @link TPR_ENVIRONMENT_KEY_PLACEMENT_ID @/link
        @link TPR_ENVIRONMENT_KEY_REWARD_TITLE @/link
        @link TPR_ENVIRONMENT_KEY_REWARD_AMOUNT @/link
 
    Use @link TPR_PLAYER_DEFAULT_TIMEOUT @/link as a default timeout.
 
    An event with the name @link TPR_EVENT_NAME_PLAYER_READY @/link event is fired when the player is ready to load an ad
 
 @return TPRRewardedVideo object
 */
- (instancetype)initWithEnvironment:(NSDictionary*)environment
                             params:(NSDictionary*)playerParams
                            timeout:(NSTimeInterval)secs;

/*!
 @brief Loads an ad
 @discussion An event with the name @link TPR_EVENT_NAME_AD_LOADED @/link is fired when the player has loaded an ad
 */
- (void)loadAd;

/*!
 @brief Displays the ad
@discussion An event with the name @link TPR_EVENT_NAME_AD_STOPPED @/link is fired when the player is stopped displaing an ad.
 */
- (void)displayAd;

/*!
 @brief Resets the ad placement and closes the ad view
 @discussion Method @link //apple_ref/occ/instm/TPRRewardedVideo/loadAd @/link can be called to load another ad.
 */
- (void)reset;

/*!
 @brief Removes the player and releases resources
 @discussion Method @link //apple_ref/occ/instm/TPRRewardedVideo/initWithEnvironment:params:timeout: @/link must be called before loading a new ad.
 */
- (void)removePlayer;

// Not available
- (instancetype)init NS_UNAVAILABLE;

/*!
 @brief Reward title
 */
@property (readonly, strong) NSString* rewardTitle;

/*!
 @brief Reward amount
 */
@property (readonly, strong) NSNumber* rewardAmount;


@end
