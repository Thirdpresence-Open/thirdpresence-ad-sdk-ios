# Thirdpresence Ad SDK For iOS - MoPub mediation

Thirdpresence Ad SDK MoPub mediation enables displaying Thirdpresence video ads in an application that has the MoPub SDK integrated.

https://firebase.google.com/docs/admob/

## Minimum requirements

- XCode 7 or later
- Deployment target iOS 8.0 or later

## Adding library dependencies

There are two options to add Thirdpresence Ad SDK libraries to your XCode project:

1. Using CocoaPods
2. Copying the source code

For more details, see [Thirdpresence Ad SDK - Adding library dependencies](../ThirdpresenceAdSDK/#adding-library-dependencies) 

## Additional requirements

For common additional requirements, see [Thirdpresence Ad SDK - Additional requirements](../ThirdpresenceAdSDK/#additional-requirements) 

## Creating an ad unit

- Login to the MoPub console
- Create an ad unit, or use an existing ad unit in one of your apps
- Create a new Custom Native Network (for detailed instructions, see https://dev.twitter.com/mopub/ui-setup/network-setup-custom-native)
- Set Custom Event Class and Custom Event Class Data for the ad unit with following values:

| Ad Unit | Custom Event Class | Custom Event Class Data |
| --- | --- | --- |
| Medium Ad | TPRCustomEventBanner | { "account":"REPLACE_ME", "placementid":"REPLACE_ME", "appname":"REPLACE_ME" } |
| Fullscreen Ad | TPRInterstitialCustomEvent | { "account":"REPLACE_ME", "placementid":"REPLACE_ME", "appname":"REPLACE_ME"} |
| Rewarded Video | TPRRewardedVideoCustomEvent | { "account":"REPLACE_ME", "placementid":"REPLACE_ME", "appname":"REPLACE_ME", "rewardtitle":"REPLACE_ME", "rewardamount":"REPLACE_ME"}  |

The Custom Event Method field should be left blank.

**Replace all the REPLACE_ME placeholders with actual values!**

For the rewarded video the reward title and reward amount values are mandatory.

For testing purposes, use account name "sdk-demo" and following placement ids:

|  Ad Unit | Placement Id | 
| --- | --- |
| Medium ad | zhlwlm9280 | 
| Interstitial | sa7nvltbrn |
| Rewarded video | nhdfxqclej |

- Open the Segments tab on the Mopub console
- Select the segment where you want to enable the Thirdpresence custom native network
- Enable the network for this segment, and set the CPM
- Test the integration with the MoPub sample app. Remember to include the Thirdpresence plugin in your project.
