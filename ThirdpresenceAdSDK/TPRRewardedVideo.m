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
    
    self = [super initWithPlacementType:TPR_PLACEMENT_TYPE_REWARDED_VIDEO
                            environment:environment
                                 params:playerParams
                                timeout:secs];
    
    if ([self.playerHandler.playerParams valueForKey:TPR_PLAYER_PARAMETER_KEY_REWARD_TITLE] == nil) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Player Parameter for reward title is not set" forKey:NSLocalizedDescriptionKey]];
       
        [self.delegate videoAd:self failed:error];
    } else if ([self.playerHandler.playerParams valueForKey:TPR_PLAYER_PARAMETER_KEY_REWARD_AMOUNT] == nil) {
        NSError* error = [NSError errorWithDomain:TPR_AD_SDK_ERROR_DOMAIN
                                             code:TPR_ERROR_PLAYER_INIT_FAILED
                                         userInfo:[NSDictionary dictionaryWithObject:@"Player Parameter for reward amount is not set" forKey:NSLocalizedDescriptionKey]];
       
        [self.delegate videoAd:self failed:error];
    }
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
