//
//  TPRRewardedVideo.m
//  ThirdpresenceAdSDK
//
//  Created by Marko Okkonen on 20/04/16.
//  Copyright © 2016 Marko Okkonen. All rights reserved.
//

#import "TPRRewardedVideo.h"
#import "TPRVideoPlayerHandler.h"
#import "ThirdpresenceAdSDK.h"

@implementation TPRRewardedVideo

- (instancetype)initWithEnvironment:(NSDictionary *)environment
                             params:(NSDictionary *)playerParams
                            timeout:(NSTimeInterval)secs {
    
    TPRLog(@"[TPR] Initialising rewarded video");
   
    NSAssert([environment valueForKey:TPR_ENVIRONMENT_KEY_REWARD_TITLE] != nil, @"Environment does not contain reward title key");

    NSAssert([environment valueForKey:TPR_ENVIRONMENT_KEY_REWARD_AMOUNT] != nil, @"Environment does not contain reward amount key");

    self = [super initWithPlacementType:TPR_PLACEMENT_TYPE_REWARDED_VIDEO
                            environment:environment
                                 params:playerParams
                                timeout:secs];
    

    return self;
}

- (void)dealloc {
}
    
- (void)loadAd {
    [super loadAd];
}

- (void)displayAd {
    [super displayAd];
}

- (void)reset {
    [super reset];
}

- (void)removePlayer {
    [super removePlayer];
}

@end
