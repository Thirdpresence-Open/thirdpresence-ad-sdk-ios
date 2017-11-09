//
//  TPRVideoPlayerPresentationController.h
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 07/11/2017.
//  Copyright © 2017 Marko Okkonen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPRVideoPlayerPresentationController : UIPresentationController

- (id) initWithPresentedViewController:(UIViewController*)presentedVC presentingViewController:(UIViewController*)presentingVC;
@end
