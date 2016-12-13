/*!
 
 @header TPRBannerView.h
 
 This file contains TPRBannerView class declaration
 
 @author Marko Okkonen
 @copyright 2016 Thirdpresence
 
 */

#import <UIKit/UIKit.h>

@class TPRWebView;

/*!
 @brief TPRBannerView implements a view that can contains the video ad player
 @discussion This can be used like UIViewfor displaying the banner view.
 */
@interface TPRBannerView : UIView

// Internal
@property (strong) TPRWebView* webView;
@end
