//
//  UserProfileViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum UserProfileItemKind {
    case Header
    case Detail
    case Gender
    case Birthday
    case HeaderSection
    case Purchases
    case Recommendations
    case Logout
    case Separator
}

final class UserProfileItem {
    let itemType: UserProfileItemKind
    let item: AnyObject?

    init(itemType: UserProfileItemKind, item: AnyObject?) {
        self.item = item
        self.itemType = itemType
    }
}

/**
 *  @author Nazih Shoura
 *
 *  UserProfileViewControllerViewModel
 */

final class UserProfileViewControllerViewModel: ViewModel {

    // MARK:- Dependency
    let userProvider: UserProvider
    let cityProvider: CityProvider
    let rxAnalytics: RxAnalytics

    // MARK- Output
    let userProfileItems: Driver<[UserProfileItem]>

    init(userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault,
         rxAnalytics: RxAnalytics = rxAnalyticsDefault) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.rxAnalytics = rxAnalytics

        userProfileItems = Observable
            .combineLatest(
                userProvider.currentUser.asObservable()
                , cityProvider.currentCity.asObservable().filterNil()
                , resultSelector: {
                    (user: User, city: City) -> [UserProfileItem] in

                    var items = [UserProfileItem]()

                    // Currently this case can't happen as more tab is not shown when the user is a guest
                    guard !user.isGuest else {
                        let vm = UserDetailViewModel(title: NSLocalizedString("profile_setting_location_text", comment: ""), details: city.name)
                        items.append(UserProfileItem(itemType: .Detail, item: vm))
                        items.append(UserProfileItem(itemType: .Separator, item: nil))
                        items.append(UserProfileItem(itemType: .Logout, item: nil))
                        return items
                    }

                    if let name = user.name {
                        let userProfileHeaderViewModel = UserProfileHeaderViewModel()
                        items.append(UserProfileItem(itemType: .Header, item: userProfileHeaderViewModel))

                        let userDetailViewModel = UserDetailViewModel(title: NSLocalizedString("profile_setting_name_text", comment: ""), details: name)
                        items.append(UserProfileItem(itemType: .Detail, item: userDetailViewModel))
                    }

                    if let email = user.email {
                        let vm = UserDetailViewModel(title: NSLocalizedString("profile_setting_email_text", comment: ""), details: email)
                        items.append(UserProfileItem(itemType: .Detail, item: vm))
                    }

                    let location = city.slug
                    let vm = UserDetailViewModel(title: NSLocalizedString("profile_setting_location_text", comment: ""), details: location)
                    items.append(UserProfileItem(itemType: .Detail, item: vm))

                    if let phoneNumber = user.phoneNumber {
                        let vm = UserDetailViewModel(title: NSLocalizedString("profile_setting_phone_text", comment: ""), details: phoneNumber)
                        items.append(UserProfileItem(itemType: .Detail, item: vm))
                    }

                    if let gender = user.gender {
                        let vm = UserGenderViewModel(details: gender.rawValue)
                        items.append(UserProfileItem(itemType: .Gender, item: vm))
                    } else {
                        let vm = UserGenderViewModel(details: NSLocalizedString("profile_setting_not_specify_text", comment: ""))
                        items.append(UserProfileItem(itemType: .Gender, item: vm))
                    }

                    if let birthDay = user.dateOfBirth {
                        let vm = UserBirthdayViewModel(details: birthDay.PromoDateString!)
                        items.append(UserProfileItem(itemType: .Birthday, item: vm))
                    } else {
                        let vm = UserBirthdayViewModel(details: NSLocalizedString("profile_setting_not_specify_text", comment: ""))
                        items.append(UserProfileItem(itemType: .Birthday, item: vm))
                    }

                    // Thanh> We not support change receive notification by now
                    // CC: Change the value
//                    items.append(UserProfileItem(itemType: .HeaderSection, item: "PUSH NOTIFICATIONS"))
//                    
//                    items.append(UserProfileItem(itemType: .Purchases, item: UserSwitchViewModel(title: "Updates about your purchases", value: true)))
//                    
//                    items.append(UserProfileItem(itemType: .Recommendations, item: UserSwitchViewModel(title: "Lastest recommendations, news & promotions", value: true)))

                    items.append(UserProfileItem(itemType: .Separator, item: nil))
                    items.append(UserProfileItem(itemType: .Logout, item: nil))

                    return items
                })
        .asDriver(onErrorJustReturn: [UserProfileItem]())
    }

    // MARK:- Life cycle
    deinit {

    }

    func logout() {
        app.logoutSignal.onNext(())
    }

    func updateGender(gender: Gender) {
        self.userProvider.updateProfileRequest(false, dateOfBirth: nil, gender: gender.rawValue, purchaseNotification: nil, marketingNotification: nil, advertisingId: nil, profileImage: nil)
    }

    func updateBirthday(date: NSDate) {
        self.userProvider.updateProfileRequest(false, dateOfBirth: date.APIDateString, gender: nil, purchaseNotification: nil, marketingNotification: nil, advertisingId: nil, profileImage: nil)
    }

    func updatePurchasesNotification(value: Bool) {
        self.userProvider.updateProfileRequest(false, dateOfBirth: nil, gender: nil, purchaseNotification: value, marketingNotification: nil, advertisingId: nil, profileImage: nil)
    }

    func updateRecommendNotification(value: Bool) {
        self.userProvider.updateProfileRequest(false, dateOfBirth: nil, gender: nil, purchaseNotification: nil, marketingNotification: value, advertisingId: nil, profileImage: nil)
    }

    func updateAvatar(image: UIImage) {
        userProvider.updateProfileRequest(false, dateOfBirth: nil, gender: nil, purchaseNotification: nil, marketingNotification: nil, advertisingId: nil, profileImage: image)
    }

}
