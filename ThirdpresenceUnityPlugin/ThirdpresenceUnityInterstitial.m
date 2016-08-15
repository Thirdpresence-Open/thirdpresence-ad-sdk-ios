//
//  ThirdpresenceUnityInterstitial.m
//  ThirdpresenceUnityPlugin
//
//  Created by Marko Okkonen on 05/08/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "ThirdpresenceUnityInterstitial.h"
#import "ThirdpresenceUnity.h"

@implementation ThirdpresenceUnityInterstitial

+ (id)sharedInterstitial {
    static ThirdpresenceUnityInterstitial *sharedInterstitial = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInterstitial = [[self alloc] init];
    });
    return sharedInterstitial;
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
    
    _interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:[self convertEnvironment:env] params:params timeout:timeout];
    _interstitial.delegate = self;
}

- (void) displayAd {
    if (!_interstitial) {
        [self sendErrorWithCode:TPR_ERROR_INVALID_STATE message:@"Interstitial is not initialised"];
    }
    else if (!_adLoaded) {
        [self sendErrorWithCode:TPR_ERROR_INVALID_STATE message:@"An ad is not loaded"];
    }
    else {
        [_interstitial displayAd];
    }
}

- (void) removePlayer {
    [_interstitial removePlayer];
    _interstitial = nil;
    _adLoaded = NO;
}

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
    if (videoAd == _interstitial) {
        [self sendErrorWithCode:[error code] message:[error localizedDescription]];
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
    
    if (videoAd == _interstitial) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
             [_interstitial loadAd];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            _adLoaded = YES;
            [self sendEvent:nil handler:@"onInterstitialLoaded"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STARTED]) {
            [self sendEvent:nil handler:@"onInterstitialShown"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            _adLoaded = NO;
            [self sendErrorWithCode:TPR_ERROR_NO_FILL message:@"Player failed to display an ad"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            _adLoaded = NO;
            [self.interstitial removePlayer];
            [self sendEvent:nil handler:@"onInterstitialDismissed"];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self sendEvent:nil handler:@"onInterstitialClicked"];
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
    NSNumber *errorCodeNumber = [NSNumber numberWithInteger:errorCode];
    NSDictionary *dictonary = [NSDictionary dictionaryWithObjectsAndKeys:
                               errorCodeNumber, @"code",
                               message, @"message", nil];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictonary options:kNilOptions error:&error];
    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self sendEvent:strData handler:@"onInterstitialFailed"];
}

- (void) sendEvent:(NSString*)data handler:(NSString*)func {
    const char * funcion = [func cStringUsingEncoding:NSUTF8StringEncoding];
    const char * message = data ? [data cStringUsingEncoding:NSUTF8StringEncoding] : "";
    UnitySendMessage(UNITY_HANDLER_OBJECT, funcion, message);
}

@end

void _initInterstitial (const char* environment, const char* playerParams, long timeout)
{
    __block NSString *envStr = [NSString stringWithCString:environment encoding:NSUTF8StringEncoding];
    __block NSString *paramStr = [NSString stringWithCString:playerParams encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ThirdpresenceUnityInterstitial *interstital = [ThirdpresenceUnityInterstitial sharedInterstitial];
        NSError *error = nil;
        NSData *data = [envStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *env = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
        if (error) {
            [interstital sendErrorWithCode:TPR_ERROR_PLAYER_INIT_FAILED message:@"Environment data not valid"];
            return;
        }
        
        data = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
        if (error) {
            [interstital sendErrorWithCode:TPR_ERROR_PLAYER_INIT_FAILED message:@"Player parameters not valid" ];
            return;
        }
        
        [interstital setupPlayerWithEnvironment:env params:params timeout:timeout];
        
    });
}

void _showInterstitial () {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ThirdpresenceUnityInterstitial sharedInterstitial] displayAd];
    });
}

void _removeInterstitial () {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ThirdpresenceUnityInterstitial sharedInterstitial] removePlayer];
    });
}


