//
//  MainViewController.m
//  ThirdpresenceAdSDKSampleApp
//
//  Created by Marko Okkonen on 25/01/17.
//  Copyright © 2017 Thirdpresence. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.stagingSwitch setOn:appDelegate.useStagingServer];
    
    // Requests user's authorization to use location services
    // This is required to get mored targeted ads and therefore better revenue
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
}

- (void) dealloc {
    self.stagingSwitch = nil;
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self.stagingSwitch setOn:!self.stagingSwitch.on];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.useStagingServer = self.stagingSwitch.on;
    }
}

@end
