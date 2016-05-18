//
//  TPRAdmobCustomEventHelper.m
//  ThirdpresenceAdmobMediation
//
//  Created by Marko Okkonen on 09/05/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "TPRAdmobCustomEventHelper.h"

@implementation TPRAdmobCustomEventHelper

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
@end
