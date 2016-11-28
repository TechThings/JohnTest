//
//  AssetProvider.swift
//  FAVE
//
//  Created by Ranjeet on 04/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK:- Image Assets
protocol ImageAssest {
    var welcomeImage: UIImage {get}
    var aboutImage: UIImage {get}

    var onboardingBgImage_0: UIImage {get}
    var onboardingBgImage_1: UIImage {get}
    var onboardingBgImage_2: UIImage {get}
    var onboardingBgImage_3: UIImage {get}
    var onboardingBgImage_4: UIImage {get}

    var onboardingIconImage_0: UIImage {get}
    var onboardingIconImage_1: UIImage {get}
    var onboardingIconImage_2: UIImage {get}
    var onboardingIconImage_3: UIImage {get}
    var onboardingIconImage_4: UIImage {get}
}

struct GrouponImageAssest: ImageAssest {
    var welcomeImage: UIImage { return UIImage(named: "ic_home_headerCell_ind")! }

    var aboutImage: UIImage { return UIImage(named: "ic_about_fave_by_groupon")! }

    var onboardingBgImage_0: UIImage { return UIImage(named: "bg_launch_1")! }
    var onboardingBgImage_1: UIImage { return UIImage(named: "bg_launch_3")! }
    var onboardingBgImage_2: UIImage { return UIImage(named: "bg_launch_4")! }
    var onboardingBgImage_3: UIImage { return UIImage(named: "bg_launch_5")! }
    var onboardingBgImage_4: UIImage { return UIImage(named: "bg_launch_2")! }

    var onboardingIconImage_0: UIImage { return UIImage(named: "ic_launch_0")! }
    var onboardingIconImage_1: UIImage { return UIImage(named: "ic_launch_7")! }
    var onboardingIconImage_2: UIImage { return UIImage(named: "ic_launch_6")! }
    var onboardingIconImage_3: UIImage { return UIImage(named: "ic_launch_5")! }
    var onboardingIconImage_4: UIImage { return UIImage(named: "ic_launch_2")! }
}

struct KfitImageAssest: ImageAssest {
    var welcomeImage: UIImage { return UIImage(named: "ic_home_headerCell")! }
    var aboutImage: UIImage { return UIImage(named: "fave_by_kfit")! }

    var onboardingBgImage_0: UIImage { return UIImage(named: "bg_launch_1")! }
    var onboardingBgImage_1: UIImage { return UIImage(named: "bg_launch_2")! }
    var onboardingBgImage_2: UIImage { return UIImage(named: "bg_launch_3")! }
    var onboardingBgImage_3: UIImage { return UIImage(named: "bg_launch_4")! }
    var onboardingBgImage_4: UIImage { return UIImage(named: "bg_launch_5")! }

    var onboardingIconImage_0: UIImage { return UIImage(named: "ic_launch_1")! }
    var onboardingIconImage_1: UIImage { return UIImage(named: "ic_launch_2")! }
    var onboardingIconImage_2: UIImage { return UIImage(named: "ic_launch_3")! }
    var onboardingIconImage_3: UIImage { return UIImage(named: "ic_launch_4")! }
    var onboardingIconImage_4: UIImage { return UIImage(named: "ic_launch_5")! }
}

// MARK:- Text Assets
protocol TextAssest {

    var welcomeText: String {get}
    var aboutText: String {get}

    var onboardingText_0: String {get}
    var onboardingText_1: String {get}
    var onboardingText_2: String {get}
    var onboardingText_3: String {get}
    var onboardingText_4: String {get}

    var onboardingTitle_0: String {get}
    var onboardingTitle_1: String {get}
    var onboardingTitle_2: String {get}
    var onboardingTitle_3: String {get}
    var onboardingTitle_4: String {get}

    var paymentDescriptionText: String {get}
}

struct GrouponTextAssest: TextAssest {
    var welcomeText: String { return NSLocalizedString("ind_welcome_text", comment: "welcome to fave") }
    var aboutText: String { return NSLocalizedString("ind_about", comment: "about") }

    var onboardingText_0: String { return NSLocalizedString("better_mobile_platform_groupon", comment: "welcome to fave") }
    var onboardingText_1: String { return NSLocalizedString("ind_save_90_on_favourite", comment: "save") }
    var onboardingText_2: String { return NSLocalizedString("ind_convenient_user_experience", comment: "enjoy") }
    var onboardingText_3: String { return NSLocalizedString("ind_find_deals_you_love", comment: "discover") }
    var onboardingText_4: String { return NSLocalizedString("organise_activities_with_chat", comment: "plan") }

    var onboardingTitle_0: String { return NSLocalizedString("ind_welcome_text", comment: "welcome to fave").uppercaseString }
    var onboardingTitle_1: String { return NSLocalizedString("save", comment: "save").uppercaseString }
    var onboardingTitle_2: String { return NSLocalizedString("enjoy", comment: "enjoy").uppercaseString }
    var onboardingTitle_3: String { return NSLocalizedString("discover", comment: "discover").uppercaseString }
    var onboardingTitle_4: String { return NSLocalizedString("plan", comment: "plan").uppercaseString }

    var paymentDescriptionText: String { return NSLocalizedString("view_your_receipts", comment: "payment") }

}

struct KfitTextAssest: TextAssest {
    var welcomeText: String { return NSLocalizedString("splash_title_1_text", comment: "welcome to fave") }
    var aboutText: String { return NSLocalizedString("fave_about", comment: "about") }

    var onboardingText_0: String { return NSLocalizedString("fave_welcome_text", comment: "welcome to fave") }
    var onboardingText_1: String { return NSLocalizedString("organise_activities_with_chat", comment: "plan") }
    var onboardingText_2: String { return NSLocalizedString("fave_save_70_on_favourite", comment: "save") }
    var onboardingText_3: String { return NSLocalizedString("latest_offers_at_your_fingertips", comment: "decide") }
    var onboardingText_4: String { return NSLocalizedString("explore_hundreds_on_restaurants", comment: "descover") }

    var onboardingTitle_0: String { return NSLocalizedString("splash_title_1_text", comment: "welcome to fave").uppercaseString }
    var onboardingTitle_1: String { return NSLocalizedString("plan", comment: "plan").uppercaseString }
    var onboardingTitle_2: String { return NSLocalizedString("save", comment: "save").uppercaseString }
    var onboardingTitle_3: String { return NSLocalizedString("decide", comment: "decide").uppercaseString }
    var onboardingTitle_4: String { return NSLocalizedString("discover", comment: "discover").uppercaseString }

    var paymentDescriptionText: String { return NSLocalizedString("more_payment_description_text", comment: "paymet") }

}

protocol AssetProvider {
    var imageAssest: Variable<ImageAssest> {get}
    var textAssest: Variable<TextAssest> {get}
    var assestDidUpdate: PublishSubject<()> { get }
}

final class AssetProviderDefault: Provider, AssetProvider {
    // MARK:- Dependency
    let settingsProvider: SettingsProvider

    // MARK: Provider variables
    let textAssest: Variable<TextAssest>
    let imageAssest: Variable<ImageAssest>
    let assestDidUpdate = PublishSubject<()>()

    init(
        settingsProvider: SettingsProvider = settingsProviderDefault
    ) {
        self.settingsProvider = settingsProvider

        let textTypeAssest: TextAssest = { () -> TextAssest in
            switch settingsProvider.settings.value.appCompany {
            case .groupon: return GrouponTextAssest()
            case .kfit: return KfitTextAssest()
            }
        }()

        let imageTypeAssest: ImageAssest = { () -> ImageAssest in
            switch settingsProvider.settings.value.appCompany {
            case .groupon: return GrouponImageAssest()
            case .kfit: return KfitImageAssest()
            }
        }()

        self.textAssest = Variable(textTypeAssest)
        self.imageAssest = Variable(imageTypeAssest)

        super.init()

        self.settingsProvider
            .settings
            .asObservable()
            .map { $0.appCompany }
            .distinctUntilChanged()
            .map {
                switch $0 {
                case .groupon: return GrouponImageAssest()
                case .kfit: return KfitImageAssest()
                }
            }
            .bindTo(imageAssest)
            .addDisposableTo(disposeBag)

        self.settingsProvider
            .settings
            .asObservable()
            .map { $0.appCompany }
            .distinctUntilChanged()
            .map { _ in return () }
            .bindTo(assestDidUpdate)
            .addDisposableTo(disposeBag)

        self.settingsProvider
            .settings
            .asObservable()
            .map { $0.appCompany }
            .distinctUntilChanged()
            .map {
                switch $0 {
                case .groupon: return GrouponTextAssest()
                case .kfit: return KfitTextAssest()
                }
            }
            .bindTo(textAssest)
            .addDisposableTo(disposeBag)

    }
}
