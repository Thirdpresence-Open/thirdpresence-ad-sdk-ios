//
//  TPRVideoInterstitial.h
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPRVideoAd.h"

@class TPRVideoPlayerHandler;

/**
 * Class for loading and displaying a video interstitial ad
 */
@interface TPRVideoInterstitial : TPRVideoAd

/**
 *  Inits the interstitial
 *
 *  @param environment is a dictionary containing environment parameters. 
 *    @see TPRVideoAd for available keys. Values for following keys are mandatory:
 *     TPR_ENVIRONMENT_KEY_ACCOUNT
 *     TPR_ENVIRONMENT_KEY_PLACEMENT_ID
 *
 *  @param playerParams is a dictionary containing customization parameters for the player
 *  @param secs for initializing the player and loading an ad.
 *     Use TPR_PLAYER_DEFAULT_TIMEOUT as a default.
 *
 *  An event TPR_EVENT_NAME_PLAYER_READY is fired when the player is ready for taking further commands
 *
 *  @return TPRVideoInterstitial object
 */
- (instancetype)initWithEnvironment:(NSDictionary*)environment
                              params:(NSDictionary*)playerParams
                             timeout:(NSTimeInterval)secs;
// Intended to be used from derived classed
- (instancetype)initWithPlacementType:(TPRPlacementType*)type
                           environment:(NSDictionary*)environment
                                params:(NSDictionary*)playerParams
                               timeout:(NSTimeInterval)secs;

/**
 *  Loads an ad
 *
 *  An event TPR_EVENT_NAME_AD_LOADED is fired when the player has loaded an ad
 *
 */
- (void)loadAd;

/**
 *  Displays the ad
 *
 *  An event TPR_EVENT_NAME_AD_STOPPED when the player is stopped displaing an ad.
 *
 */
- (void)displayAd;

/**
 *  Resets ad placement and dismissed the ad unit. loadAd can be called to load another ad.
 */
- (void)reset;

/**
 *  Removes the player and releases resources. Interstitial needs to be re-initialized to load another ad.
 */
- (void)removePlayer;

/**
 * Sets delegate for player events.
 */
@property (nonatomic, weak) id<TPRVideoAdDelegate> delegate;

// Internal
@property (readonly, strong) TPRVideoPlayerHandler* playerHandler;

// Not available
- (instancetype) init NS_UNAVAILABLE;

@end
