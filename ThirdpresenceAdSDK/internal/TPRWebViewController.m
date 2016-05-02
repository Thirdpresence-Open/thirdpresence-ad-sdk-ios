//
//  TPRWebViewController.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 19/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRWebViewController.h"

NSTimeInterval const REQUEST_TIMEOUT = 5.0;

@implementation TPRWebViewController

- (instancetype)init {
    self = [super init];
    
    _orientationMask = UIInterfaceOrientationMaskAll;
    
    _webView = [[UIWebView alloc] init];
    [_webView setAllowsInlineMediaPlayback:YES];
    [_webView setMediaPlaybackRequiresUserAction:NO];
    [_webView setSuppressesIncrementalRendering:YES];
    [_webView setMediaPlaybackAllowsAirPlay:NO];
    _webView.scrollView.bounces = NO;
    
    self.webView.delegate = self;
    self.view = self.webView;
    
    return self;
}

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.delegate = nil;
    self.delegate = nil;
}

- (void)callJSFunction:(NSString*)function {
    NSString* functiontring = [NSString stringWithFormat:@"javascript:%@()", function];
    [self.webView stringByEvaluatingJavaScriptFromString:functiontring];
    
}
- (void)loadUrl:(NSString*)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    _request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIMEOUT];
    [self.webView loadRequest:self.request];
}

- (void)stopLoading {
    [self.webView stopLoading];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _webView = nil;
    [self.webView stopLoading];
    self.webView.delegate = nil;
    self.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.delegate webViewControllerDidReceiveMemoryWarning:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.delegate webViewControllerWillAppear:self animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.delegate webViewControllerDidAppear:self animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate webViewControllerWillDisappear:self animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.delegate webViewControllerDidDisappear:self animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _orientationMask;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.delegate webViewControllerDidStartLoad:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.delegate webViewControllerDidFinishLoad:self];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.delegate webViewController:self didFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self.delegate webViewController:self shouldStartLoadWithRequest:request navigationType:navigationType];
}

@end
