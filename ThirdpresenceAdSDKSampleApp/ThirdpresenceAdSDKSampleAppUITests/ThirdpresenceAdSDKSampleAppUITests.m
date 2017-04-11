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
    BOOL alertHandled;
}
@end

@implementation ThirdpresenceAdSDKSampleAppUITests

- (void)setUp {
    [super setUp];

    self.continueAfterFailure = NO;
    
    app = [[XCUIApplication alloc] init];
    [app launch];

    sleep(1); // Time for animations
    
    if (!alertHandled) {

        interruptionMonitor = [self addUIInterruptionMonitorWithDescription:@"Location alert" handler:^BOOL(XCUIElement *interruptingElement) {
            sleep(1); // Time for animations
            if (interruptingElement.buttons[@"Allow"].exists) {
                [interruptingElement.buttons[@"Allow"] tap];
                alertHandled = YES;
            }
            sleep(1); // Time for animations
            return YES;

        }];

        [app tap];
        if (app.buttons[@"Allow"].exists) {
            [app.buttons[@"Allow"] tap];
            alertHandled = YES;
        }
        else {
            // wait for alert
            sleep(5);
        }
        
    }
    NSLog(@"setUp completed");
}

- (void)tearDown {
    [self removeUIInterruptionMonitor:interruptionMonitor];
    [super tearDown];
}

- (void)testInterstitialAd {
    
#if USE_STAGING_SERVER == 1
    [app.tables.staticTexts[@"Use staging server"] tap];
#endif
    
    [app.tables.staticTexts[@"Interstitial"] tap];
    
    sleep(1);
    
#if USE_STAGING_SERVER == 0
    XCUIElement *placementField = [[app.textFields containingPredicate:
                                 [NSPredicate predicateWithFormat:@"identifier MATCHES 'placement_field'"]] element];
    [placementField.buttons[@"Clear text"] tap];
    [placementField tap];
    [placementField typeText:@"5c23vpeypb"];
    
#endif
    
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
    
#if USE_STAGING_SERVER == 1
    [app.tables.staticTexts[@"Use staging server"] tap];
#endif
    
    [app.tables.staticTexts[@"Rewarded video"] tap];
  
#if USE_STAGING_SERVER == 0
    XCUIElement *placementField = [[app.textFields containingPredicate:
                                    [NSPredicate predicateWithFormat:@"identifier MATCHES 'placement_field'"]] element];
    [placementField.buttons[@"Clear text"] tap];
    [placementField tap];
    [placementField typeText:@"izqeiozlat"];
    
#endif
    
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
    
#if USE_STAGING_SERVER == 1
    [app.tables.staticTexts[@"Use staging server"] tap];
#endif
    
    [app.tables.staticTexts[@"Banner"] tap];
    

#if USE_STAGING_SERVER == 0
    XCUIElement *placementField = [[app.textFields containingPredicate:
                                    [NSPredicate predicateWithFormat:@"identifier MATCHES 'placement_field'"]] element];
    
    [placementField.buttons[@"Clear text"] tap];
    [placementField tap];
    [placementField typeText:@"p3hidjfvui"];
    
    [[[app.buttons containingPredicate:
       [NSPredicate predicateWithFormat:@"identifier MATCHES 'reload_button'"]] element] tap];
    
#endif
    
    sleep(1);
    
    XCUIElement *statusField = [[app.textFields containingPredicate:
                                 [NSPredicate predicateWithFormat:@"identifier MATCHES 'status_field'"]] element];
    
    [self expectationForPredicate:[NSPredicate predicateWithFormat:@"value MATCHES 'DISPLAYING'"] evaluatedWithObject: statusField handler:nil];
    
    [self waitForExpectationsWithTimeout:INIT_TIMEOUT + LOAD_TIMEOUT handler: ^(NSError * __nullable error) {
        if (error) {
            XCTFail(@"Timeout while displaying");
        }
    }];
    

}

@end
