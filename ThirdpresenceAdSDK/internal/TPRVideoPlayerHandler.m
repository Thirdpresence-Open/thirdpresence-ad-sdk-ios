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
#import <CoreLocation/CLLocationManager.h>
#import <TRDPMoatMobileAppKit/TRDPMoatAnalytics.h>
#import <AVFoundation/AVFoundation.h>

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
- (NSString*)getAdvertisingID;
- (void)updateVolume;
- (void)initLocationServices;
- (CLLocation*)getLastKnownLocation;
- (void)updateLocationToPlayer;
- (void)startAdTrackingAnalytics;
- (void)createAdTrackers;
- (void)startAdTracking;
- (void)stopAdTracking;

@property (strong) TRDPMoatWebTracker *moatWebTracker;
@property (strong, readonly) CLLocationManager* locationManager;
@property (strong) TPRPlacementType* placementType;
@property (strong) AVAudioSession* avSession;
@end

@implementation TPRVideoPlayerHandler

NSString *const PLAYER_URL_BASE = @"%@//d1c13tt6n7tja5.cloudfront.net/tags/%@/sdk/LATEST/sdk_player.v3.html?env=%@&cid=%@&playerid=%@&adsdk=%@&type=%@&customization=%@&adverification=%@";

NSString *const TPR_PLAYER_NOTIFICATION = @"TPRPlayerNotification";
NSString *const PLAYER_EVENT_CUSTOM_SCHEME = @"thirdpresence";
NSString *const PLAYER_EVENT_HOST_NAME = @"onPlayerEvent";

NSInteger const LOCATION_DISTANCE_FILTER = 1000;
NSTimeInterval const LOCATION_EXPIRATION_LIMIT = 3600;

NSString *const AD_VERIFICATION_TYPE_MOAT = @"moat";

static void *VolumeObserverContext = &VolumeObserverContext;

- (instancetype)initWithPlayer:(TPRWebView *)webView
                   environment:(NSDictionary *)environment
                        params:(NSDictionary *)playerParams
                 placementType:(TPRPlacementType*)placementType{
    self = [super init];

    _webView = webView;
    _environment = environment;
    _playerParams = playerParams;
    _placementType = placementType;
    
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
    
    _avSession = [AVAudioSession sharedInstance];
    [_avSession addObserver:self
                 forKeyPath:@"outputVolume"
                    options:NSKeyValueObservingOptionNew
                    context:VolumeObserverContext];
    
    _webView.delegate = self;
    
    [self startAdTrackingAnalytics];
    [self initLocationServices];

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
        [_webView startAd];
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
    
    NSString* versionString = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_SDK_VERSION];
    
    if (!versionString) {
        NSBundle* libBundle = [NSBundle bundleWithIdentifier:@"com.thirdpresence.ThirdpresenceAdSDK"];
        versionString = [libBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
    
    if (!versionString) {
        // If CocoaPods used the plist file is in the main bundle
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThirdpresenceAdSDK-Info" ofType:@"plist"]];
    
        versionString = [dictionary objectForKey:@"CFBundleShortVersionString"];
    }
    
    NSString *extSdkName = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_EXT_SDK];
    if (extSdkName) {
        NSString *extSdkVer = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_EXT_SDK_VERSION];
        if (!extSdkVer) {
            extSdkVer = @"";
        }
        versionString = [NSString stringWithFormat:@"%@,%@,%@", versionString, extSdkName, extSdkVer];
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
    
    NSBundle *appBundle = [NSBundle mainBundle];
    NSString *appName = [appBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [appBundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    if (appName) {
        if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_APP_NAME]) {
            [params setValue:appName forKey:TPR_PLAYER_PARAMETER_KEY_APP_NAME];
        }
    
        if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_APP_VERSION]) {
            NSString *version = [appBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
            if (version) {
                [params setValue:version forKey:TPR_PLAYER_PARAMETER_KEY_APP_VERSION];
            }
        }
        
        if (![params objectForKey:TPR_PLAYER_PARAMETER_KEY_PUBLISHER]) {
            [params setValue:appName forKey:TPR_PLAYER_PARAMETER_KEY_PUBLISHER];
        }
    }
    
    CLLocation* location = [self getLastKnownLocation];
    if (location) {
        CLLocationDegrees latitude = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        TPRLog(@"[TPR] Location available %f,%f", latitude, longitude);
        
        [params setValue:[NSString stringWithFormat:@"%f", latitude] forKey:TPR_PLAYER_PARAMETER_KEY_GEO_LAT];
        [params setValue:[NSString stringWithFormat:@"%f", longitude] forKey:TPR_PLAYER_PARAMETER_KEY_GEO_LON];
    } else {
        TPRLog(@"[TPR] Location data not available");
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
    
    NSString *useHTTP = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP];
    NSString *protocol = [useHTTP isEqualToString:TPR_VALUE_TRUE] ? @"http:" : @"https:";
   
    NSString* enableMoat = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_MOAT_AD_TRACKING];
    
    _playerPageURL = [NSString stringWithFormat:PLAYER_URL_BASE,
                      protocol,
                      env,
                      env,
                      account,
                      placementId,
                      versionString,
                      _placementType,
                      customization ? [self encodeUrlString:customization] : @"",
                      [enableMoat isEqualToString:TPR_VALUE_FALSE] ? @"" : AD_VERIFICATION_TYPE_MOAT
                     ];
    
    _playerTimeoutTimer = [self startTimer:_playerTimeout target:@selector(timeoutOccuredOn:)];
    
    TPRLog(@"Loading player from URL: %@", _playerPageURL);
    
    [_webView prepare:_playerPageURL];
    
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
            [self createAdTrackers];
            _loadAdTimeoutTimer = [self startTimer:_loadAdTimeout target:@selector(timeoutOccuredOn:)];
            [_webView loadAd];
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
        [self startAdTracking];
        [self updateVolume];
        [_webView startAd];
        _adPlaying = YES;
    }
}

- (void)resetState {
    [self stopAdTracking];
    
    [_webView reset];
    
    [self cancelTimer:_playerTimeoutTimer];
    _playerTimeoutTimer = nil;
    [self cancelTimer:_loadAdTimeoutTimer];
    _loadAdTimeoutTimer = nil;
    
    _adLoadPending = NO;
    _adLoaded = NO;
    _adLoading = NO;
    _adDisplayed = NO;
    _adPlaying = NO;
}

- (void)removePlayer {
    _playerLoading = NO;
    _playerLoaded = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _webView.delegate = nil;
    _webView = nil;
    
    
    [_avSession removeObserver:self
                    forKeyPath:@"outputVolume"
                       context:VolumeObserverContext];
    _avSession = nil;
    
    [_locationManager  stopMonitoringSignificantLocationChanges];
    _locationManager.delegate = nil;
    _locationManager = nil;
    
    _playerParams = nil;
    _environment = nil;
    _playerPageURL = nil;
    _placementType = nil;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!_playerLoaded) {
        _playerLoading = NO;
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* scheme = request.URL.scheme;
    
    if ([scheme isEqualToString:PLAYER_EVENT_CUSTOM_SCHEME] && [request.URL.host isEqualToString:PLAYER_EVENT_HOST_NAME]) {
        [self handlePlayerEvent:[self parseEvent:request.URL.query]];
    } else if ((navigationType != UIWebViewNavigationTypeOther && navigationType != UIWebViewNavigationTypeLinkClicked) || !_adLoaded) {
        return YES;
    }
    else {
        BOOL click = ![_playerPageURL isEqualToString:[request.mainDocumentURL absoluteString]];
        if (click) {
            if ([scheme hasPrefix:@"http"]) {
                [self openURL:request.URL];
            }
        }
    }
    return NO;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (howRecent < LOCATION_EXPIRATION_LIMIT) {
        TPRLog(@"Stop updating location");
        [_locationManager stopUpdatingLocation];
    }
    
    if (_locationTimeStamp == nil || [_locationTimeStamp compare:eventDate] == NSOrderedAscending) {
        TPRLog(@"[TPR] Location updated %f,%f", location.coordinate.latitude, location.coordinate.longitude);
        if (_playerLoading) {
            _playerLocationUpdatePending = YES;
        }
        else if (_playerLoaded) {
            [self updateLocationToPlayer];
        }
    }
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
        _playerLoading = NO;
        _playerLoaded = YES;
        [self cancelTimer:_playerTimeoutTimer];
        _playerTimeoutTimer = nil;
        if (_playerLocationUpdatePending) {
            [self updateLocationToPlayer];
        }
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

- (void)updateVolume {
    if (_avSession) {
        float volume = [_avSession outputVolume];
        [_webView updateVolume:volume];
    }
}

- (void)initLocationServices {
    if ([CLLocationManager class] && [CLLocationManager authorizationStatus] >= kCLAuthorizationStatusAuthorizedAlways) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = (TPRVideoPlayerHandler<CLLocationManagerDelegate>*)self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.distanceFilter = LOCATION_DISTANCE_FILTER;
        CLLocation* location = [self getLastKnownLocation];
        NSDate *expiration = [NSDate dateWithTimeIntervalSinceNow:-LOCATION_EXPIRATION_LIMIT];
        if (location == nil || [location.timestamp compare:expiration] == NSOrderedAscending) {
            // Start location updates if most recent update older than the expiration limit
            TPRLog(@"Start to updating location");
            [_locationManager startUpdatingLocation];
        }
    }
}

- (CLLocation*)getLastKnownLocation {
    if ([CLLocationManager class]) {
        CLLocation* lastKnownLocation = nil;
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] >= kCLAuthorizationStatusAuthorizedAlways) {
            lastKnownLocation = [_locationManager location];
            _locationTimeStamp = lastKnownLocation.timestamp;
        }
        return lastKnownLocation;
    }
    return nil;
}

- (void)updateLocationToPlayer {
    if ([CLLocationManager class]) {
        CLLocation* location = [self getLastKnownLocation];
        if (location) {
            [_webView updateLocationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        }
    }
}

- (void)startAdTrackingAnalytics {
    NSString* enableMoat = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_MOAT_AD_TRACKING];
    if (![enableMoat isEqualToString:TPR_VALUE_FALSE]) {
        TRDPMoatOptions *options = [[TRDPMoatOptions alloc] init];
#ifdef DEBUG
        options.debugLoggingEnabled = true;
#endif
        [[TRDPMoatAnalytics sharedInstance] startWithOptions:options];
    }
}

- (void)createAdTrackers {
    NSString* enableMoat = [self.environment objectForKey:TPR_ENVIRONMENT_KEY_MOAT_AD_TRACKING];
    if (!enableMoat || [enableMoat isEqualToString:TPR_VALUE_TRUE]) {
        self.moatWebTracker = [TRDPMoatWebTracker trackerWithWebComponent:_webView];
        TPRLog(@"[TPR] MOAT ad tracker enabled");
    } else {
        TPRLog(@"[TPR] MOAT SDK not available");
    }
}

- (void)startAdTracking {
    if (self.moatWebTracker) {
        [self.moatWebTracker startTracking];
    }
}

- (void)stopAdTracking {
    if (self.moatWebTracker) {
        [self.moatWebTracker stopTracking];
        self.moatWebTracker = nil;
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == VolumeObserverContext) {
        [self updateVolume];
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

@end
