//
// Created by Michael Cheah on 7/26/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

class AnalyticsEvent {
    let rxAnalytics: RxAnalytics

    let eventName: String
    var properties: [String:AnyObject]

    init(eventName: String,
         rxAnalytics: RxAnalytics = rxAnalyticsDefault) {
        self.eventName = eventName
        self.properties = [String: AnyObject]()
        self.rxAnalytics = rxAnalytics
    }

    func addProperty(key: String, value: String) -> AnalyticsEvent {
        self.properties[key] = value
        return self
    }

    func addProperty(key: String, value: Bool) -> AnalyticsEvent {
        self.properties[key] = value
        return self
    }

    func addProperty(key: String, value: Int) -> AnalyticsEvent {
        self.properties[key] = value
        return self
    }

    func addProperty(key: String, value: Double) -> AnalyticsEvent {
        self.properties[key] = value
        return self
    }

    func addProperty(key: String, value: [String]) -> AnalyticsEvent {
        self.properties[key] = value.map({ (value: String) -> String in
                    return "'"
                        .stringByAppendingString(value)
                        .stringByAppendingString("'")
                }).joinWithSeparator(",")
        return self
    }

    func send() -> AnalyticsEvent {
        self.rxAnalytics.sendAnalyticsEvent(self)
        return self
    }

    func sendToMoEngage() -> AnalyticsEvent {
        self.rxAnalytics.sendAnalyticsEvent(self, providers: AnalyticsProviderType.MoEngage)
        return self
    }
}
