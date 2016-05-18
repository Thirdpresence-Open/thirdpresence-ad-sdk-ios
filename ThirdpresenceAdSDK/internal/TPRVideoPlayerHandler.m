//
//  TPRVideoPlayerHandler.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 25/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRVideoPlayerHandler.h"
#import "ThirdpresenceAdSDK.h"
#import <AdSupport/ASIdentifierManager.h>


@interface TPRVideoPlayerHandler ()

- (void)openURL:(NSURL*)urlString;
- (void)handlePlayerEvent:(TPRPlayerEvent*)event;
- (TPRPlayerEvent*)parseEvent:(NSString*)query;
- (NSString*)encodeUrlString:(NSString *)string;
- (NSTimer*)startTimer:(NSTimeInterval)timeout target:(SEL)selector;
- (void)cancelTimer:(NSTimer*)timer;
- (void)timeoutOccuredOn:(NSTimer*)timer;
- (void)sendEvent:(NSString*)eventName arg1:(NSObject*)arg1 arg2:(NSObject*)arg2 arg3:(NSObject*)arg3;
- (void)sendEvent:(TPRPlayerEvent*)event;
- (void)checkOrientation;
- (NSString*)getAdvertisingID;
@end

@implementation TPRVideoPlayerHandler

NSString *const PLAYER_URL_BASE = @"http://d1c13tt6n7tja5.cloudfront.net/tags/%@/sdk/LATEST/sdk_player.v3.html?env=%@&cid=%@&playerid=%@&customization=%@";

NSString *const TPR_PLAYER_NOTIFICATION = @"TPRPlayerNotification";
NSString *const PLAYER_EVENT_CUSTOM_SCHEME = @"thirdpresence";
NSString *const PLAYER_EVENT_HOST_NAME = @"onPlayerEvent";

- (instancetype)initWithEnvironment:(NSDictionary *)environment
                             params:(NSDictionary *)playerParams {
    self = [super init];

    _environment = environment;
    _playerParams = playerParams;
    
    _playerTimeout = TPR_PLAYER_DEFAULT_TIMEOUT;
    _loadAdTimeout = TPR_PLAYER_DEFAULT_TIMEOUT;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    _webViewController = [[TPRWebViewController alloc] init];
    _webViewController.delegate = self;

    [self checkOrientation];
    
    _adPlaying = NO;
    
    return self;
}

- (void)dealloc {
    [self resetState];
    [self removePlayer];
}

- (void)appWillResignActive:(NSNotification*)note {
    if (_adPlaying) {
        _adPlayPending = YES;
    }
}

- (void)appDidBecomeActive:(NSNotification*)note {
    if (_adPlayPending) {
        _adPlayPending = NO;
        UIViewController *root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if (root.presentedViewController == _webViewController) {
            [_webViewController callJSFunction:@"startAd"];
        }
    }
}

- (void)loadPlayer {
    [self resetState];
    
    NSString* env = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_SERVER];
    if (!env) {
        env = TPR_SERVER_TYPE_PRODUCTION;
    }
    
    NSString* account = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_ACCOUNT];
    if (!account) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Environment dictionary does not contain account id" forKey:NSLocalizedDescriptionKey]];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
        return;
    }
    
    NSString* placementId = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_PLACEMENT_ID];
    if (!placementId) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Environment dictionary does not contain placementid id" forKey:NSLocalizedDescriptionKey]];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
        return;
    }
    
    NSString *customization = nil;
    NSMutableDictionary *params;
    
    if (_playerParams) {
        params = [NSMutableDictionary dictionaryWithDictionary:_playerParams];
    } else {
        params = [NSMutableDictionary dictionaryWithCapacity:5];
    }

    if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_DEVICE_ID]) {
        NSString* advertisingIdentifier = [self getAdvertisingID];
        if (advertisingIdentifier) {
            [params setValue:advertisingIdentifier forKey:TPR_PLAYER_PARAMETER_KEY_DEVICE_ID];
        }
    }
    
    if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_BUNDLE_ID]) {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        if (bundleIdentifier) {
             [params setValue:bundleIdentifier forKey:TPR_PLAYER_PARAMETER_KEY_BUNDLE_ID];
        }
    }
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (appName) {
        if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_APP_NAME]) {
            [params setValue:appName forKey:TPR_PLAYER_PARAMETER_KEY_APP_NAME];
        }
    
        if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_APP_VERSION]) {
            NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
            if (version) {
                [params setValue:version forKey:TPR_PLAYER_PARAMETER_KEY_APP_VERSION];
            }
        }
        
        if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_PUBLISHER]) {
            [params setValue:appName forKey:TPR_PLAYER_PARAMETER_KEY_PUBLISHER];
        }
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:0
                                                         error:&error];
    if (! jsonData) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Invalid player parameters"
                                                                              forKey:NSLocalizedDescriptionKey]];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
        return;
    }
    
    customization = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:PLAYER_URL_BASE,
                     env,
                     env,
                     account,
                     placementId,
                     customization ? [self encodeUrlString:customization] : @""
                     ];
    
    _playerTimeoutTimer = [self startTimer:_playerTimeout target:@selector(timeoutOccuredOn:)];
    
    [_webViewController loadUrl:url];
}

- (void)loadAd {
    if (_adDisplayed) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"An ad is being displayed. The reset message needs to be passed before loading a new ad" forKey:NSLocalizedDescriptionKey]];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
    } else if (_adLoaded) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"An ad is already loaded. The reset message needs to be passed before loading a new ad" forKey:NSLocalizedDescriptionKey]];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
    } else if (_playerLoaded) {
        _adLoadPending = NO;
        if (!_adLoading) {
            _adLoading = YES;
            _loadAdTimeoutTimer = [self startTimer:_loadAdTimeout target:@selector(timeoutOccuredOn:)];
            [_webViewController callJSFunction:@"loadAd"];
        }
    } else {
        _adLoadPending = YES;
    }
}

- (void)displayAd {
    if (!_adLoaded) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Ad not loaded yet" forKey:NSLocalizedDescriptionKey]];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
        
        
    }
    else if (_adDisplayed) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_INVALID_STATE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Ad already shown" forKey:NSLocalizedDescriptionKey]];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
    }
    else {
        UIViewController *root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if (!root.presentingViewController.presentedViewController) {
            _webViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [root presentViewController:_webViewController animated:YES completion: nil];
            _adPlaying = YES;
            [_webViewController callJSFunction:@"startAd"];
        } else {
            NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                                 code:TPR_ERROR_INVALID_STATE
                                             userInfo:[NSDictionary dictionaryWithObject:@"Cannot display ad while modal view controller is presented" forKey:NSLocalizedDescriptionKey]];
            [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
        }
    }
}

- (void)resetState {
    [_webViewController stopLoading];
    
    [self cancelTimer:_playerTimeoutTimer];
    _playerTimeoutTimer = nil;
    [self cancelTimer:_loadAdTimeoutTimer];
    _loadAdTimeoutTimer = nil;
    
    [_webViewController dismissViewControllerAnimated:YES completion:nil];
    
    _adLoadPending = NO;
    _adLoaded = NO;
    _adLoading = NO;
    _adDisplayed = NO;
    _adPlaying = NO;
}

- (void)removePlayer {
    _playerLoaded = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationWillResignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidBecomeActiveNotification];

    _webViewController.delegate = nil;
    _webViewController = nil;
    _playerParams = nil;
    _environment = nil;
}

#pragma mark - WebViewControllerDelegate

- (void)webViewControllerWillAppear:(TPRWebViewController*)webViewController animated:(BOOL)animated {
}

- (void)webViewControllerDidAppear:(TPRWebViewController*)webViewController animated:(BOOL)animated {
}

- (void)webViewControllerWillDisappear:(TPRWebViewController*)webViewController animated:(BOOL)animated {
}

- (void)webViewControllerDidDisappear:(TPRWebViewController*)webViewController animated:(BOOL)animated {
}

- (void)webViewControllerDidReceiveMemoryWarning:(TPRWebViewController*)webViewController {
    NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                         code:TPR_ERROR_LOW_MEMORY
                                     userInfo:[NSDictionary dictionaryWithObject:@"Low memory warning received" forKey:NSLocalizedDescriptionKey]];
    [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
}

- (void)webViewControllerDidStartLoad:(TPRWebViewController*)webViewController  {
}

- (void)webViewControllerDidFinishLoad:(TPRWebViewController*)webViewController  {
}

- (void)webViewController:(TPRWebViewController*)webViewController
     didFailLoadWithError:(NSError*)error {
    if (!_playerLoaded) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_NETWORK_FAILURE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Network failure while loading the player" forKey:NSLocalizedDescriptionKey]];
        [self resetState];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
    } else if (!_adLoaded) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_NETWORK_FAILURE
                                         userInfo:[NSDictionary dictionaryWithObject:@"Network failure while loading an ad" forKey:NSLocalizedDescriptionKey]];
        [self resetState];
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
    }
}

- (BOOL)webViewController:(TPRWebViewController *)webViewController
shouldStartLoadWithRequest:(NSURLRequest *)request
            navigationType:(UIWebViewNavigationType)navigationType {
    NSString* scheme = request.URL.scheme;
    
    if ([scheme isEqualToString:PLAYER_EVENT_CUSTOM_SCHEME] && [request.URL.host isEqualToString:PLAYER_EVENT_HOST_NAME]) {
        [self handlePlayerEvent:[self parseEvent:request.URL.query]];
    } else if (navigationType != UIWebViewNavigationTypeOther || !_adLoaded) {
        return YES;
    }
    else if ([scheme hasPrefix:@"http"]) {
        [self openURL:request.URL];
    }
    return NO;
}

#pragma mark - PrivateMethods

- (void)openURL:(NSURL*)url {
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [self sendEvent:TPR_EVENT_NAME_AD_LEFT_APPLICATION arg1:url arg2:nil arg3:nil];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)handlePlayerEvent:(TPRPlayerEvent*)event {
    NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
    if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
        _playerLoaded = YES;
        [self cancelTimer:_playerTimeoutTimer];
        _playerTimeoutTimer = nil;
        if (_adLoadPending) {
            [self loadAd];
        }
    } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
        [self cancelTimer:_loadAdTimeoutTimer];
        _loadAdTimeoutTimer = nil;
        _adLoadPending = NO;
        _adLoading = NO;
        _adLoaded = YES;
    } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED] ||
               [eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_COMPLETE] ||
               [eventName isEqualToString:TPR_EVENT_NAME_AD_SKIPPED]) {
        _adPlaying = NO;
    }
    
    [self sendEvent:event];
}

- (TPRPlayerEvent*)parseEvent:(NSString*)query {
    NSMutableDictionary* event = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray *queryItems = [query componentsSeparatedByString:@"&"];
    
    for (NSString *item in queryItems) {
        NSArray *kvp = [item componentsSeparatedByString:@"="];
        if (kvp[0] && kvp[1]) {
            NSString *value = [[kvp[1]
                                stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                               stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [event setObject:value forKey:kvp[0]];
        }
    }
    return event;
}

-(NSString *)encodeUrlString:(NSString *)string {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                     kCFAllocatorDefault,
                                                                     (__bridge CFStringRef)string,
                                                                     NULL,
                                                                     CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                     kCFStringEncodingUTF8)
                             );
}

- (NSTimer*)startTimer:(NSTimeInterval) timeout target:(SEL)selector {
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeout
                                             target:self
                                           selector:selector
                                           userInfo:nil
                                            repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

- (void)cancelTimer:(NSTimer*)timer {
    if ([timer isValid]) {
        [timer invalidate];
    }
}

- (void)timeoutOccuredOn:(NSTimer*)timer {
    NSError* error;

    if (timer == _playerTimeoutTimer) {
        error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                    code:TPR_ERROR_NETWORK_TIMEOUT
                                userInfo:[NSDictionary dictionaryWithObject:@"Timeout occured while loading the player" forKey:NSLocalizedDescriptionKey]];
    } else if (timer == _loadAdTimeoutTimer) {
        error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                    code:TPR_ERROR_NETWORK_TIMEOUT
                                userInfo:[NSDictionary dictionaryWithObject:@"Timeout occured while loading an ad" forKey:NSLocalizedDescriptionKey]];
    }
    
    [self resetState];
    
    if (error) {
        [self sendEvent:TPR_EVENT_NAME_PLAYER_ERROR arg1:error arg2:nil arg3:nil];
    }
}

- (NSString*)getAdvertisingID {
    if ([ASIdentifierManager class]) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return nil;
}

- (void)checkOrientation {
    NSString* value = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE];
    if ([value isEqualToString:TPR_VALUE_TRUE]) {
        _webViewController.orientationMask = UIInterfaceOrientationMaskLandscape;
        return;
    }
    
    value = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_FORCE_PORTRAIT];
    if ([value isEqualToString:TPR_VALUE_TRUE]) {
        _webViewController.orientationMask = UIInterfaceOrientationMaskPortrait;
    }
}

- (void)sendEvent:(NSString*)eventName arg1:(NSObject*)arg1 arg2:(NSObject*)arg2 arg3:(NSObject*)arg3  {
    TPRPlayerEvent *event = [NSMutableDictionary dictionaryWithCapacity:4];
    [event setValue:eventName forKey:TPR_EVENT_KEY_NAME];
    if (arg1) [event setValue:arg1 forKey:TPR_EVENT_KEY_ARG1];
    if (arg2) [event setValue:arg2 forKey:TPR_EVENT_KEY_ARG2];
    if (arg3) [event setValue:arg3 forKey:TPR_EVENT_KEY_ARG3];
    [self sendEvent:event];
}

- (void)sendEvent:(TPRPlayerEvent*)event {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        [[NSNotificationCenter defaultCenter] postNotificationName:TPR_PLAYER_NOTIFICATION
                                                            object:self
                                                          userInfo:event];
    });
}

@end
