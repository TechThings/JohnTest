//
//  ChatAnalyticsModel.swift
//  FAVE
//
//  Created by Gautam on 22/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

class ChatAnalyticsModel: BaseAnalyticsModel {

    // MARK:- Dependency

    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let channel: Channel?

    init(userProvider: UserProvider = userProviderDefault,
         cityProvider: CityProvider = cityProviderDefault,
         channel: Channel?) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.channel = channel
    }

    var chatCreated: AnalyticsEvent {
        let event = AnalyticsEvent(eventName: "Chat Created")

        if let _ = self.channel {
            self.addChannelProperties(event, channel: self.channel!)
        }
        return event
    }

    func addChannelProperties(event: AnalyticsEvent, channel: Channel) {
        event.addProperty("Number of participants", value: channel.chatParticipants.count)
        event.addProperty("City", value: channel.citySlug)
    }

}
