//
//  InviteAnalyticsModel.swift
//  FAVE
//
//  Created by Gautam on 22/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

enum InvitePlatform: String {
    case Fb = "fb", Email = "email", Twitter = "twitter", Sms = "sms", WhatsApp = "whatsapp", Code = "code"
}

class InviteAnalyticsModel: BaseAnalyticsModel {
    // CC This should be broken down into smaller units, preferably based on screens

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let cityProvider: CityProvider

    init(userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
    }

    func inviteEvent (platform: InvitePlatform) -> AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Invite")
        event.addProperty("Channel", value: platform.rawValue)
        return event
    }
}
