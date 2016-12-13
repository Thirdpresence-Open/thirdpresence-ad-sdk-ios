/*!
 
 @header TPRVideoBanner.h
 
 This file contains TPRVideoBanner class declaration
 
 @author Marko Okkonen
 @copyright 2016 Thirdpresence
 
 */

#import "TPRVideoAd.h"
#import "TPRBannerView.h"

@class TPRVideoPlayerHandler;

/*!
 @brief TPRVideoBanner implements a video banner ad placement
 */
@interface TPRVideoBanner : TPRVideoAd

/*!
 @brief Inits the banner placement
 @param bannerView the view that contains the ad
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
 
 @return TPRVideoBanner object
 */
- (instancetype)initWithBannerView:(TPRBannerView*)bannerView
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
 @discussion By default the ad is displayed automatically right after the ad is loaded. Set @link  disableAutoDisplay @/link to true in order to disable the default behaviour.
 */
- (void)displayAd;


/*!
 @brief Resets the ad placement
 @discussion Method @link //apple_ref/occ/instm/TPRVideoBanner/loadAd @/link can be called to load another ad.
 */
- (void)reset;

/*!
 @brief Removes the player and releases resources
 @discussion Method @link //apple_ref/occ/instm/TPRVideoBanner/initWithBannerView:environment:params:timeout: @/link must be called before loading a new ad.
 */
- (void)removePlayer;

/*!
 @brief Delegate for player events.
 */
@property (nonatomic, weak) id<TPRVideoAdDelegate> delegate;

/*!
 @brief Disables the auto display behaviour
 */
@property (assign) BOOL disableAutoDisplay;

// Internal
@property (readonly, strong) TPRVideoPlayerHandler* playerHandler;

// Not available
- (instancetype) init NS_UNAVAILABLE;


@end
