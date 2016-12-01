//
//  TPRRewardedVideo.h
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRVideoInterstitial.h"

/**
 * Class for Rewarded video interstitial ad
 */
@interface TPRRewardedVideo : TPRVideoInterstitial

/**
 *  Inits the rewarded video
 *
 *  @param environment is a dictionary containing environment parameters.
 *    @see TPRVideoAd for available keys. Values for following keys are mandatory:
 *     TPR_ENVIRONMENT_KEY_ACCOUNT
 *     TPR_ENVIRONMENT_KEY_PLACEMENT_ID
 *     TPR_ENVIRONMENT_KEY_REWARD_TITLE
 *     TPR_ENVIRONMENT_KEY_REWARD_AMOUNT
 *
 *  @param playerParams is a dictionary containing customization parameters for the player
 *    @see TPRVideoAd for available keys.

 *
 *  @param secs for initializing the player and loading an ad.
 *    Use TPR_PLAYER_DEFAULT_TIMEOUT as a default.
 *
 *  @return TPRRewardedVideo object
 */
- (instancetype)initWithEnvironment:(NSDictionary*)environment
                             params:(NSDictionary*)playerParams
                            timeout:(NSTimeInterval)secs;

/**
 *  Loads an ad
 */
- (void)loadAd;

/**
 *  Displays the ad
 */
- (void)displayAd;

/**
 *  Resets ad placement and dismissed the ad unit. loadAd can be called to load another ad.
 */
- (void)reset;

/**
 *  Removes the player and releases resources. Rewarded video needs to be re-initialized to load another ad.
 */
- (void)removePlayer;

// Not available
- (instancetype)init NS_UNAVAILABLE;

@end
