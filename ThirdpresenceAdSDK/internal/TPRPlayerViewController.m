//
//  TPRPlayerViewController.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 19/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRPlayerViewController.h"
#import "TPRVideoAd.h"

@implementation TPRPlayerViewController

- (instancetype)initWithOrientationMask:(UIInterfaceOrientationMask)orientationMask {
    self = [super init];
    
    _orientationMask = orientationMask;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    _webView = [[TPRWebView alloc] initWithFrame:frame];
    self.view = self.webView;
    
    return self;
}

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.delegate = nil;
    _webView = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView initAdTracker];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _displaying = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _displaying = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate {
    return NO;
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

@end
