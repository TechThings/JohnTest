//
//  Category.swift
//  FAVE
//
//  Created by Thanh KFit on 10/6/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

final class Category {
    let type: String
    let name: String
    let description: String
    let icon_outline: NSURL
    let background: NSURL
    let filters: [FilterSection]
    let homeScreen: Bool

    init(
        type: String,
        name: String,
        description: String,
        icon_outline: NSURL,
        background: NSURL,
        filters: [FilterSection],
        homeScreen: Bool
        ) {
        self.type = type
        self.name = name
        self.description = description
        self.icon_outline = icon_outline
        self.background = background
        self.filters = filters
        self.homeScreen = homeScreen
    }

    func compareWithDeepLink(deepLink: String) -> Bool {
        let urlComponents = NSURLComponents(string: deepLink)

        guard let path = urlComponents?.path else {return false}

        if path == deepLinkPath.FaveEat && type == "eat" {
            return true
        }

        if path == deepLinkPath.FaveFit && type == "fit" {
            return true
        }

        if path == deepLinkPath.FavePamper && type == "pamper" {
            return true
        }

        return false
    }
}

extension Category: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> Category? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let type = json["type"] as? String else {return nil}

        guard let name = json["name"] as? String else {return nil}

        guard let description = json["description"] as? String else {return nil}

        guard let icon_outline_string = json["icon_outline"] as? String,
            let icon_outlet = NSURL(string: icon_outline_string)
            else {return nil}

        guard let backgroundString = json["background"] as? String,
            let background = NSURL(string: backgroundString)
            else {return nil}

        var filters = [FilterSection]()
        if let value = json["filters"] as? [AnyObject] {
            for representation in value {
                if let filter = FilterSection.serialize(representation) {
                    filters.append(filter)
                }
            }
        }

        guard let homeScreen = json["homescreen"] as? Bool else { return nil }

        return Category(type: type, name: name, description: description, icon_outline: icon_outlet, background: background, filters: filters, homeScreen: homeScreen)
    }
}
