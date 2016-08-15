//
//  TPRVideoInterstitial.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRVideoInterstitial.h"
#import "TPRVideoPlayerHandler.h"
#import "ThirdpresenceAdSDK.h"

@interface TPRVideoInterstitial ()
- (void)handleNotification:(NSNotification*)note;
@end

@implementation TPRVideoInterstitial

- (instancetype)initWithPlacementType:(TPRPlacementType*)type
                          environment:(NSDictionary *)environment
                               params:(NSDictionary *)playerParams
                              timeout:(NSTimeInterval)secs {
    self = [super initWithPlacementType:type];

    [[NSNotificationCenter defaultCenter] addObserverForName:TPR_PLAYER_NOTIFICATION
                                                      object:_playerHandler
                                                       queue: [NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self handleNotification:note];
                                                  }];
    
    _playerHandler = [[TPRVideoPlayerHandler alloc] initWithEnvironment:environment params:playerParams];
    
    if (secs > 0) {
        _playerHandler.playerTimeout = secs;
        _playerHandler.loadAdTimeout = secs;
    }
    
    [_playerHandler loadPlayer];
    
    return self;
}

- (instancetype)initWithEnvironment:(NSDictionary *)environment
                             params:(NSDictionary *)playerParams
                            timeout:(NSTimeInterval)secs {
    
    TPRLog(@"[TPR] Initialising interstitial");

    self = [self initWithPlacementType:TPR_PLACEMENT_TYPE_INTERSTITIAL
                           environment:environment
                                params:playerParams
                               timeout:secs];
    return self;
}

- (void)dealloc {
    [_playerHandler removePlayer];
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
    TPRLog(@"[TPR] Trying to display an ad");

    if (_playerHandler) {
        [_playerHandler displayAd];
    } else {
        TPRLog(@"[TPR] Failure: player not allocated");
        NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Player not initialized" forKey:NSLocalizedDescriptionKey]];
        [_delegate videoAd:self failed:error];
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

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.ready = NO;
    [_playerHandler resetState];
    _playerHandler = nil;
}

- (void)handleNotification:(NSNotification*)note {
    TPRLog(@"[TPR] Handling an event %@", note);
    if (_delegate) {
        NSString *eventName = [note.userInfo objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
            NSError *error = [note.userInfo objectForKey:TPR_EVENT_KEY_ARG1];
            [_delegate videoAd:self failed:error];
        } else {
            if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
                self.ready = YES;
            }
            [_delegate videoAd:self eventOccured:note.userInfo];
        }
    }
};


@end
