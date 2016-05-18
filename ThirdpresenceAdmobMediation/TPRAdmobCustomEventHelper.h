//
//  TPRAdmobCustomEventHelper.h
//  ThirdpresenceAdmobMediation
//
//  Created by Marko Okkonen on 09/05/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPRAdmobCustomEventHelper : NSObject

+ (NSDictionary*)parseParamsString:(NSString*)paramsString;

@end
