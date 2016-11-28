//
//  UserAnalyticsModel.swift
//  FAVE
//
//  Created by Michael Cheah on 7/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  UserAnalyticsModel
 */

class UserAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    // MARK:- Dependency
    private let user: User
    private let cityProvider: CityProvider
    private let rxAnalytics: RxAnalytics

    // MARK- Output
    var loginSuccessfulEvent: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Login_Success")
        return event.addProperty("User_ID", value: self.user.id)
    }

    var signupSuccessfulEvent: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Signup_Success")
        return event.addProperty("User_ID", value: self.user.id)
    }

    func identifyUserWithCity() {
        if let userCity = cityProvider.currentCity.value {
            self.rxAnalytics.identifyUser(UserAttributes(user: self.user, city: userCity), providers: AnalyticsProviderType.MoEngage)
        }
    }

    init(user: User
        , cityProvider: CityProvider = cityProviderDefault
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault
         ) {
        self.cityProvider = cityProvider
        self.user = user
        self.rxAnalytics = rxAnalytics
    }

    // MARK:- Life cycle
    deinit {

    }
}
