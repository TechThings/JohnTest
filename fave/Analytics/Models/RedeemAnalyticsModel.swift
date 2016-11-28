//
//  RedeemAnalyticsModel.swift
//  FAVE
//
//  Created by Gautam on 22/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

class RedeemAnalyticsModel: BaseAnalyticsModel {

    // MARK:- Dependency

    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let reservation: Reservation?

    init(userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault,
         reservation: Reservation?) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.reservation = reservation
    }

    var redeemButtonClickedEvent: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Redeem_Clicked")
        if(reservation != nil) {
            self.addReservationProperties(event, reservation: self.reservation!)
        }
        return event
    }

    var redeemSuccessful: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Redeem_Successful")
        if(reservation != nil) {
            self.addReservationProperties(event, reservation: self.reservation!)
        }

        if let city = self.cityProvider.currentCity.value {
            event.addProperty("City", value: city.slug)
            event.addProperty("Currency", value: city.currency)
        }

        return event
    }

    var cancelReservationClicked: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Cancel_Reservation_Clicked")
        return event
    }

    var reservationCancelled: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Reservation_Cancelled")

        if (reservation != nil) {
            self.addReservationProperties(event, reservation: self.reservation!)
        }
        return event
    }

}
