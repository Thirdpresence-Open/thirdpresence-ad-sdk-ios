# Thirdpresence Ad SDK For iOS

Thirdpresence Ad SDK is based on an UIWebView and the Thirdpresence HTML5 player.  

It provides a VideoInterstitial ad unit implementation

## Minimum requirements

- XCode 7 or later
- Deployment target iOS 8.0 or later

## Thirdpresence AdS DK integration

There are two options to integrate the SDK:

1. Direct Integration
2. Mediation with existing SDK (e.g. MoPub)

Available mediation adapters:

- MoPub interstitial
- MoPub rewarded video
- Admob interstitial

### Adding library dependencies

There are two options to add Thirdpresence Ad SDK libraries to your XCode project:

1. Using CocoaPods
2. Copying the source code

#### Using CocoaPods

CocoaPods is a widely used dependency manager for Swift and Objective-C Cocoa projects. 
It allows easily to add third-party libraries for your project. 
See more at https://cocoapods.org/

Thirdpresence libraries are available in CocoaPods with following pods. Use one of them depending if your using SDK directly or if using via mediation.

  pod 'thirdpresence-ad-sdk-ios'
  pod 'thirdpresence-ad-sdk-ios/ThirdpresenceMopubMediation'
  pod 'thirdpresence-ad-sdk-ios/ThirdpresenceAdAdmobMediation'


#### Copying the source code

- Clone or download this Github repository to your machine
- Open XCode project of your application

- Drag and drop ThirdpresenceAdSDK folder to the Project Navigator in the XCode and add the source to required targets. Make sure to check 'Create groups' option.

- Do the same for a mediation library if using mediation. Following mediation libraries are currently available:
    - ThirdpresenceMopubMediation (MoPub interstitial and rewarded video) 
    - ThirdpresenceAdmobMediation (Admob interstitial)

- Add following frameworks to your application target:
    - AdSupport.framework


### Additional requirements

By default iOS 9.0 requires apps to make network connections over SSL. Currently all demand sources do not support SSL, which will likely to have mojor impact to fill rates. Allowing the player make non-SSL connections you shall add the following to your app plist file:
```
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

In case your application is not using ARC (Automatic Reference Counting), you must indicate to the compiler that Ad SDK files 
are built with ARC. This is done using fobjc-arc compiler flag. See more details about ARC:
https://developer.apple.com/library/mac/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW15


### Direct integration

A quick guide to start showing ads on an application. Continue reading from [Mediation section](#mediation) if you are doing mediation.

Implement TPRVideoAdDelegate interface on the class that handles showing the ad:

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

    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"<ACCOUNT_NAME>", TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        @"<PLACEMENT_ID>", TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        TPR_VALUE_TRUE, TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE, nil];

    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"<APP_NAME>", TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                         @"<APP_VERSION>",TPR_PLAYER_PARAMETER_KEY_APP_VERSION,
                                         @"<APP_STORE_URL>", TPR_PLAYER_PARAMETER_KEY_APP_STORE_URL,
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

Check out the Sample App for a reference. 

### Mediation

Using mediation adapters do not require changes in your existing code. The mediating Ad SDK will detect the existence of a mediation adapter dynamically. Make sure that your app target embeds Thirdpresence Ad SDK and mediation adapter libraries and other requirements are met. See following instruction how to add Thirdpresence ad source to the waterfall of the ad unit.

#### MoPub

- Login to the MoPub console
- Create a Fullscreen Ad or Rewarded Video Ad ad unit if not using existing one
- Add new Custom Native Network
- Set Custom Event Class and Custom Event Class Data for the ad unit with following values:

| Ad Unit | Custom Event Class | Custom Event Class Data |
| --- | --- | --- |
| Fullscreen Ad | TPRInterstitialCustomEvent | { "account":"REPLACE_ME", "placementid":"REPLACE_ME", "appname":"REPLACE_ME", "appversion":"REPLACE_ME", "appstoreurl":"REPLACE_ME"} |
| Rewarded Video | TPRRewardedVideoCustomEvent | { "account":"REPLACE_ME", "placementid":"REPLACE_ME", "appname":"REPLACE_ME", "appversion":"REPLACE_ME", "appstoreurl":"REPLACE_ME", "rewardtitle":"REPLACE_ME", "rewardamount":"REPLACE_ME"}  |

**Replace REPLACE_ME placeholders with actual values!**

- Go to Segments
- Select the segment where you want to enable the network
- Enable the network you just created and set the CPM.
- Test the integration with the MoPub sample app

#### Admob

- Login to the Admob console
- Create an Interstitial ad unit for video if not using existing one
- In the ad units list, click "x ad source(s)" link on the Mediation column of the interstitial ad unit
- Click New ad network button
- Click "+ Custom event" button
- Fill the form:

| Field | Value |
| --- | --- |
| Class Name | TPRAdmobCustomEventInterstitial |
| Label | Thirdpresence |
| Parameter | account:REPLACE_ME,placementid:REPLACE_ME |

**Replace REPLACE_ME placeholders with actual values!**

- Click Continue button
- Give eCPM for the Thirdpresence ad network
- Save changes and the integration is ready
