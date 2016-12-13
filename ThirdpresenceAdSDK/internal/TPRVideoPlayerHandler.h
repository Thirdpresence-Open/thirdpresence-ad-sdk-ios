/*!
 
 @header TPRVideoPlayerHandler.h
 
 This file contains TPRVideoPlayerHandler class declaration
 
 @author Marko Okkonen
 
 @copyright 2016 Thirdpresence
 
 */

#import <Foundation/Foundation.h>
#import "TPRPlayerViewController.h"
#import "TPRVideoAd.h"

FOUNDATION_EXPORT NSString *const TPR_PLAYER_NOTIFICATION;

/*!
 @brief Class wraps Web View that contains the Thirdpresence HTML5 video player
 @discussion Ad placement implementations use this class initialise and display the video player
 */
@interface TPRVideoPlayerHandler : NSObject <UIWebViewDelegate>
/*!
  @brief Inits the player
  @param webView the webview that contains the player
  @param environment dictionary. See @link TPRVideoAd @/link for available keys. Values for @link TPR_ENVIRONMENT_KEY_ACCOUNT @/link and @link TPR_ENVIRONMENT_KEY_PLACEMENT_ID @/link are mandatory
  @param playerParams contains customization parameters for player. See @link TPRVideoAd @/link for available keys.
  @param placementType the type of the placement. See @link TPRVideoAd @/link for placement types.
  @return TPRVideoPlayerHandler object
 */
- (instancetype)initWithPlayer:(TPRWebView*)webView
                   environment:(NSDictionary *)environment
                        params:(NSDictionary *)playerParams
                 placementType:(TPRPlacementType*)placementType;

/*!
  @brief Loads the player
  @discussion An event with event name @link TPR_EVENT_NAME_PLAYER_READY @/link is fired when the player is ready for taking further commands
 */
- (void)loadPlayer;

/*!
  @brief Loads an ad
  @discussion An event with event name @link TPR_EVENT_NAME_AD_LOADED @/link is fired when the player has loaded an ad
 */
- (void)loadAd;

/*!
  @brief Displays the ad
  @discussion An event with event name @link TPR_EVENT_NAME_AD_STOPPED @/link when the player is stopped displaing an ad.
 */
- (void)displayAd;

/*!
  @brief Resets the player and dismissed the web view controller.
  @discussion LoadAd can be called to load another ad.
 */
- (void)resetState;

/*!
  @brief Removes the player and releases resources. The player needs to be re-initialized to load another ad.
 */
- (void)removePlayer;

@property (strong, readonly) TPRWebView* webView;


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
