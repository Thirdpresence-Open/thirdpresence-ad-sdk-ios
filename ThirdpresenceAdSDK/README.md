# Thirdpresence Ad SDK For iOS

Thirdpresence Ad SDK provides an API to display video banner, interstitial and rewarded video ads in an application.

## Minimum requirements

- XCode 7 or later
- Deployment target iOS 8.0 or later

## Adding library dependencies

There are two options to add Thirdpresence Ad SDK libraries to your XCode project:

1. Using CocoaPods
2. Copying the source code

### Using CocoaPods

CocoaPods is a widely used dependency manager for Swift and Objective-C Cocoa projects. It enables easy addition of third-party libraries to your project. For more information, see https://cocoapods.org/

Thirdpresence libraries are available in CocoaPods with the following pods. Get the base SDK and, additionally if needed, one of the mediation plugins.

```
// Base SDK
pod 'thirdpresence-ad-sdk-ios'

// Mopub mediation plugin
pod 'thirdpresence-ad-sdk-ios/ThirdpresenceMopubMediation'

// Admob mediation plugin
pod 'thirdpresence-ad-sdk-ios/ThirdpresenceAdAdmobMediation'
```

### Copying the source code

- Clone or download this Github repository to your computer.

- Open the XCode application project.

- Drag and drop the ThirdpresenceAdSDK folder to the Project Navigator in the XCode, and add the source to the required targets. Make sure to check the 'Create groups' option.

- Do the same for a mediation library if you use mediation. The mediation libraries below are currently available:
    - ThirdpresenceMopubMediation
    - ThirdpresenceAdmobMediation 

## Additional requirements

Enable the frameworks below to your application target:
- AdSupport.framework
- CoreLocation.framework (optional, but highly recommended for enabling more targeted ads)

From January 2017 Apple App Review requires App Transport Security (ATS) to be used. Therefore Thirdpresence SDK uses Secure HTTP by default (since version 1.4.1). 

If your application does not use ARC (Automatic Reference Counting), you must indicate to the compiler that the Ad SDK files 
are built with ARC. This is done by using the fobjc-arc compiler flag. For more details on the ARC, see
https://developer.apple.com/library/mac/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW15

It is recommended to enable Location Services for better ad targeting and higher revenue.
Define the keys below in the app's info.plist file.
NSLocationUsageDescription and NSLocationWhenInUseUsageDescription describe the user reasoning why they shall grant permission for location services.
```
<key>UIRequiredDeviceCapabilities</key>
<array>
<string>location-services</string>
</array>
<key>NSLocationUsageDescription</key>
<string>Location services are used for ads targeting</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location services are used for ads targeting</string>
```

Before initialising Thirdpresence ad placement, the application shall request the user to enable location services:

```
self.locationManager = [[CLLocationManager alloc] init];
[self.locationManager requestWhenInUseAuthorization];
[self.locationManager startUpdatingLocation];
```

### Integration

With these instructions, you can start displaying ads on an application without using mediation plugins. 

Check out the Sample App for a complete reference. 

#### Intersitial 

There are three methods to be called in order to display interstitial ad: initWithEnvironment, loadAd and displayAd. The ad placement is closed by calling reset or completely removed by calling removePlayer.

Implement the TPRVideoAdDelegate interface on the class that handles displaying the ad:

ViewController.h:

```
#import <ThirdpresenceAdSDK/ThirdpresenceAdSDK.h>

@interface ViewController : UIViewController <TPRVideoAdDelegate>

...

@property (strong) TPRVideoInterstitial *interstitial;

@end
```

ViewController.m:
```
	- (void) videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
		if (videoAd == self.interstitial) {
			NSLog(@"VideoAd failed: %@", error.localizedDescription);
			// Handle the error
		}
	}


	- (void) videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
		if (videoAd == self.interstitial) {
			NSLog(@"VideoAd event: %@", event);
		
			NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
			if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
			   // The player is ready for loading ads
			} else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
				// An ad is loaded
				_adLoaded = YES;
			} else if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
				// Failed displaying the loaded ad
			} else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
				// Displaying the ad stopped
				// Close and reset the interstitial
				[self.interstitial reset];
			}
		}
	}
```

Instantiate and setup the ad placement:
```

    // The environment dictionary is mandatory to pass the SDK the account and placement id.
    // For testing purposes you can use the account name "sdk-demo" and placementid "nhdfxqclej".
    // Contact to Thirdpresence get your own.
    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"<ACCOUNT_NAME>", TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        @"<PLACEMENT_ID>", TPR_ENVIRONMENT_KEY_PLACEMENT_ID, nil];

    // With the playerParams dictionary you can pass data about the application for advertisers.
    // The application's bundle id is determined automatically.
    // In order to get more targeted ads the user's gender and year of birth are recommended.
    // You can get the data, for example, from Facebook Graph API if you have integrated with Facekbook.
    // https://developers.facebook.com/docs/graph-api/reference/v2.6/user

    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"<APP_NAME>", TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                         @"<USER_GENDER>", TPR_PLAYER_PARAMETER_KEY_USER_GENDER,
                                         @"<USER_YEAR_OF_BIRTH>", TPR_PLAYER_PARAMETER_KEY_USER_YOB,
                                         nil];
                                         
    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment 
                                                                   params:playerParams
                                                                  timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    self.interstitial.delegate = self;                                     
                                         
```        
Load an ad:
```        
	if (self.interstitial.ready) {
        [self.interstitial loadAd];
    } 
```
Display the ad:
```
	if (_adLoaded) {
         [self.interstitial displayAd];
    }
```
Close the ad placement and clean up:
```
	[self.interstitial removePlayer];
	self.interstitial.delegate = nil;
	self.interstitial = nil;
```

#### Rewarded video

There are three methods to be called in order to display interstitial ad: initWithEnvironment, loadAd and displayAd. The ad placement is closed by calling reset or completely removed by calling removePlayer.

Implement the TPRVideoAdDelegate interface on the class that handles displaying the ad:

ViewController.h:

```
#import <ThirdpresenceAdSDK/ThirdpresenceAdSDK.h>

@interface ViewController : UIViewController <TPRVideoAdDelegate>

...

@property (strong) TPRRewardedVideo *rewardedVideo;

@end
```

ViewController.m:
```
    - (void) videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error {
        if (videoAd == self.rewardedVideo) {
            NSLog(@"VideoAd failed: %@", error.localizedDescription);
            // Handle the error
        }
    }


    - (void) videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event {
        if (videoAd == self.rewardedVideo) {
            NSLog(@"VideoAd event: %@", event);

            NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
            if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
                // The player is ready for loading ads
            } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
                // An ad is loaded
                _adLoaded = YES;
            } else if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
                // Failed displaying the loaded ad
            } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
                // Displaying the ad stopped
                // Close and reset the interstitial
                [self.rewardedVideo reset];
            } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_COMPLETE]) {
                // Reward based on video complete
                NSLog(@"Reward: %@ %@", self.rewardedVideo.rewardAmount, self.rewardedVideo.rewardTitle);
            }
        }
    }
```

Instantiate and setup the ad placement:
```

    // The environment dictionary is mandatory to pass the SDK the account and placement id.
    // For testing purposes you can use the account name "sdk-demo" and placementid "sa7nvltbrn".
    // Contact to Thirdpresence get your own.
    //
    // It is also mandotory to set values for TPR_ENVIRONMENT_KEY_REWARD_TITLE and
    // TPR_ENVIRONMENT_KEY_REWARD_AMOUNT keys.
    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"<ACCOUNT_NAME>", TPR_ENVIRONMENT_KEY_ACCOUNT,
                                    @"<PLACEMENT_ID>", TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                    @"my-money", TPR_ENVIRONMENT_KEY_REWARD_TITLE,
                                    @"10", TPR_ENVIRONMENT_KEY_REWARD_AMOUNT, nil];

    // With the playerParams dictionary you can pass data about the application for advertisers.
    // The application's bundle id is determined automatically.
    // In order to get more targeted ads the user's gender and year of birth are recommended.
    // You can get the data, for example, from Facebook Graph API if you have integrated with Facekbook.
    // https://developers.facebook.com/docs/graph-api/reference/v2.6/user

    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"<APP_NAME>", TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                    @"<USER_GENDER>", TPR_PLAYER_PARAMETER_KEY_USER_GENDER,
                                    @"<USER_YEAR_OF_BIRTH>", TPR_PLAYER_PARAMETER_KEY_USER_YOB, nil];

    self.rewardedVideo = [[TPRRewardedVideo alloc] initWithEnvironment:environment 
                                                                params:playerParams
                                                               timeout:TPR_PLAYER_DEFAULT_TIMEOUT];
    self.rewardedVideo.delegate = self;                                     

```        
Load an ad:
```        
    if (self.rewardedVideo.ready) {
        [self.rewardedVideo loadAd];
    } 
```
Display the ad:
```
    if (_adLoaded) {
        [self.rewardedVideo displayAd];
    }
```
Close the ad placement and clean up:
```
    [self.rewardedVideo removePlayer];
    self.rewardedVideo.delegate = nil;
    self.rewardedVideo = nil;
```


#### Video banner

Following steps are required in order to display a video banner. This example assumes the TPRBannerView is instantiated from XIB. Alternatively it can be done programatically. 

In the Interface Builder, drag a View type of object from the Object Library to your View Controller to the position where the banner is going to be displayed. Type the class name TPRBannerView to the Class field in the Identity Inspector. Set size of the view according the desired size of the banner.

Add an outlet for the banner view in header file of the view controller and connect the outlet to the banner view in the Interface Builder.

ViewController.h:

```
#import <ThirdpresenceAdSDK/ThirdpresenceAdSDK.h>

@interface ViewController : UIViewController

...

@property(weak) IBOutlet TPRBannerView *bannerView;
@property(strong) TPRVideoBanner *banner;

```

Instantiate and setup the banner placement:

ViewController.m:
```

- (void)viewDidLoad {
    [super viewDidLoad];

    // Your own setup code here

    // The video banner setup

    // The environment dictionary is mandatory to pass the SDK the account and placement id.
    // For testing purposes you can use the account name "sdk-demo" and placementid "zhlwlm9280".
    // Contact to Thirdpresence get your own.
    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"<ACCOUNT_NAME>", TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        @"<PLACEMENT_ID>", TPR_ENVIRONMENT_KEY_PLACEMENT_ID, nil];

    // With the playerParams dictionary you can pass data about the application for advertisers.
    // The application's bundle id is determined automatically.
    // In order to get more targeted ads the user's gender and year of birth are recommended.
    // You can get the data, for example, from Facebook Graph API if you have integrated with Facekbook.
    // https://developers.facebook.com/docs/graph-api/reference/v2.6/user

    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"<APP_NAME>", TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                        @"<USER_GENDER>", TPR_PLAYER_PARAMETER_KEY_USER_GENDER,
                                        @"<USER_YEAR_OF_BIRTH>", TPR_PLAYER_PARAMETER_KEY_USER_YOB,nil];

    self.banner = [[TPRVideoBanner alloc] initWithBannerView:self.bannerView
                                                 environment:environment 
                                                      params:playerParams
                                                     timeout:TPR_PLAYER_DEFAULT_TIMEOUT];           

    [self.banner loadAd];

```        

Finally clean up when the view controller is deallocated.
```
    - (void)dealloc {
        [self.banner removePlayer];
        self.banner = nil;
        self.bannerView = nil
    }
```

In case the banner view is in an UIScrollView or similar where it might be not visible at the time the view is loaded then the ad should not be displayed before the view is actually visible. By default the ad is displayed automatically right after it is loaded. Set property disableAutoDisplay in TPRVideoBanner to true and implement TPRVideoAdDelegate protocol. See the SampleApp for detailed example.



### API reference

See Thirdpresence Ad SDK [API Reference](https://thirdpresence-ad-tags.s3.amazonaws.com/sdk/javadoc/ios/1.5.2/index.html)
