//
//  TPRWebView.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 02/12/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRWebView.h"
#import "TPRVideoAd.h"

// MOAT SDK Framework to be added
//#import <TRDPMoatMobileAppKit/TRDPMoatMobileAppKit.h>

NSTimeInterval const REQUEST_TIMEOUT = 5.0;

@implementation TPRWebView

- (void)internalInit {
    [self setAllowsInlineMediaPlayback:YES];
    [self setMediaPlaybackRequiresUserAction:NO];
    [self setSuppressesIncrementalRendering:YES];
    [self setMediaPlaybackAllowsAirPlay:NO];
    self.scrollView.bounces = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self internalInit];
    }
    return self;
}

- (void)callJSFunction:(NSString*)function arg1:(NSString*)arg1 arg2:(NSString*)arg2 {
    NSString* functiontring = [NSString stringWithFormat:@"javascript:%@(%@,%@)", function, arg1, arg2];
    [self stringByEvaluatingJavaScriptFromString:functiontring];
    
}

- (BOOL) prepare:(NSString*)playerUrl {
    NSURL *url = [NSURL URLWithString:playerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:REQUEST_TIMEOUT];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [self loadRequest:request];
    return YES;
}

- (void) loadAd {
    [self callJSFunction:@"loadAd" arg1:nil arg2:nil];
}

- (void) startAd {
    [self callJSFunction:@"startAd" arg1:nil arg2:nil];
}

- (void) reset {
    [self stopLoading];
}

- (void) updateLocationWithLatitude:(double)latitude longitude:(double)longitude {
    [self callJSFunction:@"updateLocation"
                            arg1:[NSString stringWithFormat:@"%f", latitude]
                            arg2:[NSString stringWithFormat:@"%f", longitude]];
}

- (void)initAdTracker {
    BOOL success = NO;
    if (self.enableAdTracker) {
        Class classObj = NSClassFromString(@"TRDPMoatBootstrap");
        SEL selector = NSSelectorFromString(@"injectDelegateWrapper:");
        if (classObj && [classObj respondsToSelector:selector]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [classObj performSelector:selector withObject:self];
            success = YES;
        }
    }
    if (success) {
        TPRLog(@"[TPR] MOAT ad tracker enabled");
    } else {
        TPRLog(@"[TPR] MOAT SDK not available");
    }
}

@end
