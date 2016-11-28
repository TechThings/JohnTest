//
//  ParseDeeplink.swift
//  FAVE
//
//  Created by Thanh KFit on 8/2/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

let deepLinkPath = DeepLinkPath()

struct DeepLinkPath {
    let Home =            "/home"
    let FAQ =             "/faq"
    let AccountSetting =  "/account-settings"
    let TalkToUs =        "/talk-to-us"
    let Payment =         "/payment"
    let Search =          "/search"
    let Promo =           "/promo"
    let Favourites =      "/favourites"
    let Reservations =    "/reservations"
    let Offer =           "/offer"
    let Collections =     "/collections"
    let Partner =         "/partner"
    let FaveEat =         "/fave_eat"
    let FavePamper =      "/fave_spa"
    let FaveFit =         "/fave_fit"
    let Chat =            "/chat"
    let Invite =          "/invite"
    let Credits =         "/credits"
}

enum LinkType {
    case Home
    case FAQ
    case AccountSetting
    case TalkToUs
    case Payment
    case Search
    case Promo
    case Favourites
    case Reservations
    case Collections
    case Partner
    case Offer
    case Chat
    case Invite
    case Credits
    case Nearby
}

final class LinkModel: NSObject {
    let type: LinkType
    let deepLink: String
    let params: [String: AnyObject]?

    init(type: LinkType, deepLink: String, params: [String: AnyObject]?) {
        self.type = type
        self.deepLink = deepLink
        self.params = params
        super.init()
    }
}

final class ParseDeeplink {
    static let faveScheme = "fave"

    final class func getLinkType(deepLink: String) -> LinkType? {
        let urlComponents = NSURLComponents(string: deepLink)

        guard let path = urlComponents?.path else {return nil}

        switch path {
        case deepLinkPath.Home:
            return .Home

        case deepLinkPath.FAQ:
            return .FAQ

        case deepLinkPath.AccountSetting:
            return .AccountSetting

        case deepLinkPath.TalkToUs:
            return .TalkToUs

        case deepLinkPath.Payment:
            return .Payment

        case deepLinkPath.Search:
            return .Search

        case deepLinkPath.Promo:
            return .Promo

        case deepLinkPath.Favourites:
            return .Favourites

        case deepLinkPath.Reservations:
            return .Reservations

        case deepLinkPath.Collections:
            return .Collections

        case deepLinkPath.Partner:
            return .Partner

        case deepLinkPath.Offer:
            return .Offer

        case deepLinkPath.FaveEat:
            return .Nearby

        case deepLinkPath.FavePamper:
            return .Nearby

        case deepLinkPath.FaveFit:
            return .Nearby

        case deepLinkPath.Chat:
            return .Chat

        case deepLinkPath.Invite:
            return .Invite

        case deepLinkPath.Credits:
            return .Credits

        default:
            return nil
        }
    }

    final class func parseFromDict(dict: [String: AnyObject]) -> LinkModel? {
        guard let deepLinkPath = dict["$deeplink_path"] as? String else {return nil}

        let deepLink = "\(faveScheme)://\(deepLinkPath)"
        guard let type = getLinkType(deepLink) else {return nil}

        var params = dict

        if let dictParams = dict["parameters"] as? [String: AnyObject] {
            params += dictParams
        }

        return LinkModel(type: type, deepLink: deepLink, params: params)
    }

    final class func parseDirectDeeplink(deeplink: String) -> LinkModel? {
        guard let type = getLinkType(deeplink) else {return nil}
        return LinkModel(type: type, deepLink: deeplink, params: nil)
    }
}
