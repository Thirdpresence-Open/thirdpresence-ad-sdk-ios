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
- Create an Interstitial ad unit for video, if one does not exist
- In the ad units list, click the "x ad source(s)" link on the Mediation column of the interstitial ad unit
- Click New ad network button
- Click the "+ Custom event" button
- Fill in the form:

| Field | Value |
| --- | --- |
| Class Name | TPRAdmobCustomEventInterstitial |
| Label | Thirdpresence |
| Parameter | account:REPLACE_ME,placementid:REPLACE_ME,gender:REPLACE_ME,yob:REPLACE_ME |

**Replace REPLACE_ME placeholders with actual values!**

For testing purposes, use account name "sdk-demo" and placementid "sa7nvltbrn".
Provide the user's gender and yob (year of birth) to get more targeted ads. Leave them empty if the information is not available.

- Click the Continue button
- Give eCPM for the Thirdpresence ad network
- Save changes, and the integration is ready

