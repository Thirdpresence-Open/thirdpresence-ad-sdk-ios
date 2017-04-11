//
//  TRDPMoatWebTracker.h
//  TRDPMoatMobileAppKit
//
//  Created by Moat on 6/2/16.
//  Copyright © 2016 Moat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TRDPMoatBaseTracker.h"

@interface TRDPMoatWebTracker : TRDPMoatBaseTracker

+ (TRDPMoatWebTracker *)trackerWithWebComponent:(UIView *)webViewOrWebViewContainer;

// Use this to track hybrid, two-view ads that consist both of a native UIView and a web-based component.
+ (TRDPMoatWebTracker *)trackerWithAdView:(UIView *)adView withWebComponent:(UIView *)webViewOrWebViewContainer;

- (bool)startTracking;

- (void)stopTracking;

@end
