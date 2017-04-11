//
//  MainViewController.h
//  ThirdpresenceAdSDKSampleApp
//
//  Created by Marko Okkonen on 25/01/17.
//  Copyright © 2017 Thirdpresence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>

@interface MainViewController : UITableViewController

@property (weak) IBOutlet UISwitch *stagingSwitch;
// Location manager for providing location data for Ad SDK
@property (strong) CLLocationManager* locationManager;

@end
