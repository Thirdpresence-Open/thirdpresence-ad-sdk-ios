//
//  ThirdpresenceAdSDKSampleAppUITests.m
//  ThirdpresenceAdSDKSampleAppUITests
//
//  Created by Marko Okkonen on 10/11/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"

NSTimeInterval const INIT_TIMEOUT = 5.0;
NSTimeInterval const LOAD_TIMEOUT = 10.0;
NSTimeInterval const DISPLAY_TIMEOUT = 35.0;

@interface ThirdpresenceAdSDKSampleAppUITests : XCTestCase {
@private
    XCUIApplication *app;
    id<NSObject> interruptionMonitor;
}
@end

@implementation ThirdpresenceAdSDKSampleAppUITests

- (void)setUp {
    [super setUp];
    
    self.continueAfterFailure = NO;
    
    app = [[XCUIApplication alloc] init];
    [app launch];

    interruptionMonitor = [self addUIInterruptionMonitorWithDescription:@"Location alert" handler:^BOOL(XCUIElement *interruptingElement) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label MATCHES 'Allow'"];
        XCUIElement *button = [[interruptingElement.buttons containingPredicate:predicate] element];
        if ([button exists]) {
            [button tap];
            return true;
        }
    
        return false;
    }];

    [app tap];
    
    // Wait for location alert to appear
    sleep(5);
    
    NSPredicate *alertPredicate = [NSPredicate predicateWithFormat:@"exists == false"];
    XCUIElement *alert = [app.alerts element];
    
    [self expectationForPredicate:alertPredicate evaluatedWithObject:alert handler:nil];
    
    [self waitForExpectationsWithTimeout:INIT_TIMEOUT handler: ^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Alerts did not disappear in time");
        }
    }];
    
    NSLog(@"setUp completed");
}

- (void)tearDown {
    [self removeUIInterruptionMonitor:interruptionMonitor];
    [super tearDown];
}

- (void)testInterstitialAd {
    [app.tables.staticTexts[@"Interstitial"] tap];
    
    sleep(1);
    
    [[[app.buttons containingPredicate:
      [NSPredicate predicateWithFormat:@"identifier MATCHES 'init_button'"]] element] tap];
    
    XCUIElement *statusField = [[app.textFields containingPredicate:
                                [NSPredicate predicateWithFormat:@"identifier MATCHES 'status_field'"]] element];
    
    [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value MATCHES 'READY'"] evaluatedWithObject: statusField handler:nil];
    
    [self waitForExpectationsWithTimeout:INIT_TIMEOUT handler: ^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Timeout while initializing");
        }
        else {
            [[[app.buttons containingPredicate:
               [NSPredicate predicateWithFormat:@"identifier MATCHES 'load_button'"]] element] tap];
            
            [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value MATCHES 'LOADED'"] evaluatedWithObject: statusField handler:nil];
            
            [self waitForExpectationsWithTimeout:LOAD_TIMEOUT handler: ^(NSError * __nullable error) {
                if (error) {
                    XCTFail(@"Timeout while loading");
                }
                else {
                    [[[app.buttons containingPredicate:
                       [NSPredicate predicateWithFormat:@"identifier MATCHES 'display_button'"]] element] tap];
                    
                    [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value IN {'COMPLETED', 'READY'}"] evaluatedWithObject: statusField handler:nil];
                    
                    [self waitForExpectationsWithTimeout:DISPLAY_TIMEOUT handler: ^(NSError * __nullable error) {
                        if (error) {
                            XCTFail(@"Timeout while displaying");
                        }
                        
                    }];
                }
            }];
        }
    }];

}


- (void)testRewardedAd {
    
    [app.tables.staticTexts[@"Rewarded video"] tap];
    
    sleep(1);
    
    [[[app.buttons containingPredicate:
       [NSPredicate predicateWithFormat:@"identifier MATCHES 'init_button'"]] element] tap];
    
    XCUIElement *statusField = [[app.textFields containingPredicate:
                                 [NSPredicate predicateWithFormat:@"identifier MATCHES 'status_field'"]] element];
    
    [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value MATCHES 'READY'"] evaluatedWithObject: statusField handler:nil];
    
    [self waitForExpectationsWithTimeout:INIT_TIMEOUT handler: ^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Timeout while initializing");
        }
        else {
            [[[app.buttons containingPredicate:
               [NSPredicate predicateWithFormat:@"identifier MATCHES 'load_button'"]] element] tap];
            
            [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value MATCHES 'LOADED'"] evaluatedWithObject: statusField handler:nil];
            
            [self waitForExpectationsWithTimeout:LOAD_TIMEOUT handler: ^(NSError * __nullable error) {
                if (error) {
                    XCTFail(@"Timeout while loading");
                }
                else {
                    [[[app.buttons containingPredicate:
                       [NSPredicate predicateWithFormat:@"identifier MATCHES 'display_button'"]] element] tap];
                    
                    [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value IN {'COMPLETED', 'READY'}"] evaluatedWithObject: statusField handler:nil];
                    
                    [self waitForExpectationsWithTimeout:DISPLAY_TIMEOUT handler: ^(NSError * __nullable error) {
                        if (error) {
                            XCTFail(@"Timeout while displaying");
                        }
                        
                        XCUIElement *rewardField = [[app.textFields containingPredicate:
                                                     [NSPredicate predicateWithFormat:@"identifier MATCHES 'reward_field'"]] element];
                        NSString *value = rewardField.value;
                        XCTAssert([value isEqualToString:@"10 diamonds"], @"Reward not equal with expected");
                        
                    }];
                }
            }];
        }
    }];
    
}

- (void)testBannerAd {
    [app.tables.staticTexts[@"Banner"] tap];
    
    sleep(1);
    
    XCUIElement *statusField = [[app.textFields containingPredicate:
                                 [NSPredicate predicateWithFormat:@"identifier MATCHES 'status_field'"]] element];
    
    [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value MATCHES 'DISPLAYING'"] evaluatedWithObject: statusField handler:nil];
    
    [self waitForExpectationsWithTimeout:LOAD_TIMEOUT handler: ^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Timeout while displaying");
        }
    }];
    

}

@end
