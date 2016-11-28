# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'
target 'fave' do
    # Comment this line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    # pod "RxShortcuts/RxCocoa"
    pod 'Fabric', '1.6.11'
    pod 'Crashlytics', '3.8.3'
    pod 'Validator', '1.2.1'
    pod 'DeviceKit', '0.3.4'
    pod 'GoogleMaps', '2.1.0'
    pod 'IDMPhotoBrowser', '1.9.1'
    pod 'KTCenterFlowLayout', '1.3.1'
    pod 'RxSwift', '2.6.0'
    pod 'RxCocoa', '2.6.0'
    pod 'Kingfisher', '2.6.0'
    pod 'Alamofire', '3.5.0'
    pod 'MXSegmentedPager', '3.2.0'
    pod 'Braintree', '4.7.1'
    pod 'Alexandria/Core', :git => 'git@github.com:ovenbits/Alexandria.git', :branch => 'swift2.3'
    pod 'RxSwiftExt', '1.2'
    pod 'RxOptional', '2.0.0'
    pod 'ZendeskSDK', '1.7.5.1'
    pod 'ZDCChat', '1.3.2.1'
    pod 'SwiftLoader', '0.2.5'
    pod 'SwiftOverlays', '2.0.1'
    pod 'AppsFlyerFramework', '4.5.5'
    pod 'MoEngage-iOS-SDK', '3.1.0'
    pod 'RxDataSources', '0.9'
    pod 'Branch', '0.12.14'
    pod 'GooglePlaces', '2.1.0'
    pod 'GooglePlacePicker', '2.1.0'
    pod 'RSKImageCropper', '1.5.1'
    pod 'SendBirdSDK', '2.2.13'
    pod 'JSQMessagesViewController', '7.3.4'
    pod 'CircleProgressView', '1.0.11'
    pod 'DateTools', '1.7.0'
    pod 'Firebase/Core', '3.8.0'
    pod 'Firebase/Messaging', '3.8.0'
    pod 'Localytics', '4.1.0'
    pod 'AMPopTip', '1.3.0'
    pod 'AdyenCheckout', '0.0.2'
    pod 'PhoneNumberKit', '~> 0.8'
    pod 'PolyglotLocalization', '0.4.0'
    pod 'CreditCardValidator', '0.2.0'
    pod 'MidtransKit', '1.0.8'
    
    target 'faveTests' do
        inherit! :search_paths
        # Pods for testing
#        pod 'Quick'
#        pod 'Nimble'
    end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            config.build_settings['SWIFT_VERSION'] = '2.3'
            
            if target.name == 'MoEngage-iOS-SDK'
                config.build_settings["OTHER_LDFLAGS"] = '$(inherited) "-ObjC"'
            end
        end
    end
end
