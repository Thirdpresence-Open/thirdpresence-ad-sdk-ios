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

@property (strong) id <NSObject> notificationObserver;
@property (strong) TPRPlayerViewController* playerViewController;

@end

@implementation TPRVideoInterstitial

- (instancetype)initWithPlacementType:(TPRPlacementType*)type
                          environment:(NSDictionary *)environment
                               params:(NSDictionary *)playerParams
                              timeout:(NSTimeInterval)secs {
    self = [super initWithPlacementType:type];
    
    _notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:TPR_PLAYER_NOTIFICATION
                                                                              object:nil
                                                                               queue: [NSOperationQueue mainQueue]
                                                                          usingBlock:^(NSNotification *note) {
                                                                              [self handleNotification:note];
                                                                          }];
    
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAll;
    NSString* forceLandscape = [environment objectForKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    NSString* forcePortrait = [environment objectForKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];

    if ([forceLandscape isEqualToString:TPR_VALUE_TRUE]) {
        orientationMask = UIInterfaceOrientationMaskLandscape;
    }
    else if ([forcePortrait isEqualToString:TPR_VALUE_TRUE]) {
        orientationMask = UIInterfaceOrientationMaskPortrait;
    } else {
        orientationMask = 1 << [[UIApplication sharedApplication] statusBarOrientation];
    }
    
    _playerViewController = [[TPRPlayerViewController alloc] initWithOrientationMask:orientationMask];
    
    _playerHandler = [[TPRVideoPlayerHandler alloc] initWithPlayer:_playerViewController.webView
                                                       environment:environment
                                                            params:playerParams
                                                     placementType:type];
    
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
    _playerHandler = nil;
    _playerViewController = nil;
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
        UIViewController *root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if (!root.presentingViewController.presentedViewController) {
            _playerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [root presentViewController:_playerViewController animated:YES completion: ^{
                [_playerHandler displayAd];
            }];
            [self.startTimeoutTimer invalidate];
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:TPR_PLAYER_DISPLAY_TIMEOUT
                                                              target:self
                                                            selector:@selector(onDisplayTimeout:)
                                                            userInfo:nil
                                                             repeats:NO];
            self.startTimeoutTimer = timer;
        } else {
            TPRLog(@"[TPR] Failure: already displaying a modal view controller");
            NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                                 code:TPR_ERROR_INVALID_STATE
                                             userInfo:[NSDictionary dictionaryWithObject:@"Cannot display ad while modal view controller is presented" forKey:NSLocalizedDescriptionKey]];
            [_delegate videoAd:self failed:error];
        }
        
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

    if (_playerViewController.displaying) {
        [_playerViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
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

    if (_playerViewController.displaying) {
        [_playerViewController dismissViewControllerAnimated:YES completion:nil];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:_notificationObserver];
    self.notificationObserver = nil;
    self.ready = NO;
    [_playerHandler resetState];
    [_playerHandler removePlayer];
    _playerHandler = nil;
    _playerViewController = nil;
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
            } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STARTED]) {
                [self.startTimeoutTimer invalidate];
            }
            
            if (_delegate) {
                [_delegate videoAd:self eventOccured:note.userInfo];
            }
        }
        
    }
    
};

- (void)onDisplayTimeout:(NSTimer*)timer {
    NSError *error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                         code:TPR_ERROR_TIMEOUT_DISPLAYING_AD
                                     userInfo:[NSDictionary dictionaryWithObject:@"Failed to display the loaded ad" forKey:NSLocalizedDescriptionKey]];
    [_delegate videoAd:self failed:error];
}


@end
