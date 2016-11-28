//
//  Filter.swift
//  FAVE
//
//  Created by Thanh KFit on 9/14/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class FilterHeaderData {
    let type: String
    let name: String
    let description: String
    let icon_outline: NSURL
    let background: NSURL

    init(
        type: String,
        name: String,
        description: String,
        icon_outline: NSURL,
        background: NSURL
        ) {
        self.type = type
        self.name = name
        self.description = description
        self.icon_outline = icon_outline
        self.background = background
    }
}

extension FilterHeaderData: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> FilterHeaderData? {
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

        let result = FilterHeaderData(type: type, name: name, description: description, icon_outline: icon_outlet, background: background)

        return result
    }
}
