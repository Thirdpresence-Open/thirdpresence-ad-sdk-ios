# Thirdpresence Ad SDK For iOS - Admob mediation

Thirdpresence Ad SDK Admob mediation enables displaying Thirdpresence video ads in an application that has the Admob SDK integrated.

https://firebase.google.com/docs/admob/

## Minimum requirements

- XCode 7 or later
- Deployment target iOS 8.0 or later

## Adding library dependencies

There are two options to add Thirdpresence Ad SDK libraries to your XCode project:

1. Using CocoaPods
2. Copying the source code

For details, see [Thirdpresence Ad SDK - Adding library dependencies] (../ThirdpresenceAdSDK/#adding-library-dependencies) 

## Additional requirements

For common additional requirements, see [Thirdpresence Ad SDK - Additional requirements] (../ThirdpresenceAdSDK/#additional-requirements) 

## Creating an ad unit

- Login to the Admob console
- Create a new ad unit for video, if one does not exist. Following ad units are supported:
    - Banner (Automatic refresh shall be "no refresh" or min. 60 seconds)
    - Interstitial
    - Rewarded interstitial
- In the ad units list, click the "x ad source(s)" link on the Mediation column of the interstitial ad unit
- Click New ad network button
- Click the "+ Custom event" button
- Fill in the form:

| Ad Unit | Class Name | Parameter |
| --- | --- | --- |
| Banner | TPRAdmobCustomEventBanner | account:REPLACE_ME,placementid:REPLACE_ME |
| Interstitial | TPRAdmobCustomEventInterstitial | account:REPLACE_ME,placementid:REPLACE_ME |
| Rewarded interstitial | TPRAdmobCustomEventRewardedVideo | account:REPLACE_ME,placementid:REPLACE_ME,rewardtitle:REPLACE_ME,rewardamount:REPLACE_ME |

Give a descriptive name for the network in the Label field, e.g. "Thirdpresence Banner"

**Replace all the REPLACE_ME placeholders with actual values!**

For the rewarded video the reward title and reward amount values are mandatory.

For testing purposes, use account name "sdk-demo" and following placement ids:

|  Ad Unit | Placement Id | 
| --- | --- |
| Medium ad | zhlwlm9280 | 
| Interstitial | sa7nvltbrn |
| Rewarded video | nhdfxqclej |

- Click the Continue button
- Give eCPM for the Thirdpresence ad network
- Save changes, and the integration is ready

## Passing user info and keywords

Thirdpresence can provide more targeted ads if user info and keywords are passed. In order to do that the data needs to be added to MoPub ad request.
An example for adding the data. This shall be done before any ad requests.
```
    NSString userGender = @"male"; // allowed values are "male" or "female"
    NSString userYearOfBirth = @"1976";
    NSString keywords = @"advertising,sdk,programming"; // comma-separated string of keyworads

    NSMutableDictionary* targeting = [[TPRDataManager sharedManager] targeting];
    [targeting setValue:userGender forKey:TPR_MP_TARGETING_PARAM_GENDER];
    [targeting setValue:userYearOfBirth forKey:TPR_MP_TARGETING_PARAM_YOB];
    [targeting setValue:keywords forKey:TPR_MP_TARGETING_PARAM_KEYWORDS];

```



