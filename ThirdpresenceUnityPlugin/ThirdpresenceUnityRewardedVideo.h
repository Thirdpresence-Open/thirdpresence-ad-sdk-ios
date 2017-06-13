//
//  ThirdpresenceUnityRewardedVideo.h
//  ThirdpresenceUnityPlugin
//
//  Created by Marko Okkonen on 09/08/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPRRewardedVideo.h"

@interface ThirdpresenceUnityRewardedVideo : NSObject <TPRVideoAdDelegate>

+ (id) sharedRewardedVideo;
- (void) setupPlayerWithEnvironment:(NSDictionary*)env params:(NSDictionary*)params timeout:(NSTimeInterval)timeout;
- (void) displayAd;
- (void) removePlayer;

- (void) sendErrorWithCode:(NSInteger)errorCode message:(NSString*)message;
- (void) sendEvent:(NSString*)data handler:(NSString*)func;
- (NSMutableDictionary*) convertEnvironment:(NSDictionary*)dictionary;

@property (strong) TPRRewardedVideo* rewardedVideo;
@property (assign) BOOL adLoaded;
@property (assign) BOOL adDisplaying;
@property (strong) NSString* rewardTitle;
@property (assign) NSString* rewardAmount;
@end
