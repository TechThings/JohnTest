//
//  ListingAnalyticsModel.swift
//  FAVE
//
//  Created by Michael Cheah on 7/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Michael Cheah
 *
 *  ListingAnalyticsModel
 */

class ListingAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let listing: ListingType

    // MARK- Output
    var activityClickedEvent: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Activity_Clicked")

        if let city = self.cityProvider.currentCity.value {
            event.addProperty("City", value: city.slug)
            event.addProperty("Currency", value: city.currency)
        }

        return self.addListingProperties(event, listing: self.listing)
    }

    init(userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault,
         listing: ListingType) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.listing = listing
    }

    var buyNowClickedEvent: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Reserve_Clicked")
        if let city = self.cityProvider.currentCity.value {
            event.addProperty("City", value: city.slug)
        }
        self.addListingProperties(event, listing: self.listing)
        return event
    }

    // MARK:- Life cycle
    deinit {

    }
}
