#!/bin/bash    

display_usage() { 
  echo usage: $0 '<environment> <version string>'
  echo use environment values: testing, staging, production, open
  exit 1
}

ENV=$1 
VER=$2

IOS_SDK=iphoneos9.3
UNITY_EXPORT_DIR=../ThirdpresenceUnityPlugin/unity-package/export
UNITY_PACKAGE_NAME=thirdpresence-ad-sdk-ios.unitypackage

if [ ! -z $VER ]; then
  if [ ! -z $ENV ]; then
    xcodebuild -target ThirdpresenceUnityPlugin -sdk $IOS_SDK -project ../ThirdpresenceUnityPlugin.xcodeproj
    if [ $? == 0 ]; then
	  if [ -e $UNITY_EXPORT_DIR/$VER ]; then
        aws s3 cp ${UNITY_EXPORT_DIR}/${VER}/${UNITY_PACKAGE_NAME} s3://files.thirdpresence.com/adsdk/ios/${ENV}/${VER}/Unity/ --acl public-read --cache-control no-cache --region eu-west-1
      	if [ "$ENV" == "open" ]; then
          aws s3 cp ${UNITY_EXPORT_DIR}/${VER}/${UNITY_PACKAGE_NAME} s3://thirdpresence-ad-tags/sdk/plugins/unity/ios_${VER}/ --acl public-read --cache-control no-cache --region eu-west-1    
     	fi
		echo Unity package exported
      else
        echo ERROR: Build version $VER not found!
        display_usage
      fi
    else
 	  echo ERROR: Build failed
 	  exit 1
    fi
  else
    echo ERROR: environment not set
    display_usage
  fi
else
    echo ERROR: Build version not set
    display_usage
fi
