# Thirdpresence Ad SDK For iOS

Thirdpresence Ad SDK is based on a WebView and the Thirdpresence HTML5 player.  

It provides implementations for an interstitial video and rewarded video ad units.

## Minimum requirements

- XCode 7 or later
- Deployment target iOS 8.0 or later

## Thirdpresence AdS DK integration

There are two different ways to integrate the SDK with your app:

1. Direct Integration
2. Plugin for Mopub or Admob mediation (rewarded video not yet available from Admob)

In all cases, you will need to download the appropriate SDK/plugin, add it to your app project and compile a new version of the app.

### Adding library dependencies

There are two options to add Thirdpresence Ad SDK libraries to your XCode project:

1. Using CocoaPods
2. Copying the source code

#### Using CocoaPods

CocoaPods is a widely used dependency manager for Swift and Objective-C Cocoa projects. 
It allows easily to add third-party libraries for your project. 
See more at https://cocoapods.org/

Thirdpresence libraries are available in CocoaPods with following pods. Get the base SDK and additionally one of the mediation plugins if needed.

```
// Base SDK
pod 'thirdpresence-ad-sdk-ios'

// Mopub mediation plugin
pod 'thirdpresence-ad-sdk-ios/ThirdpresenceMopubMediation'

// Admob mediation plugin
pod 'thirdpresence-ad-sdk-ios/ThirdpresenceAdAdmobMediation'
```

#### Copying the source code

- Clone or download this Github repository to your machine
- Open XCode project of your application

- Drag and drop ThirdpresenceAdSDK folder to the Project Navigator in the XCode and add the source to required targets. Make sure to check 'Create groups' option.

- Do the same for a mediation library if using mediation. Following mediation libraries are currently available:
    - ThirdpresenceMopubMediation (MoPub interstitial and rewarded video) 
    - ThirdpresenceAdmobMediation (Admob interstitial)

### Additional requirements

Enable following frameworks to your application target:
- AdSupport.framework
- CoreLocation.framework (optional, but highly recommended for enabling more targetted ads)

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

It is recommended to enable Location Services for better ad targeting and higher revenue.
Following keys shall be defined in the app's info.plist file.
NSLocationUsageDescription and NSLocationWhenInUseUsageDescription describes the user reasoning why they shall grant permission for location services.
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

Before initialising Thirdpresence ad unit the application shall request user to enable location services:

```
self.locationManager = [[CLLocationManager alloc] init];
[self.locationManager requestWhenInUseAuthorization];
[self.locationManager startUpdatingLocation];
```


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

### Mediation

When using mediation adapters it does not require changes in your existing code. The mediating Ad SDK will detect the existence of a mediation adapter dynamically. Make sure that your app target embeds Thirdpresence Ad SDK and mediation adapter libraries and other requirements are met. See following instruction how to add Thirdpresence ad source to the waterfall of the ad unit.

#### MoPub

- Login to the MoPub console
- Create a Fullscreen Ad or Rewarded Video Ad ad unit or use an existing ad unit in one of your apps
- Create a new Custom Native Network (see detailed instructions here https://dev.twitter.com/mopub/ui-setup/network-setup-custom-native)
- Set Custom Event Class and Custom Event Class Data for the ad unit with following values:

| Ad Unit | Custom Event Class | Custom Event Class Data |
| --- | --- | --- |
| Fullscreen Ad | TPRInterstitialCustomEvent | { "account":"REPLACE_ME", "placementid":"REPLACE_ME", "appname":"REPLACE_ME", "appversion":"REPLACE_ME", "appstoreurl":"REPLACE_ME", "gender":"REPLACE_ME", "yob":"REPLACE_ME"} |
| Rewarded Video | TPRRewardedVideoCustomEvent | { "account":"REPLACE_ME", "placementid":"REPLACE_ME", "appname":"REPLACE_ME", "appversion":"REPLACE_ME", "appstoreurl":"REPLACE_ME", "rewardtitle":"REPLACE_ME", "rewardamount":"REPLACE_ME", "gender":"REPLACE_ME", "yob":"REPLACE_ME"}  |

**Replace all the REPLACE_ME placeholders with actual values!**

The Custom Event Method field should be left blank.
For testing purposes you can use the account name "sdk-demo" and placementid "sa7nvltbrn".
Provide user's gender and yob (year of birth) to get more targeted ads. Leave them empty if not available.

- Go to the Segments tab on the Mopub console
- Select the segment where you want to enable the Thirdpresence custom native network
- Enable the network for this segment and set the CPM
- Test the integration with the MoPub sample app, remember to include the Thirdpresence plugin in your project

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
| Parameter | account:REPLACE_ME,placementid:REPLACE_ME,gender:REPLACE_ME,yob:REPLACE_ME |

**Replace REPLACE_ME placeholders with actual values!**

For testing purposes you can use the account name "sdk-demo" and placementid "sa7nvltbrn".
Provide user's gender and yob (year of birth) to get more targeted ads. Leave them empty if not available.

- Click Continue button
- Give eCPM for the Thirdpresence ad network
- Save changes and the integration is ready


### Unity plugin

The Thirdpresence Ad SDK Unity plugin is compatible with Unity 5 or newer.

Get the Thirdpresence Ad SDK Unity plugin and import to your Unity project. 

The plugin can be downloaded from:
http://s3.amazonaws.com/thirdpresence-ad-tags/sdk/plugins/unity/ios_1.1.2/thirdpresence-ad-sdk-ios.unitypackage

In order to start getting ads the ThirdpresenceAdsAndroid singleton object needs to be initialised in an Unity script:
``` 
#if UNITY_IPHONE
using TPR = ThirdpresenceAdsIOS;
#endif

```
The plugin supports interstitial and rewarded video ad units. 

An example for loading and displaying an interstitial ad:
``` 
// Initialise ad unit as soon as the app is ready to load an ad
private void initInterstitial() {

    // Subscribe to ad events and implement needed event handler methods.
    // See a list below for a full list of available events.
    TPR.OnThirdpresenceInterstitialLoaded -= InterstitialLoaded;
    TPR.OnThirdpresenceInterstitialLoaded += InterstitialLoaded;
    TPR.OnThirdpresenceInterstitialFailed -= InterstitialFailed;
    TPR.OnThirdpresenceInterstitialFailed += InterstitialFailed;

    // Create dictionary objects that hold the data needed to initialise the ad unit and the player.
    Dictionary<string, string> environment = new Dictionary<string, string>();
    environment.Add ("account", "REPLACE_ME"); // For the testing purposes use account name "sdk-demo" 
    environment.Add ("placementid", "REPLACE_ME"); // For the testing purposes use placement id "sa7nvltbrn". 
    environment.Add ("sdk-name", "Unity" + Application.platform);
    environment.Add ("sdk-version", Application.unityVersion);

    Dictionary<string, string> playerParams = new Dictionary<string, string>();
    playerParams.Add ("appname", Application.productName);
    playerParams.Add ("appversion", Application.version);
    playerParams.Add ("appstoreurl", "REPLACEME");
    playerParams.Add ("bundleid", Application.bundleIdentifier);

    // In order to get more targeted ads you shall provide user's gender and year of birth
    playerParams.Add ("gender", "male");
    playerParams.Add ("yob", "1975");

    long timeoutMs = 10000;

    // Initialise the interstitial
    TPR.initInterstitial (environment, playerParams, timeoutMs);
}	

// When an ad is loaded the event handler method is called
private void InterstitialLoaded() {
    adLoaded = true;
}

// When an ad load is failed the error handler method is called
private void InterstitialFailed(int errorCode, string errorText) {
    // failed to load interstitial ad
}

// Call showInterstitial when the ad shall be displayed 
private void showAd() {
    if (adLoaded) {
        TPR.showInterstitial ();
    }
}
```
Following events are available for the interstitial ad unit:

| Event | Description | 
| --- | --- |
| OnThirdpresenceInterstitialLoaded | Interstitial ad has been loaded |
| OnThirdpresenceInterstitialShown | Interstitial ad has been displayed |
| OnThirdpresenceInterstitialDismissed | Interstitial ad has been dismissed |
| OnThirdpresenceInterstitialFailed | Interstitial ad has failed to load |
| OnThirdpresenceInterstitialClicked | Interstitial ad has been clicked |

An example for loading and displaying a rewarded video ad:
``` 
// Initialise ad unit as soon as the app is ready to load an ad
private void initRewardedVideo() {

    // Subscribe to ad events and implement needed event handler methods.
    // See a list below for a full list of available events.
    TPR.OnThirdpresenceRewardedVideoLoaded -= RewardedVideoLoaded;
    TPR.OnThirdpresenceRewardedVideoLoaded += RewardedVideoLoaded;
    TPR.OnThirdpresenceRewardedVideoFailed -= RewardedVideoFailed;
    TPR.OnThirdpresenceRewardedVideoFailed += RewardedVideoFailed;
    TPR.OnThirdpresenceRewardedVideoCompleted -= RewardedVideoCompleted;
    TPR.OnThirdpresenceRewardedVideoCompleted += RewardedVideoCompleted;

    // Create dictionary objects that hold the data needed to initialise the ad unit and the player.
    Dictionary<string, string> environment = new Dictionary<string, string>();
    environment.Add ("account", "REPLACE_ME"); // For the testing purposes use account name "sdk-demo" 
    environment.Add ("placementid", "REPLACE_ME"); // For the testing purposes use placement id "sa7nvltbrn". 
    environment.Add ("sdk-name", "Unity" + Application.platform);
    environment.Add ("sdk-version", Application.unityVersion);

    // rewardtitle can be used as a virtual currency name. rewardamount is the amount of currency gained.
    environment.Add ("rewardtitle", "my-money");
    environment.Add ("rewardamount", "100");

    Dictionary<string, string> playerParams = new Dictionary<string, string>();
    playerParams.Add ("appname", Application.productName);
    playerParams.Add ("appversion", Application.version);
    playerParams.Add ("appstoreurl", "REPLACEME");
    playerParams.Add ("bundleid", Application.bundleIdentifier);


    // In order to get more targeted ads you shall provide user's gender and year of birth
    playerParams.Add ("gender", "male");
    playerParams.Add ("yob", "1975");

    long timeoutMs = 10000;

    // Initialise the interstitial
    TPR.initInterstitial (environment, playerParams, timeoutMs);
}	

// When an ad is loaded the event handler method is called
private void RewardedVideoLoaded() {
    adLoaded = true;
}

// When the ad load is failed the error handler method is called
private void RewardedVideoFailed(int errorCode, string errorText) {
    // failed to load interstitial ad
}

// When the user has watched the video the completed handler is called
private void RewardedVideoCompleted(string rewardTitle, int rewardAmount) {
    // User has earned the reward
}

// Call TPR.showRewardedVideo when the ad shall be displayed 
private void showAd() {
    if (TPR.RewardedVideoLoaded) {
        TPR.showRewardedVideo ();
    }
}
```
Following events are available for the rewarded video ad unit:

| Event | Description | 
| --- | --- |
| OnThirdpresenceRewardedVideoLoaded | Rewarded video ad has been loaded |
| OnThirdpresenceRewardedVideoShown | Rewarded video ad has been displayed |
| OnThirdpresenceRewardedVideoDismissed | Rewarded video ad has been dismissed |
| OnThirdpresenceRewardedVideoFailed | Rewarded video ad has failed to load |
| OnThirdpresenceRewardedVideoClicked | Rewarded video ad has been clicked |
| OnThirdpresenceRewardedVideoCompleted | Rewarded video ad has been completed  |
| OnThirdpresenceRewardedVideoAdLeftApplication | Rewarded video ad has opened an another app |



