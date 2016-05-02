//
//  TPRInterstitialCustomEvent.h
//  ThirdpresenceMopubMediation
//
//  Created by Marko Okkonen on 28/04/16.
//  Copyright © 2016 thirdpresence. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#else
#import "MPInterstitialCustomEvent.h"
#endif

@interface TPRInterstitialCustomEvent : MPInterstitialCustomEvent
@end
