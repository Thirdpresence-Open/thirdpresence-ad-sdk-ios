/*!
 
 @header TPRVideoInterstitial.h
 
 This file contains TPRRewardedVideo class declaration.
 
 @author Marko Okkonen
 @copyright 2016 Thirdpresence
 
 */

#import <UIKit/UIKit.h>
#import "TPRVideoAd.h"

@class TPRVideoPlayerHandler;
@class TPRViewControllerTransitioningDelegate;

/*!
 @brief TPRVideoInterstitial implements a video interstitial ad placement
 */
@interface TPRVideoInterstitial : TPRVideoAd

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
 
    Use @link TPR_PLAYER_DEFAULT_TIMEOUT @/link as a default timeout.
 
    An event with the name @link TPR_EVENT_NAME_PLAYER_READY @/link event is fired when the player is ready to load an ad

 @return TPRVideoInterstitial object
 */
- (instancetype)initWithEnvironment:(NSDictionary*)environment
                              params:(NSDictionary*)playerParams
                             timeout:(NSTimeInterval)secs;

// Intended to be used from derived classed only
- (instancetype)initWithPlacementType:(TPRPlacementType*)type
                           environment:(NSDictionary*)environment
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
 @discussion Method @link //apple_ref/occ/instm/TPRVideoInterstitial/loadAd @/link can be called to load another ad.
 */
- (void)reset;

/*!
 @brief Removes the player and releases resources
 @discussion Method @link //apple_ref/occ/instm/TPRVideoInterstitial/initWithEnvironment:params:timeout: @/link must be called before loading a new ad.
 */
- (void)removePlayer;

/*!
 @brief Delegate for player events.
 */
@property (nonatomic, weak) id<TPRVideoAdDelegate> delegate;

// Internal
@property (readonly, strong) TPRVideoPlayerHandler* playerHandler;
@property (weak) NSTimer *startTimeoutTimer;
@property (strong) TPRViewControllerTransitioningDelegate* playerControllerTransitionDelegate;
// Not available
- (instancetype) init NS_UNAVAILABLE;

@end
