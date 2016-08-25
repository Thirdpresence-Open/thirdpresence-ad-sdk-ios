//
//  TPRWebViewController.h
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 19/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPRWebViewController;

/**
 *  Delegate protocol for TPRWebViewController
 */
@protocol TPRWebViewControllerDelegate <NSObject>
- (void)webViewControllerWillAppear:(TPRWebViewController*)webViewController animated:(BOOL)animated;
- (void)webViewControllerDidAppear:(TPRWebViewController*)webViewController animated:(BOOL)animated;
- (void)webViewControllerWillDisappear:(TPRWebViewController*)webViewController animated:(BOOL)animated;
- (void)webViewControllerDidDisappear:(TPRWebViewController*)webViewController animated:(BOOL)animated;
- (void)webViewControllerDidReceiveMemoryWarning:(TPRWebViewController*)webViewController;
- (void)webViewControllerDidStartLoad:(TPRWebViewController*)webViewController;
- (void)webViewControllerDidFinishLoad:(TPRWebViewController*)webViewController;
- (void)webViewController:(TPRWebViewController*)webViewController didFailLoadWithError:(NSError*)error;
- (BOOL)webViewController:(TPRWebViewController*)webViewController shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType;

@end

/**
 * View controller that contains single web view
 */
@interface TPRWebViewController : UIViewController <UIWebViewDelegate>

/**
 *  Initializer
 *
 *  @return TPRWebViewController object
 */
- (instancetype)init;

/**
 *  Loads a web page
 *
 *  @param urlString for the URL to be loaded
 */
- (void)loadUrl:(NSString*)urlString;

/**
 *  Executes a JavaScript function in the loaded web page
 *
 *  @param function to be execeuted
 *  @param arg1 first argument for the function
 *  @param arg2 second argument for the function
 */
- (void)callJSFunction:(NSString*)function arg1:(NSString*)arg1 arg2:(NSString*)arg2;

/**
 *  Stops loading the page
 */
- (void)stopLoading;

@property (nonatomic, weak) id<TPRWebViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (assign) UIInterfaceOrientationMask orientationMask;

@end
