//
//  IAnalyticTracker.swift
//  FAVE
//
//  Created by Michael Cheah on 7/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

enum AnalyticsProviderType: String {
    case AppsFlyer = "AppsFlyer Analytics"
    case MoEngage = "MoEngage"
    case Localytics = "Localytics"
}

protocol IAnalyticTracker {
    func providerType() -> AnalyticsProviderType

    func enabledByDefault() -> Bool

    func trackEvent(analyticsEvent: AnalyticsEvent)

    func identifyUser(userAttributes: UserAttributes)

    func trackRevenueEvent(listingID: Int,
                           reservationSetID: Int,
                           reservableID: Int,
                           citySlug: String,
                           reservableType: String,
                           currencyCode: String,
                           amount: NSDecimalNumber)

    func logout()
}
