//
//  TPRBannerView.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 01/12/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRBannerView.h"
#import "TPRVideoAd.h"
#import "TPRWebView.h"

@implementation TPRBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _webView = [[TPRWebView alloc] initWithFrame:self.bounds];
        [self addSubview:_webView];

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _webView = [[TPRWebView alloc] initWithFrame:self.bounds];
        [self addSubview:_webView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _webView.frame = self.bounds;
}

@end
