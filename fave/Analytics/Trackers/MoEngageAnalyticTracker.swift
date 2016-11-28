//
// Created by Michael Cheah on 7/27/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import MoEngage_iOS_SDK

class MoEngageAnalyticTracker: IAnalyticTracker {
    let tracker: MoEngage

    init(tracker: MoEngage = MoEngage.sharedInstance()) {
        self.tracker = tracker
    }

    func providerType() -> AnalyticsProviderType {
        return .MoEngage
    }

    func enabledByDefault() -> Bool {
        return true
    }

    func trackEvent(analyticsEvent: AnalyticsEvent) {
        let dictionary = NSMutableDictionary(dictionary: analyticsEvent.properties)
        self.tracker.trackEvent(analyticsEvent.eventName, andPayload: dictionary)
    }

    func identifyUser(userAttributes: UserAttributes) {
        self.tracker.setUserAttribute(userAttributes.id, forKey: USER_ATTRIBUTE_UNIQUE_ID)

        if let email = userAttributes.email {
            self.tracker.setUserAttribute(email, forKey: USER_ATTRIBUTE_USER_EMAIL)
        }

        if let name = userAttributes.name {
            self.tracker.setUserAttribute(name, forKey: USER_ATTRIBUTE_USER_NAME)
        }

        if let city = userAttributes.cityName {
            self.tracker.setUserAttribute(city, forKey: "User City")
        }
    }

    func trackRevenueEvent(listingID: Int,
                           reservationSetID: Int,
                           reservableID: Int,
                           citySlug: String,
                           reservableType: String,
                           currencyCode: String,
                           amount: NSDecimalNumber) {

        guard let amountUSD = CurrencyExchange.toUSDollar(currencyCode, amount: amount) else {
            // Currency not supported. Sorry.
            return
        }

        let properties = [
                "amount": amountUSD.doubleValue,
                "currency": "USD",
                "original_amount": amount.doubleValue,
                "original_currency": currencyCode,
                "reservation_set_id": reservationSetID,
                "reservable_id": reservableID,
                "reservable_type": reservableType,
                "city_slug": citySlug,
                "listing_id": listingID
        ] as [String:AnyObject]

        let dictionary = NSMutableDictionary(dictionary: properties)
        self.tracker.trackEvent("Made Purchase USD", andPayload: dictionary)
    }

    func logout() {
        self.tracker.resetUser()
    }
}
