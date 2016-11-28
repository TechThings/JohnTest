//
//  OnboardingViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 02/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OnboardingViewModel: ViewModel {

    // Screen Tracking
    let trackingScreen: TrackingScreen

    // MARK:- Dependency
    let locationService: LocationService
    let cityProvider: CityProvider
    let rxAnalytics: RxAnalytics
    let assetProvider: AssetProvider

    // MARK:- Signal
    let loginButtonDidTap = PublishSubject<()>()
    let pageControlDidTap = PublishSubject<()>()

    var dataSource = Variable([(bgImage: UIImage, message: String, icon: UIImage, title: String)]())
    let reloadList = PublishSubject<()>()

    init (
        locationService: LocationService = locationServiceDefault
        , cityProvider: CityProvider = cityProviderDefault
        , trackingScreen: TrackingScreen = trackingScreenDefault
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault
        , assetProvider: AssetProvider = assetProviderDefault
        ) {
        self.trackingScreen = trackingScreen
        self.locationService = locationService
        self.cityProvider = cityProvider
        self.rxAnalytics = rxAnalytics
        self.assetProvider = assetProvider

        super.init()

        self.loadLatestDataSource()

        loginButtonDidTap.subscribeNext { [weak self] _ in
            self?.lightHouseService.navigate.onNext({ (viewController) in
                let vm = EnterPhoneNumberViewControllerViewModel(enterPhoneNumberViewControllerViewModelFunctionality: EnterPhoneNumberViewControllerViewModelFunctionality.LoginANewUser)
                let vc = EnterPhoneNumberViewController.build(vm)
                viewController.navigationController?.pushViewController(vc, animated: true)
            })
            }.addDisposableTo(disposeBag)
        }

    func loadLatestDataSource() {
        self.dataSource.value = [
            (bgImage: assetProvider.imageAssest.value.onboardingBgImage_0, message: assetProvider.textAssest.value.onboardingText_0, icon: assetProvider.imageAssest.value.onboardingIconImage_0, title: assetProvider.textAssest.value.onboardingTitle_0)
            , (bgImage: assetProvider.imageAssest.value.onboardingBgImage_1, message: assetProvider.textAssest.value.onboardingText_1, icon: assetProvider.imageAssest.value.onboardingIconImage_1, title: assetProvider.textAssest.value.onboardingTitle_1)
            , (bgImage: assetProvider.imageAssest.value.onboardingBgImage_2, message: assetProvider.textAssest.value.onboardingText_2, icon: assetProvider.imageAssest.value.onboardingIconImage_2, title: assetProvider.textAssest.value.onboardingTitle_2)
            , (bgImage: assetProvider.imageAssest.value.onboardingBgImage_3, message: assetProvider.textAssest.value.onboardingText_3, icon: assetProvider.imageAssest.value.onboardingIconImage_3, title: assetProvider.textAssest.value.onboardingTitle_3)
            , (bgImage: assetProvider.imageAssest.value.onboardingBgImage_4, message: assetProvider.textAssest.value.onboardingText_4, icon: assetProvider.imageAssest.value.onboardingIconImage_4, title: assetProvider.textAssest.value.onboardingTitle_4)
        ]
    }
}
