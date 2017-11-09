//
//  TPRViewControllerTransitioningDelegate.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 07/11/2017.
//  Copyright © 2017 Marko Okkonen. All rights reserved.
//

#import "TPRViewControllerTransitioningDelegate.h"
#import "TPRVideoPlayerPresentationController.h"

@implementation TPRViewControllerTransitioningDelegate

- (id)init {
    self = [super init];
    return self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    UIPresentationController* presentationController = [[TPRVideoPlayerPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    
    return presentationController;
}

@end
