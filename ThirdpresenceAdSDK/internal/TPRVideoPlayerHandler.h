//
//  TPRVideoPlayerHandler.h
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 25/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPRWebViewController.h"
#import "TPRVideoAd.h"

FOUNDATION_EXPORT NSString *const TPR_PLAYER_NOTIFICATION;

/**
 * Class that wraps WebView that contains the HTML5 player
 */
@interface TPRVideoPlayerHandler : NSObject <TPRWebViewControllerDelegate>
/**
 *  Inits the player
 *
 *  @param environment dictionary. @see TPRVideoAd for available keys. Values for TPR_ENVIRONMENT_KEY_ACCOUNT and TPR_ENVIRONMENT_KEY_PLACEMENT_ID are mandatory
 *
 *  @param playerParams contains customization parameters for player
 *
 *  @return TPRVideoInterstitial object
 */
- (instancetype)initWithEnvironment:(NSDictionary*)environment
                             params:(NSDictionary*)playerParams;

/**
 *  loads the player
 *
 *  An event TPR_EVENT_NAME_PLAYER_READY is fired when the player is ready for taking further commands
 *
 */
- (void)loadPlayer;

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
 *  Resets the player and dismissed the web view controller. loadAd can be called to load another ad.
 */
- (void)resetState;

/**
 *  Removes the player and releases resources. The player needs to be re-initialized to load another ad.
 */
- (void)removePlayer;

@property (strong, readonly) TPRWebViewController* webViewController;

@property (readonly) BOOL playerLoading;
@property (readonly) BOOL playerLoaded;
@property (readonly) BOOL playerLocationUpdatePending;

@property (readonly) BOOL adLoadPending;
@property (readonly) BOOL adLoading;
@property (readonly) BOOL adLoaded;
@property (readonly) BOOL adDisplayed;
@property (readonly) BOOL adPlaying;
@property (readonly) BOOL adPlayPending;

@property (readonly) NSDictionary* environment;
@property (readonly) NSDictionary* playerParams;

@property (strong, readonly) NSTimer* playerTimeoutTimer;
@property (strong, readonly) NSTimer* loadAdTimeoutTimer;

@property (assign) NSTimeInterval playerTimeout;
@property (assign) NSTimeInterval loadAdTimeout;

@property (readonly) NSDate* locationTimeStamp;

@property (readonly) NSString* playerPageURL;

// Not available
- (instancetype)init NS_UNAVAILABLE;


@end
