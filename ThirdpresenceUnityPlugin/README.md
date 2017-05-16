# Thirdpresence Ad SDK For iOS - Unity plugin

The Thirdpresence Ad SDK Unity plugin provides means to display interstitial and rewarded video ads on a Unity application.

## Minimum requirements

- Unity SDK 5 or newer
- Deployment target iOS 8.0 or later

## Getting Unity plugin package

The pre-built plugin is available here:
http://s3.amazonaws.com/thirdpresence-ad-tags/sdk/plugins/unity/1.5.4/thirdpresence-ad-sdk-ios.unitypackage

The plugin is built with the following tools:

- Unity SDK 5.6.0
- Java JDK 1.8
- iOS 10.3

Another option is to manually build the SDK and the Unity plugin. All the source code is available in this repository. Before building the Unity project, check that the path to the Unity Editor is correctly set in "Build Settings -> User-Defined -> TPR_AD_SDK_UNITY_EDITOR"

## Importing plugin package

- Open an application project in the Unity Editor
- Select Assets -> Import Package -> Custom Package from the main menu
- Locate the Unity plugin package file and open it
- Import all files, and the plugin is available in the project

## Player Settings

Verify the following player settings in the Unity editor.

File -> Build Settings (iOS platform selected) -> Player Settings...

Inspector -> Other Settings: 
- Target minimum iOS version 8.0 or higher
- Allow downloads over HTTP selected

Services -> Ads:
- Enable Ads. This is only required to import AdSupport.framework to the iOS build. Therefore, it is not necessary to use Unity Ads in the scripting code. An alternative solution is to add AdSupport.framework directly to XCode project.
    
## Integration

To start getting ads, the ThirdpresenceAdsAndroid singleton object must be initialised in a Unity script:
``` 
#if UNITY_IPHONE
using TPR = ThirdpresenceAdsIOS;
#endif
```
The plugin supports interstitial and rewarded video ad units. 

### Interstitial

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
An example for loading and displaying a rewarded video ad:

| Event | Description | 
| --- | --- |
| OnThirdpresenceInterstitialLoaded | Interstitial ad has been loaded |
| OnThirdpresenceInterstitialShown | Interstitial ad has been displayed |
| OnThirdpresenceInterstitialDismissed | Interstitial ad has been dismissed |
| OnThirdpresenceInterstitialFailed | Interstitial ad has failed to load |
| OnThirdpresenceInterstitialClicked | Interstitial ad has been clicked |

### Rewarded video

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
The events below are available for the rewarded video ad unit:

| Event | Description | 
| --- | --- |
| OnThirdpresenceRewardedVideoLoaded | Rewarded video ad has been loaded |
| OnThirdpresenceRewardedVideoShown | Rewarded video ad has been displayed |
| OnThirdpresenceRewardedVideoDismissed | Rewarded video ad has been dismissed |
| OnThirdpresenceRewardedVideoFailed | Rewarded video ad has failed to load |
| OnThirdpresenceRewardedVideoClicked | Rewarded video ad has been clicked |
| OnThirdpresenceRewardedVideoCompleted | Rewarded video ad has been completed  |
| OnThirdpresenceRewardedVideoAdLeftApplication | Rewarded video ad has opened an another app |



