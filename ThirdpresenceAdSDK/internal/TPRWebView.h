/*!
 
 @header TPRWebView.h
 
 This file contains TPRWebView class declaration
 
 @author Marko Okkonen
 
 @copyright 2016 Thirdpresence
 
 */

#import <UIKit/UIKit.h>

@class TRDPMoatWebTracker;

@interface TPRWebView : UIWebView

/*!
 @brief Executes a JavaScript function in the loaded web page
 @param function to be execeuted
 @param arg1 first argument for the function
 @param arg2 second argument for the function
 */
- (void)callJSFunction:(NSString*)function arg1:(NSString*)arg1 arg2:(NSString*)arg2;

/*!
 @brief Loads a web page
 @param playerUrl for the player to be loaded
 */
- (BOOL) prepare:(NSString*)playerUrl;

/*!
 @brief Loads an ad
 */
- (void) loadAd;

/*!
 @brief starts playing the loaded ad
 */
- (void) startAd;

/*!
 @brief Resets the ad
 */
- (void) reset;

/*!
 @brief Updates the volume level to the player
 @param volume the volume level in scale 0 to 1
 */
- (void) updateVolume:(float)volume;

/*!
 @brief Updates coordinates to the player
 @param latitude the latitude coordinate
 @param longitude the longitude coordinate
 */
- (void) updateLocationWithLatitude:(double)latitude longitude:(double)longitude;

@end
