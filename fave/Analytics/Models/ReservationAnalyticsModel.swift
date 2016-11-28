//
// Created by Michael Cheah on 7/27/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

class ReservationAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    // MARK:- Dependency
    private let rxAnalytics: RxAnalytics
    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let reservation: Reservation?

    // MARK- Output
    var paymentSuccessEvent: AnalyticsEvent? {
        let event = AnalyticsEvent(eventName: "Payment_Success")
        let user = self.userProvider.currentUser.value

        guard let reservation = self.reservation else {
            return nil
        }

        self.addReservationProperties(event, reservation: reservation)

        // TODO: Add reservation time

        if let city = self.cityProvider.currentCity.value {
            event.addProperty("City", value: city.slug)
            event.addProperty("Currency", value: city.currency)
        }

        if let email = user.email {
            event.addProperty("Email", value: email)
        }

        if let name = user.name {
            event.addProperty("Name", value: name)
        }

        return event
    }

    var paymentFailedEvent: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Payment_Failed")

        // TODO: Add Reason

        return event
    }

    init(rxAnalytics: RxAnalytics = rxAnalyticsDefault,
         userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault,
         reservation: Reservation?) {
        self.rxAnalytics = rxAnalytics
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.reservation = reservation
    }

    func trackRevenue() {
        guard let reservation = self.reservation else {
            return
        }

        guard let currencyCode = self.cityProvider.currentCity.value?.currency else {
            return
        }

        guard let citySlug = self.cityProvider.currentCity.value?.slug else {
            return
        }

        let totalChargeAmount = reservation.totalChargedAmountUserVisible
        guard let totalChargeAmountDecimal = totalChargeAmount.pricingInDecimal() else {
            return
        }

        rxAnalytics.trackRevenueEvent(reservation.listingDetails.id, reservationSetId: reservation.reservationSetId, reservableId: reservation.reservableId,
                                      citySlug: citySlug, reservableType: reservation.reservableType, currencyCode: currencyCode,
                                      amount: totalChargeAmountDecimal)

    }

    // MARK:- Life cycle
    deinit {

    }
}
