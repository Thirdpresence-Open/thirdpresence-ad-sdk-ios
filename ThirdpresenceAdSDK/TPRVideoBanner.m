//
//  TPRVideoBanner.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 01/12/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRVideoBanner.h"
#import "TPRVideoPlayerHandler.h"

@interface TPRVideoBanner ()
- (void)handleNotification:(NSNotification*)note;

@property (strong) id <NSObject> notificationObserver;
@end

@implementation TPRVideoBanner

- (instancetype)initWithBannerView:(TPRBannerView*)bannerView
                       environment:(NSDictionary*)environment
                            params:(NSDictionary*)playerParams
                           timeout:(NSTimeInterval)secs {
    TPRLog(@"[TPR] Initialising video banner");

    self = [super initWithPlacementType:TPR_PLACEMENT_TYPE_BANNER];

    _notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:TPR_PLAYER_NOTIFICATION
                                                                              object:nil
                                                                               queue: [NSOperationQueue mainQueue]
                                                                          usingBlock:^(NSNotification *note) {
                                                                              [self handleNotification:note];
                                                                          }];
        
    _playerHandler = [[TPRVideoPlayerHandler alloc] initWithPlayer:bannerView.webView environment:environment params:playerParams placementType:TPR_PLACEMENT_TYPE_BANNER];
    
    if (secs > 0) {
        _playerHandler.playerTimeout = secs;
        _playerHandler.loadAdTimeout = secs;
    }
    
    [_playerHandler loadPlayer];

    return self;
}

- (void)loadAd {
    TPRLog(@"[TPR] Loading an ad");
    
    if (_playerHandler) {
        [_playerHandler loadAd];
    } else {
        TPRLog(@"[TPR] Failure: player not allocated");
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Player not initialized" forKey:NSLocalizedDescriptionKey]];
        [_delegate videoAd:self failed:error];
    }
}

- (void)displayAd {
    if (_playerHandler.adLoaded && !_playerHandler.adDisplayed) {
        [_playerHandler displayAd];
    }
}

- (void)reset {
    TPRLog(@"[TPR] Resetting the player");
    
    self.ready = NO;
    if (_playerHandler) {
        [_playerHandler resetState];
        [_playerHandler loadPlayer];
    } else {
        TPRLog(@"[TPR] Failure: player not allocated");
        
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Player not initialized" forKey:NSLocalizedDescriptionKey]];
        [_delegate videoAd:self failed:error];
    }
}

- (void)removePlayer {
    TPRLog(@"[TPR] Removing the player");
    
    [[NSNotificationCenter defaultCenter] removeObserver:_notificationObserver];
    self.notificationObserver = nil;
    self.ready = NO;
    [_playerHandler resetState];
    [_playerHandler removePlayer];
    _playerHandler = nil;
}

- (void)handleNotification:(NSNotification*)note {
    if (note.object == _playerHandler) {
        TPRLog(@"[TPR] Handling an event %@", note);
        
        NSString *eventName = [note.userInfo objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
            NSError *error = [note.userInfo objectForKey:TPR_EVENT_KEY_ARG1];
            if (_delegate) {
                [_delegate videoAd:self failed:error];
            }
        } else {
            if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
                self.ready = YES;
            } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
                if (!_disableAutoDisplay) {
                    [_playerHandler displayAd];
                }
            }
            if (_delegate) {
                [_delegate videoAd:self eventOccured:note.userInfo];
            }
        }
        
    }
};

@end
