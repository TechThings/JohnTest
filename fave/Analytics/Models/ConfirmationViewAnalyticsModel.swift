//
//  ConfirmationViewAnalyticsModel.swift
//  FAVE
//
//  Created by Gautam on 22/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

class ConfirmationViewAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let listing: ListingType?

    init(userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault,
         listing: ListingType) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.listing = listing
    }

    var closeClicked: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Close")
        if(listing != nil) {
            self.addListingProperties(event, listing: self.listing!)
        }
        return event
    }

    var confirmReservationClicked: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Confirm_Reservation_Clicked")
        if(listing != nil) {
            self.addListingProperties(event, listing: self.listing!)
        }
        return event
    }
}
