//
//  ThirdpresenceUnityRewardedVideo.m
//  ThirdpresenceUnityPlugin
//
//  Created by Marko Okkonen on 09/08/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "ThirdpresenceUnityRewardedVideo.h"
#import "ThirdpresenceUnity.h"

@implementation ThirdpresenceUnityRewardedVideo

+ (id)sharedRewardedVideo {
    static ThirdpresenceUnityRewardedVideo *sharedRewardedVideo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRewardedVideo = [[self alloc] init];
    });
    return sharedRewardedVideo;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void) setupPlayerWithEnvironment:(NSDictionary*)env params:(NSDictionary*)params timeout:(NSTimeInterval)timeout {
    [self removePlayer];
    
    _rewardTitle = [env valueForKey:TPR_ENVIRONMENT_KEY_REWARD_TITLE];
    _rewardAmount = [env valueForKey:TPR_ENVIRONMENT_KEY_REWARD_AMOUNT];

    if (!_rewardTitle) {
        [self sendErrorWithCode:TPR_ERROR_INVALID_STATE message:@"Environment data does not contain reward title"];
    }
    else if (!_rewardAmount) {
        [self sendErrorWithCode:TPR_ERROR_INVALID_STATE message:@"Environment data does not contain reward amount"];
    }
    else {
        NSMutableDictionary* environment = [self convertEnvironment:env];
        [environment setValue:@"unity" forKey:TPR_ENVIRONMENT_KEY_EXT_SDK];
        
        NSString *version = [NSString stringWithUTF8String:TPR_SDK_VERSION];
        [environment setValue:version forKey:TPR_ENVIRONMENT_KEY_SDK_VERSION];
        
        _rewardedVideo = [[TPRRewardedVideo alloc] initWithEnvironment:environment params:params timeout:timeout];
        _rewardedVideo.delegate = self;
    }
}

- (void) displayAd {
    if (!_rewardedVideo) {
        [self sendErrorWithCode:TPR_ERROR_INVALID_STATE message:@"Rewarded Video is not initialised"];
    }
    else if (!_adLoaded) {
        [self sendErrorWithCode:TPR_ERROR_INVALID_STATE message:@"An ad is not loaded"];
    }
    else {
        _adDisplaying = YES;
        [_rewardedVideo displayAd];
    }
}

- (void) removePlayer {
    [_rewardedVideo removePlayer];
    _rewardedVideo.delegate = nil;
    _rewardedVideo = nil;
    _rewardAmount = nil;
    _rewardTitle = nil;
    _adLoaded = NO;
    _adDisplaying = NO;
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == _rewardedVideo) {
        [self sendErrorWithCode:[error code] message:[error localizedDescription]];
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
    if (videoAd == _rewardedVideo) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            [_rewardedVideo loadAd];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            _adLoaded = YES;
            [self sendEvent:nil handler:@"onRewardedVideoLoaded"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STARTED]) {
            [self sendEvent:nil handler:@"onRewardedVideoShown"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            NSString* errorMessage = [event objectForKey:TPR_EVENT_KEY_ARG1];
            if (_adLoaded) {
                _adLoaded = NO;
                [self sendErrorWithCode:TPR_ERROR_VIDEO_PLAYBACK message:errorMessage];
            } else {
                [self sendErrorWithCode:TPR_ERROR_NO_FILL message:errorMessage];
            }                
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            _adLoaded = NO;
            if (_adDisplaying) {
                _adDisplaying = NO;
                [self sendEvent:nil handler:@"onRewardedVideoDismissed"];
            }
            [_rewardedVideo removePlayer];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self sendEvent:nil handler:@"onRewardedVideoClicked"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_COMPLETE]) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:_rewardTitle, @"title", _rewardAmount, @"amount", nil];
            NSError* error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
            NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [self sendEvent:strData handler:@"onRewardedVideoCompleted"];
        }
    }
}

- (NSMutableDictionary*) convertEnvironment:(NSDictionary*)dictionary {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [newDict setObject:[dictionary objectForKey:@"placementid"] forKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    return newDict;
}

- (void) sendErrorWithCode:(NSInteger)errorCode message:(NSString*)message {
    NSError* error;
    if (!message) message = @"Unknown error";

    NSNumber *errorCodeNumber = [NSNumber numberWithInteger:errorCode];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                errorCodeNumber, @"code",
                                message, @"message", nil];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self sendEvent:strData handler:@"onRewardedVideoFailed"];
}

- (void) sendEvent:(NSString*)data handler:(NSString*)func {
    const char * funcion = [func cStringUsingEncoding:NSUTF8StringEncoding];
    const char * message = data ? [data cStringUsingEncoding:NSUTF8StringEncoding] : "";
    UnitySendMessage(UNITY_HANDLER_OBJECT, funcion, message);
}

@end

void _initRewardedVideo (const char* environment, const char* playerParams, long timeout)
{
    __block NSString *envStr = [NSString stringWithCString:environment encoding:NSUTF8StringEncoding];
    __block NSString *paramStr = [NSString stringWithCString:playerParams encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ThirdpresenceUnityRewardedVideo *rewardedVideo = [ThirdpresenceUnityRewardedVideo sharedRewardedVideo];
        NSError *error = nil;
        NSData *data = [envStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *env = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
        if (error) {
            [rewardedVideo sendErrorWithCode:TPR_ERROR_PLAYER_INIT_FAILED message:@"Environment data not valid"];
            return;
        }
        
        data = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
        if (error) {
            [rewardedVideo sendErrorWithCode:TPR_ERROR_PLAYER_INIT_FAILED message:@"Player parameters not valid" ];
            return;
        }
        
        [rewardedVideo setupPlayerWithEnvironment:env params:params timeout:timeout];
        
    });
}

void _showRewardedVideo () {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ThirdpresenceUnityRewardedVideo sharedRewardedVideo] displayAd];
    });
}

void _removeRewardedVideo () {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ThirdpresenceUnityRewardedVideo sharedRewardedVideo] removePlayer];
    });
}


