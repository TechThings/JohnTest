//
// Created by Michael Cheah on 8/3/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

class OnboardingAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    var guestBrowsingEvent: AnalyticsEvent {
        return AnalyticsEvent(eventName: "Go_Guest_Browsing")
    }

    var goLoginEvent: AnalyticsEvent {
        return AnalyticsEvent(eventName: "Go_Login")
    }

    // MARK:- Life cycle
    deinit {

    }
}
