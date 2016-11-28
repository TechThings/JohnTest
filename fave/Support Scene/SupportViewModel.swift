//
//  SupportViewModel.swift
//  FAVE
//
//  Created by Michael Cheah on 7/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ZDCChat
import ZendeskSDK

/**
 *  @author Michael Cheah
 *
 *  SupportViewModel
 */

final class SupportViewModel: ViewModel {

    // MARK:- Dependency
    private let userProvider: UserProvider
    private let cityProvider: CityProvider
    private let settingsProvider: SettingsProvider

    // MARK:- State

    // MARK:- Input

    // MARK:- Intermediate

    // MARK- Output
    let zendeskIdentity: ZDKIdentity?
    var chatConfig: ZDCConfigBlock
    let visitorInfo: ZDCVisitorConfigBlock

    init(userProvider: UserProvider = userProviderDefault
        , cityProvider: CityProvider = cityProviderDefault
        , settingsProvider: SettingsProvider = settingsProviderDefault) {
        self.userProvider = userProvider
        self.cityProvider = cityProvider
        self.settingsProvider = settingsProvider

        // Set User Identity
        let user = userProvider.currentUser.value

        let identity = ZDKAnonymousIdentity()
        identity.name = user.name
        identity.email = user.email
        ZDKConfig.instance().userIdentity = identity
        zendeskIdentity = identity

        visitorInfo = {
            (visitor: ZDCVisitorInfo!) in
            visitor.name = user.name
            visitor.email = user.email
            visitor.phone = ""
        }

        chatConfig = { _ in } /// we need `self` use to get app.keys which is from the base class. and we can't access self.app before super.init() is called, and we can't initialize after because it will complain that not all properties are initialized before super.init() is called. sucks, so this is the workaround

        super.init()

        // FAQ urls
        let url = app.keys.ZendeskURL
        // setup ZDConfig
        ZDKConfig.instance()
            .initializeWithAppId(
                app.keys.ZendeskAppId,
                zendeskUrl: url,
                clientId: app.keys.ZendeskClientId)

        chatConfig = { [weak self]
            (config: ZDCConfig!) in

            if let city = cityProvider.currentCity.value {
                config.tags = ["fave", city.slug]
            } else {
                config.tags = ["fave"]
            }

            // Use Pre Chat Form as a workaround to force message to go to offline message
            // if that particular department is not online
            config.preChatDataRequirements.department = ZDCPreChatDataRequirement.Required

            config.department = self!.app.keys.ZendeskDepartment
        }
    }
    // MARK:- Life cycle
    deinit {

    }
}
