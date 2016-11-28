//
//  HomeAnalyticsModel.swift
//  FAVE
//
//  Created by Gautam on 22/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class HomeAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    // MARK:- Dependency
    private let rxAnalytics: RxAnalytics
    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let listing: ListingType?

    init(userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault,
         rxAnalytics: RxAnalytics = rxAnalyticsDefault,
         listing: ListingType) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.rxAnalytics = rxAnalytics
        self.listing = listing
    }

    var addToFavorite: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Activity_Add_Favourite")
        if(listing != nil) {
            self.addListingProperties(event, listing: self.listing!)
        }
        return event
    }

    func identifyUserWithCity() {
        if let userCity = cityProvider.currentCity.value {
            self.rxAnalytics.identifyUser(UserAttributes(user:userProvider.currentUser.value, city: userCity), providers: AnalyticsProviderType.MoEngage)
        }
    }

    var activityClicked: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Activity_Clicked")
        if (listing != nil) {
            self.addListingProperties(event, listing: self.listing!)
        }
        return event
    }
}
