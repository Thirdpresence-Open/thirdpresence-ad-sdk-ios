//
//  TPRAdmobCustomEventHelper.m
//  ThirdpresenceAdmobMediation
//
//  Created by Marko Okkonen on 09/05/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "TPRAdmobCustomEventHelper.h"

#if __has_include(<ThirdpresenceAdSDK/TPRVideoAd.h>)
#import <ThirdpresenceAdSDK/TPRVideoAd.h>
#else
#import "TPRVideoAd.h"
#endif

#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation TPRAdmobCustomEventHelper

NSString *const TPR_PUBLISHER_PARAM_KEY_ACCOUNT = @"account";
NSString *const TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID = @"placementid";
NSString *const TPR_PUBLISHER_PARAM_KEY_FORCE_LANDSCAPE = @"forcelandscape";
NSString *const TPR_PUBLISHER_PARAM_KEY_FORCE_PORTRAIT = @"forceportrait";
NSString *const TPR_PUBLISHER_PARAM_REWARD_TITLE = @"rewardtitle";
NSString *const TPR_PUBLISHER_PARAM_REWARD_AMOUNT = @"rewardamount";
NSString *const TPR_PUBLISHER_PARAM_USE_INSECURE_HTTP = @"usehttp";

+ (NSDictionary*)parseParamsString:(NSString*)paramsString {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (paramsString) {
        NSArray* params = [paramsString componentsSeparatedByString:@","];
        for (NSString* param in params) {
            NSArray* kvp = [param componentsSeparatedByString:@":"];
            if ([kvp count] == 2 && kvp[0] != nil && kvp[1] != nil) {
                [dict setObject:kvp[1] forKey:kvp[0]];
            }
        }
    }
    return dict;
}

// request object can be either GADMediationAdRequest or GADCustomEventRequest
+ (NSDictionary*)createPlayerParams:(NSObject*)request {
    NSMutableDictionary* playerParams = [NSMutableDictionary dictionary];
    SEL selector = @selector(userGender);
    if ([request respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[request class] instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:request];
        [invocation invoke];
        GADGender gender;
        [invocation getReturnValue:&gender];
        
        if (gender){
                NSString *genderStr = (gender == kGADGenderMale) ? TPR_USER_GENDER_MALE : TPR_USER_GENDER_FEMALE;
        
            [playerParams setValue:genderStr forKey:TPR_PLAYER_PARAMETER_KEY_USER_GENDER];
        }
    }
    
    if ([request respondsToSelector:@selector(userBirthday)]) {
        NSDate *birthday = [request performSelector:@selector(userBirthday)];
        
        if (birthday) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy"];
            NSString *yob = [df stringFromDate:birthday];
            if (yob) {
                [playerParams setValue:yob forKey:TPR_PLAYER_PARAMETER_KEY_USER_YOB];
            }
        }
    }
    
    if ([request respondsToSelector:@selector(userKeywords)]) {
        NSArray *keywordArray = [request performSelector:@selector(userKeywords)];
        
        if (keywordArray) {
            NSString* keywords = [keywordArray componentsJoinedByString:@","];
            [playerParams setValue:keywords forKey:TPR_PLAYER_PARAMETER_KEY_KEYWORDS];
        }
    }
    return playerParams;
}

@end
