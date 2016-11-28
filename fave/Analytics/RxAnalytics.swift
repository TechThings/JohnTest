//
// Created by Michael Cheah on 7/26/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

protocol RxAnalytics {
    func sendAnalyticsEvent(analyticsEvent: AnalyticsEvent, providers: AnalyticsProviderType...)

    func identifyUser(userAttributes: UserAttributes, providers: AnalyticsProviderType...)

    func trackRevenueEvent(listingId: Int,
                           reservationSetId: Int,
                           reservableId: Int,
                           citySlug: String,
                           reservableType: String,
                           currencyCode: String,
                           amount: NSDecimalNumber,
                           providers: AnalyticsProviderType...)
}

class RxAnalyticsDefault: NSObject, RxAnalytics {

    // MARK:- Dependancy
    let app: AppType

    var providersMap = [AnalyticsProviderType: IAnalyticTracker]()

    let disposeBag = DisposeBag()

    init(analyticTrackers: IAnalyticTracker...,
        app: AppType = appDefault) {
        self.app = app
        super.init()

        for analyticTracker in analyticTrackers {
            providersMap[analyticTracker.providerType()] = analyticTracker
        }

        app
            .logoutSignal
            .subscribeNext { _ in
                analyticTrackers.forEach { (tracker: IAnalyticTracker) in
                    if (tracker.enabledByDefault()) {
                        tracker.logout()
                    }
                }
            }
            .addDisposableTo(disposeBag)
    }

    /**
     * Send an Analytics Event to the enabled providers, or specific providers is given in the arguments
     *
     * @param analyticsEvent the analytics event to send
     */
    func sendAnalyticsEvent(analyticsEvent: AnalyticsEvent, providers: AnalyticsProviderType...) {
        var useProviders = [IAnalyticTracker]()

        if (providers.isEmpty) {
            useProviders += providersMap.values.filter({ (iAnalyticTracker: IAnalyticTracker) -> Bool in
                iAnalyticTracker.enabledByDefault()
            })
        } else {
            for provider in providers {
                if let aProvider = providersMap[provider] {
                    useProviders.append(aProvider)
                }
            }
        }
        for useProvider in useProviders {
            useProvider.trackEvent(analyticsEvent)
        }
    }

    /**
    * Send user identifications to the enabled providers, or specific providers is given in the arguments
    *
    * @param userAttributes the user's attributes
    */
    func identifyUser(userAttributes: UserAttributes, providers: AnalyticsProviderType...) {
        var useProviders = [IAnalyticTracker]()

        if (providers.isEmpty) {
            useProviders += providersMap.values.filter({ (iAnalyticTracker: IAnalyticTracker) -> Bool in
                iAnalyticTracker.enabledByDefault()
            })
        } else {
            for provider in providers {
                if let aProvider = providersMap[provider] {
                    useProviders.append(aProvider)
                }
            }
        }

        for useProvider in useProviders {
            useProvider.identifyUser(userAttributes)
        }
    }

    func trackRevenueEvent(listingId: Int,
                           reservationSetId: Int,
                           reservableId: Int,
                           citySlug: String,
                           reservableType: String,
                           currencyCode: String,
                           amount: NSDecimalNumber,
                           providers: AnalyticsProviderType...) {
        var useProviders = [IAnalyticTracker]()

        if (providers.isEmpty) {
            useProviders += providersMap.values.filter({ (iAnalyticTracker: IAnalyticTracker) -> Bool in
                iAnalyticTracker.enabledByDefault()
            })
        } else {
            for provider in providers {
                if let aProvider = providersMap[provider] {
                    useProviders.append(aProvider)
                }
            }
        }
        for useProvider in useProviders {
            useProvider.trackRevenueEvent(listingId, reservationSetID: reservationSetId, reservableID: reservableId, citySlug: citySlug, reservableType: reservableType, currencyCode: currencyCode, amount: amount)
        }
    }
}
