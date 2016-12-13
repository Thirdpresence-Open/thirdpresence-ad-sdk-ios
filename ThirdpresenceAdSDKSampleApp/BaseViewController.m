//
//  BaseViewController.m
//  ThirdpresenceAdSDKSampleApp
//
//  Created by Marko Okkonen on 02/12/16.
//  Copyright © 2016 Thirdpresence. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pendingMessages = [NSMutableArray arrayWithCapacity:10];
    
    // Requests user's authorization to use location services
    // This is required to get mored targeted ads and therefore better revenue
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self showNextMessage];
}

- (void) dealloc {
    [self.pendingMessages removeAllObjects];
    self.pendingMessages = nil;
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

/**
 *  Show next queued message
 */
- (void) showNextMessage {
    if (!_showingAlert && !self.presentedViewController && [_pendingMessages count] > 0) {
        
        NSString *msgToShow = [_pendingMessages objectAtIndex:0];
        [_pendingMessages removeObjectAtIndex:0];
        
        _showingAlert = YES;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:msgToShow
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{
                    _showingAlert = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showNextMessage];
                    });
                }];
            });
            
        }];
    }
    
}

/**
 *  Queues a message for displaying
 *
 *  @param message to display
 */
- (void) queueMessage:(NSString*)message {
    if (message) {
        [_pendingMessages addObject:message];
    }
    [self showNextMessage];
}

@end
