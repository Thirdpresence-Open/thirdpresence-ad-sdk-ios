Pod::Spec.new do |s|
  s.name             = "thirdpresence-ad-sdk-ios"
  s.version          = "1.3.3"
  s.summary          = "Thirdpresence Ad SDK for iOS apps"
  s.description      = <<-DESC
    Thirdpresence Ad SDK is a VPAID compatible ad SDK for apps. 
                       DESC
  s.homepage         = "https://github.com/Thirdpresence-Open/thirdpresence-ad-sdk-ios"
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { "okkonen" => "marko.okkonen@thirdpresence.com" }
  s.source           = { :git => "https://github.com/Thirdpresence-Open/thirdpresence-ad-sdk-ios.git", :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.platform         = :ios, '8.0'
  s.frameworks       = 'UIKit'
  s.default_subspecs = "ThirdpresenceAdSDK"

  s.subspec 'ThirdpresenceAdSDK' do |ss1|
    ss1.source_files = 'ThirdpresenceAdSDK/**/*.{h,m}'
 	ss1.public_header_files = 'ThirdpresenceAdSDK/*.h'
  end
  
  s.subspec 'ThirdpresenceMopubMediation' do |ss2|
    ss2.source_files        = 'ThirdpresenceMopubMediation/*.{h,m}'
 	ss2.public_header_files = 'ThirdpresenceMopubMediation/*.h'
	ss2.dependency 'thirdpresence-ad-sdk-ios/ThirdpresenceAdSDK'
 	ss2.dependency 'mopub-ios-sdk'
  end  

  s.subspec 'ThirdpresenceAdmobMediation' do |ss3|
    ss3.source_files        = 'ThirdpresenceAdmobMediation/*.{h,m}'
 	ss3.public_header_files = 'ThirdpresenceAdmobMediation/*.h'
  	ss3.frameworks          = 'UIKit', 'GoogleMobileAds','SafariServices', 'CoreBluetooth'
	ss3.dependency 'thirdpresence-ad-sdk-ios/ThirdpresenceAdSDK'
 	ss3.dependency 'Google-Mobile-Ads-SDK', '7.8.0'
  end  

  s.subspec 'ThirdpresenceAdmobMediation' do |ss4|
    ss4.source_files        = 'ThirdpresenceUnityPlugin/*.{h,m}'
    ss4.public_header_files = 'ThirdpresenceUnityPlugin/*.h'
    ss4.frameworks          = 'UIKit', 'GoogleMobileAds','SafariServices', 'CoreBluetooth'
    ss4.dependency 'thirdpresence-ad-sdk-ios/ThirdpresenceAdSDK'
  end

end


