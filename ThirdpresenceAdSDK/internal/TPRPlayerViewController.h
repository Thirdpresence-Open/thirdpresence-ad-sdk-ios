/*!
 
 @header TPRPlayerViewController.h
 
 This file contains TPRPlayerViewController class declaration
 
 @author Marko Okkonen
 
 @copyright 2016 Thirdpresence
 
 */

#import <UIKit/UIKit.h>
#import "TPRWebView.h"

/*!
 * @brief View controller that contains a player
 */
@interface TPRPlayerViewController : UIViewController

/*!
 @brief Initializer
 @return TPRPlayerViewController object
 */
- (instancetype)initWithOrientationMask:(UIInterfaceOrientationMask)orientationMask;

@property (assign) UIInterfaceOrientationMask orientationMask;
@property (strong) TPRWebView* webView;
@property (assign) BOOL displaying;
@end
