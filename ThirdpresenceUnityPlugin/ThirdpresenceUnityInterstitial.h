//
//  ThirdpresenceUnityInterstitial.h
//  ThirdpresenceUnityPlugin
//
//  Created by Marko Okkonen on 05/08/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPRVideoInterstitial.h"

@interface ThirdpresenceUnityInterstitial : NSObject <TPRVideoAdDelegate>

+ (id) sharedInterstitial;
- (void) setupPlayerWithEnvironment:(NSDictionary*)env params:(NSDictionary*)params timeout:(NSTimeInterval)timeout;
- (void) displayAd;
- (void) removePlayer;

- (void) sendErrorWithCode:(NSInteger)errorCode message:(NSString*)message;
- (void) sendEvent:(NSString*)data handler:(NSString*)func;
- (NSMutableDictionary*) convertEnvironment:(NSDictionary*)dictionary;

@property (strong) TPRVideoInterstitial* interstitial;
@property (assign) BOOL adLoaded;
@property (assign) BOOL adDisplaying;
@end
