//
//  LocalyticsEvent.swift
//  FAVE
//
//  Created by Michael Cheah on 9/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

class LocalyticsEvent: AnalyticsEvent {
    private static let KEY_SCREEN_NAME = "screen_name"
    private static let KEY_TAPPED_ON   = "tapped_on"

    private var isEmpty = false
    private let isLoggedIn: Bool

    init(eventName: String,
         rxAnalytics: RxAnalytics = rxAnalyticsDefault,
         userProvider: UserProvider = userProviderDefault) {

        isLoggedIn = !userProvider.currentUser.value.isGuest
        super.init(eventName: eventName, rxAnalytics: rxAnalytics)
    }

    class func empty() -> LocalyticsEvent {
        let event = LocalyticsEvent(eventName: "")
        event.isEmpty = true

        return event
    }

    class func createScreenEvent(screenName screenName: String) -> LocalyticsEvent {
        let event = LocalyticsEvent(eventName: "Screen Displayed")
        event.addProperty(KEY_SCREEN_NAME, value: screenName)
        event.addProperty("logged_in", value: event.isLoggedIn)
        event.isEmpty = false

        return event
    }

    class func createTapEvent(tappedOn tappedOn: String, screenName: String) -> LocalyticsEvent {
        let event = LocalyticsEvent(eventName: "Tap")
        event.addProperty(KEY_TAPPED_ON, value: tappedOn)
        event.addProperty(KEY_SCREEN_NAME, value: screenName)
        event.addProperty("logged_in", value: event.isLoggedIn)
        event.isEmpty = false

        return event
    }

    class func createAPIEvent(screenName screenName: String) -> LocalyticsEvent {
        let event = LocalyticsEvent(eventName: "API Events")
        event.addProperty(KEY_SCREEN_NAME, value: screenName)
        event.addProperty("logged_in", value: event.isLoggedIn)
        event.isEmpty = false

        return event
    }

    override func addProperty(key: String, value: String) -> LocalyticsEvent {
        super.addProperty(key, value: value)
        return self
    }

    override func addProperty(key: String, value: Bool) -> LocalyticsEvent {
        super.addProperty(key, value: value)
        return self
    }

    override func addProperty(key: String, value: Int) -> LocalyticsEvent {
        super.addProperty(key, value: value)
        return self
    }

    override func addProperty(key: String, value: Double) -> LocalyticsEvent {
        super.addProperty(key, value: value)
        return self
    }

    override func addProperty(key: String, value: [String]) -> LocalyticsEvent {
        super.addProperty(key, value: value)
        return self
    }

    override func send() -> LocalyticsEvent {
        if (!isEmpty) {
            self.rxAnalytics.sendAnalyticsEvent(self, providers: AnalyticsProviderType.Localytics)
        }

        return self
    }

}
