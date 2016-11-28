//
//  LocalyticsAnalyticTracker.swift
//  FAVE
//
//  Created by Michael Cheah on 9/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import Localytics

class LocalyticsAnalyticTracker: IAnalyticTracker {

    func providerType() -> AnalyticsProviderType {
        return .Localytics
    }

    func enabledByDefault() -> Bool {
        return false
    }

    func trackEvent(analyticsEvent: AnalyticsEvent) {
        Localytics.tagEvent(analyticsEvent.eventName, attributes: LocalyticsAnalyticTracker.toStringDict(analyticsEvent.properties))
    }

    func identifyUser(userAttributes: UserAttributes) {
        Localytics.setCustomerId(userAttributes.id)

        if let email = userAttributes.email {
            Localytics.setCustomerEmail(email)
        }

        if let name = userAttributes.name {
            Localytics.setCustomerFullName(name)
        }

        if let gender = userAttributes.gender {
            Localytics.setValue(gender, forProfileAttribute: "Gender")
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
            "reservation_set_id": "\(reservationSetID)",
            "city_slug": citySlug,
            "original_currency": currencyCode,
            "original_amount": "\(amount.doubleValue)",
            "currency": "USD",
            "listing_id": "\(listingID)"
        ] as [String: String]

        Localytics.tagPurchased(nil, itemId: "\(reservableID)", itemType: reservableType, itemPrice: NSNumber(double: amountUSD.doubleValue), attributes: properties)
    }

    func logout() {
        // Nothing as of now
    }

    private class func toStringDict(properties: [String: AnyObject]) -> [String: String]? {
        if (properties.isEmpty) {
            return nil
        }

        var result = [String: String]()

        properties.forEach { (key: String, value: AnyObject) in
            if let stringValue = value as? String {
                result[key] = stringValue
            } else if let boolValue = value as? Bool {
                result[key] = boolValue ? "true" : "false"
            } else if let intValue = value as? Int {
                result[key] = "\(intValue)"
            } else if let doubleValue = value as? Double {
                result[key] = "\(doubleValue)"
            } else if let intValue = value as? Int {
                result[key] = "\(intValue)"
            } else {
                // Can't translate value
                print("Dropping Key: \(key) due to untranslatable value")
            }
        }

        return result
    }
}
