//
//  TPRAdmobCustomEventHelper.h
//  ThirdpresenceAdmobMediation
//
//  Created by Marko Okkonen on 09/05/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GADCustomEventRequest;

FOUNDATION_EXPORT NSString *const TPR_PUBLISHER_PARAM_KEY_ACCOUNT;
FOUNDATION_EXPORT NSString *const TPR_PUBLISHER_PARAM_KEY_PLACEMENT_ID;
FOUNDATION_EXPORT NSString *const TPR_PUBLISHER_PARAM_KEY_FORCE_LANDSCAPE;
FOUNDATION_EXPORT NSString *const TPR_PUBLISHER_PARAM_KEY_FORCE_PORTRAIT;
FOUNDATION_EXPORT NSString *const TPR_PUBLISHER_PARAM_REWARD_TITLE;
FOUNDATION_EXPORT NSString *const TPR_PUBLISHER_PARAM_REWARD_AMOUNT;
FOUNDATION_EXPORT NSString *const TPR_PUBLISHER_PARAM_USE_INSECURE_HTTP;

@interface TPRAdmobCustomEventHelper : NSObject

+ (NSDictionary*)parseParamsString:(NSString*)paramsString;
+ (NSDictionary*)createPlayerParams:(NSObject*)request;

@end
