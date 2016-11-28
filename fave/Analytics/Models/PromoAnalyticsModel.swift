//
// Created by Michael Cheah on 8/3/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

class PromoAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    // MARK:- Dependency
    private let promoCode: String

    var promoAddedEvent: AnalyticsEvent {
        return AnalyticsEvent(eventName: "Promo_Code_Added")
        .addProperty("Promo_Code", value: self.promoCode)
    }

    init(promoCode: String) {
        self.promoCode = promoCode
    }

    // MARK:- Life cycle
    deinit {

    }
}
