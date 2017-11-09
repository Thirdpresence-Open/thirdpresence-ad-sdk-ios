//
//  TPRVideoPlayerPresentationController.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 07/11/2017.
//  Copyright © 2017 Marko Okkonen. All rights reserved.
//

#import "TPRVideoPlayerPresentationController.h"
#import "ThirdpresenceAdSDK.h"

@implementation TPRVideoPlayerPresentationController

- (id) initWithPresentedViewController:(UIViewController*)presentedVC presentingViewController:(UIViewController*)presentingVC  {
    self = [super initWithPresentedViewController:presentedVC presentingViewController:presentingVC];
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return [[UIScreen mainScreen] bounds];
}

- (BOOL) shouldPresentInFullscreen {
    return YES;
}

@end
