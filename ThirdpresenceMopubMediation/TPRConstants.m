//
//  TPRConstants.m
//  ThirdpresenceMopubMediation
//
//  Created by Marko Okkonen on 23/08/16.
//  Copyright © 2016 thirdpresence. All rights reserved.
//

#import "TPRConstants.h"

#if __has_include(<ThirdpresenceAdSDK/TPRVideoAd.h>)
#import <ThirdpresenceAdSDK/TPRVideoAd.h>
#else
#import "TPRVideoAd.h"
#endif

NSString *const TPR_MP_PUB_PARAM_ACCOUNT = @"account";
NSString *const TPR_MP_PUB_PARAM_PLACEMENT_ID = @"placementid";

NSString *const TPR_MP_TARGETING_PARAM_YOB = @"yob";
NSString *const TPR_MP_TARGETING_PARAM_GENDER = @"gender";
NSString *const TPR_MP_TARGETING_PARAM_KEYWORDS = @"keywords";
