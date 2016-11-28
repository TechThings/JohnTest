//
// Created by Michael Cheah on 7/27/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import AppsFlyer

class AppsFlyerAnalyticTracker: IAnalyticTracker {
    let tracker: AppsFlyerTracker

    init(tracker: AppsFlyerTracker = AppsFlyerTracker.sharedTracker()) {
        self.tracker = tracker
        // self.tracker.isDebug = true
    }

    func providerType() -> AnalyticsProviderType {
        return .AppsFlyer
    }

    func enabledByDefault() -> Bool {
        return true
    }

    func trackEvent(analyticsEvent: AnalyticsEvent) {
        var properties = analyticsEvent.properties
        if let listingID = properties["Activity_ID"] {
            properties[AFEventParamContentType] = "product"
            properties[AFEventParamContentId] = "\(listingID)"
        }

        self.tracker.trackEvent(analyticsEvent.eventName, withValues: properties)
    }

    func identifyUser(userAttributes: UserAttributes) {
        self.tracker.customerUserID = userAttributes.id

        if let email = userAttributes.email {
            self.tracker.setUserEmails([email], withCryptType: EmailCryptTypeNone)
        }
    }

    func trackRevenueEvent(listingID: Int,
                           reservationSetID: Int,
                           reservableID: Int,
                           citySlug: String,
                           reservableType: String,
                           currencyCode: String,
                           amount: NSDecimalNumber) {

        let reservableIDString: String = "\(reservableID)"
        let reservationSetIDString: String = "\(reservationSetID)"
        let listingIDString: String = "\(listingID)"

        let properties: [String: AnyObject] = [
                AFEventParamRevenue: amount.doubleValue,
                AFEventParamCurrency: currencyCode,
                AFEventParamContentType: "product", // The value has to be this for Facebook Dynamic Ads
                AFEventParamContentId: listingIDString, // We use listing ID here to be consistent with the Ads tracking
                "reservable_id": reservableIDString,
                "reservable_type": reservableType,
                "reservation_set_id": reservationSetIDString,
                "city_slug": citySlug
        ]

        self.tracker.trackEvent(AFEventPurchase, withValues: properties)
    }

    func logout() {
        // Nothing as of now
    }

}
