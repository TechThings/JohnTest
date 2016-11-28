//
//  TrackingScreen.swift
//  FAVE
//
//  Created by Thanh KFit on 9/8/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import Localytics

protocol TrackingScreen {
    func trackingScreen(screenName: String)
}

final class TrackingScreenDefault: NSObject, TrackingScreen {
    let userProvider: UserProvider
    let rxAnalytics: RxAnalytics

    init(userProvider: UserProvider = userProviderDefault,
         rxAnalytics: RxAnalytics = rxAnalyticsDefault) {
        self.userProvider = userProvider
        self.rxAnalytics = rxAnalytics
        super.init()
    }

    func trackingScreen(screenName: String) {
        localyticsTrackingUserFlow(screenName)
        localyticsTrackingEvent(screenName)
    }

    func localyticsTrackingUserFlow(screenName: String) {
        Localytics.tagScreen(screenName)
    }

    func localyticsTrackingEvent(screenName: String) {
        let analyticsEvent = AnalyticsEvent(eventName: "Screen Displayed")

        let properties = ["screen_name" : screenName,
                          "logged_in": !userProvider.currentUser.value.isGuest]
        analyticsEvent.properties = properties as! [String : AnyObject]

        rxAnalytics.sendAnalyticsEvent(analyticsEvent, providers: AnalyticsProviderType.Localytics)
    }
}
