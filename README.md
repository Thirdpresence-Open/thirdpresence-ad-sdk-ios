# Thirdpresence Ad SDK For iOS

Thirdpresence Ad SDK is based on an UIWebView and the Thirdpresence HTML5 player.  

It provides a VideoInterstitial ad unit implementation

## Minimum requirements

- XCode 7 or later
- Deployment target iOS 8.0 or later

## Integration to an application

There are two options to integrate the SDK:

1. Direct Integration
2. Mediation with existing SDK (e.g. MoPub)

Available mediation plugins:

- MoPub interstitial
- MoPub rewarded video

### Adding library dependencies

#### Using CocoaPods
 
TODO

#### Manually building the SDK

- Open XCode project of your application 

Add the following to your app plist in order allow use http URLs. Currently all the demand source do not support HTTPS
and therefore may impact to fill rates:
```
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
```

- Drag and drop ThirdpresenceAdSDK.xcodeproj file to the XCode Project Navigator
- Select tha application project in the Project Navigator
- In the General tab, add ThirdpresenceAdSDK.framework for to the Embedded Libraries

Do the same for mediation libraries. Following mediation libraries are currently available:

- Mopub (Interstitial and Rewarded Video)
    Project: ThirdpresenceMopubMediation.xcodeproj
    Framework: ThirdpresenceMopubMediation.framework

Note: if your application is not using ARC (Automatic Reference Counting), you must indicate to the compiler that Ad SDK files 
are built with ARC. This is done using fobjc-arc compiler flag. See more details about ARC:
https://developer.apple.com/library/mac/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW15

### Direct integration:

A quick guide to start showing ads on an application:

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

### MoPub mediation:

- Login to the MoPub console
- Create a Fullscreen Ad or Rewarded Video Ad ad unit
- Add new Custom Native Network
- Set Custom Event Class and Custom Event Class Data for the ad unit with following values:

| Ad Unit | Custom Event Class | Custom Event Class Data |
| --- | --- | --- |
| Fullscreen Ad | TPRInterstitialCustomEvent | { "account":"REPLACE_ME", "playerid":"REPLACE_ME", "appname":"REPLACE_ME", "appversion":"REPLACE_ME", "appstoreurl":"REPLACE_ME", "skipoffset":"REPLACE_ME"} |
| Rewarded Video | TPRRewardedVideoCustomEvent | { "account":"REPLACE_ME", "playerid":"REPLACE_ME", "appname":"REPLACE_ME", "appversion":"REPLACE_ME", "appstoreurl":"REPLACE_ME", "rewardtitle":"REPLACE_ME", "rewardamount":"REPLACE_ME"}  |

Replace placeholders with the actual data.

- Go to Segments
- Select the segment where you want to enable the network
- Enable the network you just created and set the CPM.
- Test the integration with the MoPub sample app


