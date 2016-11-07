# Thirdpresence Ad SDK For iOS

Thirdpresence Ad SDK provides an API to display interstitial and rewarded video ads in an application.

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
    - ThirdpresenceMopubMediation (MoPub interstitial and rewarded video) 
    - ThirdpresenceAdmobMediation (Admob interstitial)

## Additional requirements

Enable the frameworks below to your application target:
- AdSupport.framework
- CoreLocation.framework (optional, but highly recommended for enabling more targeted ads)

By default, iOS 9.0 requires apps to establish network connections over SSL. Currently, all demand sources do not support SSL, which is likely to have a major impact to fill rates. To allow the player to establish non-SSL connections, add the following to your app plist file:
```
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

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

Before initialising Thirdpresence ad unit, the application shall request the user to enable location services:

```
self.locationManager = [[CLLocationManager alloc] init];
[self.locationManager requestWhenInUseAuthorization];
[self.locationManager startUpdatingLocation];
```

### Integration

With these instructions, you can start displaying ads on an application without using mediation plugins. 

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
				// Displaying ad stopped
				// Close and reset the interstitial
				[self.interstitial reset];
			}
		}
	}
```

Instantiate and setup the ad unit:
```

    // The environment dictionary is mandatory to pass the SDK the account and placement id.
    // For testing purposes you can use the account name "sdk-demo" and placementid "sa7nvltbrn".
    // Contact to Thirdpresence get your own.
    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"<ACCOUNT_NAME>", TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        @"<PLACEMENT_ID>", TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        TPR_VALUE_TRUE, TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE, nil];

    // With the playerParams dictionary you can pass data about the application for advertisers.
    // The application's bundle id is determined automatically.
    // In order to get more targeted ads the user's gender and year of birth are recommended.
    // You can get the data, for example, from Facebook Graph API if you have integrated with Facekbook.
    // https://developers.facebook.com/docs/graph-api/reference/v2.6/user

    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"<APP_NAME>", TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                         @"<APP_VERSION>",TPR_PLAYER_PARAMETER_KEY_APP_VERSION,
                                         @"<APP_STORE_URL>", TPR_PLAYER_PARAMETER_KEY_APP_STORE_URL,
                                         @"<USER_GENDER>", TPR_PLAYER_PARAMETER_KEY_USER_GENDER,
                                         @"<USER_YEAR_OF_BIRTH>", TPR_PLAYER_PARAMETER_KEY_USER_YOB,
                                         nil];
                                         
    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment params:playerParams];
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
Close the ad unit and clean up:
```
	[self.interstitial removePlayer];
	self.interstitial.delegate = nil;
	self.interstitial = nil;
```

Check out the Sample App for a complete reference. 

