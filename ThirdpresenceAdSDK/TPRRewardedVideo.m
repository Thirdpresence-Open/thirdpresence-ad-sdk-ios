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
   
    NSString *rewardTitle = [environment valueForKey:TPR_ENVIRONMENT_KEY_REWARD_TITLE];
    NSAssert(rewardTitle != nil, @"Environment does not contain reward title key");

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *rewardAmount = [f numberFromString:[environment valueForKey:TPR_ENVIRONMENT_KEY_REWARD_AMOUNT]];
    
    NSAssert(rewardAmount != nil, @"Environment does not contain reward amount key");

    self = [super initWithPlacementType:TPR_PLACEMENT_TYPE_REWARDED_VIDEO
                            environment:environment
                                 params:playerParams
                                timeout:secs];
    
    _rewardTitle = rewardTitle;
    _rewardAmount = rewardAmount;
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
